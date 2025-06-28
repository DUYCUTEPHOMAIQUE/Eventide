import 'package:flutter/material.dart';
import 'package:enva/l10n/app_localizations.dart';
import 'package:enva/models/card_model.dart';
import 'package:enva/models/subscription_model.dart';
import 'package:enva/screens/card/minimalist_card_creation_screen.dart';
import 'package:enva/services/gemini_service.dart';
import 'package:enva/services/subscription_service.dart';
import 'package:enva/widgets/permission_gate.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:enva/screens/upgrade/upgrade_screen.dart';
import 'package:image_picker/image_picker.dart';

class AICardCreationScreen extends StatefulWidget {
  const AICardCreationScreen({Key? key}) : super(key: key);

  @override
  State<AICardCreationScreen> createState() => _AICardCreationScreenState();
}

class _AICardCreationScreenState extends State<AICardCreationScreen> {
  final TextEditingController _promptController = TextEditingController();
  final TextEditingController _eventTypeController = TextEditingController();
  final TextEditingController _eventToneController = TextEditingController();
  bool _isGenerating = false;
  CardModel? _generatedCard;
  String _generatedPrompt = '';
  EventCardContent? _generatedContent;

  // Predefined event types for better prompt engineering
  final List<String> _eventTypes = [
    'Birthday Party',
    'Wedding',
    'Business Meeting',
    'Conference',
    'Workshop',
    'Concert',
    'Exhibition',
    'Sports Event',
    'Dinner Party',
    'Graduation',
    'Anniversary',
    'Product Launch',
    'Charity Event',
    'Holiday Celebration',
    'Custom Event'
  ];

  // Event tones/moods for better prompt engineering
  final List<Map<String, dynamic>> _eventTones = [
    {'name': 'Vui vẻ', 'icon': '😊', 'color': 0xFFFFB74D},
    {'name': 'Hài hước', 'icon': '😄', 'color': 0xFFFF8A65},
    {'name': 'Lãng mạn', 'icon': '💕', 'color': 0xFFF06292},
    {'name': 'Trang trọng', 'icon': '🎩', 'color': 0xFF8E24AA},
    {'name': 'Thân thiện', 'icon': '🤝', 'color': 0xFF4FC3F7},
    {'name': 'Chuyên nghiệp', 'icon': '💼', 'color': 0xFF5C6BC0},
    {'name': 'Sôi động', 'icon': '🎉', 'color': 0xFF26A69A},
    {'name': 'Thư giãn', 'icon': '😌', 'color': 0xFF81C784},
    {'name': 'Căng thẳng', 'icon': '😰', 'color': 0xFFE57373},
    {'name': 'Gấp gáp', 'icon': '⏰', 'color': 0xFFFFB74D},
    {'name': 'Quan trọng', 'icon': '⭐', 'color': 0xFFFFD54F},
    {'name': 'Ưu tiên', 'icon': '🚀', 'color': 0xFFFF7043},
    {'name': 'Lo lắng', 'icon': '😟', 'color': 0xFFAED581},
    {'name': 'Bí mật', 'icon': '🤫', 'color': 0xFF9575CD},
    {'name': 'Thách thức', 'icon': '💪', 'color': 0xFF64B5F6},
  ];

