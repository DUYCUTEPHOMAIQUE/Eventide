import 'dart:ui';
import 'package:card_swiper/card_swiper.dart';
import 'package:enva/models/card_model.dart';
import 'package:enva/models/event_category.dart';
import 'package:enva/screens/home/widgets/invite_card.dart';
import 'package:enva/screens/home/widgets/user_avatar.dart';
import 'package:enva/screens/screens.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  EventCategory _selectedCategory = EventCategory.upcoming;
  int _currentCardIndex = 0;

  // Sample cards data - replace with your data source
  final List<CardModel> _cards = [
    CardModel(
      title: 'Housewarming Party',
      description: 'Party',
      imageUserUrl: 'https://source.unsplash.com/random/100x100?face',
      ownerId: 'user1',
    ),
    CardModel(
      title: 'Birthday Celebration',
      description: 'Birthday',
      imageUserUrl: 'https://source.unsplash.com/random/100x100?person',
      ownerId: 'user2',
    ),
    CardModel(
      title: 'Networking Event',
      description: 'Networking',
      imageUserUrl: 'https://source.unsplash.com/random/100x100?portrait',
      ownerId: 'user1',
    ),
  ];

  // Sample attendee avatars
  final List<String> _attendeeAvatars = List.generate(
    8,
    (index) => 'https://source.unsplash.com/random/100x100?face=${index}',
  );

  void _showCategoryPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: EventCategory.values.map((category) {
            return ListTile(
              title: Text(
                category.label,
                style: TextStyle(
                  color: _selectedCategory == category
                      ? Colors.white
                      : Colors.white70,
                  fontSize: 18,
                  fontWeight: _selectedCategory == category
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
              ),
              trailing: _selectedCategory == category
                  ? const Icon(Icons.check, color: Colors.white)
                  : null,
              onTap: () {
                setState(() => _selectedCategory = category);
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                children: [
                  // Category Selector
                  GestureDetector(
                    onTap: _showCategoryPicker,
                    child: Row(
                      children: [
                        Text(
                          _selectedCategory.label,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.keyboard_arrow_down,
                          color: Colors.white.withOpacity(0.7),
                          size: 28,
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  // Add Button
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.1),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.add, color: Colors.white),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const CardCreationScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                  // User Avatar
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                        width: 1,
                      ),
                      image: const DecorationImage(
                        image: NetworkImage(
                          'https://placekitten.com/100/100', // Placeholder avatar
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Card Swiper
            Expanded(
              child: _cards.isEmpty
                  ? _buildEmptyState()
                  : Swiper(
                      itemBuilder: (context, index) {
                        final card = _cards[index];
                        return InviteCard(
                          card: card,
                        );
                      },
                      itemCount: _cards.length,
                      viewportFraction: 0.85,
                      scale: 0.9,
                      onIndexChanged: (index) {
                        setState(() {
                          _currentCardIndex = index;
                        });
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.calendar_today,
            size: 64,
            color: Colors.white.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No ${_selectedCategory.label} Events',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () {
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(
              //     builder: (context) => const CardCreationWrapper(),
              //   ),
              // );
            },
            child: const Text(
              'Create an Event',
              style: TextStyle(
                color: Colors.blue,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
