import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:enva/viewmodels/card_creation_viewmodel.dart';
import 'package:enva/widgets/minimalist_location_picker.dart';
import 'dart:io';

class MinimalistCardCreationScreen extends StatelessWidget {
  const MinimalistCardCreationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => CardCreationViewModel(),
      child: const _MinimalistCardCreationView(),
    );
  }
}

class _MinimalistCardCreationView extends StatefulWidget {
  const _MinimalistCardCreationView();

  @override
  State<_MinimalistCardCreationView> createState() =>
      _MinimalistCardCreationViewState();
}

class _MinimalistCardCreationViewState
    extends State<_MinimalistCardCreationView> {
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
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
                borderRadius: BorderRadius.circular(12),
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
                  'Create Event',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade900,
                    letterSpacing: -0.5,
                  ),
                ),
                Text(
                  'Share your special moment',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),

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
        borderRadius: BorderRadius.circular(12),
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
          _buildSectionHeader('Basic Information', 'Tell us about your event'),
          const SizedBox(height: 24),
          _buildMinimalistTextField(
            label: 'Event Title',
            hintText: 'What\'s the occasion?',
            value: viewModel.title,
            onChanged: viewModel.setTitle,
            icon: Icons.event_outlined,
          ),
          const SizedBox(height: 20),
          _buildMinimalistTextField(
            label: 'Description',
            hintText: 'Share more details about your event...',
            value: viewModel.description,
            onChanged: viewModel.setDescription,
            icon: Icons.description_outlined,
            maxLines: 3,
          ),
          const SizedBox(height: 32),
          _buildSectionHeader('Location', 'Where will it happen?'),
          const SizedBox(height: 24),
          _buildLocationSection(viewModel),
          const SizedBox(height: 32),
          _buildSectionHeader('Event Time', 'When will it happen?'),
          const SizedBox(height: 24),
          _buildDateTimeSection(context, viewModel),
          const SizedBox(height: 32),
          _buildSectionHeader('Media', 'Add photos to make it special'),
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
  }) {
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
        Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: value.isNotEmpty
                  ? Colors.blue.shade200
                  : Colors.grey.shade200,
              width: 1.5,
            ),
          ),
          child: TextField(
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
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 20,
                vertical: maxLines > 1 ? 16 : 14,
              ),
            ),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildLocationSection(CardCreationViewModel viewModel) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
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
          borderRadius: BorderRadius.circular(16),
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
                        ? 'Event Date & Time'
                        : 'Set Event Date & Time',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    viewModel.hasEventDateTime
                        ? viewModel.formattedEventDateTime
                        : 'Tap to select when your event will happen',
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
          title: 'Background',
          subtitle: 'Main event image',
          icon: Icons.wallpaper_outlined,
          imageFile: viewModel.backgroundImageFile,
          onAdd: () => viewModel.pickBackgroundImage(context),
          onRemove: viewModel.removeBackgroundImage,
        ),
        const SizedBox(height: 16),
        _buildMediaCard(
          title: 'Memory Photo',
          subtitle: 'Special moment capture',
          icon: Icons.photo_outlined,
          imageFile: viewModel.cardImageFile,
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
    required VoidCallback onAdd,
    required VoidCallback onRemove,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color:
              imageFile != null ? Colors.blue.shade200 : Colors.grey.shade200,
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
                if (imageFile != null)
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
          if (imageFile != null) ...[
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(bottom: Radius.circular(16)),
              child: Image.file(
                imageFile,
                height: 120,
                width: double.infinity,
                fit: BoxFit.cover,
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
                        'Tap to add',
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
        borderRadius: BorderRadius.circular(12),
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
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: viewModel.isFormValid && !viewModel.isCreatingCard
                  ? () => _handleCreateCard(context, viewModel)
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    viewModel.isFormValid ? Colors.black : Colors.grey.shade300,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
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
                  : const Text(
                      'Create Event',
                      style: TextStyle(
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
                : 'Your event will be shared with invited guests',
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
}
