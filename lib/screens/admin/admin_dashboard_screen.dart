import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/announcement_provider.dart';
import '../../models/announcement_model.dart';
import '../../utils/constants.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({Key? key}) : super(key: key);

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  String? _selectedCategoryFilter;
  String? _selectedAreaFilter;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
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
      body: Consumer<AnnouncementProvider>(
        builder: (context, announcementProvider, _) {
          final authProvider = context.read<AuthProvider>();
          final adminId = authProvider.currentUser?.userId;

          return CustomScrollView(
            slivers: [
              // Statistics Section
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Quick Stats',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatCard(
                              'Total Announcements',
                              announcementProvider.announcements.length
                                  .toString(),
                              Icons.notifications_active,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildStatCard(
                              'Unresolved',
                              _getUnresolvedCount(
                                announcementProvider.announcements,
                              ).toString(),
                              Icons.error_outline,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Create Button
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const CreateEditAnnouncementScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Create Announcement'),
                    ),
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 16)),
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 44,
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    scrollDirection: Axis.horizontal,
                    children: [
                      FilterChip(
                        label: const Text('All Categories'),
                        selected: _selectedCategoryFilter == null,
                        onSelected: (selected) {
                          setState(() {
                            _selectedCategoryFilter = null;
                            _selectedAreaFilter = null;
                          });
                        },
                      ),
                      const SizedBox(width: 8),
                      ...announcementCategories.map((category) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: Text(category),
                            selected: _selectedCategoryFilter == category,
                            onSelected: (selected) {
                              setState(() {
                                _selectedCategoryFilter = selected ? category : null;
                                _selectedAreaFilter = null;
                              });
                            },
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 16)),
              if (_selectedCategoryFilter != null && _selectedCategoryFilter != 'Billing & Rates') ...[
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 44,
                    child: ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      scrollDirection: Axis.horizontal,
                      children: [
                        FilterChip(
                          label: const Text('All Areas'),
                          selected: _selectedAreaFilter == null,
                          onSelected: (selected) {
                            setState(() {
                              _selectedAreaFilter = null;
                            });
                          },
                        ),
                        const SizedBox(width: 8),
                        ...areas.map((area) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: FilterChip(
                              label: Text(area),
                              selected: _selectedAreaFilter == area,
                              onSelected: (selected) {
                                setState(() {
                                  _selectedAreaFilter = selected ? area : null;
                                });
                              },
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 24)),
              ],

              // Your Announcements
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: const Text(
                    'Your Announcements',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 12)),

              // Announcements List
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: Consumer<AnnouncementProvider>(
                  builder: (context, announcementProvider, _) {
                    final userAnnouncements = announcementProvider.announcements
                        .where((a) => a.createdBy == adminId)
                        .where((a) => _selectedCategoryFilter == null || _selectedCategoryFilter!.isEmpty || a.category == _selectedCategoryFilter)
                        .where((a) => _selectedAreaFilter == null || _selectedAreaFilter!.isEmpty || a.area == _selectedAreaFilter)
                        .toList();

                    if (userAnnouncements.isEmpty) {
                      return SliverFillRemaining(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.note_outlined,
                                size: 64,
                                color: Color(0xFFBDBDBD),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'No Announcements Yet',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF757575),
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Create your first announcement',
                                style: TextStyle(
                                  color: Color(0xFF999999),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    return SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final announcement = userAnnouncements[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _buildAdminAnnouncementCard(
                              announcement,
                              context,
                            ),
                          );
                        },
                        childCount: userAnnouncements.length,
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: const Color(0xFF4DA8DA), size: 28),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF757575),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminAnnouncementCard(
    Announcement announcement,
    BuildContext context,
  ) {
    final isResolved = announcement.category.toLowerCase() == 'resolved';
    final isBillingRates = announcement.category == 'Billing & Rates';
    final now = DateTime.now();
    final isOngoing = !isBillingRates &&
        now.isAfter(announcement.startTime) &&
        now.isBefore(announcement.endTime);
    final statusLabel = isBillingRates
        ? 'Announcement'
        : isResolved
            ? 'Resolved'
            : isOngoing
                ? 'Ongoing'
                : 'Scheduled';
    final statusColor = isBillingRates
        ? const Color(0xFF1976D2)
        : isResolved
            ? const Color(0xFF388E3C)
            : isOngoing
                ? const Color(0xFFFF9800)
                : const Color(0xFF1976D2);
    final statusBackground = isBillingRates
        ? const Color(0x241976D2)
        : isResolved
            ? const Color(0x24388E3C)
            : isOngoing
                ? const Color(0x24FF9800)
                : const Color(0x241976D2);
    final dateText = isBillingRates
        ? 'Created: ${announcement.createdAt.day}/${announcement.createdAt.month}/${announcement.createdAt.year} ${announcement.createdAt.hour}:${announcement.createdAt.minute.toString().padLeft(2, '0')}'
        : '${announcement.startTime.day}/${announcement.startTime.month}/${announcement.startTime.year} - ${announcement.endTime.day}/${announcement.endTime.month}/${announcement.endTime.year}';

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
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
                const Spacer(),
                PopupMenuButton(
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      child: const Text('Edit'),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                CreateEditAnnouncementScreen(
                              announcement: announcement,
                            ),
                          ),
                        );
                      },
                    ),
                    if (!isResolved && announcement.category != 'Billing & Rates')
                      PopupMenuItem(
                        child: const Text('Mark Resolved'),
                        onTap: () async {
                          if (!mounted) return;
                          final announcementProvider =
                              context.read<AnnouncementProvider>();
                          final messenger = ScaffoldMessenger.of(context);
                          final success = await announcementProvider.updateAnnouncement(
                            announcement.copyWith(category: 'Resolved'),
                          );
                          if (!mounted) return;
                          if (success) {
                            messenger.showSnackBar(
                              const SnackBar(
                                content: Text('Announcement marked resolved.'),
                              ),
                            );
                          }
                        },
                      ),
                    PopupMenuItem(
                      child: const Text('Delete'),
                      onTap: () {
                        _showDeleteConfirmation(context, announcement.id);
                      },
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              announcement.title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                Chip(
                  label: Text(announcement.category),
                  visualDensity: VisualDensity.compact,
                ),
                Chip(
                  label: Text(announcement.area),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              dateText,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF777777),
              ),
            ),
          ],
        ),
      ),
    );
  }

  int _getUnresolvedCount(List<Announcement> announcements) {
    return announcements.where((a) {
      return a.category.toLowerCase() == 'maintenance' &&
          a.category.toLowerCase() != 'resolved';
    }).length;
  }

  void _showDeleteConfirmation(BuildContext context, String announcementId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Announcement'),
        content: const Text('Are you sure you want to delete this announcement?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<AnnouncementProvider>().deleteAnnouncement(
                    announcementId,
                  );
              Navigator.pop(context);
            },
            child: const Text('Delete'),
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

