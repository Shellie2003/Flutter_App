import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../models/teacher.dart';
import '../services/data_service.dart';
import '../theme/app_theme.dart';


class TeacherScreen extends StatefulWidget {
  const TeacherScreen({Key? key}) : super(key: key);

  @override
  State<TeacherScreen> createState() => _TeacherScreenState();
}

class _TeacherScreenState extends State<TeacherScreen> with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  List<Teacher> _teachers = [];
  List<Teacher> _filteredTeachers = [];
  String _searchQuery = '';
  String _selectedPosition = 'All';
  String _selectedSubject = 'All';
  
  late AnimationController _animationController;
  final List<String> _positions = ['All', 'Teacher', 'Head of Department', 'Coordinator', 'Principal', 'Vice Principal'];
  final List<String> _subjects = ['All', 'Mathematics', 'Science', 'Physics', 'Chemistry', 'Biology', 'English', 'History', 'Geography', 'Computer Science'];
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _loadTeachers();
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  Future<void> _loadTeachers() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final dataService = Provider.of<DataService>(context, listen: false);
      final teachers = await dataService.getTeachers();
      
      setState(() {
        _teachers = teachers;
        _applyFilters();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar('Failed to load teachers');
    }
  }
  
  void _applyFilters() {
    setState(() {
      _filteredTeachers = _teachers.where((teacher) {
        // Apply search filter
        final matchesSearch = teacher.fullName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            teacher.email.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            teacher.qualification.toLowerCase().contains(_searchQuery.toLowerCase());
        
        // Apply position filter
        final matchesPosition = _selectedPosition == 'All' || teacher.position.contains(_selectedPosition);
        
        // Apply subject filter
        final matchesSubject = _selectedSubject == 'All' || 
            teacher.subjectsTaught.any((subject) => subject.contains(_selectedSubject));
        
        return matchesSearch && matchesPosition && matchesSubject;
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
  
  Future<void> _showTeacherDetails(Teacher teacher) async {
    // Show teacher details in a modal bottom sheet
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TeacherDetailsBottomSheet(teacher: teacher),
    );
  }
  
  Future<void> _showAddEditTeacherDialog(Teacher? teacher) async {
    // Show dialog to add or edit teacher
    // If teacher is null, it's an add operation, otherwise it's an edit
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AddEditTeacherDialog(teacher: teacher),
    );
    
    if (result == true) {
      // Reload teachers if changes were made
      _loadTeachers();
    }
  }
  
  Future<void> _confirmDeleteTeacher(Teacher teacher) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text('Are you sure you want to delete ${teacher.fullName}?'),
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
        await dataService.deleteTeacher(teacher.id);
        _loadTeachers();
        
        // Show success message
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Teacher deleted successfully'),
            backgroundColor: AppTheme.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } catch (e) {
        _showErrorSnackBar('Failed to delete teacher');
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
                        'Teachers',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Manage teacher records',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).textTheme.bodySmall?.color,
                        ),
                      ),
                    ],
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _showAddEditTeacherDialog(null),
                    icon: const Icon(Icons.add),
                    label: const Text('Add Teacher'),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: AppTheme.secondaryColor,
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
                      hintText: 'Search teachers...',
                      prefixIcon: const Icon(Icons.search, color: AppTheme.secondaryColor),
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
                      // Position filter
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _selectedPosition,
                          decoration: InputDecoration(
                            labelText: 'Position',
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            fillColor: Theme.of(context).cardTheme.color,
                            filled: true,
                          ),
                          items: _positions.map((position) => DropdownMenuItem(
                            value: position,
                            child: Text(position),
                          )).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                _selectedPosition = value;
                                _applyFilters();
                              });
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 15),
                      
                      // Subject filter
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _selectedSubject,
                          decoration: InputDecoration(
                            labelText: 'Subject',
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            fillColor: Theme.of(context).cardTheme.color,
                            filled: true,
                          ),
                          items: _subjects.map((subject) => DropdownMenuItem(
                            value: subject,
                            child: Text(subject),
                          )).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                _selectedSubject = value;
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
            
            // Teacher list
            Expanded(
              child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredTeachers.isEmpty
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
                            'No teachers found',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Theme.of(context).textTheme.bodySmall?.color,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextButton.icon(
                            onPressed: _loadTeachers,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Refresh'),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      physics: const BouncingScrollPhysics(),
                      itemCount: _filteredTeachers.length,
                      itemBuilder: (context, index) {
                        final teacher = _filteredTeachers[index];
                        return _buildTeacherCard(teacher, index);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildTeacherCard(Teacher teacher, int index) {
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
              onTap: () => _showTeacherDetails(teacher),
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    // Teacher image
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: AppTheme.secondaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: teacher.profileImageUrl != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                teacher.profileImageUrl!,
                                fit: BoxFit.cover,
                              ),
                            )
                          : Center(
                              child: Text(
                                teacher.firstName[0] + teacher.lastName[0],
                                style: TextStyle(
                                  color: AppTheme.secondaryColor,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                    ),
                    const SizedBox(width: 16),
                    
                    // Teacher info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            teacher.fullName,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            teacher.position,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Subjects: ${teacher.subjectsTaught.join(', ')}',
                            style: Theme.of(context).textTheme.bodySmall,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    
                    // Years of service badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppTheme.secondaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${teacher.yearsOfService} ${teacher.yearsOfService == 1 ? 'year' : 'years'}',
                        style: TextStyle(
                          color: AppTheme.secondaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    
                    const SizedBox(width: 8),
                    
                    // Action buttons
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      onSelected: (value) {
                        switch (value) {
                          case 'view':
                            _showTeacherDetails(teacher);
                            break;
                          case 'edit':
                            _showAddEditTeacherDialog(teacher);
                            break;
                          case 'delete':
                            _confirmDeleteTeacher(teacher);
                            break;
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem<String>(
                          value: 'view',
                          child: Row(
                            children: [
                              Icon(Icons.visibility, size: 20),
                              SizedBox(width: 8),
                              Text('View Details'),
                            ],
                          ),
                        ),
                        const PopupMenuItem<String>(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit, size: 20),
                              SizedBox(width: 8),
                              Text('Edit'),
                            ],
                          ),
                        ),
                        PopupMenuItem<String>(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, size: 20, color: AppTheme.error),
                              const SizedBox(width: 8),
                              Text('Delete', style: TextStyle(color: AppTheme.error)),
                            ],
                          ),
                        ),
                      ],
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
}

