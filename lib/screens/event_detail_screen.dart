import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/card_model.dart';
import '../models/user_model.dart';
import '../services/card_service.dart';
import '../services/invite_service.dart';
import '../services/supabase_services.dart';

class EventDetailScreen extends StatefulWidget {
  final CardModel card;

  const EventDetailScreen({
    Key? key,
    required this.card,
  }) : super(key: key);

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  final CardService _cardService = CardService();
  final InviteService _inviteService = InviteService();
  final TextEditingController _searchController = TextEditingController();

  List<UserModel> _searchResults = [];
  List<UserModel> _selectedUsers = [];
  bool _isSearching = false;
  bool _isSendingInvites = false;
  CardModel? _currentCard;

  @override
  void initState() {
    super.initState();
    _currentCard = widget.card;
    _searchController.addListener(_onSearchChanged);
    _loadCardParticipants();
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

      // Update the card with participants
      if (mounted) {
        setState(() {
          _currentCard = widget.card.copyWith(participants: allInvitedUsers);
        });
      }
    } catch (e) {
      print('Error loading card participants: $e');
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
        _showErrorSnackBar('Lỗi tìm kiếm: $e');
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
      _showErrorSnackBar('Vui lòng chọn ít nhất một người để mời');
      return;
    }

    setState(() {
      _isSendingInvites = true;
    });

    try {
      final currentUser = SupabaseServices.client.auth.currentUser;
      if (currentUser == null) {
        print('No current user found');
        _showErrorSnackBar('Bạn chưa đăng nhập');
        return;
      }

      print('Current user: ${currentUser.id}');
      print('Sending invites to ${_selectedUsers.length} users');

      final receiverIds = _selectedUsers.map((user) => user.id).toList();
      print('Receiver IDs: $receiverIds');

      final success = await _inviteService.sendMultipleInvites(
        cardId: widget.card.id,
        senderId: currentUser.id,
        receiverIds: receiverIds,
      );

      if (success) {
        print('Invites sent successfully');
        _showSuccessSnackBar('Đã gửi lời mời thành công!');
        setState(() {
          _selectedUsers.clear();
          _searchResults.clear();
        });

        // Refresh card data
        print('Refreshing card data');
        final updatedCard = await _cardService.getCardById(widget.card.id);
        if (updatedCard != null) {
          setState(() {
            _currentCard = updatedCard;
          });
          print(
              'Card data refreshed with ${updatedCard.participants.length} participants');
        }
      } else {
        print('Failed to send invites');
        _showErrorSnackBar('Gửi lời mời thất bại');
      }
    } catch (e) {
      print('Error sending invites: $e');
      _showErrorSnackBar('Lỗi: $e');
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

  @override
  Widget build(BuildContext context) {
    final card = _currentCard ?? widget.card;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết sự kiện'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card Image
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
                image: DecorationImage(
                  image: NetworkImage(card.backgroundImageUrl),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.7),
                    ],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        card.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (card.hasEventDateTime)
                        Text(
                          card.formattedEventDateTime,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Description
                  const Text(
                    'Mô tả',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    card.description,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Location
                  if (card.location.isNotEmpty) ...[
                    const Text(
                      'Địa điểm',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.location_on, color: Colors.grey),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            card.location,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Participants
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Người tham gia',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${card.participantCount} người',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Participants avatars
                  if (card.participants.isNotEmpty)
                    SizedBox(
                      height: 50,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: card.participants.length,
                        itemBuilder: (context, index) {
                          final participant = card.participants[index];
                          return Container(
                            margin: const EdgeInsets.only(right: 8),
                            child: CircleAvatar(
                              radius: 20,
                              backgroundImage: participant.avatarUrl != null
                                  ? NetworkImage(participant.avatarUrl!)
                                  : null,
                              child: participant.avatarUrl == null
                                  ? Text(
                                      participant.displayName
                                              ?.substring(0, 1)
                                              .toUpperCase() ??
                                          participant.email
                                              .substring(0, 1)
                                              .toUpperCase(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    )
                                  : null,
                            ),
                          );
                        },
                      ),
                    )
                  else
                    const Text(
                      'Chưa có người tham gia',
                      style: TextStyle(
                        color: Colors.grey,
                        fontStyle: FontStyle.italic,
                      ),
                    ),

                  const SizedBox(height: 30),

                  // Invite section
                  const Text(
                    'Mời người tham gia',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Search input
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Tìm kiếm theo email hoặc tên...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _isSearching
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: Padding(
                                padding: EdgeInsets.all(8.0),
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              ),
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),

                  // Search results
                  if (_searchResults.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(
                      'Kết quả tìm kiếm (${_searchResults.length} người):',
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
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: _searchResults.length,
                        itemBuilder: (context, index) {
                          final user = _searchResults[index];
                          final isCurrentUser = user.id ==
                              SupabaseServices.client.auth.currentUser?.id;

                          return ListTile(
                            leading: CircleAvatar(
                              backgroundImage: user.avatarUrl != null
                                  ? NetworkImage(user.avatarUrl!)
                                  : null,
                              child: user.avatarUrl == null
                                  ? Text(
                                      user.displayName
                                              ?.substring(0, 1)
                                              .toUpperCase() ??
                                          user.email
                                              .substring(0, 1)
                                              .toUpperCase(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    )
                                  : null,
                            ),
                            title: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    user.displayName ?? 'Không có tên',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600),
                                  ),
                                ),
                                if (isCurrentUser)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.shade100,
                                      borderRadius: BorderRadius.circular(12),
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
                                ? const Text(
                                    'Không thể mời',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  )
                                : IconButton(
                                    icon: const Icon(Icons.add,
                                        color: Colors.blue),
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
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Text(
                          'Không tìm thấy người dùng nào',
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
                    const Text(
                      'Đã chọn:',
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
                                    user.displayName
                                            ?.substring(0, 1)
                                            .toUpperCase() ??
                                        user.email
                                            .substring(0, 1)
                                            .toUpperCase(),
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
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isSendingInvites
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              )
                            : const Text(
                                'Gửi lời mời',
                                style: TextStyle(fontSize: 16),
                              ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
