import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_models/home_view_model.dart';
import '../../auth/view_models/auth_view_model.dart';
import '../../medicine/view_models/medicine_view_model.dart';
import '../../device/view_models/device_view_model.dart';
import 'dashboard_view.dart';
import '../../medicine/views/schedule_view.dart';
import '../../history/views/history_view.dart';
import '../../device/views/my_device_view.dart';
import '../../settings/views/settings_view.dart';
import '../../../core/theme/app_colors.dart';

class MainLayoutView extends StatefulWidget {
  const MainLayoutView({super.key});

  @override
  State<MainLayoutView> createState() => _MainLayoutViewState();
}

class _MainLayoutViewState extends State<MainLayoutView> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authVm = Provider.of<AuthViewModel>(context, listen: false);
      final homeVm = Provider.of<HomeViewModel>(context, listen: false);
      final medicineVm = Provider.of<MedicineViewModel>(context, listen: false);
      final deviceVm = Provider.of<DeviceViewModel>(context, listen: false);

      final userId = authVm.currentUser?.uid ?? '';
      const deviceId = 'SM-ESP32-001';

      if (userId.isNotEmpty) {
        homeVm.init(userId, deviceId: deviceId);
        medicineVm.init(userId, deviceId: deviceId);
        deviceVm.init(userId, deviceId: deviceId);
      }
    });
  }

  final List<Widget> _pages = const [
    DashboardView(),
    ScheduleView(),
    HistoryView(),
    MyDeviceView(),
    SettingsView(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: AppColors.border, width: 1)),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textMuted,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined),
              activeIcon: Icon(Icons.dashboard_rounded),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today_outlined),
              activeIcon: Icon(Icons.calendar_today_rounded),
              label: 'Schedule',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history_outlined),
              activeIcon: Icon(Icons.history_rounded),
              label: 'History',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.devices_outlined),
              activeIcon: Icon(Icons.devices_rounded),
              label: 'Device',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings_outlined),
              activeIcon: Icon(Icons.settings_rounded),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}
