import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hydrate/core/providers/user_preferences_provider.dart';
import 'package:hydrate/core/providers/notification_provider.dart';

class NotificationPreferences extends ConsumerWidget {
  const NotificationPreferences({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userPreferences = ref.watch(userPreferencesProvider);

    String intervalText = _getIntervalText(
      userPreferences.notificationIntervalMinutes,
    );

    return ListTile(
      title: const Text('Water Reminders'),
      subtitle: FutureBuilder<bool>(
        future: Platform.isAndroid
            ? ref.read(notificationServiceProvider).canScheduleExactAlarms()
            : Future.value(true),
        builder: (context, snapshot) => Text(
          'Remind me $intervalText${Platform.isAndroid && snapshot.data == false && userPreferences.notificationIntervalMinutes > 0 ? ' · timing may be delayed' : ''}',
        ),
      ),
      trailing: TextButton(
        onPressed: () {
          _showNotificationIntervalDialog(
            context,
            ref,
            userPreferences.notificationIntervalMinutes,
          );
        },
        child: const Text('Edit'),
      ),
    );
  }

  String _getIntervalText(int minutes) {
    if (minutes == 0) {
      return 'Never';
    } else if (minutes < 60) {
      return 'Every $minutes minute${minutes == 1 ? '' : 's'}';
    } else if (minutes % 60 == 0) {
      final hours = minutes ~/ 60;
      return 'Every $hours hour${hours == 1 ? '' : 's'}';
    } else {
      final hours = minutes ~/ 60;
      final remainingMinutes = minutes % 60;
      return 'Every ${hours}h ${remainingMinutes}m';
    }
  }

  void _showNotificationIntervalDialog(
    BuildContext context,
    WidgetRef ref,
    int currentIntervalMinutes,
  ) {
    int selectedIntervalMinutes = currentIntervalMinutes;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 16,
              insetPadding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * 0.05,
                vertical: MediaQuery.of(context).size.height * 0.15,
              ),
              child: Container(
                width: double.infinity,
                height: double.infinity,
                child: Column(
                  children: [
                    // Header
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withOpacity(0.1),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.notifications_active,
                            size: 32,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Water Reminder Interval',
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'How often should I remind you to drink water?',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface.withOpacity(0.7),
                                ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    // Scrollable content
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            // All options in a scrollable single column
                            _buildIntervalOption(
                              context: context,
                              title: 'Never',
                              subtitle: 'No reminders',
                              icon: Icons.notifications_off,
                              value: 0,
                              iconColor: Colors.grey,
                              selectedValue: selectedIntervalMinutes,
                              onChanged: (value) {
                                setState(() {
                                  selectedIntervalMinutes = value!;
                                });
                              },
                            ),
                            _buildIntervalOption(
                              context: context,
                              title: 'Every 15 minutes',
                              subtitle: 'Frequent hydration reminders',
                              icon: Icons.timer,
                              value: 15,
                              iconColor: Colors.red,
                              selectedValue: selectedIntervalMinutes,
                              onChanged: (value) {
                                setState(() {
                                  selectedIntervalMinutes = value!;
                                });
                              },
                            ),
                            _buildIntervalOption(
                              context: context,
                              title: 'Every 30 minutes',
                              subtitle: 'Regular hydration schedule',
                              icon: Icons.schedule,
                              value: 30,
                              iconColor: Colors.orange,
                              selectedValue: selectedIntervalMinutes,
                              onChanged: (value) {
                                setState(() {
                                  selectedIntervalMinutes = value!;
                                });
                              },
                            ),
                            _buildIntervalOption(
                              context: context,
                              title: 'Every 45 minutes',
                              subtitle: 'Balanced hydration approach',
                              icon: Icons.access_time,
                              value: 45,
                              iconColor: Colors.amber,
                              selectedValue: selectedIntervalMinutes,
                              onChanged: (value) {
                                setState(() {
                                  selectedIntervalMinutes = value!;
                                });
                              },
                            ),
                            _buildIntervalOption(
                              context: context,
                              title: 'Every 1 hour',
                              subtitle: 'Gentle hourly reminders',
                              icon: Icons.hourglass_bottom,
                              value: 60,
                              iconColor: Colors.green,
                              selectedValue: selectedIntervalMinutes,
                              onChanged: (value) {
                                setState(() {
                                  selectedIntervalMinutes = value!;
                                });
                              },
                            ),
                            _buildIntervalOption(
                              context: context,
                              title: 'Every 1.5 hours',
                              subtitle: 'Relaxed hydration schedule',
                              icon: Icons.update,
                              value: 90,
                              iconColor: Colors.blue,
                              selectedValue: selectedIntervalMinutes,
                              onChanged: (value) {
                                setState(() {
                                  selectedIntervalMinutes = value!;
                                });
                              },
                            ),
                            _buildIntervalOption(
                              context: context,
                              title: 'Every 2 hours',
                              subtitle: 'Minimal hydration reminders',
                              icon: Icons.schedule,
                              value: 120,
                              iconColor: Colors.indigo,
                              selectedValue: selectedIntervalMinutes,
                              onChanged: (value) {
                                setState(() {
                                  selectedIntervalMinutes = value!;
                                });
                              },
                            ),
                            _buildIntervalOption(
                              context: context,
                              title: 'Every 3 hours',
                              subtitle: 'Basic hydration maintenance',
                              icon: Icons.timer_outlined,
                              value: 180,
                              iconColor: Colors.purple,
                              selectedValue: selectedIntervalMinutes,
                              onChanged: (value) {
                                setState(() {
                                  selectedIntervalMinutes = value!;
                                });
                              },
                            ),
                            _buildIntervalOption(
                              context: context,
                              title: 'Every 4 hours',
                              subtitle: 'Light hydration reminders',
                              icon: Icons.access_time_filled,
                              value: 240,
                              iconColor: Colors.teal,
                              selectedValue: selectedIntervalMinutes,
                              onChanged: (value) {
                                setState(() {
                                  selectedIntervalMinutes = value!;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Action buttons
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(20),
                          bottomRight: Radius.circular(20),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: Theme.of(
                                context,
                              ).colorScheme.onSurface.withOpacity(0.6),
                            ),
                            child: const Text('Cancel'),
                          ),
                          const SizedBox(width: 16),
                          ElevatedButton(
                            onPressed: () async {
                              bool preciseTiming = true;
                              // Request notification permissions if enabling notifications
                              if (selectedIntervalMinutes > 0) {
                                final notificationService = ref.read(
                                  notificationServiceProvider,
                                );
                                final hasPermission = await notificationService
                                    .requestPermissions();

                                if (!hasPermission) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Notification permission denied. Please enable notifications in app settings.',
                                        ),
                                        backgroundColor: Colors.orange,
                                      ),
                                    );
                                  }
                                  return;
                                }
                                if (Platform.isAndroid) {
                                  try {
                                    preciseTiming = await notificationService
                                        .requestExactAlarmPermission();
                                  } catch (_) {
                                    preciseTiming = false;
                                  }
                                }
                              }

                              try {
                                await ref
                                    .read(userPreferencesProvider.notifier)
                                    .updateNotificationInterval(
                                      selectedIntervalMinutes,
                                    );
                              } catch (error) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Could not schedule reminders: $error',
                                      ),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                                return;
                              }

                              if (context.mounted) {
                                Navigator.of(context).pop();

                                // Show confirmation
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      selectedIntervalMinutes == 0
                                          ? 'Water reminders disabled'
                                          : preciseTiming
                                          ? 'Water reminders set to ${_getIntervalText(selectedIntervalMinutes).toLowerCase()}'
                                          : 'Reminders enabled with approximate timing. Allow Alarms & reminders for precise timing.',
                                    ),
                                    backgroundColor: preciseTiming
                                        ? Colors.green
                                        : Colors.orange,
                                  ),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(
                                context,
                              ).colorScheme.primary,
                              foregroundColor: Theme.of(
                                context,
                              ).colorScheme.onPrimary,
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text('Save'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildIntervalOption({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required int value,
    required Color iconColor,
    required int selectedValue,
    required Function(int?) onChanged,
  }) {
    final isSelected = selectedValue == value;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: isSelected
            ? iconColor.withOpacity(0.15)
            : (value == 0
                  ? Colors.grey.withOpacity(0.05)
                  : iconColor.withOpacity(0.06)),
        border: Border.all(
          color: isSelected
              ? iconColor.withOpacity(0.6)
              : iconColor.withOpacity(0.2),
          width: isSelected ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: () => onChanged(value),
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Icon
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: isSelected
                      ? iconColor.withOpacity(0.25)
                      : iconColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(6),
                  border: isSelected
                      ? Border.all(color: iconColor.withOpacity(0.4), width: 1)
                      : null,
                ),
                child: Icon(
                  icon,
                  color: isSelected ? iconColor : iconColor.withOpacity(0.7),
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              // Text content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w500,
                        color: isSelected ? iconColor : null,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 11,
                        color: isSelected
                            ? iconColor.withOpacity(0.8)
                            : Colors.grey.shade600,
                        fontWeight: isSelected
                            ? FontWeight.w500
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
              // Radio button
              Radio<int>(
                value: value,
                groupValue: selectedValue,
                onChanged: onChanged,
                activeColor: iconColor,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompactIntervalOption({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required int value,
    required Color iconColor,
    required int selectedValue,
    required Function(int?) onChanged,
  }) {
    final isSelected = selectedValue == value;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: isSelected
            ? iconColor.withOpacity(0.15)
            : (value == 0
                  ? Colors.grey.withOpacity(0.05)
                  : iconColor.withOpacity(0.06)),
        border: Border.all(
          color: isSelected
              ? iconColor.withOpacity(0.6)
              : iconColor.withOpacity(0.2),
          width: isSelected ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: () => onChanged(value),
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          child: Row(
            children: [
              // Icon
              Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: isSelected
                      ? iconColor.withOpacity(0.25)
                      : iconColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(3),
                ),
                child: Icon(
                  icon,
                  color: isSelected ? iconColor : iconColor.withOpacity(0.7),
                  size: 12,
                ),
              ),
              const SizedBox(width: 6),
              // Text content
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w500,
                        color: isSelected ? iconColor : null,
                        fontSize: 10,
                        height: 1.1,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 8,
                        color: isSelected
                            ? iconColor.withOpacity(0.8)
                            : Colors.grey.shade600,
                        height: 1.0,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              // Radio indicator
              Container(
                width: 5,
                height: 5,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected ? iconColor : Colors.transparent,
                  border: Border.all(
                    color: isSelected ? iconColor : Colors.grey.shade400,
                    width: 1,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
