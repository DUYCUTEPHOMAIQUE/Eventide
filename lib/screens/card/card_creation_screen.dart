import 'dart:ui';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:enva/viewmodels/card_creation_viewmodel.dart';
import 'package:enva/widgets/custom_text_field.dart';
import 'package:enva/widgets/location_picker.dart';

class CardCreationScreen extends StatelessWidget {
  const CardCreationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => CardCreationViewModel(),
      child: const _CardCreationView(),
    );
  }
}

class _CardCreationView extends StatefulWidget {
  const _CardCreationView();

  @override
  State<_CardCreationView> createState() => _CardCreationViewState();
}

class _CardCreationViewState extends State<_CardCreationView> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CardCreationViewModel>(
      builder: (context, viewModel, child) {
        return Scaffold(
          backgroundColor: Colors.black,
          appBar: _buildAppBar(context),
          body: _buildBody(context, viewModel),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text(
        'Create Card',
        style: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildBody(BuildContext context, CardCreationViewModel viewModel) {
    return Stack(
      children: [
        _buildBackground(context, viewModel),
        _buildContent(context, viewModel),
        if (viewModel.isCreatingCard) _buildLoadingOverlay(viewModel),
      ],
    );
  }

  Widget _buildBackground(
      BuildContext context, CardCreationViewModel viewModel) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.4,
      width: double.infinity,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: _getBackgroundImage(viewModel),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
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
    );
  }

  ImageProvider _getBackgroundImage(CardCreationViewModel viewModel) {
    // Priority: File -> Default asset
    if (viewModel.backgroundImageFile != null) {
      return FileImage(viewModel.backgroundImageFile!);
    } else {
      return const AssetImage('assets/frieren.jpg');
    }
  }

  Widget _buildContent(BuildContext context, CardCreationViewModel viewModel) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.25),
          _buildFormCard(context, viewModel),
          const SizedBox(height: 20),
          _buildCreateButton(context, viewModel),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildFormCard(BuildContext context, CardCreationViewModel viewModel) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: Column(
            children: [
              // Title field
              CustomTextField(
                label: 'Title',
                value: viewModel.title,
                onChanged: (value) {
                  viewModel.setTitle(value);
                  _titleController.value =
                      _titleController.value.copyWith(text: value);
                },
                hintText: 'Enter event title',
              ),
              const SizedBox(height: 16),

              // Description field
              CustomTextField(
                label: 'Description',
                value: viewModel.description,
                onChanged: (value) {
                  viewModel.setDescription(value);
                  _descriptionController.value =
                      _descriptionController.value.copyWith(text: value);
                },
                maxLines: 3,
                hintText: 'Enter event description',
              ),
              const SizedBox(height: 20),

              // Location field with map picker
              LocationPickerWidget(
                location: viewModel.location,
                selectedLocation: viewModel.selectedLocation,
                onLocationChanged: viewModel.setLocation,
                onLocationSelected: viewModel.setSelectedLocation,
                onGetCurrentLocation: viewModel.getCurrentLocation,
              ),
              const SizedBox(height: 20),

              // Background Image Section
              _buildImagePickerSection(
                context,
                title: 'Background Image',
                imageFile: viewModel.backgroundImageFile,
                onPickImage: () => viewModel.pickBackgroundImage(context),
                onRemoveImage: viewModel.removeBackgroundImage,
              ),
              const SizedBox(height: 20),

              // Card Image Section
              _buildImagePickerSection(
                context,
                title: 'Card Image',
                imageFile: viewModel.cardImageFile,
                onPickImage: () => viewModel.pickCardImage(context),
                onRemoveImage: viewModel.removeCardImage,
              ),

              // Error message
              if (viewModel.errorMessage != null &&
                  viewModel.errorMessage!.isNotEmpty) ...[
                const SizedBox(height: 16),
                _buildErrorMessage(viewModel),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePickerSection(
    BuildContext context, {
    required String title,
    required File? imageFile,
    required VoidCallback onPickImage,
    required VoidCallback onRemoveImage,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 120,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.3)),
            color: Colors.white.withOpacity(0.05),
          ),
          child: imageFile != null
              ? Stack(
                  children: [
                    // Image display
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        imageFile,
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),

                    // Remove button
                    Positioned(
                      top: 8,
                      right: 8,
                      child: GestureDetector(
                        onTap: onRemoveImage,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              : InkWell(
                  onTap: onPickImage,
                  child: const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.add_photo_alternate,
                          size: 32,
                          color: Colors.white54,
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Tap to select image',
                          style: TextStyle(
                            color: Colors.white54,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildErrorMessage(CardCreationViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              viewModel.errorMessage ?? '',
              style: const TextStyle(color: Colors.red, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCreateButton(
      BuildContext context, CardCreationViewModel viewModel) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: viewModel.isFormValid && !viewModel.isCreatingCard
            ? () => _handleCreateCard(context, viewModel)
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: viewModel.isFormValid
              ? Colors.blue
              : Colors.grey.withOpacity(0.3),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: viewModel.isCreatingCard
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Text(
                'Create Card',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  Widget _buildLoadingOverlay(CardCreationViewModel viewModel) {
    return Container(
      color: Colors.black.withOpacity(0.8),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          margin: const EdgeInsets.symmetric(horizontal: 32),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 3,
              ),
              const SizedBox(height: 20),
              Text(
                viewModel.progressMessage,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleCreateCard(
      BuildContext context, CardCreationViewModel viewModel) async {
    final success = await viewModel.createCard();
    if (success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Card created successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true); // Return true to indicate success
    }
  }
}
