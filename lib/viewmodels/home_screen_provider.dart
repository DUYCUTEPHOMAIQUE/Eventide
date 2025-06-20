import 'package:flutter/material.dart';
import '../models/card_model.dart';
import '../models/invite_model.dart';
import '../services/card_service.dart';
import '../services/invite_service.dart';
import '../services/supabase_services.dart';
import 'package:enva/l10n/app_localizations.dart';

enum ViewMode { carousel, grid }

enum InviteStatusFilter { all, pending, going, notgoing, maybe, cancelled }

enum EventCategory { upcoming, hosting, invited, past }

class HomeScreenProvider extends ChangeNotifier {
  final CardService _cardService = CardService();
  final InviteService _inviteService = InviteService();

  List<CardModel> _allCards = [];
  List<CardModel> _invitationCards = [];
  bool _isLoading = false;
  String _error = '';
  ViewMode _viewMode = ViewMode.carousel;
  EventCategory _selectedCategory = EventCategory.upcoming;
  InviteStatusFilter _inviteStatusFilter = InviteStatusFilter.all;
  PageController? _pageController;

  // Animation controllers
  AnimationController? _headerFadeAnimation;
  AnimationController? _tabSelectorAnimation;
  AnimationController? _contentAnimation;

  // Getters
  List<CardModel> get allCards => _allCards;
  List<CardModel> get invitationCards => _invitationCards;
  bool get isLoading => _isLoading;
  String get error => _error;
  ViewMode get viewMode => _viewMode;
  EventCategory get selectedCategory => _selectedCategory;
  InviteStatusFilter get inviteStatusFilter => _inviteStatusFilter;
  PageController? get pageController => _pageController;
  AnimationController? get headerFadeAnimation => _headerFadeAnimation;
  AnimationController? get tabSelectorAnimation => _tabSelectorAnimation;
  AnimationController? get contentAnimation => _contentAnimation;

  // Get category title
  String getCategoryTitle(BuildContext context) {
    switch (_selectedCategory) {
      case EventCategory.upcoming:
        return AppLocalizations.of(context)!.upcoming;
      case EventCategory.hosting:
        return AppLocalizations.of(context)!.hosting;
      case EventCategory.invited:
        return AppLocalizations.of(context)!.invited;
      case EventCategory.past:
        return AppLocalizations.of(context)!.past;
    }
  }

  // Get filtered cards based on selected category
  List<CardModel> getFilteredCards() {
    switch (_selectedCategory) {
      case EventCategory.upcoming:
        return _getUpcomingCards();
      case EventCategory.hosting:
        return _getHostingCards();
      case EventCategory.invited:
        return _getInvitedCards();
      case EventCategory.past:
        return _getPastCards();
    }
  }

  // Get upcoming cards (events with future dates)
  List<CardModel> _getUpcomingCards() {
    final now = DateTime.now();
    return _allCards.where((card) {
      if (card.eventDateTime == null) return false;
      return card.eventDateTime!.isAfter(now);
    }).toList();
  }

  // Get hosting cards (cards owned by current user)
  List<CardModel> _getHostingCards() {
    final currentUser = SupabaseServices.client.auth.currentUser;
    if (currentUser == null) return [];

    return _allCards.where((card) => card.ownerId == currentUser.id).toList();
  }

  // Get invited cards (cards where user is receiver in invites)
  List<CardModel> _getInvitedCards() {
    if (_inviteStatusFilter == InviteStatusFilter.all) {
      return _invitationCards;
    }

    final statusString = _getStatusString(_inviteStatusFilter);
    return _invitationCards.where((card) {
      return card.inviteStatus == statusString;
    }).toList();
  }

  // Get past cards (events with past dates)
  List<CardModel> _getPastCards() {
    final now = DateTime.now();
    return _allCards.where((card) {
      if (card.eventDateTime == null) return false;
      return card.eventDateTime!.isBefore(now);
    }).toList();
  }

  // Get filtered invitation cards based on status filter
  List<CardModel> _getFilteredInvitationCards() {
    if (_inviteStatusFilter == InviteStatusFilter.all) {
      return _invitationCards;
    }

    // Filter by status
    final statusString = _getStatusString(_inviteStatusFilter);
    return _invitationCards.where((card) {
      return card.inviteStatus == statusString;
    }).toList();
  }

  String _getStatusString(InviteStatusFilter filter) {
    switch (filter) {
      case InviteStatusFilter.pending:
        return 'pending';
      case InviteStatusFilter.going:
        return 'going';
      case InviteStatusFilter.notgoing:
        return 'notgoing';
      case InviteStatusFilter.maybe:
        return 'maybe';
      case InviteStatusFilter.cancelled:
        return 'cancelled';
      case InviteStatusFilter.all:
        return 'all';
    }
  }

  // Set event category
  void setEventCategory(EventCategory category) {
    if (_selectedCategory != category) {
      _selectedCategory = category;
      // Dispose and recreate page controller when switching categories
      _pageController?.dispose();
      _pageController = null;
      notifyListeners();
    }
  }

  // Set invite status filter
  void setInviteStatusFilter(InviteStatusFilter filter) {
    if (_inviteStatusFilter != filter) {
      _inviteStatusFilter = filter;
      // Dispose and recreate page controller when changing filter
      _pageController?.dispose();
      _pageController = null;
      notifyListeners();
    }
  }

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
    // Always dispose old controller before creating new one
    _pageController?.dispose();
    _pageController = PageController();
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

