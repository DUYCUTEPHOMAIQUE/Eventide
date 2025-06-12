import 'package:flutter/material.dart';
import '../models/card_model.dart';
import '../services/card_service.dart';
import '../services/supabase_services.dart';

enum ViewMode { carousel, grid }

class HomeScreenProvider extends ChangeNotifier {
  final CardService _cardService = CardService();

  List<CardModel> _cards = [];
  bool _isLoading = false;
  String _error = '';
  ViewMode _viewMode = ViewMode.carousel;
  int _selectedTabIndex = 0;
  PageController? _pageController;

  // Tab configuration
  final List<String> _tabTitles = ['Tất cả', 'Của tôi', 'Tham gia'];
  final List<IconData> _tabIcons = [
    Icons.home_rounded,
    Icons.person_rounded,
    Icons.group_rounded,
  ];

  // Animation controllers
  AnimationController? _headerFadeAnimation;
  AnimationController? _tabSelectorAnimation;
  AnimationController? _contentAnimation;

  // Getters
  List<CardModel> get cards => _cards;
  bool get isLoading => _isLoading;
  String get error => _error;
  ViewMode get viewMode => _viewMode;
  int get selectedTabIndex => _selectedTabIndex;
  int get selectedIndex => _selectedTabIndex; // Alias for compatibility
  List<String> get tabTitles => _tabTitles;
  List<IconData> get tabIcons => _tabIcons;
  PageController? get pageController => _pageController;
  AnimationController? get headerFadeAnimation => _headerFadeAnimation;
  AnimationController? get tabSelectorAnimation => _tabSelectorAnimation;
  AnimationController? get contentAnimation => _contentAnimation;

  // Initialize animations
  void initializeAnimations(TickerProvider vsync) {
    _headerFadeAnimation = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: vsync,
    );
    _tabSelectorAnimation = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: vsync,
    );
    _contentAnimation = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: vsync,
    );

    // Start animations
    _headerFadeAnimation?.forward();
    _tabSelectorAnimation?.forward();
    _contentAnimation?.forward();
  }

  // Initialize page controller
  void initializePageController() {
    _pageController = PageController();
  }

  // Get page controller (non-nullable)
  PageController getPageController() {
    _pageController ??= PageController();
    return _pageController!;
  }

  // Dispose animations
  @override
  void dispose() {
    _headerFadeAnimation?.dispose();
    _tabSelectorAnimation?.dispose();
    _contentAnimation?.dispose();
    _pageController?.dispose();
    super.dispose();
  }

  // Load cards based on selected tab
  Future<void> loadCards() async {
    _setLoading(true);
    _setError('');

    try {
      final currentUser = SupabaseServices.client.auth.currentUser;
      if (currentUser == null) {
        _setError('Bạn chưa đăng nhập');
        return;
      }

      List<CardModel> loadedCards = [];

      switch (_selectedTabIndex) {
        case 0: // All cards
          loadedCards = await _cardService.getAllCards();
          break;
        case 1: // My cards
          loadedCards = await _cardService.getCardsByOwner(currentUser.id);
          break;
        case 2: // Participating
          loadedCards =
              await _cardService.getCardsUserParticipates(currentUser.id);
          break;
      }

      _setCards(loadedCards);
    } catch (e) {
      _setError('Lỗi tải dữ liệu: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Refresh cards
  Future<void> refreshCards() async {
    await loadCards();
  }

  // Get filtered cards (for compatibility)
  List<CardModel> getFilteredCards() {
    return _cards;
  }

  // Set view mode
  void setViewMode(ViewMode mode) {
    _viewMode = mode;
    notifyListeners();
  }

  // Change view mode (alias for compatibility)
  void changeViewMode(ViewMode mode) {
    setViewMode(mode);
  }

  // Set selected tab
  void setSelectedTab(int index) {
    _selectedTabIndex = index;
    loadCards();
  }

  // Change tab (alias for compatibility)
  void changeTab(int index) {
    setSelectedTab(index);
  }

  // Get greeting based on time
  String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Chào buổi sáng';
    } else if (hour < 17) {
      return 'Chào buổi chiều';
    } else {
      return 'Chào buổi tối';
    }
  }

  // Get status text based on selected tab
  String getStatusText() {
    switch (_selectedTabIndex) {
      case 0:
        return 'Tất cả sự kiện';
      case 1:
        return 'Sự kiện của tôi';
      case 2:
        return 'Đang tham gia';
      default:
        return 'Tất cả sự kiện';
    }
  }

  // Format event info
  String formatEventInfo(CardModel card) {
    final parts = <String>[];

    if (card.hasEventDateTime) {
      parts.add(card.formattedEventDateTime);
    }

    if (card.location.isNotEmpty) {
      parts.add(card.location);
    }

    if (card.participantCount > 0) {
      parts.add('${card.participantCount} người tham gia');
    }

    return parts.join(' • ');
  }

  // Format event info compact
  String formatEventInfoCompact(CardModel card) {
    final parts = <String>[];

    if (card.hasEventDateTime) {
      parts.add(card.formattedEventDateTime);
    }

    if (card.location.isNotEmpty) {
      parts.add(card.location);
    }

    return parts.join(' • ');
  }

  // Private methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _setCards(List<CardModel> cards) {
    _cards = cards;
    notifyListeners();
  }
}
