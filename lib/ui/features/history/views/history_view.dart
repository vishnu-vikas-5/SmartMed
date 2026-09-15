import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../medicine/view_models/medicine_view_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/status_badge.dart';

class HistoryView extends StatefulWidget {
  const HistoryView({super.key});

  @override
  State<HistoryView> createState() => _HistoryViewState();
}

class _HistoryViewState extends State<HistoryView> {
  String _selectedFilter = 'All';

  @override
  Widget build(BuildContext context) {
    final medVm = Provider.of<MedicineViewModel>(context);
    final logs = medVm.allLogs;

    final filteredLogs = logs.where((log) {
      if (_selectedFilter == 'Taken') {
        return log.status.name == 'taken';
      } else if (_selectedFilter == 'Missed') {
        return log.status.name == 'missed';
      }
      return true;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Medicine History Logs'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Filter Pills
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: ['All', 'Taken', 'Missed'].map((filter) {
                  final isSelected = _selectedFilter == filter;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(filter),
                      selected: isSelected,
                      selectedColor: AppColors.primary,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _selectedFilter = filter;
                          });
                        }
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
            const Divider(height: 1, color: AppColors.border),

            Expanded(
              child: filteredLogs.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.history_toggle_off,
                              size: 48, color: AppColors.textMuted),
                          const SizedBox(height: 12),
                          Text(
                            'No history logs found',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(20),
                      itemCount: filteredLogs.length,
                      itemBuilder: (context, index) {
                        final log = filteredLogs[index];
                        final dateStr =
                            DateFormat('dd MMM yyyy').format(log.scheduledTime);
                        final timeStr =
                            DateFormat('hh:mm a').format(log.scheduledTime);

                        String takenStr = '';
                        if (log.takenTime != null) {
                          takenStr = 'Taken at ${DateFormat('hh:mm a').format(log.takenTime!)}';
                        }

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppColors.secondary,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    'Box ${log.compartment}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primaryDark,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            log.medicineName,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.textPrimary,
                                            ),
                                          ),
                                          StatusBadge(status: log.status),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '$dateStr at $timeStr',
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                      if (takenStr.isNotEmpty) ...[
                                        const SizedBox(height: 2),
                                        Text(
                                          takenStr,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: AppColors.taken,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
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
    );
  }
}