  // Load all cards
  Future<void> loadCards() async {
    _setLoading(true);
    _setError('');

    try {
      final currentUser = SupabaseServices.client.auth.currentUser;
      if (currentUser == null) {
        _setError('Bạn chưa đăng nhập');
        return;
      }

      await _loadAllCards(currentUser.id);
    } catch (e) {
      _setError('Lỗi tải dữ liệu: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Load all cards (owned + received invites)
  Future<void> _loadAllCards(String userId) async {
    try {
      // Get cards owned by user
      final ownedCards = await _cardService.getCardsByOwner(userId);

      // Get cards where user is receiver in invites table
      final receivedInviteCards = await _getCardsFromInvites(userId);

      // Combine and remove duplicates
      final allCardsMap = <String, CardModel>{};

      // Add owned cards with participants reloaded to get only accepted participants
      for (var card in ownedCards) {
        // Reload participants using getAcceptedParticipants to get only people with status 'going'
        final participants =
            await _inviteService.getAcceptedParticipants(card.id);
        card.participants = participants;
        allCardsMap[card.id] = card;
      }

      // Add received invite cards (already have participants loaded)
      for (var card in receivedInviteCards) {
        allCardsMap[card.id] = card;
      }

      _allCards = allCardsMap.values.toList();
      _allCards.sort((a, b) => b.created_at.compareTo(a.created_at));

      // Also set invitation cards for invited category
      _invitationCards = receivedInviteCards;
      _invitationCards.sort((a, b) => b.created_at.compareTo(a.created_at));

      print('Loaded ${_allCards.length} total cards');
      print('Loaded ${_invitationCards.length} invitation cards');
    } catch (e) {
      print('Error loading all cards: $e');
      _setError('Lỗi tải tất cả thẻ: $e');
    }
  }

  // Get cards from invites table where user is receiver
  Future<List<CardModel>> _getCardsFromInvites(String userId) async {
    try {
      final response = await SupabaseServices.client.from('invites').select('''
            card_id,
            status,
            cards!inner(*)
          ''').eq('receiver_id', userId);

      if (response == null) {
        return [];
      }

      List<CardModel> cards = [];
      for (var inviteData in response) {
        if (inviteData['cards'] != null) {
          final cardData = inviteData['cards'];
          final status = inviteData['status'] as String;

          // Apply status filter if needed
          if (_inviteStatusFilter != InviteStatusFilter.all) {
            final filterStatus = _getStatusString(_inviteStatusFilter);
            if (status != filterStatus) {
              continue;
            }
          }

          final participants =
              await _inviteService.getAcceptedParticipants(cardData['id']);
          final card = CardModel.fromJson(cardData);
          card.participants = participants;
          card.inviteStatus = status; // Set the invite status

          cards.add(card);
        }
      }

      return cards;
    } catch (e) {
      print('Error getting cards from invites: $e');
      return [];
    }
  }

  // Refresh cards
  Future<void> refreshCards() async {
    // Dispose page controller before refreshing to avoid conflicts
    _pageController?.dispose();
    _pageController = null;
    await loadCards();
  }

  // Toggle view mode
  void toggleViewMode() {
    _viewMode =
        _viewMode == ViewMode.carousel ? ViewMode.grid : ViewMode.carousel;
    notifyListeners();
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

  // Get status text based on selected category
  String getStatusText() {
    switch (_selectedCategory) {
      case EventCategory.upcoming:
        return 'Sự kiện sắp diễn ra';
      case EventCategory.hosting:
        return 'Sự kiện bạn tổ chức';
      case EventCategory.invited:
        return 'Lời mời đến bạn';
      case EventCategory.past:
        return 'Sự kiện đã qua';
    }
  }

  // Private methods for state management
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _setCards(List<CardModel> cards) {
    _allCards = cards;
    notifyListeners();
  }

  // Format event info for display
  String formatEventInfo(BuildContext context, CardModel card) {
    try {
      final date = DateTime.parse(card.created_at);
      final locale = Localizations.localeOf(context).languageCode;
      String formattedDate;

      if (locale == 'vi') {
        // Vietnamese format: "ngày 28 tháng 6"
        formattedDate = 'ngày ${date.day} ${_getMonth(context, date.month)}';
      } else {
        // English format: "Jun 28"
        formattedDate = '${_getMonth(context, date.month)} ${date.day}';
      }

      return card.location.isNotEmpty
          ? '$formattedDate • ${card.location}'
          : formattedDate;
    } catch (e) {
      return card.location.isNotEmpty ? card.location : 'Sep 2';
    }
  }

  String formatEventInfoCompact(BuildContext context, CardModel card) {
    try {
      final date = DateTime.parse(card.created_at);
      final locale = Localizations.localeOf(context).languageCode;
      String formattedDate;

      if (locale == 'vi') {
        // Vietnamese format: "ngày 28 tháng 6"
        formattedDate = 'ngày ${date.day} ${_getMonth(context, date.month)}';
      } else {
        // English format: "Jun 28"
        formattedDate = '${_getMonth(context, date.month)} ${date.day}';
      }

      return card.location.isNotEmpty
          ? '$formattedDate • ${card.location}'
          : formattedDate;
    } catch (e) {
      return card.location.isNotEmpty ? card.location : 'Sep 2';
    }
  }

  String _getMonth(BuildContext context, int month) {
    final l10n = AppLocalizations.of(context)!;
    switch (month) {
      case 1:
        return l10n.month_jan;
      case 2:
        return l10n.month_feb;
      case 3:
        return l10n.month_mar;
      case 4:
        return l10n.month_apr;
      case 5:
        return l10n.month_may;
      case 6:
        return l10n.month_jun;
      case 7:
        return l10n.month_jul;
      case 8:
        return l10n.month_aug;
      case 9:
        return l10n.month_sep;
      case 10:
        return l10n.month_oct;
      case 11:
        return l10n.month_nov;
      case 12:
        return l10n.month_dec;
      default:
        return '';
    }
  }
}
