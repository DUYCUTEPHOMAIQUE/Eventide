import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as latlong;
import 'dart:ui' as ui;
import '../models/card_model.dart';
import '../models/user_model.dart';
import '../models/invite_model.dart';
import '../services/card_service.dart';
import '../services/invite_service.dart';
import '../services/supabase_services.dart';
import '../services/map_service.dart';
import '../screens/card/minimalist_card_creation_screen.dart';
import '../widgets/rsvp_selector.dart';
import '../l10n/app_localizations.dart';

class EventDetailScreen extends StatefulWidget {
  final CardModel card;

  const EventDetailScreen({
    super.key,
    required this.card,
  });

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  final CardService _cardService = CardService();
  final InviteService _inviteService = InviteService();
  final TextEditingController _searchController = TextEditingController();

  List<UserModel> _searchResults = [];
  final List<UserModel> _selectedUsers = [];
  bool _isSearching = false;
  bool _isSendingInvites = false;
  bool _isRefreshing = false;
  bool _isUpdatingRSVP = false;
  CardModel? _currentCard;
  InviteModel? _currentUserInvite;
  UserModel? _ownerProfile;
  Map<String, String> _participantStatuses =
      {}; // Store status for each participant

  @override
  void initState() {
    super.initState();
    _currentCard = widget.card;
    _searchController.addListener(_onSearchChanged);
    _loadCardParticipants();
    _loadCurrentUserInvite();
    _loadOwnerProfile();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadCardParticipants() async {
    print('Loading card participants for card: ${widget.card.id}');

    try {
      // Load all invited users for this card
      final allInvitedUsers =
          await _inviteService.getAllInvitedUsers(widget.card.id);
      print('Loaded ${allInvitedUsers.length} invited users');

      // Load all statuses in one API call
      final participantStatuses =
          await _inviteService.getAllInviteStatuses(widget.card.id);
      print('Loaded ${participantStatuses.length} statuses');

      // Update the card with participants and store statuses
      if (mounted) {
        setState(() {
          _currentCard = (_currentCard ?? widget.card)
              .copyWith(participants: allInvitedUsers);
          _participantStatuses = participantStatuses;
        });
      }
    } catch (e) {
      print('Error loading card participants: $e');
    }
  }

  Future<void> _loadCurrentUserInvite() async {
    try {
      final invite =
          await _inviteService.getInviteForCurrentUser(widget.card.id);
      if (mounted) {
        setState(() {
          _currentUserInvite = invite;
        });
      }
    } catch (e) {
      print('Error loading current user invite: $e');
    }
  }

  Future<void> _loadOwnerProfile() async {
    try {
      final response = await SupabaseServices.client
          .from('profiles')
          .select('*')
          .eq('id', widget.card.ownerId)
          .single();

      if (response != null) {
        final ownerProfile = UserModel.fromJson(response);
        if (mounted) {
          setState(() {
            _ownerProfile = ownerProfile;
          });
        }
      }
    } catch (e) {
      print('Error loading owner profile: $e');
    }
  }

  void _onSearchChanged() async {
    final query = _searchController.text.trim();
    print('Search query changed: $query');

    if (query.length >= 2) {
      setState(() {
        _isSearching = true;
      });

      try {
        print('Searching users with query: $query');
        final results = await _inviteService.searchUsers(query);
        print('Search results: ${results.length} users found');

        // Debug: Print each result
        for (int i = 0; i < results.length; i++) {
          final user = results[i];
          print(
              'Result $i: ${user.displayName ?? user.email} (ID: ${user.id})');
        }

        final currentUserId = SupabaseServices.client.auth.currentUser?.id;
        print('Current user ID: $currentUserId');
        print('Selected users count: ${_selectedUsers.length}');

        // Debug: Print selected users
        for (int i = 0; i < _selectedUsers.length; i++) {
          final user = _selectedUsers[i];
          print(
              'Selected user $i: ${user.displayName ?? user.email} (ID: ${user.id})');
        }

        // Chỉ filter những user đã được chọn, không filter current user
        final filteredResults = results.where((user) {
          final isNotSelected =
              !_selectedUsers.any((selected) => selected.id == user.id);

          print('Filtering user ${user.displayName ?? user.email}:');
          print('  - Is not selected: $isNotSelected');
          print('  - Will be included: $isNotSelected');

          return isNotSelected;
        }).toList();

        print('Filtered results count: ${filteredResults.length}');

        setState(() {
          _searchResults = filteredResults;
          _isSearching = false;
        });

        print('Final search results count: ${_searchResults.length}');

        // Debug: Print final search results
        for (int i = 0; i < _searchResults.length; i++) {
          final user = _searchResults[i];
          print(
              'Final result $i: ${user.displayName ?? user.email} (ID: ${user.id})');
        }
      } catch (e) {
        print('Error searching users: $e');
        setState(() {
          _isSearching = false;
        });
        _showErrorSnackBar(AppLocalizations.of(context)!.searchError);
      }
    } else {
      print('Query too short, clearing search results');
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
    }
  }

  void _selectUser(UserModel user) {
    print('Selecting user: ${user.displayName ?? user.email}');
    setState(() {
      _selectedUsers.add(user);
      _searchResults.removeWhere((u) => u.id == user.id);
      _searchController.clear();
    });
    print('Selected users count: ${_selectedUsers.length}');
  }

  void _removeSelectedUser(UserModel user) {
    print('Removing selected user: ${user.displayName ?? user.email}');
    setState(() {
      _selectedUsers.removeWhere((u) => u.id == user.id);
    });
    print('Selected users count: ${_selectedUsers.length}');
  }

  Future<void> _sendInvites() async {
    print('Starting to send invites');

    if (_selectedUsers.isEmpty) {
      print('No users selected for invitation');
      _showErrorSnackBar(
          AppLocalizations.of(context)!.pleaseSelectAtLeastOneUserToInvite);
      return;
    }

    setState(() {
      _isSendingInvites = true;
    });

    try {
      final currentUser = SupabaseServices.client.auth.currentUser;
      if (currentUser == null) {
        print('No current user found');
        _showErrorSnackBar(AppLocalizations.of(context)!.pleaseLogin);
        return;
      }

      // Debug: Check card ID
      final cardId = widget.card.id;
      print('Card ID from widget: "$cardId"');
      print('Card ID length: ${cardId.length}');
      print('Card ID is empty: ${cardId.isEmpty}');

      if (cardId.isEmpty) {
        print('Card ID is empty, cannot send invites');
        _showErrorSnackBar(AppLocalizations.of(context)!.eventInfoMissing);
        return;
      }

      print('Current user: ${currentUser.id}');
      print('Sending invites to ${_selectedUsers.length} users');

      final receiverIds = _selectedUsers.map((user) => user.id).toList();
      print('Receiver IDs: $receiverIds');

      final success = await _inviteService.sendMultipleInvites(
        cardId: cardId,
        senderId: currentUser.id,
        receiverIds: receiverIds,
      );

      if (success) {
        print('Invites sent successfully');
        _showSuccessSnackBar(
            AppLocalizations.of(context)!.invitationSentSuccessfully);
        setState(() {
          _selectedUsers.clear();
          _searchResults.clear();
        });

        // Refresh card data - load all invited users (not just accepted)
        print('Refreshing card data');
        try {
          // Load all invited users for this card (including pending invites)
          final allInvitedUsers =
              await _inviteService.getAllInvitedUsers(cardId);
          print(
              'Loaded ${allInvitedUsers.length} invited users after sending invites');

          // Update the card with all invited users
          setState(() {
            _currentCard = (_currentCard ?? widget.card)
                .copyWith(participants: allInvitedUsers);
          });
          print(
              'Card data refreshed with ${allInvitedUsers.length} participants');
        } catch (e) {
          print('Error refreshing card data: $e');
          // Fallback to original method if getAllInvitedUsers fails
          final updatedCard = await _cardService.getCardById(cardId);
          if (updatedCard != null) {
            setState(() {
              _currentCard = updatedCard;
            });
            print(
                'Card data refreshed with fallback method: ${updatedCard.participants.length} participants');
          }
        }

        // Also refresh the participants list to ensure consistency
        await Future.delayed(const Duration(milliseconds: 500));
        await _loadCardParticipants();
      } else {
        print('Failed to send invites');
        _showErrorSnackBar(AppLocalizations.of(context)!.invitationSendFailure);
      }
    } catch (e) {
      print('Error sending invites: $e');
      _showErrorSnackBar(AppLocalizations.of(context)!.invitationSendError);
    } finally {
      setState(() {
        _isSendingInvites = false;
      });
    }
  }

  void _showErrorSnackBar(String message) {
    print('Showing error snackbar: $message');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    print('Showing success snackbar: $message');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  RSVPStatus _getStatusFromString(String status) {
    switch (status.toLowerCase()) {
      case 'going':
        return RSVPStatus.going;
      case 'notgoing':
        return RSVPStatus.notGoing;
      case 'maybe':
        return RSVPStatus.maybe;
      default:
        return RSVPStatus.pending;
    }
  }

  String _getStringFromStatus(RSVPStatus status) {
    switch (status) {
      case RSVPStatus.going:
        return 'going';
      case RSVPStatus.notGoing:
        return 'notgoing';
      case RSVPStatus.maybe:
        return 'maybe';
      default:
        return 'pending';
    }
  }

  Future<void> _handleRSVPChange(RSVPStatus newStatus) async {
    if (_currentUserInvite == null || _isUpdatingRSVP) return;

    setState(() {
      _isUpdatingRSVP = true;
    });

    try {
      final success = await _inviteService.updateRSVPStatus(
        inviteId: _currentUserInvite!.id,
        status: _getStringFromStatus(newStatus),
      );

      if (success) {
        // Refresh invite data
        await _loadCurrentUserInvite();
        // Refresh participants list
        await _loadCardParticipants();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_getRSVPSuccessMessage(newStatus)),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.unableToUpdateStatus),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      print('Error updating RSVP status: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.updateStatusError),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUpdatingRSVP = false;
        });
      }
    }
  }

  String _getRSVPSuccessMessage(RSVPStatus status) {
    switch (status) {
      case RSVPStatus.going:
        return AppLocalizations.of(context)!.confirmedParticipation;
      case RSVPStatus.notGoing:
        return AppLocalizations.of(context)!.declinedParticipation;
      case RSVPStatus.maybe:
        return AppLocalizations.of(context)!.maybeParticipation;
      default:
        return AppLocalizations.of(context)!.statusUpdatedSuccessfully;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'going':
        return Colors.green;
      case 'notgoing':
        return Colors.red;
      case 'maybe':
        return Colors.orange;
      case 'cancelled':
        return Colors.grey;
      default:
        return Colors.blue;
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'going':
        return AppLocalizations.of(context)!.willParticipate;
      case 'notgoing':
        return AppLocalizations.of(context)!.willNotParticipate;
      case 'maybe':
        return AppLocalizations.of(context)!.maybeParticipate;
      case 'cancelled':
        return AppLocalizations.of(context)!.cancelled;
      default:
        return AppLocalizations.of(context)!.waitingForResponse;
    }
  }

  @override
  Widget build(BuildContext context) {
    final card = _currentCard ?? widget.card;
    final currentUser = SupabaseServices.client.auth.currentUser;
    final isOwner = currentUser?.id == card.ownerId;
    final isInvited = _currentUserInvite != null;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back,
              color: Theme.of(context).colorScheme.onSurface),
        ),
        title: Text(
          card.title,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
        centerTitle: true,
        actions: [
          if (_isRefreshing)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).colorScheme.onSurface),
                ),
              ),
            ),
          if (isOwner)
            IconButton(
              onPressed: _isRefreshing
                  ? null
                  : () => _navigateToEditCard(context, card),
              icon: Icon(
                Icons.edit_outlined,
                color: _isRefreshing
                    ? Colors.grey
                    : Theme.of(context).colorScheme.onSurface,
                size: 24,
              ),
            ),
        ],
      ),
      body: Stack(
        children: [
          // Main content
          RefreshIndicator(
            onRefresh: () => _refreshCardData(card.id),
            child: CustomScrollView(
              slivers: [
                // Card Image with rounded top corners
                SliverToBoxAdapter(
                  child: Container(
                    height: 300,
                    width: double.infinity,
                    margin: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(32),
                      image: _shouldShowBackgroundImage(card)
                          ? DecorationImage(
                              image: NetworkImage(card.backgroundImageUrl),
                              fit: BoxFit.cover,
                              onError: (error, stackTrace) {
                                // Handle error silently
                              },
                            )
                          : null,
                      color: !_shouldShowBackgroundImage(card)
                          ? Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.1)
                          : null,
                    ),
                    child: !_shouldShowBackgroundImage(card)
                        ? _buildDefaultBackgroundContent()
                        : null,
                  ),
                ),

                // Host by and description section
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Host by section
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .primary
                                .withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.person,
                                  color: Theme.of(context).colorScheme.primary,
                                  size: 16),
                              const SizedBox(width: 6),
                              Text(
                                isOwner
                                    ? AppLocalizations.of(context)!.hostByYou
                                    : AppLocalizations.of(context)!.hostBy(
                                        _ownerProfile?.displayName ??
                                            AppLocalizations.of(context)!
                                                .unknown),
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),

                // Add RSVP selector for invited users (non-owners)
                if (!isOwner && isInvited)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            AppLocalizations.of(context)!.respondToInvitation,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 16),
                          RSVPSelector(
                            selected: _getStatusFromString(
                                _currentUserInvite?.status ?? 'pending'),
                            onChanged: _handleRSVPChange,
                            enabled: !_isUpdatingRSVP,
                            isLoading: _isUpdatingRSVP,
                          ),
                        ],
                      ),
                    ),
                  ),

                // Main content sections
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Description Section (if available)
                        if (card.description.isNotEmpty) ...[
                          _buildSectionHeader(
                              AppLocalizations.of(context)!.description),
                          const SizedBox(height: 8),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .surfaceContainerHighest
                                  .withOpacity(0.5),
                              borderRadius: BorderRadius.circular(32),
                              border: Border.all(
                                color: Theme.of(context)
                                    .colorScheme
                                    .outline
                                    .withOpacity(0.5),
                              ),
                            ),
                            child: Text(
                              card.description,
                              style: const TextStyle(
                                fontSize: 16,
                                height: 1.5,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],

                        // Event Time Section (if available)
                        if (card.hasEventDateTime) ...[
                          _buildSectionHeader(
                              AppLocalizations.of(context)!.eventTime),
                          const SizedBox(height: 8),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .surfaceVariant
                                  .withOpacity(0.5),
                              borderRadius: BorderRadius.circular(32),
                              border: Border.all(
                                color: Theme.of(context)
                                    .colorScheme
                                    .outline
                                    .withOpacity(0.5),
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .primary
                                        .withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(
                                    Icons.event,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        card.getFormattedEventDateTime(context),
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        _getRelativeTime(card.eventDateTime),
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],

                        // Memory Image Section (if available)
                        if (card.imageUrl.isNotEmpty) ...[
                          _buildSectionHeader(
                              AppLocalizations.of(context)!.memoryPhoto),
                          const SizedBox(height: 8),
                          Container(
                            width: double.infinity,
                            height: 200,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(32),
                              border: Border.all(
                                color: Theme.of(context)
                                    .colorScheme
                                    .outline
                                    .withOpacity(0.5),
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(32),
                              child: Image.network(
                                card.imageUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    height: 200,
                                    color: Colors.grey[200],
                                    child: Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.image_not_supported,
                                            size: 48,
                                            color: Colors.grey[400],
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            AppLocalizations.of(context)!
                                                .cannotLoadImage,
                                            style: TextStyle(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onSurfaceVariant,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                                loadingBuilder:
                                    (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Container(
                                    height: 200,
                                    color: Colors.grey[200],
                                    child: Center(
                                      child: CircularProgressIndicator(
                                        value: loadingProgress
                                                    .expectedTotalBytes !=
                                                null
                                            ? loadingProgress
                                                    .cumulativeBytesLoaded /
                                                loadingProgress
                                                    .expectedTotalBytes!
                                            : null,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],

                        // Event Location Section (if available)
                        if (card.hasLocation) ...[
                          _buildSectionHeader(
                              AppLocalizations.of(context)!.location),
                          const SizedBox(height: 8),
                          Container(
                            width: double.infinity,
                            height: 200,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(32),
                              border: Border.all(
                                color: Theme.of(context)
                                    .colorScheme
                                    .outline
                                    .withOpacity(0.5),
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(32),
                              child: card.hasCoordinates
                                  ? FlutterMap(
                                      mapController: MapController(),
                                      options: MapOptions(
                                        initialCenter: latlong.LatLng(
                                          card.latitude ?? 0.0,
                                          card.longitude ?? 0.0,
                                        ),
                                        initialZoom: 15.0,
                                        interactionOptions:
                                            const InteractionOptions(
                                          flags: InteractiveFlag.pinchZoom |
                                              InteractiveFlag.drag |
                                              InteractiveFlag.doubleTapZoom,
                                        ),
                                      ),
                                      children: [
                                        TileLayer(
                                          urlTemplate:
                                              'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                          userAgentPackageName:
                                              'com.example.enva',
                                        ),
                                        MarkerLayer(
                                          markers: [
                                            Marker(
                                              point: latlong.LatLng(
                                                  card.latitude!,
                                                  card.longitude!),
                                              width: 40,
                                              height: 40,
                                              child: const Icon(
                                                Icons.location_pin,
                                                color: Colors.red,
                                                size: 40,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    )
                                  : Container(
                                      color: Colors.grey[200],
                                      child: Center(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.location_off,
                                              size: 48,
                                              color: Colors.grey[400],
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              AppLocalizations.of(context)!
                                                  .noCoordinates,
                                              style: TextStyle(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onSurfaceVariant,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          if (card.hasCoordinates)
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () => _openInMaps(card),
                                    icon:
                                        const Icon(Icons.directions, size: 18),
                                    label: Text(AppLocalizations.of(context)!
                                        .directions),
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () => _shareLocation(card),
                                    icon: const Icon(Icons.share, size: 18),
                                    label: Text(
                                        AppLocalizations.of(context)!.share),
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          const SizedBox(height: 8),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .surfaceVariant
                                  .withOpacity(0.5),
                              borderRadius: BorderRadius.circular(32),
                              border: Border.all(
                                color: Theme.of(context)
                                    .colorScheme
                                    .outline
                                    .withOpacity(0.5),
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .primary
                                        .withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(
                                    Icons.location_on,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Text(
                                    card.location,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],

                        // Participants Section
                        _buildSectionHeader(
                            AppLocalizations.of(context)!.invitedPeople),
                        const SizedBox(height: 8),
                        _buildParticipantsSection(card),

                        // Invite Section (only for card owner)
                        if (isOwner) ...[
                          const SizedBox(height: 24),
                          _buildSectionHeader(
                              AppLocalizations.of(context)!.inviteMorePeople),
                          const SizedBox(height: 8),
                          _buildInviteSection(),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  String _getRelativeTime(DateTime? eventDateTime) {
    if (eventDateTime == null) return '';

    final now = DateTime.now();
    final difference = eventDateTime.difference(now);

    if (difference.isNegative) {
      final pastDifference = now.difference(eventDateTime);
      if (pastDifference.inDays > 0) {
        return '${pastDifference.inDays} ${AppLocalizations.of(context)!.daysAgo}';
      } else if (pastDifference.inHours > 0) {
        return '${pastDifference.inHours} ${AppLocalizations.of(context)!.hoursAgo}';
      } else {
        return AppLocalizations.of(context)!.justEnded;
      }
    } else {
      if (difference.inDays > 0) {
        return AppLocalizations.of(context)!.remainingDays(difference.inDays);
      } else if (difference.inHours > 0) {
        return AppLocalizations.of(context)!.remainingHours(difference.inHours);
      } else {
        return AppLocalizations.of(context)!.startingSoon;
      }
    }
  }

  void _openInMaps(CardModel card) {
    if (!card.hasCoordinates) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    AppLocalizations.of(context)!.openMap,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${card.latitude!.toStringAsFixed(6)}, ${card.longitude!.toStringAsFixed(6)}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.map, color: Colors.green),
              ),
              title: Text(AppLocalizations.of(context)!.googleMaps),
              subtitle:
                  Text(AppLocalizations.of(context)!.viewLocationOnGoogleMaps),
              onTap: () => _handleMapAction(() =>
                  MapService.openGoogleMaps(card.latitude!, card.longitude!)),
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.directions, color: Colors.blue),
              ),
              title: Text(AppLocalizations.of(context)!.directions),
              subtitle: Text(
                  AppLocalizations.of(context)!.openGoogleMapsWithDirections),
              onTap: () => _handleMapAction(() =>
                  MapService.openGoogleMapsDirections(
                      card.latitude!, card.longitude!)),
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.purple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.map_outlined, color: Colors.purple),
              ),
              title: Text(AppLocalizations.of(context)!.appleMaps),
              subtitle: Text(AppLocalizations.of(context)!.openInAppleMaps),
              onTap: () => _handleMapAction(() =>
                  MapService.openAppleMaps(card.latitude!, card.longitude!)),
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.copy, color: Colors.orange),
              ),
              title: Text(AppLocalizations.of(context)!.copyCoordinates),
              subtitle: Text(AppLocalizations.of(context)!.copyToClipboard),
              onTap: () =>
                  _handleCopyCoordinates(card.latitude!, card.longitude!),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _handleMapAction(Future<bool> Function() mapAction) async {
    Navigator.pop(context);

    try {
      final success = await mapAction();
      if (!success && mounted) {
        _showErrorSnackBar(AppLocalizations.of(context)!.cannotOpenMapApp);
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar(AppLocalizations.of(context)!.mapError);
      }
    }
  }

  void _handleCopyCoordinates(double latitude, double longitude) async {
    Navigator.pop(context);

    try {
      await MapService.copyCoordinates(latitude, longitude);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                AppLocalizations.of(context)!.coordinatesCopiedToClipboard),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar(AppLocalizations.of(context)!.copyError);
      }
    }
  }

  void _shareLocation(CardModel card) {
    if (!card.hasCoordinates) return;

    // You can implement location sharing here
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!
            .shareLocationWithCoordinates(card.latitude!, card.longitude!)),
        action: SnackBarAction(
          label: AppLocalizations.of(context)!.ok,
          onPressed: () {},
        ),
      ),
    );
  }

  void _showAllParticipants(List<UserModel> participants) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppLocalizations.of(context)!
                        .invitedPeopleCount(participants.length),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close,
                        color: Theme.of(context).colorScheme.onSurface),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: participants.length,
                itemBuilder: (context, index) {
                  final participant = participants[index];
                  final status =
                      _participantStatuses[participant.id] ?? 'pending';

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: participant.avatarUrl != null
                          ? NetworkImage(participant.avatarUrl!)
                          : null,
                      backgroundColor: Theme.of(context)
                          .colorScheme
                          .primary
                          .withOpacity(0.1),
                      child: participant.avatarUrl == null
                          ? Text(
                              participant.displayName
                                      ?.substring(0, 1)
                                      .toUpperCase() ??
                                  participant.email
                                      .substring(0, 1)
                                      .toUpperCase(),
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            )
                          : null,
                    ),
                    title: Text(
                      participant.displayName ??
                          AppLocalizations.of(context)!.noName,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(participant.email),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getStatusColor(status).withOpacity(0.5),
                        borderRadius: BorderRadius.circular(32),
                        border: Border.all(
                          color: _getStatusColor(status).withOpacity(0.5),
                        ),
                      ),
                      child: Text(
                        _getStatusText(status),
                        style: TextStyle(
                          color: _getStatusColor(status),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToEditCard(BuildContext context, CardModel card) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MinimalistCardCreationScreen(cardToEdit: card),
      ),
    ).then((result) async {
      // Refresh card data if update was successful
      if (result == true) {
        await _refreshCardData(card.id);
      }
    });
  }

  Future<void> _refreshCardData(String cardId) async {
    print('Refreshing card data for card: $cardId');
    setState(() {
      _isRefreshing = true;
    });

    try {
      // Refresh the entire card data
      final updatedCard = await _cardService.getCardById(cardId);
      if (updatedCard != null) {
        setState(() {
          _currentCard = updatedCard;
        });
        print('Card data refreshed successfully');

        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.eventDataUpdated),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }
      }

      // Also refresh participants
      await _loadCardParticipants();
    } catch (e) {
      print('Error refreshing card data: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.updateDataError),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isRefreshing = false;
        });
      }
    }
  }

  Widget _buildParticipantsSection(CardModel card) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppLocalizations.of(context)!
                    .invitedPeopleCount(card.participantCount),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              if (card.participants.isNotEmpty)
                TextButton(
                  onPressed: () => _showAllParticipants(card.participants),
                  child: Text(AppLocalizations.of(context)!.viewAll),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // Participants avatars
          if (card.participants.isNotEmpty)
            SizedBox(
              height: 60,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount:
                    card.participants.length > 8 ? 8 : card.participants.length,
                itemBuilder: (context, index) {
                  if (index == 7 && card.participants.length > 8) {
                    // Show "+X more" indicator
                    return Container(
                      margin: const EdgeInsets.only(right: 8),
                      child: CircleAvatar(
                        radius: 25,
                        backgroundColor: Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(0.1),
                        child: Text(
                          '+${card.participants.length - 7}',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    );
                  }

                  final participant = card.participants[index];
                  return Container(
                    margin: const EdgeInsets.only(right: 8),
                    child: CircleAvatar(
                      radius: 25,
                      backgroundImage: participant.avatarUrl != null
                          ? NetworkImage(participant.avatarUrl!)
                          : null,
                      backgroundColor: Theme.of(context)
                          .colorScheme
                          .primary
                          .withOpacity(0.1),
                      child: participant.avatarUrl == null
                          ? Text(
                              participant.displayName
                                      ?.substring(0, 1)
                                      .toUpperCase() ??
                                  participant.email
                                      .substring(0, 1)
                                      .toUpperCase(),
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            )
                          : null,
                    ),
                  );
                },
              ),
            )
          else
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.people_outline,
                      size: 40,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      AppLocalizations.of(context)!.noInvitedPeople,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInviteSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search input
        TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: AppLocalizations.of(context)!.searchByEmailOrName,
            prefixIcon: const Icon(Icons.search),
            suffixIcon: _isSearching
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(32),
            ),
          ),
        ),

        // Search results
        if (_searchResults.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(
            AppLocalizations.of(context)!.searchResults(_searchResults.length),
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            constraints: const BoxConstraints(maxHeight: 250),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(32),
            ),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _searchResults.length,
              itemBuilder: (context, index) {
                final user = _searchResults[index];
                final isCurrentUser =
                    user.id == SupabaseServices.client.auth.currentUser?.id;

                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: user.avatarUrl != null
                        ? NetworkImage(user.avatarUrl!)
                        : null,
                    child: user.avatarUrl == null
                        ? Text(
                            user.displayName?.substring(0, 1).toUpperCase() ??
                                user.email.substring(0, 1).toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          )
                        : null,
                  ),
                  title: Row(
                    children: [
                      Expanded(
                        child: Text(
                          user.displayName ??
                              AppLocalizations.of(context)!.noName,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                      if (isCurrentUser)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade100,
                            borderRadius: BorderRadius.circular(32),
                          ),
                          child: const Text(
                            'Bạn',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.blue,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                    ],
                  ),
                  subtitle: Text(
                    user.email,
                    style: const TextStyle(color: Colors.grey),
                  ),
                  trailing: isCurrentUser
                      ? Text(
                          AppLocalizations.of(context)!.cannotInvite,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                            fontStyle: FontStyle.italic,
                          ),
                        )
                      : IconButton(
                          icon: const Icon(Icons.add, color: Colors.blue),
                          onPressed: () {
                            print(
                                'Add button pressed for user: ${user.displayName ?? user.email}');
                            _selectUser(user);
                          },
                        ),
                );
              },
            ),
          ),
        ] else if (_searchController.text.trim().length >= 2 &&
            !_isSearching) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(32),
            ),
            child: Center(
              child: Text(
                AppLocalizations.of(context)!.noUserFound,
                style: TextStyle(
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ),
        ],

        // Selected users
        if (_selectedUsers.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context)!.selectedUsers,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _selectedUsers.map((user) {
              return Chip(
                avatar: CircleAvatar(
                  backgroundImage: user.avatarUrl != null
                      ? NetworkImage(user.avatarUrl!)
                      : null,
                  child: user.avatarUrl == null
                      ? Text(
                          user.displayName?.substring(0, 1).toUpperCase() ??
                              user.email.substring(0, 1).toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : null,
                ),
                label: Text(user.displayName ?? user.email),
                deleteIcon: const Icon(Icons.close, size: 18),
                onDeleted: () => _removeSelectedUser(user),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isSendingInvites ? null : _sendInvites,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(32),
                ),
              ),
              child: _isSendingInvites
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      AppLocalizations.of(context)!.sendInvitation,
                      style: TextStyle(fontSize: 16),
                    ),
            ),
          ),
        ],
      ],
    );
  }

  bool _shouldShowBackgroundImage(CardModel card) {
    return card.backgroundImageUrl.isNotEmpty &&
        card.backgroundImageUrl != 'default';
  }

  Widget _buildDefaultBackgroundContent() {
    return _buildPlaceholderBackground(widget.card.id);
  }

  Widget _buildPlaceholderBackground([String? cardId]) {
    // Tạo gradient ngẫu nhiên từ danh sách gradient đẹp
    final gradients = [
      LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          const Color(0xFF667eea),
          const Color(0xFF764ba2),
        ],
      ),
      LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          const Color(0xFFf093fb),
          const Color(0xFFf5576c),
        ],
      ),
      LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          const Color(0xFF4facfe),
          const Color(0xFF00f2fe),
        ],
      ),
      LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          const Color(0xFF43e97b),
          const Color(0xFF38f9d7),
        ],
      ),
      LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          const Color(0xFFfa709a),
          const Color(0xFFfee140),
        ],
      ),
      LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          const Color(0xFFa8edea),
          const Color(0xFFfed6e3),
        ],
      ),
      LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          const Color(0xFFff9a9e),
          const Color(0xFFfecfef),
        ],
      ),
      LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          const Color(0xFFffecd2),
          const Color(0xFFfcb69f),
        ],
      ),
    ];

    // Chọn gradient ổn định dựa trên card ID hoặc timestamp
    int index = 0;
    if (cardId != null) {
      index = cardId.hashCode.abs() % gradients.length;
    } else {
      index = DateTime.now().millisecondsSinceEpoch % gradients.length;
    }
    final selectedGradient = gradients[index];

    return ClipRRect(
      borderRadius: BorderRadius.circular(32),
      child: Container(
        decoration: BoxDecoration(
          gradient: selectedGradient,
        ),
        child: Stack(
          children: [
            // Background pattern
            Positioned.fill(
              child: CustomPaint(
                painter: _PlaceholderPatternPainter(),
              ),
            ),
            // Center icon
            Center(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.5),
                    width: 1,
                  ),
                ),
                child: Icon(
                  Icons.celebration,
                  size: 60,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlaceholderPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Vẽ các hình tròn nhỏ tạo pattern
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.08)
      ..style = PaintingStyle.fill;

    // Vẽ các hình tròn nhỏ
    for (int i = 0; i < 20; i++) {
      final x = (i * 47) % size.width;
      final y = (i * 73) % size.height;
      final radius = 2.0 + (i % 3) * 1.0;

      canvas.drawCircle(Offset(x, y), radius, paint);
    }

    // Vẽ đường cong mềm mại ở dưới
    final curvePaint = Paint()
      ..color = Colors.white.withOpacity(0.06)
      ..style = PaintingStyle.fill;

    final path = ui.Path();
    path.moveTo(0, size.height);
    path.quadraticBezierTo(size.width * 0.25, size.height - 30,
        size.width * 0.5, size.height - 15);
    path.quadraticBezierTo(
        size.width * 0.75, size.height, size.width, size.height - 25);
    path.lineTo(size.width, size.height);
    path.close();

    canvas.drawPath(path, curvePaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
