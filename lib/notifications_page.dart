import 'package:flutter/material.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  List<Map<String, dynamic>> notifications = [
    {
      'id': '1',
      'text': 'Welcome to Spiderw App! Get started by connecting your favorite apps.',
      'time': '9:35 AM',
      'unread': true,
    },
    {
      'id': '2',
      'text': 'You’re all set! Your fingerprint has been successfully added for secure logins.',
      'time': '9:35 AM',
      'unread': true,
    },
    {
      'id': '3',
      'text': 'Update your password every 90 days to keep your account secure.',
      'time': '9:35 AM',
      'unread': false,
    },
    {
      'id': '4',
      'text': 'If this wasn’t you, change your password immediately.',
      'time': '9:35 AM',
      'unread': false,
    },
    {
      'id': '5',
      'text': 'You’ve reached the 8-app limit. Remove one to add a new app.',
      'time': '9:35 AM',
      'unread': false,
    },
    {
      'id': '6',
      'text': 'New Level Unlocked! ‘Mystic Mountains’ is now available',
      'time': '9:35 AM',
      'unread': false,
    },
    {
      'id': '7',
      'text': 'Long-press an app icon to edit or remove it from your web.',
      'time': '9:35 AM',
      'unread': false,
    },
    {
      'id': '8',
      'text': 'Looks Empty? Tap “Manage Apps” to start building your web.',
      'time': '9:35 AM',
      'unread': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Top Right Pink Glow
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(1.3, -1.0),
                radius: 1.5,
                colors: [
                  Color(0xAAAD1457),
                  Colors.transparent,
                ],
                stops: [0.1, 1.0],
              ),
            ),
          ),

          // Bottom Left Blue Glow
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(-1.3, 1.0),
                radius: 1.5,
                colors: [
                  Color(0xAA1A237E),
                  Colors.transparent,
                ],
                stops: [0.1, 1.0],
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  // Back Arrow + Centered Title
                  Stack(
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: const Icon(Icons.arrow_back, color: Colors.white),
                        ),
                      ),
                      const Center(
                        child: Text(
                          "Notifications",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Notification List
                  Expanded(
                    child: ListView.separated(
                      itemCount: notifications.length,
                      separatorBuilder: (context, index) =>
                      const Divider(color: Colors.white24, height: 1),
                      itemBuilder: (context, index) {
                        final item = notifications[index];

                        return Dismissible(
                          key: Key(item['id']),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            color: Colors.red,
                            child: const Icon(Icons.delete, color: Colors.white),
                          ),
                          onDismissed: (direction) {
                            setState(() {
                              notifications.removeAt(index);
                            });

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Notification dismissed"),
                                duration: Duration(milliseconds: 800),
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    item['text'],
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      item['time'],
                                      style: const TextStyle(
                                        color: Colors.white54,
                                        fontSize: 12,
                                      ),
                                    ),
                                    if (item['unread'])
                                      const Padding(
                                        padding: EdgeInsets.only(top: 4.0),
                                        child: Icon(
                                          Icons.brightness_1,
                                          color: Colors.red,
                                          size: 8,
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