class CreateEditAnnouncementScreen extends StatefulWidget {
  final Announcement? announcement;

  const CreateEditAnnouncementScreen({
    Key? key,
    this.announcement,
  }) : super(key: key);

  @override
  State<CreateEditAnnouncementScreen> createState() =>
      _CreateEditAnnouncementScreenState();
}

class _CreateEditAnnouncementScreenState
    extends State<CreateEditAnnouncementScreen> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late DateTime _startTime;
  late DateTime _endTime;
  String? _selectedArea;
  String? _selectedCategory;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    if (widget.announcement != null) {
      _titleController = TextEditingController(text: widget.announcement!.title);
      _descriptionController =
          TextEditingController(text: widget.announcement!.description);
      _startTime = widget.announcement!.startTime;
      _endTime = widget.announcement!.endTime;
      _selectedCategory = widget.announcement!.category;
      // Force All Areas for Billing & Rates
      if (_selectedCategory == 'Billing & Rates') {
        _selectedArea = 'All Areas';
      } else {
        _selectedArea = widget.announcement!.area;
      }
    } else {
      _titleController = TextEditingController();
      _descriptionController = TextEditingController();
      _startTime = DateTime.now().add(const Duration(hours: 1));
      _endTime = DateTime.now().add(const Duration(hours: 2));
      _selectedCategory = announcementCategories.first;
      // Set area based on category
      if (_selectedCategory == 'Billing & Rates') {
        _selectedArea = 'All Areas';
      } else {
        _selectedArea = areas.isNotEmpty ? areas.first : null;
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.announcement == null
            ? 'Create Announcement'
            : 'Edit Announcement'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: 'Title',
                    prefixIcon: const Icon(Icons.title),
                    hintText: 'e.g., Water Main Maintenance',
                  ),
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Title is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Description
                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    prefixIcon: const Icon(Icons.description),
                    hintText: 'Detailed description of the interruption',
                  ),
                  maxLines: 5,
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Description is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Category Selection
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: InputDecoration(
                    labelText: 'Category',
                    prefixIcon: const Icon(Icons.category),
                  ),
                  items: announcementCategories.map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value;
                      // Auto-set area based on category
                      if (value == 'Billing & Rates') {
                        _selectedArea = 'All Areas';
                      } else {
                        // If switching away from Billing & Rates, reset to first area
                        _selectedArea = areas.isNotEmpty ? areas.first : null;
                      }
                    });
                  },
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Category is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Area Selection
                if (_selectedCategory != 'Billing & Rates')
                  Column(
                    children: [
                      DropdownButtonFormField<String>(
                        value: _selectedArea,
                        decoration: InputDecoration(
                          labelText: 'Area',
                          prefixIcon: const Icon(Icons.location_on),
                        ),
                        items: areas.map((area) {
                          return DropdownMenuItem(
                            value: area,
                            child: Text(area),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedArea = value;
                          });
                        },
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return 'Area is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                    ],
                  )
                else
                  const SizedBox(height: 16),

                // Start Time (hidden for Billing & Rates)
                if (_selectedCategory != 'Billing & Rates')
                  TextFormField(
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: 'Start Time',
                      prefixIcon: const Icon(Icons.access_time),
                      hintText: 'Select start time',
                    ),
                    controller: TextEditingController(
                      text:
                          '${_startTime.day}/${_startTime.month}/${_startTime.year} ${_startTime.hour}:${_startTime.minute.toString().padLeft(2, '0')}',
                    ),
                    onTap: () => _selectDateTime(context, true),
                  ),
                if (_selectedCategory != 'Billing & Rates')
                  const SizedBox(height: 16),

                // End Time (hidden for Billing & Rates)
                if (_selectedCategory != 'Billing & Rates')
                  TextFormField(
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: 'End Time',
                      prefixIcon: const Icon(Icons.access_time),
                      hintText: 'Select end time',
                    ),
                    controller: TextEditingController(
                      text:
                          '${_endTime.day}/${_endTime.month}/${_endTime.year} ${_endTime.hour}:${_endTime.minute.toString().padLeft(2, '0')}',
                    ),
                    onTap: () => _selectDateTime(context, false),
                  ),
                if (_selectedCategory != 'Billing & Rates')
                  const SizedBox(height: 16),
                const SizedBox(height: 24),

                // Save Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _saveAnnouncement();
                      }
                    },
                    child: Text(widget.announcement == null
                        ? 'Create'
                        : 'Update'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _selectDateTime(BuildContext context, bool isStartTime) async {
    final date = await showDatePicker(
      context: context,
      initialDate: isStartTime ? _startTime : _endTime,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(
          isStartTime ? _startTime : _endTime,
        ),
      );

      if (time != null) {
        setState(() {
          final dateTime = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );

          if (isStartTime) {
            _startTime = dateTime;
          } else {
            _endTime = dateTime;
          }
        });
      }
    }
  }

  Future<void> _saveAnnouncement() async {
    final authProvider = context.read<AuthProvider>();
    final announcementProvider = context.read<AnnouncementProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    if (_selectedCategory == null ||
        (_selectedCategory != 'Billing & Rates' && _selectedArea == null)) {
      return;
    }

    final areaToUse = _selectedCategory == 'Billing & Rates'
        ? 'All Areas'
        : _selectedArea!;

    // For Billing & Rates, use creation time for start/end times
    DateTime startTimeToUse = _startTime;
    DateTime endTimeToUse = _endTime;

    if (_selectedCategory == 'Billing & Rates') {
      final now = DateTime.now();
      startTimeToUse = now;
      endTimeToUse = now.add(const Duration(hours: 1));
    }

    if (widget.announcement == null) {
      // Create new
      final success = await announcementProvider.createAnnouncement(
        title: _titleController.text,
        description: _descriptionController.text,
        area: areaToUse,
        category: _selectedCategory!,
        startTime: startTimeToUse,
        endTime: endTimeToUse,
        createdBy: authProvider.currentUser!.userId,
      );

      if (!mounted) return;
      if (success) {
        messenger.showSnackBar(
          const SnackBar(content: Text('Announcement created successfully.')),
        );
        navigator.pop();
      }
    } else {
      // Update existing
      final updated = widget.announcement!.copyWith(
        title: _titleController.text,
        description: _descriptionController.text,
        area: areaToUse,
        category: _selectedCategory!,
        startTime: startTimeToUse,
        endTime: endTimeToUse,
      );

      final success = await announcementProvider.updateAnnouncement(updated);
      if (!mounted) return;
      if (success) {
        messenger.showSnackBar(
          const SnackBar(content: Text('Announcement updated successfully.')),
        );
        navigator.pop();
      }
    }
  }
}
