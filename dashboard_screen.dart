import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:provider/provider.dart';
import 'package:animation_list/animation_list.dart';
import 'package:intl/intl.dart';

import '../services/data_service.dart';
import '../theme/app_theme.dart';
import '../models/student.dart';
import '../models/teacher.dart';
import '../models/course.dart';
import 'student_screen.dart';
import 'teacher_screen.dart';
import 'course_screen.dart';


class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  int _selectedIndex = 0;
  final List<String> _titles = ['Dashboard', 'Students', 'Teachers', 'Courses'];
  final List<Widget> _screens = [];
  
  @override
  void initState() {
    super.initState();
    
    // Initialize animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    
    _animationController.forward();
    
    // Initialize screens
    _screens.addAll([
      const DashboardContent(),
      const StudentScreen(),
      const TeacherScreen(),
      const CourseScreen(),
    ]);
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: IndexedStack(
            index: _selectedIndex,
            children: _screens,
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8),
            child: GNav(
              rippleColor: AppTheme.primaryColor.withOpacity(0.1),
              hoverColor: AppTheme.primaryColor.withOpacity(0.1),
              gap: 8,
              activeColor: Colors.white,
              iconSize: 24,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              duration: const Duration(milliseconds: 400),
              tabBackgroundColor: AppTheme.primaryColor,
              color: Theme.of(context).textTheme.bodyMedium!.color,
              tabs: const [
                GButton(
                  icon: Icons.dashboard_rounded,
                  text: 'Dashboard',
                ),
                GButton(
                  icon: Icons.school_rounded,
                  text: 'Students',
                ),
                GButton(
                  icon: Icons.person_rounded,
                  text: 'Teachers',
                ),
                GButton(
                  icon: Icons.book_rounded,
                  text: 'Courses',
                ),
              ],
              selectedIndex: _selectedIndex,
              onTabChange: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
            ),
          ),
        ),
      ),
    );
  }
}

class DashboardContent extends StatefulWidget {
  const DashboardContent({Key? key}) : super(key: key);

  @override
  State<DashboardContent> createState() => _DashboardContentState();
}

class _DashboardContentState extends State<DashboardContent> {
  bool _isLoading = true;
  int _studentCount = 0;
  int _teacherCount = 0;
  int _courseCount = 0;
  List<dynamic> _recentActivity = [];
  
  @override
  void initState() {
    super.initState();
    _loadData();
  }
  
