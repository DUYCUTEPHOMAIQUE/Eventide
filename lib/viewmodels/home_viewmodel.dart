import 'package:flutter/foundation.dart';
import '../services/card_service.dart';
import '../models/card_model.dart';

enum HomeTab { all, invitations, accepted, declined }

class HomeViewModel extends ChangeNotifier {
  final CardService _cardService = CardService();

  // State
  List<CardModel> _allCards = [];
  List<CardModel> _invitationCards = [];
  List<CardModel> _acceptedCards = [];
  List<CardModel> _declinedCards = [];
  bool _isLoading = false;
  String _progressMessage = '';
  String? _errorMessage;
  HomeTab _currentTab = HomeTab.all;

  // Getters
  List<CardModel> get allCards => _allCards;
  List<CardModel> get invitationCards => _invitationCards;
  List<CardModel> get acceptedCards => _acceptedCards;
  List<CardModel> get declinedCards => _declinedCards;
  bool get isLoading => _isLoading;
  String get progressMessage => _progressMessage;
  String? get errorMessage => _errorMessage;
  HomeTab get currentTab => _currentTab;

  // Get current cards based on selected tab
  List<CardModel> get currentCards {
    switch (_currentTab) {
      case HomeTab.all:
        return _allCards;
      case HomeTab.invitations:
        return _invitationCards;
      case HomeTab.accepted:
        return _acceptedCards;
      case HomeTab.declined:
        return _declinedCards;
    }
  }

  bool get hasCards => currentCards.isNotEmpty;
  bool get isEmpty => currentCards.isEmpty && !_isLoading;

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setProgress(String message) {
    _progressMessage = message;
    notifyListeners();
  }

  void _setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
    }
  }

  // Set current tab
  void setTab(HomeTab tab) {
    _currentTab = tab;
    notifyListeners();
  }

  /// Load all data for all tabs
  Future<void> loadAllData() async {
    _setLoading(true);
    _clearError();
    _setProgress('Đang tải dữ liệu...');

    try {
      // Load all cards (owned + accepted invitations)
      _setProgress('Đang tải tất cả thẻ...');
      _allCards = await _cardService.getAllCards();

      // Load pending invitation cards
      _setProgress('Đang tải lời mời...');
      _invitationCards = await _cardService.getPendingInvitationCards();

      // Load accepted invitation cards
      _setProgress('Đang tải thẻ đã chấp nhận...');
      _acceptedCards = await _cardService.getAcceptedInvitationCards();

      // Load declined invitation cards
      _setProgress('Đang tải thẻ đã từ chối...');
      _declinedCards = await _cardService.getDeclinedInvitationCards();

      _setProgress('Đã tải thành công');
    } catch (e) {
      _setError('Không thể tải dữ liệu: $e');
    } finally {
      _setLoading(false);
      _setProgress('');
    }
  }

  /// Load cards for specific tab
  Future<void> loadCardsForTab(HomeTab tab) async {
    _setLoading(true);
    _clearError();

    try {
      switch (tab) {
        case HomeTab.all:
          _setProgress('Đang tải tất cả thẻ...');
          _allCards = await _cardService.getAllCards();
          break;
        case HomeTab.invitations:
          _setProgress('Đang tải lời mời...');
          _invitationCards = await _cardService.getPendingInvitationCards();
          break;
        case HomeTab.accepted:
          _setProgress('Đang tải thẻ đã chấp nhận...');
          _acceptedCards = await _cardService.getAcceptedInvitationCards();
          break;
        case HomeTab.declined:
          _setProgress('Đang tải thẻ đã từ chối...');
          _declinedCards = await _cardService.getDeclinedInvitationCards();
          break;
      }
    } catch (e) {
      _setError('Không thể tải dữ liệu: $e');
    } finally {
      _setLoading(false);
      _setProgress('');
    }
  }

  /// Refresh current tab
  Future<void> refreshCurrentTab() async {
    await loadCardsForTab(_currentTab);
  }

  /// Refresh all data
  Future<void> refreshAllData() async {
    await loadAllData();
  }

  /// Add new card to all cards list
  void addCard(CardModel card) {
    _allCards.insert(0, card);
    notifyListeners();
  }

  /// Remove card from all cards list
  void removeCard(String cardId) {
    _allCards.removeWhere((card) => card.id == cardId);
    notifyListeners();
  }

  /// Clear error message
  void clearError() {
    _clearError();
  }

  @override
  void dispose() {
    super.dispose();
  }
}
