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
    final isResolved = announcement.category.toLowerCase() == 'resolved';
    final statusLabel = isResolved
        ? 'Resolved'
        : isOngoing
            ? 'Ongoing'
            : 'Scheduled';
    final statusColor = isResolved
        ? const Color(0xFF388E3C)
        : isOngoing
            ? const Color(0xFFFF9800)
            : const Color(0xFF1976D2);
    final statusBackground = isResolved
        ? const Color(0x24388E3C)
        : isOngoing
            ? const Color(0x24FF9800)
            : const Color(0x241976D2);
    final dateText =
        '${DateFormat('MMM d, yyyy').format(announcement.startTime)} - ${DateFormat('MMM d, yyyy').format(announcement.endTime)}';

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: statusBackground,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  statusLabel.toUpperCase(),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: statusColor,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                announcement.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  height: 1.3,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 8,
                runSpacing: 8,
                children: [
                  Chip(
                    label: Text(announcement.category),
                    backgroundColor: Colors.blue.shade50,
                  ),
                  Chip(
                    label: Text(announcement.area),
                    backgroundColor: Colors.green.shade50,
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                announcement.description,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF555555),
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.calendar_today,
                    size: 14,
                    color: Color(0xFF999999),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    dateText,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF777777),
                    ),
                    textAlign: TextAlign.center,
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
