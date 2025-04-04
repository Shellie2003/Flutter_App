import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/course.dart';
import '../models/teacher.dart';
import '../services/data_service.dart';
import '../theme/app_theme.dart';


class CourseScreen extends StatefulWidget {
  const CourseScreen({Key? key}) : super(key: key);

  @override
  State<CourseScreen> createState() => _CourseScreenState();
}

class _CourseScreenState extends State<CourseScreen> with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  List<Course> _courses = [];
  List<Course> _filteredCourses = [];
  List<Teacher> _teachers = [];
  Map<String, String> _teacherNames = {};
  
  String _searchQuery = '';
  String _selectedGradeLevel = 'All';
  String _selectedCourseType = 'All';
  
  late AnimationController _animationController;
  final List<String> _gradeLevels = ['All', '5', '6', '7', '8', '9', '10', '11', '12'];
  final List<String> _courseTypes = ['All', 'Core', 'Elective', 'Enrichment'];
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _loadData();
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final dataService = Provider.of<DataService>(context, listen: false);
      final courses = await dataService.getCourses();
      final teachers = await dataService.getTeachers();
      
      // Create a map of teacher IDs to names for quick lookup
      final teacherNamesMap = <String, String>{};
      for (final teacher in teachers) {
        teacherNamesMap[teacher.id] = teacher.fullName;
      }
      
      setState(() {
        _courses = courses;
        _teachers = teachers;
        _teacherNames = teacherNamesMap;
        _applyFilters();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar('Failed to load data');
    }
  }
  
  void _applyFilters() {
    setState(() {
      _filteredCourses = _courses.where((course) {
        // Apply search filter
        final matchesSearch = course.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            course.code.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            course.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            (_teacherNames[course.teacherId]?.toLowerCase() ?? '').contains(_searchQuery.toLowerCase());
        
        // Apply grade level filter
        final matchesGradeLevel = _selectedGradeLevel == 'All' || 
            course.gradeLevel.contains(_selectedGradeLevel);
        
        // Apply course type filter
        final matchesCourseType = _selectedCourseType == 'All' || 
            course.courseType == _selectedCourseType;
        
        return matchesSearch && matchesGradeLevel && matchesCourseType;
      }).toList();
    });
  }
  
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
  
  Future<void> _showCourseDetails(Course course) async {
    // Show course details in a modal bottom sheet
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CourseDetailsBottomSheet(
        course: course,
        teacherName: _teacherNames[course.teacherId] ?? 'Unknown Teacher',
      ),
    );
  }
  
  Future<void> _showAddEditCourseDialog(Course? course) async {
    // Show dialog to add or edit course
    // If course is null, it's an add operation, otherwise it's an edit
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AddEditCourseDialog(
        course: course,
        teachers: _teachers,
      ),
    );
    
    if (result == true) {
      // Reload courses if changes were made
      _loadData();
    }
  }
  
  Future<void> _confirmDeleteCourse(Course course) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text('Are you sure you want to delete ${course.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: AppTheme.error),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    
    if (result == true) {
      try {
        final dataService = Provider.of<DataService>(context, listen: false);
        await dataService.deleteCourse(course.id);
        _loadData();
        
        // Show success message
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Course deleted successfully'),
            backgroundColor: AppTheme.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } catch (e) {
        _showErrorSnackBar('Failed to delete course');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Courses',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Manage course records',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).textTheme.bodySmall?.color,
                        ),
                      ),
                    ],
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _showAddEditCourseDialog(null),
                    icon: const Icon(Icons.add),
                    label: const Text('Add Course'),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: AppTheme.accentColor,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                ],
              ),
            ),
            
            // Search and Filter
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                children: [
                  // Search bar
                  TextField(
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                        _applyFilters();
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Search courses...',
                      prefixIcon: const Icon(Icons.search, color: AppTheme.accentColor),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      fillColor: Theme.of(context).cardTheme.color,
                      filled: true,
                    ),
                  ),
                  const SizedBox(height: 15),
                  
                  // Filter options
                  Row(
                    children: [
                      // Grade Level filter
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _selectedGradeLevel,
                          decoration: InputDecoration(
                            labelText: 'Grade Level',
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            fillColor: Theme.of(context).cardTheme.color,
                            filled: true,
                          ),
                          items: _gradeLevels.map((grade) => DropdownMenuItem(
                            value: grade,
                            child: Text(grade),
                          )).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                _selectedGradeLevel = value;
                                _applyFilters();
                              });
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 15),
                      
                      // Course Type filter
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _selectedCourseType,
                          decoration: InputDecoration(
                            labelText: 'Course Type',
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            fillColor: Theme.of(context).cardTheme.color,
                            filled: true,
                          ),
                          items: _courseTypes.map((type) => DropdownMenuItem(
                            value: type,
                            child: Text(type),
                          )).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                _selectedCourseType = value;
                                _applyFilters();
                              });
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 15),
            
            // Course list
            Expanded(
              child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredCourses.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 64,
                            color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.5),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No courses found',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Theme.of(context).textTheme.bodySmall?.color,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextButton.icon(
                            onPressed: _loadData,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Refresh'),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      physics: const BouncingScrollPhysics(),
                      itemCount: _filteredCourses.length,
                      itemBuilder: (context, index) {
                        final course = _filteredCourses[index];
                        return _buildCourseCard(course, index);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildCourseCard(Course course, int index) {
    final teacherName = _teacherNames[course.teacherId] ?? 'Unknown Teacher';
    
    // Determine card accent color based on course type
    Color accentColor;
    switch (course.courseType) {
      case 'Core':
        accentColor = AppTheme.accentColor;
        break;
      case 'Elective':
        accentColor = AppTheme.secondaryColor;
        break;
      case 'Enrichment':
        accentColor = AppTheme.primaryColor;
        break;
      default:
        accentColor = AppTheme.info;
    }
    
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0.0, end: 1.0),
          duration: Duration(milliseconds: 400 + (index * 100)),
          curve: Curves.easeInOut,
          builder: (context, value, child) {
            return Transform.translate(
              offset: Offset(0, 50 * (1 - value)),
              child: Opacity(
                opacity: value,
                child: child,
              ),
            );
          },
          child: Card(
            margin: const EdgeInsets.only(bottom: 16),
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: InkWell(
              onTap: () => _showCourseDetails(course),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: accentColor.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Course header with code and type
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: accentColor.withOpacity(0.1),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: accentColor.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.book,
                                  color: accentColor,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                course.code,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: accentColor,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: accentColor.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              course.courseType,
                              style: TextStyle(
                                color: accentColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Course info
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            course.name,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            course.description,
                            style: Theme.of(context).textTheme.bodyMedium,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 16),
                          
                          // Course details
                          Row(
                            children: [
                              _buildDetailChip(
                                icon: Icons.person,
                                label: teacherName,
                                color: AppTheme.secondaryColor,
                              ),
                              const SizedBox(width: 8),
                              _buildDetailChip(
                                icon: Icons.groups,
                                label: 'Grades: ${course.gradeLevel.join(', ')}',
                                color: AppTheme.primaryColor,
                              ),
                              const SizedBox(width: 8),
                              _buildDetailChip(
                                icon: Icons.star,
                                label: '${course.credits} credits',
                                color: AppTheme.accentColor,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    
                    // Action buttons
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            onPressed: () => _showCourseDetails(course),
                            icon: const Icon(Icons.visibility),
                            tooltip: 'View Details',
                            color: Theme.of(context).textTheme.bodySmall?.color,
                          ),
                          IconButton(
                            onPressed: () => _showAddEditCourseDialog(course),
                            icon: const Icon(Icons.edit),
                            tooltip: 'Edit',
                            color: Theme.of(context).textTheme.bodySmall?.color,
                          ),
                          IconButton(
                            onPressed: () => _confirmDeleteCourse(course),
                            icon: const Icon(Icons.delete),
                            tooltip: 'Delete',
                            color: AppTheme.error,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildDetailChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CourseDetailsBottomSheet extends StatelessWidget {
  final Course course;
  final String teacherName;
  
  const CourseDetailsBottomSheet({
    Key? key,
    required this.course,
    required this.teacherName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Determine accent color based on course type
    Color accentColor;
    switch (course.courseType) {
      case 'Core':
        accentColor = AppTheme.accentColor;
        break;
      case 'Elective':
        accentColor = AppTheme.secondaryColor;
        break;
      case 'Enrichment':
        accentColor = AppTheme.primaryColor;
        break;
      default:
        accentColor = AppTheme.info;
    }
    
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with course name and close button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Course Details',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).dividerTheme.color?.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.close),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Course header
          Row(
            children: [
              // Course icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Icon(
                    Icons.book,
                    color: accentColor,
                    size: 40,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              
              // Basic course info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      course.name,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Course Code: ${course.code}',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: accentColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        course.courseType,
                        style: TextStyle(
                          color: accentColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Course details
          Flexible(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle(context, 'Course Description', accentColor),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      course.description,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  
                  _buildSectionTitle(context, 'Course Information', accentColor),
                  _buildDetailItem(context, 'Instructor', teacherName),
                  _buildDetailItem(context, 'Credits', '${course.credits}'),
                  _buildDetailItem(context, 'Grade Levels', course.gradeLevel.join(', ')),
                  _buildDetailItem(context, 'Sections', course.sections.join(', ')),
                  
                  // Display syllabus if available
                  if (course.syllabus.isNotEmpty) ...[  
                    _buildSectionTitle(context, 'Syllabus', accentColor),
                    ..._buildSyllabus(context, course.syllabus),
                  ],
                  
                  // Additional info if any
                  if (course.additionalInfo.isNotEmpty) ...[  
                    _buildSectionTitle(context, 'Additional Information', accentColor),
                    ...course.additionalInfo.entries.map(
                      (entry) => _buildDetailItem(context, entry.key, entry.value.toString()),
                    ),
                  ],
                  
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSectionTitle(BuildContext context, String title, Color accentColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: accentColor,
            ),
          ),
          const Divider(),
        ],
      ),
    );
  }
  
  Widget _buildDetailItem(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
  
  List<Widget> _buildSyllabus(BuildContext context, Map<String, dynamic> syllabus) {
    final List<Widget> result = [];
    
    if (syllabus.containsKey('units')) {
      final units = syllabus['units'] as List;
      for (int i = 0; i < units.length; i++) {
        final unit = units[i] as Map<String, dynamic>;
        result.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Unit title
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardTheme.color,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.bookmark, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'Unit ${i + 1}: ${unit['title']}',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                
                // Topics
                if (unit.containsKey('topics')) ...[  
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Topics:',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        ...(unit['topics'] as List).map((topic) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.circle, size: 8),
                              const SizedBox(width: 8),
                              Expanded(child: Text(topic.toString())),
                            ],
                          ),
                        )),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      }
    }
    
    return result;
  }
}

class AddEditCourseDialog extends StatefulWidget {
  final Course? course;
  final List<Teacher> teachers;
  
  const AddEditCourseDialog({
    Key? key,
    this.course,
    required this.teachers,
  }) : super(key: key);

  @override
  State<AddEditCourseDialog> createState() => _AddEditCourseDialogState();
}

class _AddEditCourseDialogState extends State<AddEditCourseDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _codeController;
  late TextEditingController _descriptionController;
  
  String _selectedTeacherId = '';
  List<String> _selectedGradeLevels = ['6'];
  List<String> _selectedSections = ['A'];
  String _selectedCourseType = 'Core';
  int _credits = 3;
  
  final List<String> _allGradeLevels = ['5', '6', '7', '8', '9', '10', '11', '12'];
  final List<String> _allSections = ['A', 'B', 'C', 'D'];
  final List<String> _courseTypes = ['Core', 'Elective', 'Enrichment'];
  
  bool _isLoading = false;
  
  @override
  void initState() {
    super.initState();
    
    // Initialize controllers with course data if editing
    final course = widget.course;
    _nameController = TextEditingController(text: course?.name ?? '');
    _codeController = TextEditingController(text: course?.code ?? '');
    _descriptionController = TextEditingController(text: course?.description ?? '');
    
    if (course != null) {
      _selectedTeacherId = course.teacherId;
      _selectedGradeLevels = List.from(course.gradeLevel);
      _selectedSections = List.from(course.sections);
      _selectedCourseType = course.courseType;
      _credits = course.credits;
    } else if (widget.teachers.isNotEmpty) {
      // Default to first teacher if creating new course
      _selectedTeacherId = widget.teachers.first.id;
    }
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
  
  void _toggleGradeLevel(String grade) {
    setState(() {
      if (_selectedGradeLevels.contains(grade)) {
        _selectedGradeLevels.remove(grade);
      } else {
        _selectedGradeLevels.add(grade);
      }
    });
  }
  
  void _toggleSection(String section) {
    setState(() {
      if (_selectedSections.contains(section)) {
        _selectedSections.remove(section);
      } else {
        _selectedSections.add(section);
      }
    });
  }
  
  Future<void> _saveCourse() async {
    if (_formKey.currentState!.validate()) {
      // Validate that at least one grade level and section is selected
      if (_selectedGradeLevels.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select at least one grade level'),
            backgroundColor: AppTheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }
      
      if (_selectedSections.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select at least one section'),
            backgroundColor: AppTheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }
      
      setState(() {
        _isLoading = true;
      });
      
      try {
        final dataService = Provider.of<DataService>(context, listen: false);
        
        // Create default syllabus structure if new course
        Map<String, dynamic> syllabus = widget.course?.syllabus ?? {
          'units': [
            {
              'title': 'Introduction',
              'topics': ['Overview', 'Key Concepts', 'Learning Objectives']
            },
          ]
        };
        
        final course = Course(
          id: widget.course?.id,
          name: _nameController.text,
          code: _codeController.text,
          description: _descriptionController.text,
          teacherId: _selectedTeacherId,
          gradeLevel: _selectedGradeLevels,
          sections: _selectedSections,
          credits: _credits,
          courseType: _selectedCourseType,
          syllabus: syllabus,
          additionalInfo: widget.course?.additionalInfo ?? {},
        );
        
        if (widget.course == null) {
          // Add new course
          await dataService.addCourse(course);
        } else {
          // Update existing course
          await dataService.updateCourse(course);
        }
        
        if (!mounted) return;
        Navigator.pop(context, true); // Pop with success result
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppTheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.course != null;
    final title = isEditing ? 'Edit Course' : 'Add New Course';
    
    Color accentColor;
    switch (_selectedCourseType) {
      case 'Core':
        accentColor = AppTheme.accentColor;
        break;
      case 'Elective':
        accentColor = AppTheme.secondaryColor;
        break;
      case 'Enrichment':
        accentColor = AppTheme.primaryColor;
        break;
      default:
        accentColor = AppTheme.info;
    }
    
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 500),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Dialog header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                      splashRadius: 24,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Basic Course Information
                Text(
                  'Basic Information',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: accentColor,
                  ),
                ),
                const Divider(),
                const SizedBox(height: 16),
                
                // Course Name
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Course Name',
                    prefixIcon: Icon(Icons.book_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter course name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                // Course Code
                TextFormField(
                  controller: _codeController,
                  decoration: const InputDecoration(
                    labelText: 'Course Code',
                    prefixIcon: Icon(Icons.code),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter course code';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                // Course Description
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    prefixIcon: Icon(Icons.description_outlined),
                    alignLabelWithHint: true,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter course description';
                    }
                    return null;
                  },
                  maxLines: 3,
                ),
                const SizedBox(height: 24),
                
                // Course Details
                Text(
                  'Course Details',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: accentColor,
                  ),
                ),
                const Divider(),
                const SizedBox(height: 16),
                
                // Teacher Assignment
                DropdownButtonFormField<String>(
                  value: _selectedTeacherId.isEmpty && widget.teachers.isNotEmpty
                      ? widget.teachers.first.id
                      : _selectedTeacherId,
                  decoration: const InputDecoration(
                    labelText: 'Assigned Teacher',
                    prefixIcon: Icon(Icons.person_outlined),
                  ),
                  items: widget.teachers.map((teacher) => DropdownMenuItem(
                    value: teacher.id,
                    child: Text('${teacher.fullName} (${teacher.position})'),
                  )).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedTeacherId = value;
                      });
                    }
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a teacher';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                // Course Type and Credits
                Row(
                  children: [
                    // Course Type
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedCourseType,
                        decoration: const InputDecoration(
                          labelText: 'Course Type',
                          prefixIcon: Icon(Icons.category_outlined),
                        ),
                        items: _courseTypes.map((type) => DropdownMenuItem(
                          value: type,
                          child: Text(type),
                        )).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _selectedCourseType = value;
                            });
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    
                    // Credits
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        value: _credits,
                        decoration: const InputDecoration(
                          labelText: 'Credits',
                          prefixIcon: Icon(Icons.star_outline),
                        ),
                        items: [1, 2, 3, 4, 5].map((credit) => DropdownMenuItem(
                          value: credit,
                          child: Text('$credit ${credit == 1 ? 'Credit' : 'Credits'}'),
                        )).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _credits = value;
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                
                // Grade Levels and Sections
                Text(
                  'Class Assignment',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: accentColor,
                  ),
                ),
                const Divider(),
                const SizedBox(height: 16),
                
                // Grade Levels
                Text(
                  'Grade Levels',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _allGradeLevels.map((grade) {
                    final isSelected = _selectedGradeLevels.contains(grade);
                    return FilterChip(
                      selected: isSelected,
                      label: Text('Grade $grade'),
                      onSelected: (selected) => _toggleGradeLevel(grade),
                      selectedColor: accentColor.withOpacity(0.2),
                      checkmarkColor: accentColor,
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                
                // Sections
                Text(
                  'Sections',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _allSections.map((section) {
                    final isSelected = _selectedSections.contains(section);
                    return FilterChip(
                      selected: isSelected,
                      label: Text('Section $section'),
                      onSelected: (selected) => _toggleSection(section),
                      selectedColor: accentColor.withOpacity(0.2),
                      checkmarkColor: accentColor,
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
                
                // Button row
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: _isLoading ? null : () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _saveCourse,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accentColor,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : Text(isEditing ? 'Update' : 'Add'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