  @override
  void dispose() {
    _promptController.dispose();
    _eventTypeController.dispose();
    _eventToneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios, color: Colors.black54, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        'AI Creator',
        style: TextStyle(
          color: Colors.black87,
          fontSize: 18,
          fontWeight: FontWeight.w500,
          fontFamily: 'SF Pro Rounded',
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 32),
          _buildEventTypeSelector(),
          const SizedBox(height: 24),
          _buildEventToneSelector(),
          const SizedBox(height: 24),
          _buildPromptInput(),
          const SizedBox(height: 32),
          _buildGenerateButton(),
          if (_isGenerating) ...[
            const SizedBox(height: 24),
            _buildGeneratingIndicator(),
          ],
          if (_generatedCard != null) ...[
            const SizedBox(height: 32),
            _buildGeneratedCard(),
          ],
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.auto_awesome,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AI Card Creator',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                        fontFamily: 'SF Pro Rounded',
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Powered by Google Gemini',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                        fontFamily: 'SF Pro Rounded',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Describe your event in detail and AI will generate a personalized invitation card with matching visuals and content.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
              fontFamily: 'SF Pro Rounded',
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Event Type',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
            fontFamily: 'SF Pro Rounded',
          ),
        ),
        const SizedBox(height: 16),
        Container(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _eventTypes.length,
            itemBuilder: (context, index) {
              final eventType = _eventTypes[index];
              final isSelected = _eventTypeController.text == eventType;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _eventTypeController.text = eventType;
                  });
                },
                child: Container(
                  width: 110,
                  margin: EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.black87 : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      eventType,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: isSelected ? Colors.white : Colors.grey.shade700,
                        fontFamily: 'SF Pro Rounded',
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEventToneSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Event Mood',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
            fontFamily: 'SF Pro Rounded',
          ),
        ),
        const SizedBox(height: 16),
        Container(
          height: 80,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _eventTones.length,
            itemBuilder: (context, index) {
              final tone = _eventTones[index];
              final isSelected = _eventToneController.text == tone['name'];

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _eventToneController.text = tone['name'];
                  });
                },
                child: Container(
                  width: 75,
                  margin: EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.black87 : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        tone['icon'],
                        style: TextStyle(fontSize: 20),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        tone['name'],
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color:
                              isSelected ? Colors.white : Colors.grey.shade700,
                          fontFamily: 'SF Pro Rounded',
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPromptInput() {
    final characterCount = _promptController.text.length;
    final minLength = 20;
    final isValidLength = characterCount >= minLength;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Event Description',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
                fontFamily: 'SF Pro Rounded',
              ),
            ),
            Text(
              '$characterCount chars',
              style: TextStyle(
                fontSize: 12,
                color: isValidLength
                    ? Colors.green.shade600
                    : Colors.grey.shade500,
                fontFamily: 'SF Pro Rounded',
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: characterCount > 0
                  ? (isValidLength
                      ? Colors.green.shade300
                      : Colors.orange.shade300)
                  : Colors.grey.shade200,
              width: 1,
            ),
          ),
          child: Column(
            children: [
              TextField(
                controller: _promptController,
                maxLines: 6,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.black87,
                  fontFamily: 'SF Pro Rounded',
                  height: 1.4,
                ),
                onChanged: (value) {
                  setState(() {}); // Trigger rebuild to update button state
                },
                decoration: InputDecoration(
                  hintText: 'Tell AI about your event...',
                  hintStyle: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 15,
                    fontFamily: 'SF Pro Rounded',
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(20),
                ),
              ),
              if (characterCount == 0) _buildPromptSuggestions(),
            ],
          ),
        ),
        if (characterCount > 0 && !isValidLength)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'Add more details for better AI results (min $minLength characters)',
              style: TextStyle(
                fontSize: 12,
                color: Colors.orange.shade600,
                fontFamily: 'SF Pro Rounded',
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPromptSuggestions() {
    final suggestions = [
      '💝 Birthday party with friends at home',
      '💼 Product launch event for tech startup',
      '💒 Wedding ceremony in garden setting',
      '🎓 Graduation celebration dinner',
      '🏢 Team building workshop',
    ];

    return Container(
      padding: EdgeInsets.only(left: 20, right: 20, bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick suggestions:',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
              fontFamily: 'SF Pro Rounded',
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: suggestions.map((suggestion) {
              return GestureDetector(
                onTap: () {
                  _promptController.text =
                      suggestion.substring(2); // Remove emoji
                  setState(() {});
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Text(
                    suggestion,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade700,
                      fontFamily: 'SF Pro Rounded',
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildGenerateButton() {
    final characterCount = _promptController.text.trim().length;
    final minLength = 20;
    final canGenerate = characterCount >= minLength && !_isGenerating;

    return Container(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: canGenerate ? _onGeneratePressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: canGenerate ? Colors.black87 : Colors.grey.shade300,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_isGenerating)
              SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            else
              Icon(Icons.auto_awesome, size: 18),
            const SizedBox(width: 12),
            Text(
              _isGenerating ? 'Creating...' : 'Generate Card',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                fontFamily: 'SF Pro Rounded',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _onGeneratePressed() async {
    final isLimited =
        !(await SubscriptionService.canUseFeature(AppFeature.aiGeneration));
    if (isLimited) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Row(
            children: [
              Icon(Icons.lock, color: Colors.amber),
              const SizedBox(width: 8),
              Text('Đã đạt giới hạn'),
            ],
          ),
          content: Text(
              'Bạn đã đạt giới hạn sử dụng AI cho gói miễn phí. Nâng cấp để sử dụng không giới hạn và mở khoá nhiều tính năng cao cấp!'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Để sau'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const UpgradeScreen()),
                );
              },
              child: Text('Nâng cấp'),
            ),
          ],
        ),
      );
      return;
    }
    await _generateCard();
  }

  Widget _buildGeneratingIndicator() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.black54),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              'AI is creating your event card...',
              style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.w500,
                fontSize: 15,
                fontFamily: 'SF Pro Rounded',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGeneratedCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Thẻ đã tạo',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade800,
              ),
            ),
            if (_generatedContent?.imageData != null) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green.shade300),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.image,
                      size: 14,
                      color: Colors.green.shade700,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Có hình ảnh',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.green.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: _buildCardPreview(_generatedCard!),
          ),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => _regenerateCard(),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.purple.shade600,
                  side: BorderSide(color: Colors.purple.shade300),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.refresh, size: 18),
                    const SizedBox(width: 8),
                    Text('Tạo lại'),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () => _useGeneratedCard(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple.shade500,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check, size: 18),
                    const SizedBox(width: 8),
                    Text('Sử dụng'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCardPreview(CardModel card) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.purple.shade400,
            Colors.blue.shade500,
          ],
        ),
      ),
      child: Stack(
        children: [
          // AI-generated image background if available
          if (_generatedContent?.imageData != null)
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.memory(
                  _generatedContent!.imageData!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.purple.shade400,
                          Colors.blue.shade500,
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

          // Background pattern overlay
          Positioned.fill(
            child: CustomPaint(
              painter: _AIPatternPainter(),
            ),
          ),

          // Content overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.7),
                ],
              ),
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  card.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                if (card.description.isNotEmpty)
                  Text(
                    card.description,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                const Spacer(),
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      color: Colors.white.withOpacity(0.8),
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        card.location.isNotEmpty
                            ? card.location
                            : 'Địa điểm chưa xác định',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _generateCard() async {
    if (_promptController.text.trim().isEmpty) return;

    setState(() {
      _isGenerating = true;
      _generatedCard = null;
      _generatedContent = null;
    });

    try {
      // Generate card using Gemini AI service
      final generatedCard =
          await _generateCardWithAI(_promptController.text.trim());

      // Track AI generation usage
      await SubscriptionService.trackFeatureUsage(AppFeature.aiGeneration);

      setState(() {
        _generatedCard = generatedCard;
        _isGenerating = false;
      });

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_generatedContent?.imageData != null
              ? 'Thẻ sự kiện đã được tạo thành công với hình ảnh!'
              : 'Thẻ sự kiện đã được tạo thành công!'),
          backgroundColor: Colors.green.shade600,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      setState(() {
        _isGenerating = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Có lỗi xảy ra khi tạo thẻ: $e'),
          backgroundColor: Colors.red.shade400,
          duration: const Duration(seconds: 4),
          action: SnackBarAction(
            label: 'Thử lại',
            textColor: Colors.white,
            onPressed: () => _generateCard(),
          ),
        ),
      );
    }
  }

  Future<CardModel> _generateCardWithAI(String prompt) async {
    // Get current language from app context
    final currentLanguage = Localizations.localeOf(context).languageCode;

    // Build enhanced prompt with tone
    String enhancedPrompt = prompt;

    if (_eventToneController.text.isNotEmpty) {
      enhancedPrompt =
          'Tâm trạng sự kiện: ${_eventToneController.text}. $prompt';
    }

    // Generate card using Gemini AI service
    final generatedContent = await GeminiService.generateEventCard(
      eventType: _eventTypeController.text.isNotEmpty
          ? _eventTypeController.text
          : 'Custom Event',
      description: enhancedPrompt,
      language: currentLanguage,
    );

    // Store generated content for potential image display
    setState(() {
      _generatedContent = generatedContent;
    });

    return CardModel(
      id: 'ai_${DateTime.now().millisecondsSinceEpoch}',
      title: generatedContent.title,
      description: generatedContent.description,
      ownerId: 'ai_generated',
      imageUrl: '',
      backgroundImageUrl: 'ai_generated',
      location: generatedContent.location,
      latitude: null,
      longitude: null,
      eventDateTime: null,
      participants: [],
    );
  }

  void _regenerateCard() {
    _generateCard();
  }

  void _useGeneratedCard() async {
    if (_generatedCard != null) {
      // Prepare AI-generated data for card creation
      XFile? backgroundImageFile;
      Uint8List? backgroundImageBytes;

      // Convert imageData to XFile if available
      if (_generatedContent?.imageData != null) {
        try {
          if (kIsWeb) {
            // For web, pass bytes directly
            backgroundImageBytes = _generatedContent!.imageData!;
            // Create a fake XFile for web (path won't be used)
            backgroundImageFile = XFile.fromData(
              _generatedContent!.imageData!,
              name:
                  'ai_background_${DateTime.now().millisecondsSinceEpoch}.jpg',
              mimeType: 'image/jpeg',
            );
          } else {
            // For mobile, create actual file
            final tempDir = Directory.systemTemp;
            final file = File(
                '${tempDir.path}/ai_background_${DateTime.now().millisecondsSinceEpoch}.jpg');
            await file.writeAsBytes(_generatedContent!.imageData!);
            backgroundImageFile = XFile(file.path);
          }
        } catch (e) {
          print('Error creating file from AI image data: $e');
        }
      }

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MinimalistCardCreationScreen(
            initialData: {
              'title': _generatedCard!.title,
              'description': _generatedCard!.description,
              'location': _generatedCard!.location,
              'backgroundImageFile': backgroundImageFile,
              'backgroundImageBytes': backgroundImageBytes, // Add bytes for web
            },
          ),
        ),
      );
    }
  }
}

class _AIPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    // Draw AI-inspired pattern
    for (int i = 0; i < 8; i++) {
      final x = (size.width / 8) * i;
      final y = (size.height / 6) * (i % 3 + 1);
      canvas.drawCircle(Offset(x, y), 15 + i * 2, paint);
    }

    // Draw connecting lines
    final linePaint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < 4; i++) {
      final startX = (size.width / 4) * i;
      final endX = (size.width / 4) * (i + 1);
      canvas.drawLine(
        Offset(startX, size.height * 0.3),
        Offset(endX, size.height * 0.7),
        linePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
