import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/constants/post_media_type.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../providers/auth_provider.dart';
import '../../providers/create_post_provider.dart';
import '../../widgets/common/primary_button.dart';
import 'package:intl/intl.dart';

/// Scheduling screen — separated into WHEN and REPEAT logic with a preview.
class SchedulePostScreen extends StatefulWidget {
  const SchedulePostScreen({super.key});

  @override
  State<SchedulePostScreen> createState() => _SchedulePostScreenState();
}

class _SchedulePostScreenState extends State<SchedulePostScreen> {
  bool _submitting = false;

  // Recurrence state
  String _repeatType = 'once';
  final List<int> _repeatDays = [];
  String _endsType = 'never';
  DateTime? _endsDate;
  int _endsCount = 10;

  DateTime get _selectedTime {
    final draft = context.read<CreatePostProvider>();
    return draft.scheduledTime ?? DateTime.now().add(const Duration(hours: 1));
  }

  Future<void> _pickDateTime() async {
    final draft = context.read<CreatePostProvider>();
    final now = DateTime.now();

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedTime,
      firstDate: now,
      lastDate: now.add(const Duration(days: 730)),
    );
    if (pickedDate == null) return;

    if (!mounted) return;
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedTime),
    );
    if (pickedTime == null) return;

    final finalDateTime = DateTime(
      pickedDate.year, pickedDate.month, pickedDate.day,
      pickedTime.hour, pickedTime.minute,
    );

    draft.setScheduledTime(finalDateTime);
    setState(() {});
  }

  Map<String, dynamic>? _buildRecurrenceRule() {
    if (_repeatType == 'once') return null;

    final rule = <String, dynamic>{
      'interval': 1,
      'end': <String, dynamic>{
        'type': _endsType,
        if (_endsType == 'date' && _endsDate != null)
          'date': _endsDate!.toUtc().toIso8601String(),
        if (_endsType == 'count')
          'count': _endsCount,
      },
    };

    switch (_repeatType) {
      case 'daily':
        rule['type'] = 'daily';
        break;
      case 'weekly':
        rule['type'] = 'weekly';
        const dayNames = ['', 'mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun'];
        rule['days'] = _repeatDays.map((i) => dayNames[i]).toList();
        break;
      case 'monthly':
        rule['type'] = 'monthly';
        rule['dayOfMonth'] = _selectedTime.day;
        break;
      default:
        return null;
    }

    return rule;
  }

  void _openRepeatEditor() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(builder: (context, setModalState) {
          return Padding(
            padding: EdgeInsets.only(
              left: 24,
              right: 24,
              top: 24,
              bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                Text('Repeat this schedule', style: AppTextStyles.titleMedium),
                const SizedBox(height: 24),

                DropdownButtonFormField<String>(
                  initialValue: _repeatType,
                  decoration: const InputDecoration(labelText: 'Repeat'),
                  items: const [
                    DropdownMenuItem(value: 'once', child: Text('Does not repeat')),
                    DropdownMenuItem(value: 'daily', child: Text('Every day')),
                    DropdownMenuItem(value: 'weekly', child: Text('Every week')),
                    DropdownMenuItem(value: 'monthly', child: Text('Every month')),
                  ],
                  onChanged: (v) => setModalState(() => _repeatType = v!),
                ),
                const SizedBox(height: 16),

                if (_repeatType == 'weekly') ...[
                  Text('Repeat on', style: AppTextStyles.sectionHeader),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: ['M', 'T', 'W', 'T', 'F', 'S', 'S']
                        .asMap()
                        .entries
                        .map((entry) {
                      final dayIndex = entry.key + 1;
                      final isSelected = _repeatDays.contains(dayIndex);
                      return FilterChip(
                        label: Text(entry.value),
                        selected: isSelected,
                        onSelected: (selected) {
                          setModalState(() {
                            if (selected) {
                              _repeatDays.add(dayIndex);
                            } else {
                              _repeatDays.remove(dayIndex);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                ],

                if (_repeatType != 'once') ...[
                  const Divider(),
                  const SizedBox(height: 16),
                  Text('Ends', style: AppTextStyles.sectionHeader),
                  RadioGroup<String>(
                    groupValue: _endsType,
                    onChanged: (v) {
                      if (v == null) return;
                      if (v == 'date') {
                        showDatePicker(
                          context: context,
                          initialDate: _endsDate ?? DateTime.now().add(const Duration(days: 30)),
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
                        ).then((picked) {
                          if (picked != null && mounted) {
                            setModalState(() {
                              _endsType = 'date';
                              _endsDate = picked;
                            });
                          }
                        });
                      } else {
                        setModalState(() => _endsType = v);
                      }
                    },
                    child: Column(
                      children: const [
                        RadioListTile<String>(
                          title: Text('Never'),
                          value: 'never',
                        ),
                        RadioListTile<String>(
                          title: Text('On a date'),
                          value: 'date',
                        ),
                        RadioListTile<String>(
                          title: Text('After a number of times'),
                          value: 'count',
                        ),
                      ],
                    ),
                  ),
                  if (_endsType == 'count')
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          const Text('Times: '),
                          SizedBox(
                            width: 60,
                            child: TextFormField(
                              initialValue: '$_endsCount',
                              keyboardType: TextInputType.number,
                              onChanged: (v) {
                                final n = int.tryParse(v);
                                if (n != null && n > 0) setModalState(() => _endsCount = n);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                ],

                const SizedBox(height: 24),
                PrimaryButton(
                  label: 'Save',
                  onPressed: () {
                    setState(() {});
                    Navigator.pop(context);
                  },
                ),
              ],
              ),
            ),
          );
        });
      },
    );
  }

  String _getRepeatSummary() {
    if (_repeatType == 'once') return 'Does not repeat';
    if (_repeatType == 'daily') return 'Every day';
    if (_repeatType == 'weekly') {
      if (_repeatDays.isEmpty) return 'Every week';
      const dayNames = {1: 'Mon', 2: 'Tue', 3: 'Wed', 4: 'Thu', 5: 'Fri', 6: 'Sat', 7: 'Sun'};
      final selected = _repeatDays.map((d) => dayNames[d] ?? '').join(', ');
      return 'Every week on $selected';
    }
    if (_repeatType == 'monthly') return 'Every month';
    return '';
  }

  String _getEndsSummary() {
    if (_repeatType == 'once') return '';
    if (_endsType == 'never') return 'Never ends';
    if (_endsType == 'date' && _endsDate != null) {
      return 'Ends ${DateFormat('MMM dd, yyyy').format(_endsDate!)}';
    }
    if (_endsType == 'count') return 'Ends after $_endsCount times';
    return '';
  }

  Future<void> _schedule() async {
    final draft = context.read<CreatePostProvider>();
    if (_selectedTime.isBefore(DateTime.now())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Weka muda wa baadaye')),
      );
      return;
    }
    setState(() => _submitting = true);

    final rule = _buildRecurrenceRule();

    try {
      final messenger = ScaffoldMessenger.of(context);
      final router = GoRouter.of(context);
      await draft.submit(
        businessId: context.read<AuthProvider>().businessId,
        recurrenceRule: rule,
      );
      if (!mounted) return;
      await draft.releaseAutoDraft();
      draft.reset();
      messenger.showSnackBar(
        const SnackBar(content: Text('Post imepangwa ✓')),
      );
      router.go('/queue');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Kosa: $e')),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

   Widget _buildPreviewBox() {
    final draft = context.watch<CreatePostProvider>();
    Widget previewImage;

    if (draft.mediaType == PostMediaType.text) {
      Color bgColor = AppColors.primary;
      if (draft.backgroundColor != null && draft.backgroundColor!.length == 7) {
        bgColor = Color(int.parse(draft.backgroundColor!.substring(1, 7), radix: 16) + 0xFF000000);
      }
      previewImage = Container(
        color: bgColor,
        padding: const EdgeInsets.all(8),
        child: Center(
          child: Text(
            draft.caption.isNotEmpty ? draft.caption : 'T',
            style: const TextStyle(color: Colors.white, fontSize: 12),
            textAlign: TextAlign.center,
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      );
    } else if (draft.mediaType == PostMediaType.image) {
      final bytes = draft.imageBytes ?? (draft.multiImages.isNotEmpty ? draft.multiImages.first.bytes : null);
      if (bytes != null) {
        try {
          previewImage = Image.memory(bytes, fit: BoxFit.cover);
        } catch (_) {
          previewImage = Icon(Icons.image, size: 40, color: AppColors.textSecondary);
        }
      } else {
        previewImage = Icon(Icons.image, size: 40, color: AppColors.textSecondary);
      }
} else if (draft.mediaType == PostMediaType.video) {
      if (draft.thumbnailBytes != null) {
        try {
          previewImage = Image.memory(draft.thumbnailBytes!, fit: BoxFit.cover);
        } catch (_) {
          previewImage = Icon(Icons.videocam, size: 40, color: AppColors.textSecondary);
        }
      } else {
        previewImage = Icon(Icons.videocam, size: 40, color: AppColors.textSecondary);
      }
    } else {
      previewImage = Icon(Icons.image, size: 40, color: AppColors.textSecondary);
    }

    return Container(
      height: 120,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 100,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
              color: AppColors.background,
            ),
            clipBehavior: Clip.hardEdge,
            child: previewImage,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   Text('Post Preview', style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
                   const SizedBox(height: 8),
                   Text(draft.mediaType.name.toUpperCase(), style: AppTextStyles.bodyMedium),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('EEE, MMM dd');
    final timeFormat = DateFormat('hh:mm a');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Schedule Post'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => GoRouter.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildPreviewBox(),
              const SizedBox(height: 32),

              Text('Schedule', style: AppTextStyles.sectionHeader),
              const SizedBox(height: 16),

              InkWell(
                onTap: _pickDateTime,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(dateFormat.format(_selectedTime), style: AppTextStyles.titleMedium),
                          const SizedBox(height: 4),
                          Text(
                            timeFormat.format(_selectedTime),
                            style: AppTextStyles.displayLarge.copyWith(color: AppColors.primary),
                          ),
                        ],
                      ),
                      Icon(Icons.edit_calendar, color: AppColors.textSecondary),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              InkWell(
                onTap: _openRepeatEditor,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Repeats', style: AppTextStyles.caption),
                          const SizedBox(height: 4),
                          Text(_getRepeatSummary(), style: AppTextStyles.titleMedium),
                        ],
                      ),
                      Icon(Icons.repeat, color: AppColors.textSecondary),
                    ],
                  ),
                ),
              ),

              if (_repeatType != 'once') ...[
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Schedule Summary',
                        style: AppTextStyles.sectionHeader.copyWith(color: AppColors.primary),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'First post: ${DateFormat('MMM dd, hh:mm a').format(_selectedTime)}',
                        style: AppTextStyles.caption,
                      ),
                      const SizedBox(height: 4),
                      Text('Repeats: ${_getRepeatSummary()}', style: AppTextStyles.caption),
                      const SizedBox(height: 4),
                      Text('Ends: ${_getEndsSummary()}', style: AppTextStyles.caption),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: SizedBox(
            height: 52,
            width: double.infinity,
            child: PrimaryButton(
              label: 'PANGA',
              onPressed: _submitting ? null : _schedule,
              loading: _submitting,
            ),
          ),
        ),
      ),
    );
  }
}
