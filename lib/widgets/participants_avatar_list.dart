import 'package:flutter/material.dart';
import '../models/user_model.dart';

class ParticipantsAvatarList extends StatelessWidget {
  final List<UserModel> participants;
  final double avatarSize;
  final double spacing;
  final int maxDisplayCount;
  final bool showBorder;

  const ParticipantsAvatarList({
    Key? key,
    required this.participants,
    this.avatarSize = 40,
    this.spacing = 8,
    this.maxDisplayCount = 4,
    this.showBorder = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (participants.isEmpty) {
      return const SizedBox.shrink();
    }

    final displayCount = participants.length > maxDisplayCount
        ? maxDisplayCount
        : participants.length;
    final remainingCount = participants.length - maxDisplayCount;

    final avatarColors = [
      Colors.blue[300]!,
      Colors.green[300]!,
      Colors.orange[300]!,
      Colors.purple[300]!,
      Colors.pink[300]!,
      Colors.teal[300]!,
      Colors.indigo[300]!,
      Colors.amber[300]!,
    ];

    return Row(
      children: [
        // Show participant avatars
        ...List.generate(displayCount, (index) {
          final participant = participants[index];
          return Container(
            margin: EdgeInsets.only(right: spacing),
            child: _buildAvatar(
              participant,
              avatarColors[index % avatarColors.length],
            ),
          );
        }),

        // Show remaining count if more than maxDisplayCount participants
        if (remainingCount > 0)
          Container(
            width: avatarSize,
            height: avatarSize,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.7),
              shape: BoxShape.circle,
              border:
                  showBorder ? Border.all(color: Colors.white, width: 3) : null,
            ),
            child: Center(
              child: Text(
                '+$remainingCount',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: avatarSize * 0.3,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildAvatar(UserModel participant, Color fallbackColor) {
    return Container(
      width: avatarSize,
      height: avatarSize,
      decoration: BoxDecoration(
        color: fallbackColor,
        shape: BoxShape.circle,
        border: showBorder ? Border.all(color: Colors.white, width: 3) : null,
      ),
      child: participant.avatarUrl != null
          ? ClipOval(
              child: Image.network(
                participant.avatarUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _buildFallbackAvatar(participant);
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return _buildFallbackAvatar(participant);
                },
              ),
            )
          : _buildFallbackAvatar(participant),
    );
  }

  Widget _buildFallbackAvatar(UserModel participant) {
    return Center(
      child: Text(
        _getInitials(participant),
        style: TextStyle(
          color: Colors.white,
          fontSize: avatarSize * 0.4,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _getInitials(UserModel participant) {
    if (participant.displayName != null &&
        participant.displayName!.isNotEmpty) {
      final names = participant.displayName!.split(' ');
      if (names.length >= 2) {
        return '${names[0][0]}${names[1][0]}'.toUpperCase();
      } else {
        return participant.displayName![0].toUpperCase();
      }
    } else {
      return participant.email[0].toUpperCase();
    }
  }
}
