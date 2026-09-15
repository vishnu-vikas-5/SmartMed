import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_models/medicine_view_model.dart';
import 'add_medicine_view.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/medicine_card.dart';

class ScheduleView extends StatelessWidget {
  const ScheduleView({super.key});

  @override
  Widget build(BuildContext context) {
    final medVm = Provider.of<MedicineViewModel>(context);
    final medicines = medVm.medicines;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Today's Medicine Schedule"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: AppColors.primary),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const AddMedicineView()),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: medicines.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: const BoxDecoration(
                        color: AppColors.secondary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.medication_liquid_outlined,
                        size: 56,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'No Medicine Schedules Added',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Tap + to add your first medicine reminder',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: medicines.length,
                itemBuilder: (context, index) {
                  final medicine = medicines[index];
                  final log = medVm.getLogForMedicine(medicine.medicineId);

                  return MedicineCard(
                    medicine: medicine,
                    log: log,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => AddMedicineView(
                            existingMedicine: medicine,
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
      ),
    );
  }
}
