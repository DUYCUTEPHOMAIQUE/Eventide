import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:enva/screens/card/minimalist_card_creation_screen.dart';
import 'package:enva/screens/profile/profile_screen.dart';
import 'package:enva/services/auth_service.dart';
import 'package:enva/viewmodels/home_viewmodel.dart';
import 'package:enva/models/card_model.dart';
import 'package:enva/widgets/theme_toggle_widget.dart';

class MinimalistHomeScreen extends StatelessWidget {
  const MinimalistHomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HomeViewModel()..loadAllData(),
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        body: SafeArea(
          child: Consumer<HomeViewModel>(
            builder: (context, viewModel, child) {
              return Column(
                children: [
                  // Clean Header
                  _buildHeader(context, viewModel),

                  // Tab Bar
                  _buildTabBar(context, viewModel),

                  // Content
                  Expanded(
                    child:
                        viewModel.currentCards.isEmpty && !viewModel.isLoading
                            ? _buildEmptyState(context, viewModel)
                            : _buildCardsContent(viewModel),
                  ),
                ],
              );
            },
          ),
        ),

        // Minimalist FAB
        floatingActionButton: _buildFloatingActionButton(context),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      ),
    );
  }

  Widget _buildHeader(BuildContext context, HomeViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.background,
        border: Border(
          bottom: BorderSide(
              color: Theme.of(context).colorScheme.outline, width: 1),
        ),
      ),
      child: Row(
        children: [
          // App title
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Enva',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onBackground,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  _getTabDescription(viewModel),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
              ],
            ),
          ),

          // Theme toggle and Profile button
          Row(
            children: [
              // Theme toggle
              const ThemeToggleWidget(isCompact: true),

              const SizedBox(width: 12),

              // Profile button
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: Theme.of(context).colorScheme.outline, width: 1.5),
                ),
                child: IconButton(
                  onPressed: () => _navigateToProfile(context),
                  icon: Icon(
                    Icons.person_outline,
                    color: Theme.of(context).colorScheme.onSurface,
                    size: 24,
                  ),
                  padding: const EdgeInsets.all(12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(BuildContext context, HomeViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        children: [
          // Tab indicators row
          Row(
            children: [
              _buildTabIndicator(
                context,
                'Tất cả',
                HomeTab.all,
                viewModel.currentTab == HomeTab.all,
                () => viewModel.setTab(HomeTab.all),
              ),
              const SizedBox(width: 8),
              _buildTabIndicator(
                context,
                'Lời mời tới bạn',
                HomeTab.invitations,
                viewModel.currentTab == HomeTab.invitations,
                () => viewModel.setTab(HomeTab.invitations),
              ),
              const SizedBox(width: 8),
              _buildTabIndicator(
                context,
                'Đã chấp nhận',
                HomeTab.accepted,
                viewModel.currentTab == HomeTab.accepted,
                () => viewModel.setTab(HomeTab.accepted),
              ),
              const SizedBox(width: 8),
              _buildTabIndicator(
                context,
                'Đã từ chối',
                HomeTab.declined,
                viewModel.currentTab == HomeTab.declined,
                () => viewModel.setTab(HomeTab.declined),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Active tab content indicator
          Container(
            height: 2,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(1),
            ),
            child: AnimatedAlign(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              alignment: _getTabAlignment(viewModel.currentTab),
              child: Container(
                width: _getTabWidth(context),
                height: 2,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabIndicator(
    BuildContext context,
    String label,
    HomeTab tab,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          child: Column(
            children: [
              // Tab icon
              Icon(
                _getTabIcon(tab),
                size: 20,
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
              ),
              const SizedBox(height: 6),
              // Tab label
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.7),
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.normal,
                      fontSize: 11,
                    ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getTabIcon(HomeTab tab) {
    switch (tab) {
      case HomeTab.all:
        return Icons.grid_view_rounded;
      case HomeTab.invitations:
        return Icons.mail_outline_rounded;
      case HomeTab.accepted:
        return Icons.check_circle_outline_rounded;
      case HomeTab.declined:
        return Icons.cancel_outlined;
    }
  }

  Alignment _getTabAlignment(HomeTab tab) {
    switch (tab) {
      case HomeTab.all:
        return Alignment.centerLeft;
      case HomeTab.invitations:
        return Alignment.center;
      case HomeTab.accepted:
        return Alignment.centerRight;
      case HomeTab.declined:
        return Alignment.centerRight;
    }
  }

  double _getTabWidth(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final padding = 40.0; // 20 * 2 for horizontal padding
    final spacing = 24.0; // 8 * 3 for spacing between tabs
    return (screenWidth - padding - spacing) / 4;
  }

  String _getTabDescription(HomeViewModel viewModel) {
    switch (viewModel.currentTab) {
      case HomeTab.all:
        return viewModel.currentCards.isNotEmpty
            ? '${viewModel.currentCards.length} thẻ'
            : 'Bắt đầu tạo thẻ đầu tiên';
      case HomeTab.invitations:
        return viewModel.currentCards.isNotEmpty
            ? '${viewModel.currentCards.length} lời mời'
            : 'Chưa có lời mời nào';
      case HomeTab.accepted:
        return viewModel.currentCards.isNotEmpty
            ? '${viewModel.currentCards.length} thẻ đã chấp nhận'
            : 'Chưa có thẻ nào được chấp nhận';
      case HomeTab.declined:
        return viewModel.currentCards.isNotEmpty
            ? '${viewModel.currentCards.length} thẻ đã từ chối'
            : 'Chưa có thẻ nào bị từ chối';
    }
  }

  Widget _buildEmptyState(BuildContext context, HomeViewModel viewModel) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Empty state icon
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey[200]!, width: 2),
              ),
              child: Icon(
                _getEmptyStateIcon(viewModel.currentTab),
                size: 60,
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 32),

            // Empty state text
            Text(
              _getEmptyStateTitle(viewModel.currentTab),
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 12),

            Text(
              _getEmptyStateDescription(viewModel.currentTab),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                    height: 1.5,
                  ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 40),

            // Action button (only show for "all" tab)
            if (viewModel.currentTab == HomeTab.all)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _navigateToCreateCard(context, viewModel),
                  icon: const Icon(Icons.add, size: 20),
                  label: const Text('Tạo thẻ đầu tiên'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  IconData _getEmptyStateIcon(HomeTab tab) {
    switch (tab) {
      case HomeTab.all:
        return Icons.add_card_outlined;
      case HomeTab.invitations:
        return Icons.mail_outline;
      case HomeTab.accepted:
        return Icons.check_circle_outline;
      case HomeTab.declined:
        return Icons.cancel_outlined;
    }
  }

  String _getEmptyStateTitle(HomeTab tab) {
    switch (tab) {
      case HomeTab.all:
        return 'Chưa có thẻ nào';
      case HomeTab.invitations:
        return 'Chưa có lời mời nào';
      case HomeTab.accepted:
        return 'Đã chấp nhận';
      case HomeTab.declined:
        return 'Đã từ chối';
    }
  }

  String _getEmptyStateDescription(HomeTab tab) {
    switch (tab) {
      case HomeTab.all:
        return 'Tạo thiệp mời đầu tiên của bạn để bắt đầu chia sẻ những khoảnh khắc đặc biệt';
      case HomeTab.invitations:
        return 'Bạn sẽ thấy các lời mời sự kiện ở đây khi có người mời bạn';
      case HomeTab.accepted:
        return 'Bạn đã chấp nhận lời mời này';
      case HomeTab.declined:
        return 'Bạn đã từ chối lời mời này';
    }
  }

  Widget _buildCardsContent(HomeViewModel viewModel) {
    if (viewModel.isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.black),
            SizedBox(height: 16),
            Text('Đang tải thẻ...', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: viewModel.refreshCurrentTab,
      color: Colors.black,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(24),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.75,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) =>
                    _buildCardItem(viewModel.currentCards[index]),
                childCount: viewModel.currentCards.length,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardItem(CardModel card) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card image
          Expanded(
            flex: 3,
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
                color: Color(0xFFF5F5F5),
              ),
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(15)),
                child: card.backgroundImageUrl.isNotEmpty
                    ? Image.network(
                        card.backgroundImageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[100],
                            child: Center(
                              child: Icon(
                                Icons.image_outlined,
                                size: 40,
                                color: Colors.grey[400],
                              ),
                            ),
                          );
                        },
                      )
                    : Container(
                        color: Colors.grey[100],
                        child: Center(
                          child: Icon(
                            Icons.image_outlined,
                            size: 40,
                            color: Colors.grey[400],
                          ),
                        ),
                      ),
              ),
            ),
          ),

          // Card content
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    card.title,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Expanded(
                    child: Text(
                      card.description,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
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

  Widget _buildFloatingActionButton(BuildContext context) {
    return Consumer<HomeViewModel>(
      builder: (context, viewModel, child) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: FloatingActionButton(
            onPressed: () => _navigateToCreateCard(context, viewModel),
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.add, size: 28),
          ),
        );
      },
    );
  }

  Future<void> _navigateToCreateCard(
      BuildContext context, HomeViewModel viewModel) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const MinimalistCardCreationScreen(),
      ),
    );

    if (result == true) {
      viewModel.refreshCurrentTab();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Thẻ đã được tạo thành công!'),
            backgroundColor: Colors.black,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
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
}
