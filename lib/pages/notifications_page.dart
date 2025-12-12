import 'package:flutter/material.dart';
import 'package:labtrack/utils/page_animations.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage>
    with TickerProviderStateMixin, PageAnimationsMixin {
  bool _isLoading = true;
  List<Map<String, dynamic>> _notifications = [];

  @override
  void initState() {
    super.initState();
    initAnimations();
    _fetchNotifications();
  }

  @override
  void dispose() {
    disposeAnimations();
    super.dispose();
  }

  // Simulated API call to fetch notifications
  Future<void> _fetchNotifications() async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    // Sample notifications data
    final notifications = [
      {
        'id': '1',
        'title': 'New Test Results',
        'message':
            'The results for sample S-2023-001 are now available. The pH analysis shows normal levels within the expected range. Please review the detailed report for more information.',
        'timestamp': DateTime.now().subtract(const Duration(minutes: 30)),
        'isRead': false,
        'type': 'result',
        'relatedId': 'S-2023-001',
      },
      {
        'id': '2',
        'title': 'Sample Collection Reminder',
        'message':
            'You have a scheduled sample collection tomorrow at 10:00 AM. Please ensure all necessary equipment is prepared and calibrated.',
        'timestamp': DateTime.now().subtract(const Duration(hours: 2)),
        'isRead': false,
        'type': 'reminder',
        'relatedId': 'SC-2023-045',
      },
      {
        'id': '3',
        'title': 'System Maintenance',
        'message':
            'The system will undergo maintenance tonight from 2:00 AM to 4:00 AM. Some features may be temporarily unavailable during this period.',
        'timestamp': DateTime.now().subtract(const Duration(hours: 5)),
        'isRead': true,
        'type': 'system',
        'relatedId': null,
      },
      {
        'id': '4',
        'title': 'New Sample Received',
        'message':
            'A new soil sample (S-2023-005) has been received and registered in the system. It requires pH and metal content analysis.',
        'timestamp': DateTime.now().subtract(const Duration(days: 1)),
        'isRead': true,
        'type': 'sample',
        'relatedId': 'S-2023-005',
      },
      {
        'id': '5',
        'title': 'Equipment Calibration Due',
        'message':
            'The spectrometer in Lab 3 is due for calibration. Please schedule this task as soon as possible to ensure accurate test results.',
        'timestamp': DateTime.now().subtract(const Duration(days: 2)),
        'isRead': true,
        'type': 'equipment',
        'relatedId': 'EQ-SPEC-003',
      },
      {
        'id': '6',
        'title': 'Test Assignment',
        'message':
            'You have been assigned to perform bacterial analysis on water sample S-2023-002. Priority: High. Expected completion: 24 hours.',
        'timestamp': DateTime.now().subtract(const Duration(days: 3)),
        'isRead': true,
        'type': 'assignment',
        'relatedId': 'S-2023-002',
      },
    ];

    setState(() {
      _notifications = notifications;
      _isLoading = false;
    });

    // Start the animations after the data is loaded
    startAnimations();
  }

  // Mark a notification as read
  void _markAsRead(String id) {
    setState(() {
      final index = _notifications.indexWhere(
        (notification) => notification['id'] == id,
      );
      if (index != -1) {
        _notifications[index]['isRead'] = true;
      }
    });

    // In a real app, you would also send this update to the backend
  }

  // Format timestamp relative to current time
  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hrs ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }

  // Get icon for notification type
  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'result':
        return Icons.assignment_turned_in;
      case 'reminder':
        return Icons.alarm;
      case 'system':
        return Icons.computer;
      case 'sample':
        return Icons.science;
      case 'equipment':
        return Icons.build;
      case 'assignment':
        return Icons.assignment_ind;
      default:
        return Icons.notifications;
    }
  }

  // Get color for notification type - brighter colors for better dark mode visibility
  Color _getNotificationColor(String type) {
    switch (type) {
      case 'result':
        return Colors.blue[400]!;
      case 'reminder':
        return Colors.orange[400]!;
      case 'system':
        return Colors.purple[300]!;
      case 'sample':
        return Colors.green[400]!;
      case 'equipment':
        return Colors.red[400]!;
      case 'assignment':
        return Colors.teal[300]!;
      default:
        return Colors.grey[400]!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all),
            tooltip: 'Mark all as read',
            onPressed: () {
              setState(() {
                for (var notification in _notifications) {
                  notification['isRead'] = true;
                }
              });
            },
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _notifications.isEmpty
              ? animatedWidget(child: _buildEmptyState())
              : _buildNotificationsList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_off,
            size: 80,
            color: Colors.grey.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          const Text(
            'No notifications yet',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'You\'re all caught up!',
            style: TextStyle(
              color:
                  Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey[400]
                      : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsList() {
    return ListView.builder(
      itemCount: _notifications.length,
      itemBuilder: (context, index) {
        final notification = _notifications[index];
        // Apply animation with staggered delay based on index
        return AnimatedPageItem(
          delay: Duration(milliseconds: 50 * index),
          child: _buildNotificationCard(notification),
        );
      },
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> notification) {
    final isRead = notification['isRead'] as bool;
    final type = notification['type'] as String;
    final timestamp = notification['timestamp'] as DateTime;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: isRead ? 1 : 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side:
            isRead
                ? BorderSide.none
                : BorderSide(color: Theme.of(context).primaryColor, width: 1.5),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: ExpansionTile(
          leading: Stack(
            clipBehavior: Clip.none,
            children: [
              CircleAvatar(
                backgroundColor: _getNotificationColor(type).withOpacity(0.2),
                child: Icon(
                  _getNotificationIcon(type),
                  color: _getNotificationColor(type),
                ),
              ),
              if (!isRead)
                Positioned(
                  top: -2,
                  right: -2,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color:
                            Theme.of(context).brightness == Brightness.dark
                                ? Colors.black
                                : Colors.white,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          title: Text(
            notification['title'],
            style: TextStyle(
              fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
              color: Theme.of(context).textTheme.titleMedium?.color,
            ),
          ),
          subtitle: Text(
            _formatTimestamp(timestamp),
            style: TextStyle(
              fontSize: 12,
              color:
                  Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey[400]
                      : Colors.grey[600],
            ),
          ),
          trailing: IconButton(
            icon: Icon(
              Icons.more_vert,
              color:
                  Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey[400]
                      : Colors.grey[600],
            ),
            onPressed: () {
              // Show options menu for the notification
              showModalBottomSheet(
                context: context,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                builder:
                    (context) => Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListTile(
                          leading: const Icon(Icons.done),
                          title: const Text('Mark as read'),
                          onTap: () {
                            Navigator.pop(context);
                            _markAsRead(notification['id']);
                          },
                        ),
                        if (notification['relatedId'] != null)
                          ListTile(
                            leading: const Icon(Icons.visibility),
                            title: const Text('View related item'),
                            onTap: () {
                              Navigator.pop(context);
                              // Navigate to the related item
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Navigating to ${notification['relatedId']}',
                                  ),
                                ),
                              );
                            },
                          ),
                        ListTile(
                          leading: const Icon(Icons.delete_outline),
                          title: const Text('Delete notification'),
                          onTap: () {
                            Navigator.pop(context);
                            setState(() {
                              _notifications.removeWhere(
                                (n) => n['id'] == notification['id'],
                              );
                            });
                          },
                        ),
                      ],
                    ),
              );
            },
          ),
          onExpansionChanged: (expanded) {
            if (expanded && !isRead) {
              _markAsRead(notification['id']);
            }
          },
          backgroundColor:
              isRead
                  ? Theme.of(context).brightness == Brightness.dark
                      ? Theme.of(context).cardColor
                      : Colors.white
                  : Theme.of(context).brightness == Brightness.dark
                  ? Theme.of(context).primaryColor.withOpacity(0.15)
                  : Theme.of(context).primaryColor.withOpacity(0.05),
          collapsedBackgroundColor:
              isRead
                  ? Theme.of(context).brightness == Brightness.dark
                      ? Theme.of(context).cardColor
                      : Colors.white
                  : Theme.of(context).brightness == Brightness.dark
                  ? Theme.of(context).primaryColor.withOpacity(0.15)
                  : Theme.of(context).primaryColor.withOpacity(0.05),
          children: [
            Container(
              color:
                  Theme.of(context).brightness == Brightness.dark
                      ? Theme.of(context).cardColor
                      : Colors.white,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(),
                  const SizedBox(height: 8),
                  Text(
                    notification['message'],
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (notification['relatedId'] != null)
                    OutlinedButton.icon(
                      icon: Icon(
                        Icons.arrow_forward,
                        color: Theme.of(context).primaryColor,
                      ),
                      label: Text(
                        'View ${type.toUpperCase()} ${notification['relatedId']}',
                        style: TextStyle(color: Theme.of(context).primaryColor),
                      ),
                      onPressed: () {
                        // Navigate to related item
                        // This would typically open the sample, test, or equipment details
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Navigating to ${notification['relatedId']}',
                            ),
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Theme.of(context).primaryColor),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
