import 'package:enva/screens/card/minimalist_card_creation_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'package:provider/provider.dart';
import 'package:enva/screens/profile/profile_screen.dart';
import 'package:enva/viewmodels/home_screen_provider.dart';
import 'package:enva/models/card_model.dart';
import 'package:enva/screens/event_detail_screen.dart';
import 'package:enva/widgets/participants_avatar_list.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:math';
import 'package:enva/l10n/app_localizations.dart';
import 'package:enva/screens/card/ai_card_creation_screen.dart';
import 'package:enva/services/local_notification_storage_service.dart';
import 'package:enva/screens/notifications/notifications_screen.dart';
import 'package:enva/services/card_limit_service.dart';
import 'package:enva/widgets/card_creation_gate.dart';
import 'package:enva/widgets/card_creation_wrapper.dart';
import 'dart:async';

class EnhancedMinimalistHomeScreen extends StatelessWidget {
  const EnhancedMinimalistHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => HomeScreenProvider()..loadCards(),
      child: const _HomeScreenContent(),
    );
  }
}

class _HomeScreenContent extends StatefulWidget {
  const _HomeScreenContent({super.key});

  @override
  State<_HomeScreenContent> createState() => _HomeScreenContentState();
}

class _HomeScreenContentState extends State<_HomeScreenContent>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  int _unreadNotificationCount = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadUnreadNotificationCount();

    // Set up periodic refresh for notification count
    Timer.periodic(Duration(seconds: 5), (timer) {
      if (mounted) {
        _loadUnreadNotificationCount();
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      // Refresh notification count when app is resumed
      _loadUnreadNotificationCount();
    }
  }

  Future<void> _loadUnreadNotificationCount() async {
    final count = await LocalNotificationStorageService.getUnreadCount();
    if (mounted) {
      setState(() {
        _unreadNotificationCount = count;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeScreenProvider>(
      builder: (context, provider, child) {
        final currentCards = provider.getFilteredCards();
        final currentCard = currentCards.isNotEmpty ? currentCards.first : null;

        return Scaffold(
          backgroundColor: Colors.transparent, // Make scaffold transparent
          body: Stack(
            children: [
              // Blurred background
              if (currentCard != null &&
                  currentCard.backgroundImageUrl.isNotEmpty &&
                  currentCard.backgroundImageUrl != 'default')
                Positioned.fill(
                  child: ImageFiltered(
                    imageFilter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                    child: Image.network(
                      currentCard.backgroundImageUrl,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: Theme.of(context).colorScheme.surface,
                      ),
                    ),
                  ),
                )
              else
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Theme.of(context).colorScheme.surface,
                          Theme.of(context)
                              .colorScheme
                              .surface
                              .withOpacity(0.8),
                        ],
                      ),
                    ),
                  ),
                ),

              // Semi-transparent overlay
              Positioned.fill(
                child: Container(
                  color: Colors
                      .white, // Fully white overlay instead of semi-transparent
                ),
              ),

              // Main content
              SafeArea(
                child: Container(
                  height: MediaQuery.of(context).size.height,
                  child: Column(
                    children: [
                      _buildHeader(context, provider),
                      Expanded(
                        child: _buildContent(context, provider),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, HomeScreenProvider provider) {
    return Container(
      height: 100,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
      ),
      child: Row(
        children: [
          // Left side: Dropdown title
          Expanded(
            child: GestureDetector(
              onTap: () => _showCategoryDropdown(context, provider),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    provider.getCategoryTitle(context),
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Icon(
                    Icons.keyboard_arrow_down,
                    size: 24,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ],
              ),
            ),
          ),

          // Right side: Action buttons
          Row(
            children: [
              // AI button
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      Colors.purple.shade400,
                      Colors.blue.shade500,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.purple.shade400.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: IconButton(
                  onPressed: () => _navigateToAICreateCard(context),
                  icon: Stack(
                    alignment: Alignment.center,
                    clipBehavior: Clip.none,
                    children: [
                      Icon(
                        Icons.auto_awesome,
                        size: 24,
                        color: Colors.white,
                      ),
                      Positioned(
                        bottom: -8,
                        child: Text(
                          'AI',
                          style: TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    padding: const EdgeInsets.all(10),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Add button
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey[600], // Gray background
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey[600]!.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: IconButton(
                  onPressed: () => _navigateToCreateCard(context),
                  icon: Icon(
                    Icons.add,
                    size: 28,
                    color: Colors.white, // White icon on gray background
                  ),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    padding: const EdgeInsets.all(10),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // User avatar with notification bell
              Stack(
                children: [
                  GestureDetector(
                    onTap: () => _navigateToProfile(context),
                    child: ClipOval(
                      child: Container(
                        width: 48,
                        height: 48,
                        child: _buildUserAvatar(),
                      ),
                    ),
                  ),

                  // Notification bell in top right corner
                  Positioned(
                    top: -2,
                    right: -2,
                    child: GestureDetector(
                      onTap: () => _navigateToNotifications(context),
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.grey.shade200,
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Stack(
                          children: [
                            Center(
                              child: Icon(
                                Icons.notifications_outlined,
                                size: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            if (_unreadNotificationCount > 0)
                              Positioned(
                                top: 2,
                                right: 2,
                                child: Container(
                                  width: _unreadNotificationCount > 9 ? 16 : 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: Colors.red.shade500,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      _unreadNotificationCount > 5
                                          ? '5+'
                                          : _unreadNotificationCount.toString(),
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 8,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUserAvatar() {
    final currentUser = Supabase.instance.client.auth.currentUser;
    final userAvatar = currentUser?.userMetadata?['avatar_url'];
    final userName = currentUser?.userMetadata?['display_name'] ??
        currentUser?.userMetadata?['name'] ??
        currentUser?.email ??
        'User';
    final initials = userName.isNotEmpty ? userName[0].toUpperCase() : 'U';

    if (userAvatar != null && userAvatar.isNotEmpty) {
      return Image.network(
        userAvatar,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
            _buildAvatarPlaceholder(initials),
      );
    } else {
      return _buildAvatarPlaceholder(initials);
    }
  }

  Widget _buildAvatarPlaceholder(String initials) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue.shade400,
            Colors.purple.shade400,
          ],
        ),
      ),
      child: Center(
        child: Text(
          initials,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  void _showCategoryDropdown(
      BuildContext context, HomeScreenProvider provider) {
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
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Text(
              AppLocalizations.of(context)!.selectCategory,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            _buildCategoryOption(
              context,
              provider,
              EventCategory.upcoming,
              AppLocalizations.of(context)!.upcoming,
              AppLocalizations.of(context)!.upcomingEvents,
              Icons.event,
            ),
            _buildCategoryOption(
              context,
              provider,
              EventCategory.hosting,
              AppLocalizations.of(context)!.hosting,
              AppLocalizations.of(context)!.eventsYouHost,
              Icons.star,
            ),
            _buildCategoryOption(
              context,
              provider,
              EventCategory.invited,
              AppLocalizations.of(context)!.invited,
              AppLocalizations.of(context)!.invitationsToYou,
              Icons.mail,
            ),
            _buildCategoryOption(
              context,
              provider,
              EventCategory.past,
              AppLocalizations.of(context)!.past,
              AppLocalizations.of(context)!.pastEvents,
              Icons.history,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryOption(
    BuildContext context,
    HomeScreenProvider provider,
    EventCategory category,
    String title,
    String subtitle,
    IconData icon,
  ) {
    final isSelected = provider.selectedCategory == category;

    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
              : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Colors.grey.shade600,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          color:
              isSelected ? Theme.of(context).colorScheme.primary : Colors.black,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: Colors.grey.shade600,
          fontSize: 12,
        ),
      ),
      trailing: isSelected
          ? Icon(
              Icons.check,
              color: Theme.of(context).colorScheme.primary,
            )
          : null,
      onTap: () {
        provider.setEventCategory(category);
        Navigator.pop(context);
      },
    );
  }

  Widget _buildContent(BuildContext context, HomeScreenProvider provider) {
    return AnimatedBuilder(
      animation: provider.contentAnimation ?? const AlwaysStoppedAnimation(1.0),
      builder: (context, child) {
        return FadeTransition(
          opacity:
              provider.contentAnimation ?? const AlwaysStoppedAnimation(1.0),
          child: RefreshIndicator(
            onRefresh: () => provider.refreshCards(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  // Filter dropdown for invited category - always show when in invited tab
                  if (provider.selectedCategory == EventCategory.invited)
                    _buildInviteStatusFilter(context, provider),

                  // Content area - use Expanded to fill remaining space
                  Container(
                    height: MediaQuery.of(context).size.height -
                        200, // Adjust height for filter
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (provider.isLoading)
                          _buildLoadingState(context)
                        else if (provider.getFilteredCards().isEmpty)
                          _buildEmptyState(context, provider)
                        else ...[
                          Expanded(
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              child: provider.viewMode == ViewMode.carousel
                                  ? _buildCarouselView(
                                      provider.getPageController(),
                                      provider.getFilteredCards())
                                  : _buildGridView(provider.getFilteredCards()),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInviteStatusFilter(
      BuildContext context, HomeScreenProvider provider) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFilterChip(
              context,
              provider,
              InviteStatusFilter.all,
              AppLocalizations.of(context)!.all,
              Icons.all_inclusive,
            ),
            const SizedBox(width: 8),
            _buildFilterChip(
              context,
              provider,
              InviteStatusFilter.pending,
              AppLocalizations.of(context)!.pending,
              Icons.schedule,
            ),
            const SizedBox(width: 8),
            _buildFilterChip(
              context,
              provider,
              InviteStatusFilter.going,
              AppLocalizations.of(context)!.going,
              Icons.check_circle,
            ),
            const SizedBox(width: 8),
            _buildFilterChip(
              context,
              provider,
              InviteStatusFilter.notgoing,
              AppLocalizations.of(context)!.notGoing,
              Icons.cancel,
            ),
            const SizedBox(width: 8),
            _buildFilterChip(
              context,
              provider,
              InviteStatusFilter.maybe,
              AppLocalizations.of(context)!.maybe,
              Icons.help,
            ),
            const SizedBox(width: 8),
            _buildFilterChip(
              context,
              provider,
              InviteStatusFilter.cancelled,
              AppLocalizations.of(context)!.cancelled,
              Icons.block,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(
    BuildContext context,
    HomeScreenProvider provider,
    InviteStatusFilter filter,
    String label,
    IconData icon,
  ) {
    final isSelected = provider.inviteStatusFilter == filter;

    return GestureDetector(
      onTap: () => provider.setInviteStatusFilter(filter),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.outline.withOpacity(0.3),
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color:
                        Theme.of(context).colorScheme.primary.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected
                  ? Colors.white
                  : Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? Colors.white
                    : Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCarouselView(
      PageController pageController, List<CardModel> cards) {
    if (cards.isEmpty) {
      return const SizedBox.shrink();
    }
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Calculate card dimensions based on screen size
    // Target ratio: 354/612 = 0.578
    double cardWidth = 354;
    double cardHeight = 612;

    // Scale down if screen is too small
    if (screenWidth < 400) {
      final scale = screenWidth / 400;
      cardWidth = 354 * scale;
      cardHeight = 612 * scale;
    }

    // Scale down if screen height is too small
    if (screenHeight < 800) {
      final scale = screenHeight / 800;
      cardWidth = cardWidth * scale;
      cardHeight = cardHeight * scale;
    }

    return SizedBox(
      height: cardHeight,
      child: PageView.builder(
        controller: pageController,
        itemCount: cards.length,
        padEnds: false,
        clipBehavior: Clip.none,
        onPageChanged: (index) {
          if (mounted) {
            setState(() {});
          }
        },
        itemBuilder: (context, index) {
          return AnimatedBuilder(
            animation: pageController,
            builder: (context, child) {
              double scale = 1.0;
              double opacity = 1.0;

              if (pageController.position.haveDimensions) {
                double value = pageController.page! - index;

                // Calculate scale based on distance from center
                scale = (1 - (value.abs() * 0.15)).clamp(0.85, 1.1);

                // Calculate opacity for better visual hierarchy
                opacity = (1 - (value.abs() * 0.3)).clamp(0.6, 1.0);
              }

              return Center(
                child: Transform.scale(
                  scale: scale,
                  child: Opacity(
                    opacity: opacity,
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 8, // Simple margin for peek effect
                        vertical: 16,
                      ),
                      width: cardWidth,
                      height: cardHeight,
                      child: _buildInviteCard(cards[index]),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildGridView(List<CardModel> cards) {
    return SizedBox(
      height: 400, // Fixed height for grid view
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.0,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) => _buildCompactInviteCard(cards[index]),
                childCount: cards.length,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInviteCard(CardModel card) {
    final provider = context.read<HomeScreenProvider>();
    return GestureDetector(
      onTap: () => _navigateToEventDetail(card),
      child: Container(
        // Height will be set by parent container
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(37),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.shadow.withOpacity(0.15),
              blurRadius: 30,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Background
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(37),
                child: _buildCardBackground(card),
              ),
            ),

            // Gradient Overlay
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(37),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.2),
                      Colors.black.withOpacity(0.8),
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                ),
              ),
            ),

            // Host Badge
            if (_isCurrentUserHosting(card))
              Positioned(
                top: 24,
                left: 24,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.white.withOpacity(0.3)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.star,
                        size: 16,
                        color: Colors.white,
                      ),
                      SizedBox(width: 6),
                      Text(
                        'Hosting',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Invite Status Badge (for invitation tab)
            if (provider.selectedCategory == EventCategory.invited &&
                card.inviteStatus != null)
              Positioned(
                top: 24,
                right: 24,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getStatusColor(card.inviteStatus!).withOpacity(0.9),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withOpacity(0.3)),
                  ),
                  child: Text(
                    _getStatusText(card.inviteStatus!),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

            // Attendees
            Positioned(
              left: 0,
              right: 0,
              bottom: 120,
              child: ParticipantsAvatarList(participants: card.participants),
            ),

            // Event Details
            Positioned(
              left: 24,
              right: 24,
              bottom: 24,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Title
                  Text(
                    card.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      height: 1.1,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  // Time - only show if available
                  if (_formatEventTime(context, card).isNotEmpty) ...[
                    Text(
                      _formatEventTime(context, card),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        height: 1.2,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                  ],
                  // Location
                  if (card.location.isNotEmpty)
                    Text(
                      card.location,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        height: 1.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactInviteCard(CardModel card) {
    final provider = context.read<HomeScreenProvider>();
    return GestureDetector(
      onTap: () => _navigateToEventDetail(card),
      child: Container(
        height: 200, // Fixed height for compact cards
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(37),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.shadow.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Background
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(37),
                child: _buildCardBackground(card),
              ),
            ),

            // Gradient Overlay
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(37),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.3),
                      Colors.black.withOpacity(0.7),
                    ],
                    stops: const [0.0, 0.6, 1.0],
                  ),
                ),
              ),
            ),

            // Host Badge (smaller)
            if (_isCurrentUserHosting(card))
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.star, size: 12, color: Colors.white),
                      const SizedBox(width: 4),
                      Text(
                        'Host',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Invite Status Badge (smaller, for invitation tab)
            if (provider.selectedCategory == EventCategory.invited &&
                card.inviteStatus != null)
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: _getStatusColor(card.inviteStatus!).withOpacity(0.9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getStatusText(card.inviteStatus!),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

            // Participants (smaller)
            if (card.participants.isNotEmpty)
              Positioned(
                left: 0,
                right: 0,
                bottom: 60,
                child: ParticipantsAvatarList(
                  participants: card.participants,
                  avatarSize: 24,
                  spacing: 4,
                  maxDisplayCount: 3,
                  showBorder: true,
                ),
              ),

            // Event Details
            Positioned(
              left: 12,
              right: 12,
              bottom: 12,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Title
                  Text(
                    card.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  // Time - only show if available
                  if (_formatEventTimeCompact(context, card).isNotEmpty) ...[
                    Text(
                      _formatEventTimeCompact(context, card),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                  ],
                  // Location
                  if (card.location.isNotEmpty)
                    Text(
                      card.location,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardBackground(CardModel card) {
    if (card.backgroundImageUrl.isNotEmpty &&
        card.backgroundImageUrl != 'default') {
      return Image.network(
        card.backgroundImageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
            _buildPlaceholderBackground(card.id),
      );
    }
    return _buildPlaceholderBackground(card.id);
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

    return Container(
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
                  color: Colors.white.withOpacity(0.2),
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
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context)!.loadingData,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, HomeScreenProvider provider) {
    String title;
    String subtitle;
    IconData icon;
    bool showResetButton = false;

    switch (provider.selectedCategory) {
      case EventCategory.upcoming:
        title = AppLocalizations.of(context)!.noUpcomingEvents;
        subtitle = AppLocalizations.of(context)!.createNewEventOrWait;
        icon = Icons.event_note_outlined;
        break;
      case EventCategory.hosting:
        title = AppLocalizations.of(context)!.noHostingEvents;
        subtitle = AppLocalizations.of(context)!.startCreatingFirstEvent;
        icon = Icons.star_outline;
        break;
      case EventCategory.invited:
        if (provider.inviteStatusFilter == InviteStatusFilter.all) {
          title = AppLocalizations.of(context)!.noInvitations;
          subtitle = AppLocalizations.of(context)!.invitationsWillAppearHere;
          icon = Icons.mail_outline;
        } else {
          title =
              'Không có lời mời ${_getStatusText(_getStatusString(provider.inviteStatusFilter))}';
          subtitle = AppLocalizations.of(context)!.tryDifferentStatus;
          icon = Icons.filter_list;
          showResetButton = true;
        }
        break;
      case EventCategory.past:
        title = AppLocalizations.of(context)!.noPastEvents;
        subtitle = AppLocalizations.of(context)!.pastEventsWillAppearHere;
        icon = Icons.history;
        break;
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 50,
                color: Theme.of(context).colorScheme.primary.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            if (showResetButton)
              ElevatedButton.icon(
                onPressed: () =>
                    provider.setInviteStatusFilter(InviteStatusFilter.all),
                icon: const Icon(Icons.refresh, size: 18),
                label: Text(AppLocalizations.of(context)!.viewAllInvitations),
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(32),
                  ),
                ),
              )
            else if (provider.selectedCategory == EventCategory.upcoming ||
                provider.selectedCategory == EventCategory.hosting)
              ElevatedButton.icon(
                onPressed: () => _navigateToCreateCard(context),
                icon: const Icon(Icons.add, size: 18),
                label: Text(AppLocalizations.of(context)!.createNewEvent),
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(32),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _getStatusString(InviteStatusFilter filter) {
    switch (filter) {
      case InviteStatusFilter.pending:
        return AppLocalizations.of(context)!.pending;
      case InviteStatusFilter.going:
        return AppLocalizations.of(context)!.going;
      case InviteStatusFilter.notgoing:
        return AppLocalizations.of(context)!.notGoing;
      case InviteStatusFilter.maybe:
        return AppLocalizations.of(context)!.maybe;
      case InviteStatusFilter.cancelled:
        return AppLocalizations.of(context)!.cancelled;
      case InviteStatusFilter.all:
        return AppLocalizations.of(context)!.all;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'pending':
        return AppLocalizations.of(context)!.pending;
      case 'going':
        return AppLocalizations.of(context)!.going;
      case 'notgoing':
        return AppLocalizations.of(context)!.notGoing;
      case 'maybe':
        return AppLocalizations.of(context)!.maybe;
      case 'cancelled':
        return AppLocalizations.of(context)!.cancelled;
      default:
        return AppLocalizations.of(context)!.undefined;
    }
  }

  Future<void> _navigateToCreateCard(BuildContext context) async {
    // Navigate immediately (optimistic UI)
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CardCreationScreenWrapper(),
      ),
    );

    if (result == true && mounted) {
      final provider = context.read<HomeScreenProvider>();
      provider.refreshCards();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.cardCreatedSuccessfully),
          backgroundColor: Theme.of(context).colorScheme.primary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  Future<void> _navigateToAICreateCard(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AICardCreationScreen(),
      ),
    );
  }

  Future<void> _navigateToProfile(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ProfileScreen(),
      ),
    );
  }

  Future<void> _navigateToNotifications(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const NotificationsScreen(),
      ),
    );
    // Refresh notification count when returning from notifications screen
    _loadUnreadNotificationCount();
  }

  Future<void> _navigateToEventDetail(CardModel card) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EventDetailScreen(card: card),
      ),
    );

    // Only handle specific results, don't auto-refresh on normal navigation
    if (mounted && result is Map<String, dynamic>) {
      final provider = context.read<HomeScreenProvider>();

      // Show message if card is being deleted
      if (result['deleting'] != null) {
        provider.refreshCards(); // Only refresh when actually deleting
        final deletingTitle = result['deleting'] as String;

        // Clear any existing snackbars first
        ScaffoldMessenger.of(context).clearSnackBars();

        // Show deleting message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Đang xóa "$deletingTitle"...',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.orange.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: EdgeInsets.all(16),
            duration: const Duration(seconds: 2),
          ),
        );

        // Auto-refresh after 2 seconds to remove the deleted card
        Future.delayed(Duration(seconds: 2), () {
          if (mounted) {
            final provider = context.read<HomeScreenProvider>();
            provider.refreshCards();

            // Show success message after refresh
            ScaffoldMessenger.of(context).clearSnackBars();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.white, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Đã xóa "$deletingTitle" thành công',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
                backgroundColor: Colors.green.shade600,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: EdgeInsets.all(16),
                duration: const Duration(seconds: 2),
              ),
            );
          }
        });
      }

      // Refresh if card was edited
      else if (result['edited'] == true) {
        provider.refreshCards(); // Refresh to show updated card data
      }
    }
  }

  bool _isCurrentUserHosting(CardModel card) {
    try {
      final currentUser = Supabase.instance.client.auth.currentUser;
      if (currentUser == null) return false;

      return card.ownerId == currentUser.id;
    } catch (e) {
      // Handle error silently or log to a proper logging service
      return false;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'going':
        return Colors.green;
      case 'notgoing':
        return Colors.red;
      case 'maybe':
        return Colors.blue;
      case 'cancelled':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  String _formatEventTime(BuildContext context, CardModel card) {
    if (card.eventDateTime == null) {
      return ''; // Return empty string if no event date
    }

    try {
      final date = card.eventDateTime!;
      final locale = Localizations.localeOf(context).languageCode;
      String month = '';

      switch (date.month) {
        case 1:
          month = locale == 'vi' ? 'tháng 1' : 'Jan';
          break;
        case 2:
          month = locale == 'vi' ? 'tháng 2' : 'Feb';
          break;
        case 3:
          month = locale == 'vi' ? 'tháng 3' : 'Mar';
          break;
        case 4:
          month = locale == 'vi' ? 'tháng 4' : 'Apr';
          break;
        case 5:
          month = locale == 'vi' ? 'tháng 5' : 'May';
          break;
        case 6:
          month = locale == 'vi' ? 'tháng 6' : 'Jun';
          break;
        case 7:
          month = locale == 'vi' ? 'tháng 7' : 'Jul';
          break;
        case 8:
          month = locale == 'vi' ? 'tháng 8' : 'Aug';
          break;
        case 9:
          month = locale == 'vi' ? 'tháng 9' : 'Sep';
          break;
        case 10:
          month = locale == 'vi' ? 'tháng 10' : 'Oct';
          break;
        case 11:
          month = locale == 'vi' ? 'tháng 11' : 'Nov';
          break;
        case 12:
          month = locale == 'vi' ? 'tháng 12' : 'Dec';
          break;
        default:
          month = '';
      }

      if (locale == 'vi') {
        // Vietnamese format: "ngày 28 tháng 6"
        return 'ngày ${date.day} $month';
      } else {
        // English format: "Jun 28"
        return '$month ${date.day}';
      }
    } catch (e) {
      return '';
    }
  }

  String _formatEventTimeCompact(BuildContext context, CardModel card) {
    if (card.eventDateTime == null) {
      return ''; // Return empty string if no event date
    }

    try {
      final date = card.eventDateTime!;
      final l10n = AppLocalizations.of(context)!;
      String month = '';
      switch (date.month) {
        case 1:
          month = l10n.month_jan;
          break;
        case 2:
          month = l10n.month_feb;
          break;
        case 3:
          month = l10n.month_mar;
          break;
        case 4:
          month = l10n.month_apr;
          break;
        case 5:
          month = l10n.month_may;
          break;
        case 6:
          month = l10n.month_jun;
          break;
        case 7:
          month = l10n.month_jul;
          break;
        case 8:
          month = l10n.month_aug;
          break;
        case 9:
          month = l10n.month_sep;
          break;
        case 10:
          month = l10n.month_oct;
          break;
        case 11:
          month = l10n.month_nov;
          break;
        case 12:
          month = l10n.month_dec;
          break;
        default:
          month = '';
      }
      final day = date.day;
      return '$month $day';
    } catch (e) {
      return ''; // Return empty string on error
    }
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

    final path = Path();
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