  Future<void> _loadData() async {
    final dataService = Provider.of<DataService>(context, listen: false);
    
    // Simulate network delay for loading animation
    await Future.delayed(const Duration(milliseconds: 1000));
    
    final students = await dataService.getStudents();
    final teachers = await dataService.getTeachers();
    final courses = await dataService.getCourses();
    
    // Create sample activity feed
    final recentActivity = [
      {'type': 'student', 'action': 'added', 'data': students.isNotEmpty ? students.first : null, 'time': DateTime.now().subtract(const Duration(minutes: 30))},
      {'type': 'course', 'action': 'updated', 'data': courses.isNotEmpty ? courses.first : null, 'time': DateTime.now().subtract(const Duration(hours: 2))},
      {'type': 'teacher', 'action': 'added', 'data': teachers.isNotEmpty ? teachers.first : null, 'time': DateTime.now().subtract(const Duration(hours: 4))},
      {'type': 'student', 'action': 'removed', 'data': students.length > 1 ? students[1] : null, 'time': DateTime.now().subtract(const Duration(days: 1))},
      {'type': 'course', 'action': 'added', 'data': courses.length > 1 ? courses[1] : null, 'time': DateTime.now().subtract(const Duration(days: 2))},
    ];
    
    setState(() {
      _studentCount = students.length;
      _teacherCount = teachers.length;
      _courseCount = courses.length;
      _recentActivity = recentActivity;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return _isLoading
      ? const Center(child: CircularProgressIndicator())
      : SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with school logo and name
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: const Icon(
                                Icons.local_florist,
                                color: AppTheme.primaryColor,
                                size: 30,
                              ),
                            ),
                            const SizedBox(width: 15),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'La Pépinière',
                                  style: theme.textTheme.headlineSmall?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'School Management System',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: Colors.white.withOpacity(0.8),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 30),
                        Text(
                          'Welcome back, Admin!',
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          DateFormat('EEEE, MMMM d, yyyy').format(DateTime.now()),
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
              
              // Quick Stats Cards
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Quick Statistics',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        // Students Card
                        Expanded(
                          child: _buildStatCard(
                            title: 'Students',
                            count: _studentCount,
                            icon: Icons.school_rounded,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                        const SizedBox(width: 15),
                        // Teachers Card
                        Expanded(
                          child: _buildStatCard(
                            title: 'Teachers',
                            count: _teacherCount,
                            icon: Icons.person_rounded,
                            color: AppTheme.secondaryColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        // Courses Card
                        Expanded(
                          child: _buildStatCard(
                            title: 'Courses',
                            count: _courseCount,
                            icon: Icons.book_rounded,
                            color: AppTheme.accentColor,
                          ),
                        ),
                        const SizedBox(width: 15),
                        // Attendance Card
                        Expanded(
                          child: _buildStatCard(
                            title: 'Attendance',
                            count: 92,
                            suffix: '%',
                            icon: Icons.event_available_rounded,
                            color: AppTheme.info,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Attendance Chart
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Monthly Attendance',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          height: 200,
                          child: BarChart(
                            BarChartData(
                              alignment: BarChartAlignment.spaceAround,
                              maxY: 100,
                              minY: 0,
                              groupsSpace: 12,
                              barTouchData: BarTouchData(
                                enabled: true,
                                touchTooltipData: BarTouchTooltipData(
                                  tooltipPadding: const EdgeInsets.all(8),
                                  tooltipMargin: 8,
                                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                                    final month = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'];
                                    return BarTooltipItem(
                                      '${month[groupIndex]}\n${rod.toY.round()}%',
                                      theme.textTheme.bodyMedium!,
                                    );
                                  },
                                ),
                              ),
                              titlesData: FlTitlesData(
                                show: true,
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    getTitlesWidget: (value, meta) {
                                      final month = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'];
                                      return SideTitleWidget(
                                        axisSide: meta.axisSide,
                                        space: 4,
                                        child: Text(
                                          month[value.toInt()],
                                          style: theme.textTheme.bodySmall,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                leftTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    interval: 20,
                                    getTitlesWidget: (value, meta) {
                                      return SideTitleWidget(
                                        axisSide: meta.axisSide,
                                        space: 0,
                                        child: Text(
                                          '${value.toInt()}%',
                                          style: theme.textTheme.bodySmall,
                                        ),
                                      );
                                    },
                                    reservedSize: 40,
                                  ),
                                ),
                                topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              ),
                              gridData: FlGridData(
                                show: true,
                                horizontalInterval: 20,
                                getDrawingHorizontalLine: (value) {
                                  return FlLine(
                                    color: theme.dividerTheme.color?.withOpacity(0.2) ?? Colors.grey.withOpacity(0.2),
                                    strokeWidth: 1,
                                  );
                                },
                                drawVerticalLine: false,
                              ),
                              borderData: FlBorderData(show: false),
                              barGroups: [
                                _buildBarGroup(0, 89, AppTheme.primaryColor),
                                _buildBarGroup(1, 92, AppTheme.primaryColor),
                                _buildBarGroup(2, 95, AppTheme.primaryColor),
                                _buildBarGroup(3, 88, AppTheme.primaryColor),
                                _buildBarGroup(4, 91, AppTheme.primaryColor),
                                _buildBarGroup(5, 93, AppTheme.primaryColor),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              
              // Recent Activity Section
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Recent Activity',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 15),
                    SizedBox(
                      height: 300,
                      child: AnimationList(
                        duration: 1000,
                        reBounceDepth: 15.0,
                        children: _recentActivity.map((activity) {
                          return _buildActivityItem(activity);
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 20),
            ],
          ),
        );
  }
  
  Widget _buildStatCard({
    required String title,
    required int count,
    String? suffix,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 20,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            Text(
              '${count}${suffix ?? ''}',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  BarChartGroupData _buildBarGroup(int x, double y, Color color) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: color,
          width: 20,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(6),
          ),
          backDrawRodData: BackgroundBarChartRodData(
            show: true,
            toY: 100,
            color: color.withOpacity(0.1),
          ),
        ),
      ],
    );
  }
  
  Widget _buildActivityItem(Map<String, dynamic> activity) {
    final theme = Theme.of(context);
    final time = activity['time'] as DateTime;
    final timeAgo = _getTimeAgo(time);
    
    // Define color and icon based on activity type
    IconData icon;
    Color color;
    String message;
    
    switch(activity['type']) {
      case 'student':
        icon = Icons.school_rounded;
        color = AppTheme.primaryColor;
        break;
      case 'teacher':
        icon = Icons.person_rounded;
        color = AppTheme.secondaryColor;
        break;
      case 'course':
        icon = Icons.book_rounded;
        color = AppTheme.accentColor;
        break;
      default:
        icon = Icons.info_rounded;
        color = AppTheme.info;
    }
    
    // Generate message
    switch(activity['action']) {
      case 'added':
        message = 'New ${activity['type']} added';
        break;
      case 'updated':
        message = '${activity['type'].substring(0, 1).toUpperCase() + activity['type'].substring(1)} updated';
        break;
      case 'removed':
        message = '${activity['type'].substring(0, 1).toUpperCase() + activity['type'].substring(1)} removed';
        break;
      default:
        message = 'Activity with ${activity['type']}';
    }
    
    // Get name if available
    String? name;
    if (activity['data'] != null) {
      if (activity['type'] == 'student' || activity['type'] == 'teacher') {
        name = activity['data'].fullName;
      } else if (activity['type'] == 'course') {
        name = activity['data'].name;
      }
    }
    
    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: theme.cardTheme.color?.withOpacity(0.7),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (name != null)
                    Text(
                      name,
                      style: theme.textTheme.bodyMedium,
                    ),
                  Text(
                    timeAgo,
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  String _getTimeAgo(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);
    
    if (difference.inDays > 0) {
      return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
    } else {
      return 'Just now';
    }
  }
}
