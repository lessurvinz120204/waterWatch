import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/announcement_provider.dart';
import '../../models/announcement_model.dart';
import '../../utils/constants.dart';
import '../../widgets/announcement_card.dart';

class ClientHomeScreen extends StatefulWidget {
  const ClientHomeScreen({Key? key}) : super(key: key);

  @override
  State<ClientHomeScreen> createState() => _ClientHomeScreenState();
}

class _ClientHomeScreenState extends State<ClientHomeScreen> {
  final _searchController = TextEditingController();
  String? _selectedArea;
  String? _selectedCategory;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('WaterWatch'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              _showLogoutConfirmation(context);
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // Refresh announcements
          await Future.delayed(const Duration(seconds: 1));
        },
        child: Consumer<AnnouncementProvider>(
          builder: (context, announcementProvider, _) {
            return CustomScrollView(
              slivers: [
                // Search and Filter
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        // Search Field
                        TextField(
                          controller: _searchController,
                          onChanged: (value) {
                            announcementProvider.search(value);
                          },
                          decoration: InputDecoration(
                            hintText: 'Search announcements...',
                            prefixIcon: const Icon(Icons.search),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Category Filter
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              FilterChip(
                                label: const Text('All Categories'),
                                selected: _selectedCategory == null,
                                onSelected: (selected) {
                                  setState(() {
                                    _selectedCategory = null;
                                  });
                                  announcementProvider.setSelectedCategory(null);
                                },
                              ),
                              const SizedBox(width: 8),
                              ...announcementCategories.map((category) {
                                return Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 4),
                                  child: FilterChip(
                                    label: Text(category),
                                    selected: _selectedCategory == category,
                                    onSelected: (selected) {
                                      setState(() {
                                        _selectedCategory = selected ? category : null;
                                      });
                                      announcementProvider.setSelectedCategory(
                                        selected ? category : null,
                                      );
                                    },
                                  ),
                                );
                              }).toList(),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Area Filter
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              FilterChip(
                                label: const Text('All Areas'),
                                selected: _selectedArea == null,
                                onSelected: (selected) {
                                  setState(() {
                                    _selectedArea = null;
                                  });
                                  announcementProvider.setSelectedArea(null);
                                },
                              ),
                              const SizedBox(width: 8),
                              ...areas.map((area) {
                                return Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 4),
                                  child: FilterChip(
                                    label: Text(area),
                                    selected: _selectedArea == area,
                                    onSelected: (selected) {
                                      setState(() {
                                        _selectedArea = selected ? area : null;
                                      });
                                      announcementProvider.setSelectedArea(
                                        selected ? area : null,
                                      );
                                    },
                                  ),
                                );
                              }).toList(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Announcements List
                if (announcementProvider.announcements.isEmpty)
                  SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.info_outline,
                            size: 64,
                            color: Color(0xFFBDBDBD),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'No Announcements',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF757575),
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'No water interruptions announced yet',
                            style: TextStyle(
                              color: Color(0xFF999999),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final announcement =
                              announcementProvider.announcements[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: AnnouncementCard(
                              announcement: announcement,
                              onTap: () {
                                _showAnnouncementDetails(context, announcement);
                              },
                            ),
                          );
                        },
                        childCount: announcementProvider.announcements.length,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _showAnnouncementDetails(
    BuildContext context,
    Announcement announcement,
  ) {
    final authProvider = context.read<AuthProvider>();
    if (authProvider.currentUser != null) {
      context
          .read<AnnouncementProvider>()
          .markAsRead(authProvider.currentUser!.userId, announcement.id);
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          builder: (context, scrollController) {
            return ListView(
              controller: scrollController,
              padding: const EdgeInsets.all(20),
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        announcement.title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Category and Area Badges
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    Chip(
                      avatar: const Icon(Icons.category, size: 18),
                      label: Text(announcement.category),
                    ),
                    Chip(
                      avatar: const Icon(Icons.location_on, size: 18),
                      label: Text(announcement.area),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Time Information
                _buildInfoRow(
                  'Start Time',
                  '${announcement.startTime.day}/${announcement.startTime.month}/${announcement.startTime.year} ${announcement.startTime.hour}:${announcement.startTime.minute.toString().padLeft(2, '0')}',
                ),
                _buildInfoRow(
                  'End Time',
                  '${announcement.endTime.day}/${announcement.endTime.month}/${announcement.endTime.year} ${announcement.endTime.hour}:${announcement.endTime.minute.toString().padLeft(2, '0')}',
                ),
                const SizedBox(height: 16),

                // Description
                const Text(
                  'Details',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  announcement.description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF555555),
                    height: 1.5,
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF757575),
              fontSize: 12,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<AuthProvider>().signOut();
              Navigator.pop(context);
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
