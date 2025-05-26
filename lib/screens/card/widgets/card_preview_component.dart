import 'dart:io';
import 'dart:ui';

import 'package:enva/blocs/blocs.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Hiển thị card preview theo phong cách hiện đại
/// Component này có thể được sử dụng lại ở nhiều màn hình khác nhau
class CardPreviewComponent extends StatelessWidget {
  final CardCreationState state;

  const CardPreviewComponent({
    super.key,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.85,
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            fit: StackFit.expand,
            children: [
              _buildBackgroundImage(),
              _buildContentOverlay(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBackgroundImage() {
    return state.backgroundImage != null
        ? Image.file(
            state.backgroundImage!,
            fit: BoxFit.cover,
          )
        : Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/frieren.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          );
  }

  Widget _buildContentOverlay(BuildContext context) {
    return Stack(
      children: [
        // Hosting badge at the top
        Positioned(
          top: 24,
          left: 24,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.emoji_events_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Hosting',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        // Event details at the bottom
        Positioned(
          bottom: 24,
          left: 24,
          right: 24,
          child: _buildEventDetails(context),
        ),
      ],
    );
  }

  Widget _buildAttendeeAvatars(BuildContext context) {
    const int avatarCount = 6;
    const double avatarSize = 36;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 0; i < avatarCount; i++)
          Container(
            height: avatarSize,
            width: avatarSize,
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.black, width: 2),
              color: Colors.primaries[i % Colors.primaries.length],
            ),
            child: Center(
              child: Text(
                String.fromCharCode(65 + i),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        Container(
          height: avatarSize,
          width: avatarSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Theme.of(context).primaryColor,
            border: Border.all(color: Colors.black, width: 2),
          ),
          child: Center(
            child: Text(
              '+3',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEventDetails(BuildContext context) {
    final title = state.title.isNotEmpty ? state.title : 'Tyler Turns 3!';
    final date = state.formattedDateTime != 'Select Date & Time'
        ? state.formattedDateTime
        : 'Sat, June 14, 3:00 PM';
    final location = state.location.isNotEmpty ? state.location : 'Chicago, IL';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.bold,
            height: 1.2,
            shadows: [
              Shadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          date,
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
            shadows: [
              Shadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 5,
                offset: const Offset(0, 1),
              ),
            ],
          ),
        ),
        Text(
          location,
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
            shadows: [
              Shadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 5,
                offset: const Offset(0, 1),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
