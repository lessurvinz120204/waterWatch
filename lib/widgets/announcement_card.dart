import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/announcement_model.dart';

class AnnouncementCard extends StatelessWidget {
  final Announcement announcement;
  final VoidCallback? onTap;

  const AnnouncementCard({
    Key? key,
    required this.announcement,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final isOngoing = now.isAfter(announcement.startTime) &&
        now.isBefore(announcement.endTime);

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Status Badge and Title
              if (isOngoing)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFEAB0),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'ONGOING',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFFF9800),
                    ),
                  ),
                ),
              if (isOngoing) const SizedBox(height: 12),
              Text(
                announcement.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),

              // Category Badge
              Chip(
                label: Text(announcement.category),
                backgroundColor: Colors.blue.shade50,
              ),
              const SizedBox(height: 12),

              // Description Preview
              Text(
                announcement.description,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF666666),
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 14),

              // Time Info
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.schedule,
                    size: 14,
                    color: Color(0xFF999999),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${DateFormat('MMM d, yyyy').format(announcement.startTime)} - ${DateFormat('MMM d').format(announcement.endTime)}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF999999),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Area Info
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.location_on,
                    size: 14,
                    color: Color(0xFF4DA8DA),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    announcement.area,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF4DA8DA),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
