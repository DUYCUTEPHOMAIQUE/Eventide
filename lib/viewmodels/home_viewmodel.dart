import 'package:flutter/foundation.dart';
import '../services/card_service.dart';
import '../models/card_model.dart';

class HomeViewModel extends ChangeNotifier {
  final CardService _cardService = CardService();

  // State
  List<CardModel> _cards = [];
  bool _isLoading = false;
  String _progressMessage = '';
  String? _errorMessage;

  // Getters
  List<CardModel> get cards => _cards;
  bool get isLoading => _isLoading;
  String get progressMessage => _progressMessage;
  String? get errorMessage => _errorMessage;
  bool get hasCards => _cards.isNotEmpty;
  bool get isEmpty => _cards.isEmpty && !_isLoading;

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

  /// Load all cards for current user
  Future<void> loadCards() async {
    _setLoading(true);
    _clearError();
    _setProgress('Đang tải danh sách thẻ...');

    try {
      final cards = await _cardService.getAllCards();
      _cards = cards;
      _setProgress('Đã tải thành công ${cards.length} thẻ');
    } catch (e) {
      _setError('Không thể tải danh sách thẻ: $e');
    } finally {
      _setLoading(false);
      _setProgress('');
    }
  }

  /// Refresh cards (pull to refresh)
  Future<void> refreshCards() async {
    await loadCards();
  }

  /// Add new card to list (called after creating new card)
  void addCard(CardModel card) {
    _cards.insert(0, card); // Add to beginning of list
    notifyListeners();
  }

  /// Remove card from list
  void removeCard(String cardId) {
    _cards.removeWhere((card) => card.id == cardId);
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
