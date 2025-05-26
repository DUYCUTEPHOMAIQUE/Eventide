import 'dart:io';
import 'dart:ui';

import 'package:enva/blocs/blocs.dart';
import 'package:enva/screens/card/card_preview_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:enva/screens/card/widgets/card_preview_component.dart';

class CardCreationScreen extends StatelessWidget {
  const CardCreationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CardCreationBloc(),
      child: const _CardCreationView(),
    );
  }
}

class _CardCreationView extends StatelessWidget {
  const _CardCreationView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CardCreationBloc, CardCreationState>(
      builder: (context, state) {
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.light.copyWith(
            statusBarColor: Colors.transparent,
            systemNavigationBarColor: Colors.black,
          ),
          child: Scaffold(
            backgroundColor: Colors.black,
            extendBodyBehindAppBar: true,
            body: _buildBody(context, state),
          ),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, CardCreationState state) {
    return Stack(
      children: [
        _buildBackgroundLayer(context, state),
        SafeArea(
          child: Column(
            children: [
              _buildAppBar(context, state),
              Expanded(
                child: _buildContentArea(context, state),
              ),
            ],
          ),
        ),
        if (state.status == CardCreationStatus.loading)
          _buildLoadingOverlay(context),
      ],
    );
  }

  Widget _buildLoadingOverlay(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.5),
      child: const Center(
        child: CircularProgressIndicator(
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildBackgroundLayer(BuildContext context, CardCreationState state) {
    final Size screenSize = MediaQuery.of(context).size;
    final double headerHeight = screenSize.height * 0.4;

    return Stack(
      children: [
        SizedBox(
          height: headerHeight,
          width: double.infinity,
          child: state.backgroundImage != null
              ? Image.file(
                  state.backgroundImage!,
                  fit: BoxFit.cover,
                )
              : Image.asset(
                  'assets/frieren.jpg',
                  fit: BoxFit.cover,
                ),
        ),
        Positioned(
          top: headerHeight - 40,
          left: 0,
          right: 0,
          bottom: 0,
          child: ClipRRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.2),
                      Colors.black.withOpacity(0.6),
                    ],
                    stops: const [0.0, 0.3, 1.0],
                  ),
                ),
              ),
            ),
          ),
        ),
        Container(
          height: double.infinity,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Colors.black.withOpacity(0.1),
                Colors.black.withOpacity(0.4),
                Colors.black.withOpacity(0.7),
              ],
              stops: const [0.0, 0.4, 0.7, 0.9],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSelectBackgroundButton(
      BuildContext context, CardCreationState state) {
    return ElevatedButton.icon(
      onPressed: () => context.read<CardCreationBloc>().pickBackgroundImage(),
      icon: Icon(
        state.backgroundImage == null ? Icons.add_photo_alternate : Icons.edit,
        color: Colors.white,
        size: 20,
      ),
      label: Text(
        state.backgroundImage == null
            ? 'Select Background'
            : 'Change Background',
        style: GoogleFonts.poppins(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.black.withOpacity(0.5),
        foregroundColor: Colors.white,
        elevation: 4,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.white.withOpacity(0.2)),
        ),
        shadowColor: Colors.black.withOpacity(0.3),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, CardCreationState state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildIconButton(
            context: context,
            icon: Icons.close,
            onPressed: () => Navigator.of(context).pop(),
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.visibility, size: 18),
            label: Text(
              'Preview',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CardPreviewScreen(state: state),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton({
    required BuildContext context,
    required IconData icon,
    required VoidCallback onPressed,
    double size = 36,
  }) {
    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.4),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: IconButton(
        padding: EdgeInsets.zero,
        icon: Icon(icon, color: Colors.white, size: size * 0.5),
        onPressed: onPressed,
        iconSize: size * 0.5,
        splashRadius: size * 0.5,
      ),
    );
  }

  Widget _buildContentArea(BuildContext context, CardCreationState state) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          const SizedBox(height: 80),
          _buildSelectBackgroundButton(context, state),
          const SizedBox(height: 40),
          _buildCard(
            child: _buildEventDetailsBlock(context, state),
          ),
          const SizedBox(height: 20),
          _buildCard(
            child: _buildHostBlock(context, state),
          ),
          const SizedBox(height: 20),
          _buildCard(
            child: _buildMemoriesBlock(context, state),
          ),
          const SizedBox(height: 20),
          _buildCreateButton(context),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildEventDetailsBlock(
      BuildContext context, CardCreationState state) {
    final cardBloc = context.read<CardCreationBloc>();

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: Center(
              child: state.isPreviewMode
                  ? Text(
                      state.title.isEmpty ? 'Event Title' : state.title,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                      textAlign: TextAlign.center,
                    )
                  : TextField(
                      onChanged: (value) => cardBloc.add(TitleChanged(value)),
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        hintText: 'Event Title',
                        hintStyle: GoogleFonts.poppins(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 24,
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 24),
          _buildInfoListTile(
            context: context,
            icon: Icons.calendar_today_rounded,
            title: 'Date & Time',
            value: state.formattedDateTime,
            onTap: state.isPreviewMode
                ? null
                : () async {
                    final DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: state.dateTime ??
                          DateTime.now().add(const Duration(days: 1)),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                      builder: (context, child) => Theme(
                        data: ThemeData.dark().copyWith(
                          colorScheme: ColorScheme.dark(
                            primary: Theme.of(context).primaryColor,
                            surface: const Color(0xFF202020),
                          ),
                          dialogBackgroundColor: const Color(0xFF121212),
                        ),
                        child: child!,
                      ),
                    );

                    if (pickedDate != null) {
                      final TimeOfDay? pickedTime = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                        builder: (context, child) => Theme(
                          data: ThemeData.dark().copyWith(
                            colorScheme: ColorScheme.dark(
                              primary: Theme.of(context).primaryColor,
                              surface: const Color(0xFF202020),
                            ),
                            dialogBackgroundColor: const Color(0xFF121212),
                          ),
                          child: child!,
                        ),
                      );

                      if (context.mounted) {
                        cardBloc.selectDateTime(pickedDate, pickedTime);
                      }
                    }
                  },
          ),
          const SizedBox(height: 12),
          _buildInfoListTile(
            context: context,
            icon: Icons.location_on_rounded,
            title: 'Location',
            value: state.location.isEmpty ? 'Add Location' : state.location,
            onTap: state.isPreviewMode
                ? null
                : () async {
                    final TextEditingController locationController =
                        TextEditingController(text: state.location);

                    await showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        backgroundColor: const Color(0xFF202020),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        title: Text(
                          'Event Location',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        content: TextField(
                          controller: locationController,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: 'Enter location',
                            hintStyle:
                                TextStyle(color: Colors.white.withOpacity(0.6)),
                            enabledBorder: const UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white38),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                  color: Theme.of(context).primaryColor),
                            ),
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(
                              'CANCEL',
                              style: TextStyle(
                                  color: Colors.white.withOpacity(0.7)),
                            ),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).primaryColor,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: () {
                              if (locationController.text.isNotEmpty) {
                                cardBloc.add(
                                    LocationChanged(locationController.text));
                              }
                              Navigator.pop(context);
                            },
                            child: const Text('SAVE'),
                          ),
                        ],
                      ),
                    );
                  },
          ),
        ],
      ),
    );
  }

  Widget _buildInfoListTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String value,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            if (onTap != null)
              Icon(
                Icons.chevron_right_rounded,
                color: Colors.white.withOpacity(0.7),
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHostBlock(BuildContext context, CardCreationState state) {
    final cardBloc = context.read<CardCreationBloc>();

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Theme.of(context).primaryColor.withOpacity(0.7),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).primaryColor.withOpacity(0.2),
                  blurRadius: 15,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const CircleAvatar(
              radius: 40,
              backgroundImage: NetworkImage(
                  'https://source.unsplash.com/random/100x100?face'),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Hosted by Andre Lorico',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 18,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: state.isPreviewMode
                ? Text(
                    state.description.isEmpty
                        ? 'No description provided'
                        : state.description,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 15,
                      height: 1.5,
                    ),
                  )
                : TextField(
                    onChanged: (value) =>
                        cardBloc.add(DescriptionChanged(value)),
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 15,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Add a description for your event...',
                      hintStyle: GoogleFonts.poppins(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 15,
                      ),
                      border: InputBorder.none,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildMemoriesBlock(BuildContext context, CardCreationState state) {
    final cardBloc = context.read<CardCreationBloc>();

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.photo_library,
                    color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                'Memories',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              if (!state.isPreviewMode)
                _buildAddPhotoButton(context,
                    onTap: () => cardBloc.pickMemoryImage()),
            ],
          ),
          const SizedBox(height: 20),
          if (state.memoryImages.isEmpty)
            _buildEmptyMemoriesState(
                onTap: !state.isPreviewMode
                    ? () => cardBloc.pickMemoryImage()
                    : null)
          else
            _buildMemoriesGrid(state.memoryImages),
        ],
      ),
    );
  }

  Widget _buildAddPhotoButton(BuildContext context,
      {required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withOpacity(0.2),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.add_photo_alternate,
                color: Colors.white, size: 16),
            const SizedBox(width: 6),
            Text(
              'Add',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyMemoriesState({VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 5,
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(
              Icons.photo_library_outlined,
              size: 48,
              color: Colors.white.withOpacity(0.6),
            ),
            const SizedBox(height: 12),
            Text(
              'Add photos to remember your event',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                color: Colors.white.withOpacity(0.7),
                fontSize: 16,
              ),
            ),
            if (onTap != null) ...[
              const SizedBox(height: 24),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.white.withOpacity(0.3)),
                ),
                child: Text(
                  '+ Add Photos',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMemoriesGrid(List<File> images) {
    return GridView.builder(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: images.length,
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 5.0,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.file(
              images[index],
              fit: BoxFit.cover,
            ),
          ),
        );
      },
    );
  }

  Widget _buildCreateButton(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 10),
      child: ElevatedButton(
        onPressed: () {
          context.read<CardCreationBloc>().add(const SubmitCard());
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 10,
          shadowColor: Theme.of(context).primaryColor.withOpacity(0.5),
        ),
        child: Text(
          'Create Invitation',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}
