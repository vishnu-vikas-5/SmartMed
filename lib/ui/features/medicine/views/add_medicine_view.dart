import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_models/medicine_view_model.dart';
import '../../auth/view_models/auth_view_model.dart';
import '../../../../data/models/medicine_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';

class AddMedicineView extends StatefulWidget {
  final MedicineModel? existingMedicine;
  final int? presetCompartment;

  const AddMedicineView({
    super.key,
    this.existingMedicine,
    this.presetCompartment,
  });

  @override
  State<AddMedicineView> createState() => _AddMedicineViewState();
}

class _AddMedicineViewState extends State<AddMedicineView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _dosageController = TextEditingController();
  final _quantityController = TextEditingController(text: '1');
  final _instructionsController = TextEditingController();

  TimeOfDay _selectedTime = const TimeOfDay(hour: 8, minute: 0);
  int _selectedCompartment = 1;
  String _selectedFrequency = 'Every day';
  bool _enabled = true;

  @override
  void initState() {
    super.initState();
    if (widget.presetCompartment != null) {
      _selectedCompartment = widget.presetCompartment!;
    }
    if (widget.existingMedicine != null) {
      final med = widget.existingMedicine!;
      _nameController.text = med.name;
      _dosageController.text = med.dosage;
      _quantityController.text = med.quantity.toString();
      _instructionsController.text = med.instructions;
      _selectedCompartment = med.compartment;
      _selectedFrequency = med.frequency;
      _enabled = med.enabled;

      final timeParts = med.time.split(':');
      if (timeParts.length == 2) {
        _selectedTime = TimeOfDay(
          hour: int.tryParse(timeParts[0]) ?? 8,
          minute: int.tryParse(timeParts[1]) ?? 0,
        );
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dosageController.dispose();
    _quantityController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  void _onSave() async {
    if (!_formKey.currentState!.validate()) return;

    final authVm = Provider.of<AuthViewModel>(context, listen: false);
    final medVm = Provider.of<MedicineViewModel>(context, listen: false);
    final userId = authVm.currentUser?.uid ?? '';

    if (userId.isEmpty) return;

    final formattedTime = _formatTimeOfDay(_selectedTime);

    final medicine = MedicineModel(
      medicineId: widget.existingMedicine?.medicineId ?? '',
      name: _nameController.text.trim(),
      dosage: _dosageController.text.trim(),
      quantity: int.tryParse(_quantityController.text.trim()) ?? 1,
      time: formattedTime,
      compartment: _selectedCompartment,
      frequency: _selectedFrequency,
      instructions: _instructionsController.text.trim(),
      enabled: _enabled,
      createdAt: widget.existingMedicine?.createdAt ?? DateTime.now(),
    );

    if (widget.existingMedicine != null) {
      await medVm.updateMedicine(userId, medicine);
    } else {
      await medVm.addMedicine(userId, medicine);
    }

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingMedicine != null;
    final medVm = Provider.of<MedicineViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Medicine' : 'Add Medicine'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomTextField(
                  label: 'Medicine Name',
                  hint: 'e.g. Paracetamol',
                  controller: _nameController,
                  prefixIcon: const Icon(Icons.medication, color: AppColors.primary),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Please enter medicine name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 18),

                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: CustomTextField(
                        label: 'Dosage',
                        hint: 'e.g. 500 mg',
                        controller: _dosageController,
                        prefixIcon: const Icon(Icons.science, color: AppColors.primary),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'Enter dosage';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 1,
                      child: CustomTextField(
                        label: 'Quantity',
                        hint: '1',
                        controller: _quantityController,
                        keyboardType: TextInputType.number,
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'Qty';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // Time Picker
                const Text(
                  'Reminder Time',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                InkWell(
                  onTap: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: _selectedTime,
                    );
                    if (time != null) {
                      setState(() {
                        _selectedTime = time;
                      });
                    }
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.access_time_rounded,
                                color: AppColors.primary),
                            const SizedBox(width: 12),
                            Text(
                              _selectedTime.format(context),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        const Icon(Icons.arrow_drop_down, color: AppColors.textMuted),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                // Compartment Selection (1..4)
                const Text(
                  'Assigned Compartment Number',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: List.generate(4, (index) {
                    final compNum = index + 1;
                    final isSelected = _selectedCompartment == compNum;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedCompartment = compNum;
                          });
                        },
                        child: Container(
                          margin: EdgeInsets.only(right: index == 3 ? 0 : 8),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.primary : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected ? AppColors.primary : AppColors.border,
                              width: 1.5,
                            ),
                          ),
                          child: Column(
                            children: [
                              Text(
                                '💊',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: isSelected ? Colors.white : AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Box $compNum',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected ? Colors.white : AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 18),

                // Frequency Dropdown
                const Text(
                  'Frequency',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  value: _selectedFrequency,
                  decoration: const InputDecoration(),
                  items: ['Every day', 'Specific days', 'Every 12 hours', 'As needed']
                      .map((freq) => DropdownMenuItem(
                            value: freq,
                            child: Text(freq),
                          ))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _selectedFrequency = val;
                      });
                    }
                  },
                ),
                const SizedBox(height: 18),

                CustomTextField(
                  label: 'Instructions',
                  hint: 'e.g. Take after breakfast with water',
                  controller: _instructionsController,
                  prefixIcon: const Icon(Icons.info_outline, color: AppColors.primary),
                ),
                const SizedBox(height: 18),

                // Enable/Disable Reminder Switch
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.notifications_active_outlined,
                              color: AppColors.primary),
                          SizedBox(width: 12),
                          Text(
                            'Enable Alarm & Reminder',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      Switch(
                        value: _enabled,
                        activeColor: AppColors.primary,
                        onChanged: (val) {
                          setState(() {
                            _enabled = val;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                CustomButton(
                  text: isEditing ? 'Update Medicine' : 'Save Medicine Schedule',
                  isLoading: medVm.isLoading,
                  onPressed: _onSave,
                ),

                if (isEditing) ...[
                  const SizedBox(height: 12),
                  CustomButton(
                    text: 'Delete Medicine',
                    isOutlined: true,
                    backgroundColor: AppColors.missed,
                    onPressed: () async {
                      final authVm =
                          Provider.of<AuthViewModel>(context, listen: false);
                      final userId = authVm.currentUser?.uid ?? '';
                      await medVm.deleteMedicine(
                          userId, widget.existingMedicine!.medicineId);
                      if (!mounted) return;
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
