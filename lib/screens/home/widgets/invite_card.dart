import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/card_model.dart';

class InviteCard extends StatelessWidget {
  final CardModel card;

  InviteCard({required this.card});

  String _formatDateTime(String isoString) {
    if (isoString.isEmpty) return 'Unknown time';
    try {
      final dateTime = DateTime.parse(isoString);
      return DateFormat('E, MMM d, h:mm a')
          .format(dateTime); // Ví dụ: "Tue, Sep 2, 8:00 PM"
    } catch (e) {
      return 'Invalid time';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300, // Chiều cao của card
      margin: EdgeInsets.symmetric(vertical: 8.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.0),
        image: DecorationImage(
          image: card.backgroundImageUrl == 'default'
              ? AssetImage(
                  'assets/default_background.jpg') // Ảnh mặc định nếu không có backgroundImageUrl
              : NetworkImage(card.backgroundImageUrl) as ImageProvider,
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            Colors.black.withOpacity(0.3), // Lớp phủ tối để chữ dễ đọc
            BlendMode.dstATop,
          ),
        ),
      ),
      child: Stack(
        children: [
          // Avatar của chủ sự kiện
          Positioned(
            bottom: 80,
            left: 16,
            child: CircleAvatar(
              radius: 20,
              backgroundImage: card.imageUserUrl.isNotEmpty
                  ? NetworkImage(card.imageUserUrl)
                  : AssetImage('assets/default_avatar.png') as ImageProvider,
            ),
          ),
          // Tiêu đề, thời gian, địa điểm
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  card.title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  _formatDateTime(card.created_at),
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
                Text(
                  card.location.isNotEmpty ? card.location : 'Unknown location',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
