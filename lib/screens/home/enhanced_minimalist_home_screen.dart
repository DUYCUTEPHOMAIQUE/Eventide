import 'package:enva/screens/card/minimalist_card_creation_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:enva/screens/profile/profile_screen.dart';
import 'package:enva/viewmodels/home_screen_provider.dart';
import 'package:enva/models/card_model.dart';
import 'package:enva/screens/event_detail_screen.dart';
import 'package:enva/widgets/participants_avatar_list.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
    with TickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    // Initialize animations after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<HomeScreenProvider>().initializeAnimations(this);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeScreenProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surface,
          body: SafeArea(
            child: Column(
              children: [
                _buildHeader(context, provider),
                _buildContent(context, provider),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, HomeScreenProvider provider) {
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
            width: 1,
          ),
        ),
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
                    provider.getCategoryTitle(),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.keyboard_arrow_down,
                    size: 20,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ],
              ),
            ),
          ),

          // Right side: Action buttons
          Row(
            children: [
              // Add button
              IconButton(
                onPressed: () => _navigateToCreateCard(context),
                icon: Icon(
                  Icons.add,
                  size: 24,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  padding: const EdgeInsets.all(8),
                ),
              ),
              const SizedBox(width: 8),

              // User avatar
              GestureDetector(
                onTap: () => _navigateToProfile(context),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Theme.of(context)
                          .colorScheme
                          .outline
                          .withOpacity(0.3),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context)
                            .colorScheme
                            .shadow
                            .withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: _buildUserAvatar(),
                  ),
                ),
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
            fontSize: 16,
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
            const Text(
              'Chọn danh mục',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            _buildCategoryOption(
              context,
              provider,
              EventCategory.upcoming,
              'Upcoming',
              'Sự kiện sắp diễn ra',
              Icons.event,
            ),
            _buildCategoryOption(
              context,
              provider,
              EventCategory.hosting,
              'Hosting',
              'Sự kiện bạn tổ chức',
              Icons.star,
            ),
            _buildCategoryOption(
              context,
              provider,
              EventCategory.invited,
              'Invited',
              'Lời mời đến bạn',
              Icons.mail,
            ),
            _buildCategoryOption(
              context,
              provider,
              EventCategory.past,
              'Past',
              'Sự kiện đã qua',
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
    return Expanded(
      child: AnimatedBuilder(
        animation:
            provider.contentAnimation ?? const AlwaysStoppedAnimation(1.0),
        builder: (context, child) {
          return FadeTransition(
            opacity:
                provider.contentAnimation ?? const AlwaysStoppedAnimation(1.0),
            child: _buildTabContent(context, provider),
          );
        },
      ),
    );
  }

  Widget _buildTabContent(BuildContext context, HomeScreenProvider provider) {
    if (provider.isLoading) {
      return _buildLoadingState(context);
    }

    final filteredCards = provider.getFilteredCards();

    if (filteredCards.isEmpty) {
      return _buildEmptyState(context, provider);
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: RefreshIndicator(
        key: ValueKey(provider.selectedCategory),
        onRefresh: provider.refreshCards,
        color: Theme.of(context).colorScheme.primary,
        child: Column(
          children: [
            // Filter dropdown for invited category
            if (provider.selectedCategory == EventCategory.invited)
              _buildInviteStatusFilter(context, provider),
            Expanded(
              child: provider.viewMode == ViewMode.carousel
                  ? _buildCarouselView(
                      provider.getPageController(), filteredCards)
                  : _buildGridView(filteredCards),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInviteStatusFilter(
      BuildContext context, HomeScreenProvider provider) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.filter_list,
            size: 20,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          ),
          const SizedBox(width: 8),
          Text(
            'Lọc theo:',
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<InviteStatusFilter>(
                value: provider.inviteStatusFilter,
                isExpanded: true,
                icon: Icon(
                  Icons.keyboard_arrow_down,
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
                items: [
                  DropdownMenuItem(
                    value: InviteStatusFilter.all,
                    child: Text('Tất cả trạng thái'),
                  ),
                  DropdownMenuItem(
                    value: InviteStatusFilter.pending,
                    child: Text('Đang chờ'),
                  ),
                  DropdownMenuItem(
                    value: InviteStatusFilter.accepted,
                    child: Text('Đã chấp nhận'),
                  ),
                  DropdownMenuItem(
                    value: InviteStatusFilter.declined,
                    child: Text('Đã từ chối'),
                  ),
                  DropdownMenuItem(
                    value: InviteStatusFilter.cancelled,
                    child: Text('Đã hủy'),
                  ),
                  DropdownMenuItem(
                    value: InviteStatusFilter.undecided,
                    child: Text('Chưa quyết định'),
                  ),
                ],
                onChanged: (InviteStatusFilter? newValue) {
                  if (newValue != null) {
                    provider.setInviteStatusFilter(newValue);
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCarouselView(
      PageController pageController, List<CardModel> cards) {
    return PageView.builder(
      controller: pageController,
      itemCount: cards.length,
      padEnds: false, // Allow seeing parts of adjacent cards
      clipBehavior: Clip.none, // Don't clip adjacent cards
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.symmetric(
              horizontal: 16, vertical: 16), // Reduced horizontal margin
          width: MediaQuery.of(context).size.width *
              0.85, // Make cards 85% of screen width
          child: _buildInviteCard(cards[index]),
        );
      },
    );
  }

  Widget _buildGridView(List<CardModel> cards) {
    return CustomScrollView(
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
    );
  }

  Widget _buildInviteCard(CardModel card) {
    final provider = context.read<HomeScreenProvider>();
    return GestureDetector(
      onTap: () => _navigateToEventDetail(card),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.65, // Perfect ratio
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
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
                borderRadius: BorderRadius.circular(24),
                child: _buildCardBackground(card),
              ),
            ),

            // Gradient Overlay
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
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
              left: 24,
              bottom: 120,
              child: ParticipantsAvatarList(participants: card.participants),
            ),

            // Event Details
            Positioned(
              left: 24,
              right: 24,
              bottom: 24,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                  ),
                  const SizedBox(height: 12),
                  Text(
                    provider.formatEventInfo(card),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
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
          borderRadius: BorderRadius.circular(20),
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
                borderRadius: BorderRadius.circular(20),
                child: _buildCardBackground(card),
              ),
            ),

            // Gradient Overlay
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
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
                left: 12,
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                  ),
                  const SizedBox(height: 6),
                  Text(
                    provider.formatEventInfoCompact(card),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
            _buildPlaceholderBackground(),
      );
    }
    return _buildPlaceholderBackground();
  }

  Widget _buildPlaceholderBackground() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primary.withOpacity(0.8),
            Theme.of(context).colorScheme.secondary.withOpacity(0.6),
          ],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.celebration,
          size: 80,
          color: Colors.white.withOpacity(0.3),
        ),
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context)
                  .colorScheme
                  .primaryContainer
                  .withOpacity(0.3),
              borderRadius: BorderRadius.circular(20),
            ),
            child: CircularProgressIndicator(
              color: Theme.of(context).colorScheme.primary,
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Đang tải dữ liệu...',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
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

    switch (provider.selectedCategory) {
      case EventCategory.upcoming:
        title = 'Chưa có sự kiện sắp diễn ra';
        subtitle = 'Tạo sự kiện mới hoặc chờ lời mời từ bạn bè';
        icon = Icons.event_note_outlined;
        break;
      case EventCategory.hosting:
        title = 'Chưa có sự kiện nào bạn tổ chức';
        subtitle = 'Bắt đầu tạo sự kiện đầu tiên của bạn';
        icon = Icons.star_outline;
        break;
      case EventCategory.invited:
        if (provider.inviteStatusFilter == InviteStatusFilter.all) {
          title = 'Chưa có lời mời nào';
          subtitle =
              'Bạn sẽ thấy các lời mời sự kiện ở đây khi có người mời bạn';
          icon = Icons.mail_outline;
        } else {
          title =
              'Không có lời mời ${_getStatusText(_getStatusString(provider.inviteStatusFilter))}';
          subtitle = 'Thử chọn trạng thái khác hoặc chờ lời mời mới';
          icon = Icons.filter_list;
        }
        break;
      case EventCategory.past:
        title = 'Chưa có sự kiện đã qua';
        subtitle = 'Các sự kiện đã kết thúc sẽ hiển thị ở đây';
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
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 60,
                color: Theme.of(context).colorScheme.primary.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            if (provider.selectedCategory == EventCategory.upcoming ||
                provider.selectedCategory == EventCategory.hosting)
              ElevatedButton.icon(
                onPressed: () => _navigateToCreateCard(context),
                icon: const Icon(Icons.add),
                label: const Text('Tạo sự kiện mới'),
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
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
        return 'Đang chờ';
      case InviteStatusFilter.accepted:
        return 'Đã chấp nhận';
      case InviteStatusFilter.declined:
        return 'Đã từ chối';
      case InviteStatusFilter.cancelled:
        return 'Đã hủy';
      case InviteStatusFilter.undecided:
        return 'Chưa quyết định';
      case InviteStatusFilter.all:
        return 'Tất cả';
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'pending':
        return 'Đang chờ';
      case 'accepted':
        return 'Đã chấp nhận';
      case 'declined':
        return 'Đã từ chối';
      case 'cancelled':
        return 'Đã hủy';
      case 'undecided':
        return 'Chưa quyết định';
      default:
        return 'Chưa xác định';
    }
  }

  Future<void> _navigateToCreateCard(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const MinimalistCardCreationScreen(),
      ),
    );

    if (result == true && mounted) {
      final provider = context.read<HomeScreenProvider>();
      provider.refreshCards();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Thẻ đã được tạo thành công!'),
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

  Future<void> _navigateToProfile(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ProfileScreen(),
      ),
    );
  }

  Future<void> _navigateToEventDetail(CardModel card) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EventDetailScreen(card: card),
      ),
    );
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
      case 'accepted':
        return Colors.green;
      case 'declined':
        return Colors.red;
      case 'cancelled':
        return Colors.grey;
      case 'undecided':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}