class TeacherDetailsBottomSheet extends StatelessWidget {
  final Teacher teacher;
  
  const TeacherDetailsBottomSheet({Key? key, required this.teacher}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
          // Header with teacher name and close button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Teacher Details',
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
          
          // Teacher profile header
          Row(
            children: [
              // Teacher image
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppTheme.secondaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: teacher.profileImageUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.network(
                          teacher.profileImageUrl!,
                          fit: BoxFit.cover,
                        ),
                      )
                    : Center(
                        child: Text(
                          teacher.firstName[0] + teacher.lastName[0],
                          style: TextStyle(
                            color: AppTheme.secondaryColor,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
              ),
              const SizedBox(width: 16),
              
              // Basic teacher info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      teacher.fullName,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      teacher.position,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: AppTheme.secondaryColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      teacher.qualification,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Teacher details
          Flexible(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle(context, 'Personal Information'),
                  _buildDetailItem(context, 'Date of Birth', DateFormat('MMMM d, yyyy').format(teacher.dateOfBirth)),
                  _buildDetailItem(context, 'Gender', teacher.gender),
                  _buildDetailItem(context, 'Address', teacher.address),
                  
                  _buildSectionTitle(context, 'Contact Information'),
                  _buildDetailItem(context, 'Phone', teacher.phone),
                  _buildDetailItem(context, 'Email', teacher.email),
                  
                  _buildSectionTitle(context, 'Professional Information'),
                  _buildDetailItem(context, 'Joining Date', DateFormat('MMMM d, yyyy').format(teacher.joiningDate)),
                  _buildDetailItem(context, 'Years of Service', '${teacher.yearsOfService} ${teacher.yearsOfService == 1 ? 'year' : 'years'}'),
                  _buildDetailItem(context, 'Qualification', teacher.qualification),
                  
                  _buildSectionTitle(context, 'Teaching Details'),
                  _buildDetailItem(context, 'Subjects Taught', teacher.subjectsTaught.join(', ')),
                  _buildDetailItem(context, 'Classes Taught', teacher.classesTaught.join(', ')),
                  
                  // Additional info if any
                  if (teacher.additionalInfo.isNotEmpty) ...[  
                    _buildSectionTitle(context, 'Additional Information'),
                    ...teacher.additionalInfo.entries.map(
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
  
  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.secondaryColor,
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
}

class AddEditTeacherDialog extends StatefulWidget {
  final Teacher? teacher;
  
  const AddEditTeacherDialog({Key? key, this.teacher}) : super(key: key);

  @override
  State<AddEditTeacherDialog> createState() => _AddEditTeacherDialogState();
}

class _AddEditTeacherDialogState extends State<AddEditTeacherDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _qualificationController;
  late TextEditingController _addressController;
  
  DateTime _selectedDateOfBirth = DateTime.now().subtract(const Duration(days: 365 * 30)); // Default to 30 years ago
  DateTime _selectedJoiningDate = DateTime.now();
  String _selectedGender = 'Male';
  String _selectedPosition = 'Teacher';
  
  List<String> _subjectsTaught = ['Mathematics'];
  List<String> _classesTaught = ['6A'];
  
  final List<String> _allSubjects = ['Mathematics', 'Science', 'Physics', 'Chemistry', 'Biology', 'English', 'History', 'Geography', 'Computer Science'];
  final List<String> _allClasses = ['6A', '6B', '7A', '7B', '8A', '8B', '9A', '9B', '10A', '10B', '11A', '11B', '12A', '12B'];
  
  bool _isLoading = false;
  
  @override
  void initState() {
    super.initState();
    
    // Initialize controllers with teacher data if editing
    final teacher = widget.teacher;
    _firstNameController = TextEditingController(text: teacher?.firstName ?? '');
    _lastNameController = TextEditingController(text: teacher?.lastName ?? '');
    _phoneController = TextEditingController(text: teacher?.phone ?? '');
    _emailController = TextEditingController(text: teacher?.email ?? '');
    _qualificationController = TextEditingController(text: teacher?.qualification ?? '');
    _addressController = TextEditingController(text: teacher?.address ?? '');
    
    if (teacher != null) {
      _selectedDateOfBirth = teacher.dateOfBirth;
      _selectedJoiningDate = teacher.joiningDate;
      _selectedGender = teacher.gender;
      _selectedPosition = teacher.position;
      _subjectsTaught = List.from(teacher.subjectsTaught);
      _classesTaught = List.from(teacher.classesTaught);
    }
  }
  
  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _qualificationController.dispose();
    _addressController.dispose();
    super.dispose();
  }
  
  Future<void> _selectDateOfBirth() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDateOfBirth,
      firstDate: DateTime(1950),
      lastDate: DateTime.now().subtract(const Duration(days: 365 * 18)), // Must be at least 18 years old
    );
    
    if (picked != null && picked != _selectedDateOfBirth) {
      setState(() {
        _selectedDateOfBirth = picked;
      });
    }
  }
  
  Future<void> _selectJoiningDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedJoiningDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    
    if (picked != null && picked != _selectedJoiningDate) {
      setState(() {
        _selectedJoiningDate = picked;
      });
    }
  }
  
  void _toggleSubject(String subject) {
    setState(() {
      if (_subjectsTaught.contains(subject)) {
        _subjectsTaught.remove(subject);
      } else {
        _subjectsTaught.add(subject);
      }
    });
  }
  
  void _toggleClass(String className) {
    setState(() {
      if (_classesTaught.contains(className)) {
        _classesTaught.remove(className);
      } else {
        _classesTaught.add(className);
      }
    });
  }
  
  Future<void> _saveTeacher() async {
    if (_formKey.currentState!.validate()) {
      // Validate that at least one subject and class is selected
      if (_subjectsTaught.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select at least one subject'),
            backgroundColor: AppTheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }
      
      if (_classesTaught.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select at least one class'),
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
        
        final teacher = Teacher(
          id: widget.teacher?.id,
          firstName: _firstNameController.text,
          lastName: _lastNameController.text,
          dateOfBirth: _selectedDateOfBirth,
          gender: _selectedGender,
          address: _addressController.text,
          phone: _phoneController.text,
          email: _emailController.text,
          qualification: _qualificationController.text,
          position: _selectedPosition,
          joiningDate: _selectedJoiningDate,
          subjectsTaught: _subjectsTaught,
          classesTaught: _classesTaught,
          profileImageUrl: widget.teacher?.profileImageUrl,
          additionalInfo: widget.teacher?.additionalInfo ?? {},
        );
        
        if (widget.teacher == null) {
          // Add new teacher
          await dataService.addTeacher(teacher);
        } else {
          // Update existing teacher
          await dataService.updateTeacher(teacher);
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
    final isEditing = widget.teacher != null;
    final title = isEditing ? 'Edit Teacher' : 'Add New Teacher';
    
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
                
                // Personal Information
                Text(
                  'Personal Information',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.secondaryColor,
                  ),
                ),
                const Divider(),
                const SizedBox(height: 16),
                
                // First Name and Last Name
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _firstNameController,
                        decoration: const InputDecoration(
                          labelText: 'First Name',
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter first name';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _lastNameController,
                        decoration: const InputDecoration(
                          labelText: 'Last Name',
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter last name';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Date of Birth and Gender
                Row(
                  children: [
                    // Date of Birth
                    Expanded(
                      child: InkWell(
                        onTap: _selectDateOfBirth,
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Date of Birth',
                            prefixIcon: Icon(Icons.calendar_today),
                          ),
                          child: Text(DateFormat('MMM d, yyyy').format(_selectedDateOfBirth)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    
                    // Gender
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedGender,
                        decoration: const InputDecoration(
                          labelText: 'Gender',
                          prefixIcon: Icon(Icons.people_outline),
                        ),
                        items: ['Male', 'Female', 'Other'].map((gender) => DropdownMenuItem(
                          value: gender,
                          child: Text(gender),
                        )).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _selectedGender = value;
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Address
                TextFormField(
                  controller: _addressController,
                  decoration: const InputDecoration(
                    labelText: 'Address',
                    prefixIcon: Icon(Icons.home_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter address';
                    }
                    return null;
                  },
                  maxLines: 2,
                ),
                const SizedBox(height: 24),
                
                // Contact Information
                Text(
                  'Contact Information',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.secondaryColor,
                  ),
                ),
                const Divider(),
                const SizedBox(height: 16),
                
                // Phone and Email
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _phoneController,
                        decoration: const InputDecoration(
                          labelText: 'Phone',
                          prefixIcon: Icon(Icons.phone_outlined),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter phone number';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email_outlined),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter email';
                          }
                          // Simple email validation
                          if (!value.contains('@') || !value.contains('.')) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                
                // Professional Information
                Text(
                  'Professional Information',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.secondaryColor,
                  ),
                ),
                const Divider(),
                const SizedBox(height: 16),
                
                // Qualification
                TextFormField(
                  controller: _qualificationController,
                  decoration: const InputDecoration(
                    labelText: 'Qualification',
                    prefixIcon: Icon(Icons.school_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter qualification';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                // Position and Joining Date
                Row(
                  children: [
                    // Position
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedPosition,
                        decoration: const InputDecoration(
                          labelText: 'Position',
                          prefixIcon: Icon(Icons.work_outline),
                        ),
                        items: [
                          'Teacher', 
                          'Head of Department', 
                          'Coordinator', 
                          'Principal', 
                          'Vice Principal'
                        ].map((position) => DropdownMenuItem(
                          value: position,
                          child: Text(position),
                        )).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _selectedPosition = value;
                            });
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    
                    // Joining Date
                    Expanded(
                      child: InkWell(
                        onTap: _selectJoiningDate,
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Joining Date',
                            prefixIcon: Icon(Icons.calendar_today),
                          ),
                          child: Text(DateFormat('MMM d, yyyy').format(_selectedJoiningDate)),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                
                // Teaching Details
                Text(
                  'Teaching Details',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.secondaryColor,
                  ),
                ),
                const Divider(),
                const SizedBox(height: 16),
                
                // Subjects Taught
                Text(
                  'Subjects Taught',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _allSubjects.map((subject) {
                    final isSelected = _subjectsTaught.contains(subject);
                    return FilterChip(
                      selected: isSelected,
                      label: Text(subject),
                      onSelected: (selected) => _toggleSubject(subject),
                      selectedColor: AppTheme.secondaryColor.withOpacity(0.2),
                      checkmarkColor: AppTheme.secondaryColor,
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                
                // Classes Taught
                Text(
                  'Classes Taught',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _allClasses.map((className) {
                    final isSelected = _classesTaught.contains(className);
                    return FilterChip(
                      selected: isSelected,
                      label: Text(className),
                      onSelected: (selected) => _toggleClass(className),
                      selectedColor: AppTheme.secondaryColor.withOpacity(0.2),
                      checkmarkColor: AppTheme.secondaryColor,
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
                      onPressed: _isLoading ? null : _saveTeacher,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.secondaryColor,
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
