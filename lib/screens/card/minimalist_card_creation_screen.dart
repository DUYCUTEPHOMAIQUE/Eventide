import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:enva/viewmodels/card_creation_viewmodel.dart';
import 'package:enva/widgets/minimalist_location_picker.dart';
import 'package:enva/l10n/app_localizations.dart';
import 'dart:io';
import 'package:enva/models/card_model.dart';

class MinimalistCardCreationScreen extends StatelessWidget {
  final CardModel? cardToEdit;

  const MinimalistCardCreationScreen({
    Key? key,
    this.cardToEdit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) {
        final viewModel = CardCreationViewModel();
        // Load card data for editing if provided
        if (cardToEdit != null) {
          // Use Future.microtask to ensure the viewModel is fully initialized
          Future.microtask(() {
            viewModel.loadCardForEditing(cardToEdit!);
          });
        }
        return viewModel;
      },
      child: _MinimalistCardCreationView(cardToEdit: cardToEdit),
    );
  }
}

class _MinimalistCardCreationView extends StatefulWidget {
  final CardModel? cardToEdit;

  const _MinimalistCardCreationView({this.cardToEdit});

  @override
  State<_MinimalistCardCreationView> createState() =>
      _MinimalistCardCreationViewState();
}

class _MinimalistCardCreationViewState
    extends State<_MinimalistCardCreationView> {
  final _scrollController = ScrollController();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CardCreationViewModel>(
      builder: (context, viewModel, child) {
        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Column(
              children: [
                _buildCleanAppBar(context, viewModel),
                Expanded(
                  child: _buildMainContent(context, viewModel),
                ),
                _buildBottomActions(context, viewModel),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCleanAppBar(
      BuildContext context, CardCreationViewModel viewModel) {
    final isEditMode = widget.cardToEdit != null;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.shade100,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Back button
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(32),
              ),
              child: Icon(
                Icons.arrow_back_ios_new,
                size: 20,
                color: Colors.grey.shade700,
              ),
            ),
          ),

          const SizedBox(width: 16),

          // Title
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isEditMode
                      ? AppLocalizations.of(context)!.editEvent
                      : AppLocalizations.of(context)!.createEvent,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade900,
                    letterSpacing: -0.5,
                  ),
                ),
                Text(
                  isEditMode
                      ? AppLocalizations.of(context)!.updateEventDetails
                      : AppLocalizations.of(context)!.shareSpecialMoment,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),

          // Preview button
          GestureDetector(
            onTap: viewModel.isFormValid
                ? () => _showPreviewCard(context, viewModel)
                : null,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: viewModel.isFormValid
                    ? Colors.blue.shade50
                    : Colors.grey.shade50,
                borderRadius: BorderRadius.circular(32),
                border: Border.all(
                  color: viewModel.isFormValid
                      ? Colors.blue.shade200
                      : Colors.grey.shade200,
                  width: 1,
                ),
              ),
              child: Icon(
                Icons.preview_outlined,
                size: 20,
                color: viewModel.isFormValid
                    ? Colors.blue.shade600
                    : Colors.grey.shade400,
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Progress indicator
          _buildProgressIndicator(viewModel),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator(CardCreationViewModel viewModel) {
    int completedFields = 0;
    int totalFields = 4;

    if (viewModel.title.isNotEmpty) completedFields++;
    if (viewModel.description.isNotEmpty) completedFields++;
    if (viewModel.hasLocation) completedFields++;
    if (viewModel.hasEventDateTime) completedFields++;

    double progress = completedFields / totalFields;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(
        children: [
          Text(
            '$completedFields/$totalFields',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(2),
            ),
            child: FractionallySizedBox(
              widthFactor: progress,
              alignment: Alignment.centerLeft,
              child: Container(
                decoration: BoxDecoration(
                  color: progress == 1.0 ? Colors.green : Colors.blue,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent(
      BuildContext context, CardCreationViewModel viewModel) {
    return SingleChildScrollView(
      controller: _scrollController,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(AppLocalizations.of(context)!.basicInformation,
              AppLocalizations.of(context)!.tellUsAboutYourEvent),
          const SizedBox(height: 24),
          _buildMinimalistTextField(
            label: AppLocalizations.of(context)!.eventTitle,
            hintText: AppLocalizations.of(context)!.eventTitleHint,
            value: viewModel.title,
            onChanged: viewModel.setTitle,
            icon: Icons.event_outlined,
            controller: _titleController,
          ),
          const SizedBox(height: 20),
          _buildMinimalistTextField(
            label: AppLocalizations.of(context)!.eventDescription,
            hintText: AppLocalizations.of(context)!.eventDescriptionHint,
            value: viewModel.description,
            onChanged: viewModel.setDescription,
            icon: Icons.description_outlined,
            maxLines: 3,
            controller: _descriptionController,
          ),
          const SizedBox(height: 32),
          _buildSectionHeader(AppLocalizations.of(context)!.eventLocation,
              AppLocalizations.of(context)!.whereWillItHappen),
          const SizedBox(height: 24),
          _buildLocationSection(viewModel),
          const SizedBox(height: 32),
          _buildSectionHeader(AppLocalizations.of(context)!.eventDateTime,
              AppLocalizations.of(context)!.whenWillItHappen),
          const SizedBox(height: 24),
          _buildDateTimeSection(context, viewModel),
          const SizedBox(height: 32),
          _buildSectionHeader(AppLocalizations.of(context)!.media,
              AppLocalizations.of(context)!.addPhotosToMakeItSpecial),
          const SizedBox(height: 24),
          _buildMediaSection(context, viewModel),
          const SizedBox(height: 40),
          if (viewModel.errorMessage != null &&
              viewModel.errorMessage!.isNotEmpty)
            _buildErrorCard(viewModel.errorMessage!),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade900,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildMinimalistTextField({
    required String label,
    required String hintText,
    required String value,
    required Function(String) onChanged,
    required IconData icon,
    int maxLines = 1,
    TextEditingController? controller,
  }) {
    // Update controller text if it doesn't match the value
    if (controller != null && controller.text != value) {
      controller.text = value;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: Colors.grey.shade600,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextField(
          controller: controller,
          maxLines: maxLines,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey.shade900,
            fontWeight: FontWeight.w400,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(
              color: Colors.grey.shade500,
              fontWeight: FontWeight.w400,
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 20,
              vertical: maxLines > 1 ? 16 : 14,
            ),
          ),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildLocationSection(CardCreationViewModel viewModel) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: viewModel.hasLocation
              ? Colors.blue.shade200
              : Colors.grey.shade200,
          width: 1.5,
        ),
      ),
      child: MinimalistLocationPicker(
        location: viewModel.location,
        selectedLocation: viewModel.selectedLocation,
        onLocationChanged: viewModel.setLocation,
        onLocationSelected: viewModel.setSelectedLocation,
        onGetCurrentLocation: viewModel.getCurrentLocation,
      ),
    );
  }

  Widget _buildDateTimeSection(
      BuildContext context, CardCreationViewModel viewModel) {
    return GestureDetector(
      onTap: () => _showDateTimePicker(context, viewModel),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(32),
          border: Border.all(
            color: viewModel.hasEventDateTime
                ? Colors.blue.shade200
                : Colors.grey.shade200,
            width: 1.5,
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: viewModel.hasEventDateTime
                    ? Colors.blue.shade100
                    : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.schedule_outlined,
                size: 24,
                color: viewModel.hasEventDateTime
                    ? Colors.blue.shade600
                    : Colors.grey.shade600,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    viewModel.hasEventDateTime
                        ? AppLocalizations.of(context)!.eventDateTime
                        : AppLocalizations.of(context)!.setEventDateTime,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    viewModel.hasEventDateTime
                        ? viewModel.getFormattedEventDateTime(context)
                        : AppLocalizations.of(context)!.tapToSelectDateTime,
                    style: TextStyle(
                      fontSize: 14,
                      color: viewModel.hasEventDateTime
                          ? Colors.grey.shade700
                          : Colors.grey.shade500,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            if (viewModel.hasEventDateTime)
              GestureDetector(
                onTap: () => _clearDateTime(viewModel),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.clear,
                    size: 18,
                    color: Colors.grey.shade600,
                  ),
                ),
              )
            else
              Icon(
                Icons.chevron_right,
                color: Colors.grey.shade400,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _showDateTimePicker(
      BuildContext context, CardCreationViewModel viewModel) async {
    final now = DateTime.now();
    final initialDate =
        viewModel.eventDateTime ?? now.add(const Duration(days: 1));

    // First, pick date
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365 * 2)), // 2 years from now
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: Colors.blue.shade600,
                  onPrimary: Colors.white,
                ),
          ),
          child: child!,
        );
      },
    );

    if (selectedDate == null) return;

    // Then, pick time
    final selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initialDate),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: Colors.blue.shade600,
                  onPrimary: Colors.white,
                ),
          ),
          child: child!,
        );
      },
    );

    if (selectedTime == null) return;

    // Combine date and time
    final selectedDateTime = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      selectedTime.hour,
      selectedTime.minute,
    );

    viewModel.setEventDateTime(selectedDateTime);
  }

  void _clearDateTime(CardCreationViewModel viewModel) {
    viewModel.clearEventDateTime();
  }

  Widget _buildMediaSection(
      BuildContext context, CardCreationViewModel viewModel) {
    return Column(
      children: [
        _buildMediaCard(
          title: AppLocalizations.of(context)!.background,
          subtitle: AppLocalizations.of(context)!.mainEventImage,
          icon: Icons.wallpaper_outlined,
          imageFile: viewModel.backgroundImageFile,
          currentImageUrl: viewModel.currentBackgroundImageUrl,
          onAdd: () => viewModel.pickBackgroundImage(context),
          onRemove: viewModel.removeBackgroundImage,
        ),
        const SizedBox(height: 16),
        _buildMediaCard(
          title: AppLocalizations.of(context)!.memoryPhoto,
          subtitle: AppLocalizations.of(context)!.specialMomentCapture,
          icon: Icons.photo_outlined,
          imageFile: viewModel.cardImageFile,
          currentImageUrl: viewModel.currentCardImageUrl,
          onAdd: () => viewModel.pickCardImage(context),
          onRemove: viewModel.removeCardImage,
        ),
      ],
    );
  }

  Widget _buildMediaCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required File? imageFile,
    required String? currentImageUrl,
    required VoidCallback onAdd,
    required VoidCallback onRemove,
  }) {
    final hasImage = imageFile != null ||
        (currentImageUrl != null && currentImageUrl!.isNotEmpty);

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: hasImage ? Colors.blue.shade200 : Colors.grey.shade200,
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: Colors.grey.shade600,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                if (hasImage)
                  GestureDetector(
                    onTap: onRemove,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.delete_outline,
                        size: 16,
                        color: Colors.red.shade600,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (hasImage) ...[
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(bottom: Radius.circular(32)),
              child: imageFile != null
                  ? Image.file(
                      imageFile,
                      height: 120,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    )
                  : Image.network(
                      currentImageUrl!,
                      height: 120,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 120,
                          width: double.infinity,
                          color: Colors.grey.shade200,
                          child: Center(
                            child: Icon(
                              Icons.broken_image_outlined,
                              color: Colors.grey.shade400,
                              size: 32,
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ] else ...[
            GestureDetector(
              onTap: onAdd,
              child: Container(
                height: 80,
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.grey.shade300,
                    style: BorderStyle.solid,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_photo_alternate_outlined,
                        size: 24,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        AppLocalizations.of(context)!.tapToAdd,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildErrorCard(String message) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: Colors.red.shade200,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: Colors.red.shade600,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: Colors.red.shade700,
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions(
      BuildContext context, CardCreationViewModel viewModel) {
    final isEditMode = widget.cardToEdit != null;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: Colors.grey.shade100,
            width: 1,
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Create/Update Event Button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: viewModel.isFormValid && !viewModel.isCreatingCard
                  ? () => isEditMode
                      ? _handleUpdateCard(context, viewModel)
                      : _handleCreateCard(context, viewModel)
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    viewModel.isFormValid ? Colors.black : Colors.grey.shade300,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(32),
                ),
                disabledBackgroundColor: Colors.grey.shade300,
                disabledForegroundColor: Colors.grey.shade600,
              ),
              child: viewModel.isCreatingCard
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      isEditMode
                          ? AppLocalizations.of(context)!.updateEvent
                          : AppLocalizations.of(context)!.createEvent,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.2,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            viewModel.isCreatingCard
                ? viewModel.progressMessage
                : isEditMode
                    ? AppLocalizations.of(context)!.eventWillBeUpdated
                    : AppLocalizations.of(context)!.eventWillBeShared,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w400,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Future<void> _handleCreateCard(
      BuildContext context, CardCreationViewModel viewModel) async {
    final success = await viewModel.createCard();
    if (success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Event created successfully!'),
          backgroundColor: Colors.green.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
      Navigator.pop(context, true);
    }
  }

  Future<void> _handleUpdateCard(
      BuildContext context, CardCreationViewModel viewModel) async {
    final success = await viewModel.updateCard(widget.cardToEdit!.id);
    if (success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Event updated successfully!'),
          backgroundColor: Colors.green.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
      Navigator.pop(context, true);
    }
  }

  Future<void> _showPreviewCard(
      BuildContext context, CardCreationViewModel viewModel) async {
    // Create a temporary card model for preview
    final previewCard = CardModel(
      id: 'preview_${DateTime.now().millisecondsSinceEpoch}',
      title: viewModel.title.isNotEmpty ? viewModel.title : 'Event Title',
      description: viewModel.description.isNotEmpty
          ? viewModel.description
          : 'Event Description',
      ownerId: 'preview_owner',
      imageUrl: '',
      backgroundImageUrl: viewModel.backgroundImageFile != null
          ? 'preview'
          : (viewModel.currentBackgroundImageUrl.isNotEmpty
              ? viewModel.currentBackgroundImageUrl
              : 'default'),
      location: viewModel.location.isNotEmpty ? viewModel.location : 'Location',
      latitude: viewModel.selectedLocation?.latitude,
      longitude: viewModel.selectedLocation?.longitude,
      eventDateTime: viewModel.eventDateTime,
      participants: [],
    );

    // Show preview modal
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _PreviewCardModal(
        card: previewCard,
        backgroundImageFile: viewModel.backgroundImageFile,
        cardImageFile: viewModel.cardImageFile,
        onEdit: () {
          Navigator.pop(context);
        },
      ),
    );
  }
}

class _PreviewCardModal extends StatelessWidget {
  final CardModel card;
  final File? backgroundImageFile;
  final File? cardImageFile;
  final VoidCallback onEdit;

  const _PreviewCardModal({
    required this.card,
    required this.backgroundImageFile,
    required this.cardImageFile,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(24)),
              border: Border(
                bottom: BorderSide(
                  color: Colors.grey.shade100,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.previewCard,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade900,
                          letterSpacing: -0.5,
                        ),
                      ),
                      Text(
                        AppLocalizations.of(context)!.seeHowYourEventWillLook,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(
                    Icons.close,
                    color: Colors.grey.shade600,
                    size: 24,
                  ),
                ),
              ],
            ),
          ),

          // Preview Card
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Card Preview
                  Container(
                    width: 354,
                    height: 612,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
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
                            child: _buildCardBackground(),
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
                              // Time
                              Text(
                                _formatEventTime(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  height: 1.2,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
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

                  const SizedBox(height: 32),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: onEdit,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.grey.shade700,
                            side: BorderSide(
                              color: Colors.grey.shade400,
                              width: 1.5,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.edit_outlined,
                                size: 20,
                                color: Colors.grey.shade700,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Edit Card',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: const Text(
                            'Looks Good!',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardBackground() {
    // Check if there's a new background image file
    if (backgroundImageFile != null) {
      return Image.file(
        backgroundImageFile!,
        fit: BoxFit.cover,
      );
    }

    // Check if there's a current background image URL (for editing mode)
    if (card.backgroundImageUrl.isNotEmpty &&
        card.backgroundImageUrl != 'default') {
      return Image.network(
        card.backgroundImageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildDefaultBackground();
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return _buildDefaultBackground();
        },
      );
    }

    // Fallback to default background
    return _buildDefaultBackground();
  }

  Widget _buildDefaultBackground() {
    // Placeholder background with gradient
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
    ];

    final selectedGradient =
        gradients[card.id.hashCode.abs() % gradients.length];

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
                borderRadius: BorderRadius.circular(20),
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

  String _formatEventTime() {
    if (card.eventDateTime != null) {
      final now = DateTime.now();
      final eventTime = card.eventDateTime!;
      final difference = eventTime.difference(now);

      if (difference.isNegative) {
        return 'Event has passed';
      } else if (difference.inDays > 0) {
        return '${difference.inDays} days left';
      } else if (difference.inHours > 0) {
        return '${difference.inHours} hours left';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes} minutes left';
      } else {
        return 'Starting now';
      }
    }
    return 'No date set';
  }
}

class _PlaceholderPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    // Draw circles
    for (int i = 0; i < 5; i++) {
      final x = (size.width / 4) * (i + 1);
      final y = (size.height / 6) * (i % 3 + 1);
      canvas.drawCircle(Offset(x, y), 20 + i * 5, paint);
    }

    // Draw curves
    final path = Path();
    path.moveTo(0, size.height * 0.3);
    path.quadraticBezierTo(
      size.width * 0.5,
      size.height * 0.1,
      size.width,
      size.height * 0.3,
    );
    path.quadraticBezierTo(
      size.width * 0.5,
      size.height * 0.5,
      0,
      size.height * 0.3,
    );
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
