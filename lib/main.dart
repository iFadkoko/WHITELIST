import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/hive_service.dart';
import 'providers/task_provider.dart';
import 'screens/home_page.dart';
import 'screens/schedule_page.dart';
import 'screens/focus_mode_page.dart';
import 'screens/stats_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await HiveService.init();
    runApp(const MyApp());
  } catch (e) {
    print('Failed to initialize app: $e');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (context) => TaskProvider())],
      child: MaterialApp(
        title: 'To-Do List App',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
            primary: const Color(0xFF1E88E5),
            secondary: const Color(0xFF64B5F6),
            surface: Colors.white,
            onPrimary: Colors.white,
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF1E88E5),
            foregroundColor: Colors.white,
            elevation: 0,
            centerTitle: true,
          ),
        ),
        home: const SideNavigationWrapper(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class SideNavigationWrapper extends StatefulWidget {
  const SideNavigationWrapper({super.key});

  @override
  State<SideNavigationWrapper> createState() => _SideNavigationWrapperState();
}

class _SideNavigationWrapperState extends State<SideNavigationWrapper> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    HomePage(),
    SchedulePage(),
    FocusModePage(),
    StatsPage(),
  ];

  final List<String> _pageTitles = const [
    'My Tasks',
    'Schedule',
    'Focus Mode',
    'Statistics',
  ];

  final List<Color> _borderColors = const [
    Color(0xFF1E88E5), // Biru untuk Home
    Color(0xFF4CAF50), // Hijau untuk Schedule
    Color(0xFFFFC107), // Kuning untuk Focus
    Color(0xFF9C27B0), // Ungu untuk Stats
  ];

  void _onDestinationSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Navigation Rail dengan tema putih keabuan
          Container(
            width: 180, // Lebar navigation rail 180
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F7), // Warna putih keabuan
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(2, 0),
                ),
              ],
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Column(
              children: [
                // Logo aplikasi
                Padding(
                  padding: const EdgeInsets.only(top: 30.0, bottom: 40.0),
                  child: Column(
                    children: [
                      Icon(Icons.task_alt, size: 32, color: Theme.of(context).colorScheme.primary),
                      const SizedBox(height: 8),
                      const Text(
                        'WHITELIST',
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Navigation Items
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      _buildNavItem(0, Icons.home, 'Home'),
                      _buildNavItem(1, Icons.calendar_today, 'Schedule'),
                      _buildNavItem(2, Icons.timer, 'Focus'),
                      _buildNavItem(3, Icons.bar_chart, 'Stats'),
                    ],
                  ),
                ),
                
                // Tombol Settings
                Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: _buildNavItem(-1, Icons.settings, 'Settings', isSetting: true),
                ),
              ],
            ),
          ),
          
          // Konten utama
          Expanded(
            child: Container(
              color: Colors.grey[50],
              child: Column(
                children: [
                  // AppBar
                  Container(
                    height: kToolbarHeight + 10,
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 243, 241, 241),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(12),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color.fromARGB(255, 255, 253, 253).withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Row(
                        children: [
                          Text(
                            _pageTitles[_selectedIndex],
                            style: const TextStyle(
                              color: Colors.black87,
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  // Body content
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(12),
                        ),
                      ),
                      child: _pages[_selectedIndex],
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

  Widget _buildNavItem(int index, IconData icon, String title, {bool isSetting = false}) {
    bool isSelected = _selectedIndex == index;
    Color borderColor = isSetting ? Colors.grey : _borderColors[index];
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isSelected ? borderColor.withOpacity(0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isSelected ? borderColor : Colors.transparent,
          width: 1.5,
        ),
      ),
      child: ListTile(
        leading: Icon(icon, color: isSelected ? borderColor : Colors.grey[600]),
        title: Text(
          title,
          style: TextStyle(
            color: isSelected ? borderColor : Colors.grey[700],
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        onTap: () {
          if (!isSetting) {
            _onDestinationSelected(index);
          }
          // Tambahkan aksi untuk settings di sini jika diperlukan
        },
        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
        minLeadingWidth: 24,
      ),
    );
  }
}