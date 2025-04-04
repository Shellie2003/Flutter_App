import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../models/student.dart';
import '../services/data_service.dart';
import '../theme/app_theme.dart';


class StudentScreen extends StatefulWidget {
  const StudentScreen({Key? key}) : super(key: key);

  @override
  State<StudentScreen> createState() => _StudentScreenState();
}

class _StudentScreenState extends State<StudentScreen> with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  List<Student> _students = [];
  List<Student> _filteredStudents = [];
  String _searchQuery = '';
  String _selectedGrade = 'All';
  String _selectedSection = 'All';
  
  late AnimationController _animationController;
  final List<String> _grades = ['All', '5', '6', '7', '8', '9', '10', '11', '12'];
  final List<String> _sections = ['All', 'A', 'B', 'C', 'D'];
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _loadStudents();
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  Future<void> _loadStudents() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final dataService = Provider.of<DataService>(context, listen: false);
      final students = await dataService.getStudents();
      
      setState(() {
        _students = students;
        _applyFilters();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar('Failed to load students');
    }
  }
  
  void _applyFilters() {
    setState(() {
      _filteredStudents = _students.where((student) {
        // Apply search filter
        final matchesSearch = student.fullName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            student.rollNumber.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            student.email.toLowerCase().contains(_searchQuery.toLowerCase());
        
        // Apply grade filter
        final matchesGrade = _selectedGrade == 'All' || student.grade == _selectedGrade;
        
        // Apply section filter
        final matchesSection = _selectedSection == 'All' || student.section == _selectedSection;
        
        return matchesSearch && matchesGrade && matchesSection;
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
  
  Future<void> _showStudentDetails(Student student) async {
    // Show student details in a modal bottom sheet
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StudentDetailsBottomSheet(student: student),
    );
  }
  
  Future<void> _showAddEditStudentDialog(Student? student) async {
    // Show dialog to add or edit student
    // If student is null, it's an add operation, otherwise it's an edit
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AddEditStudentDialog(student: student),
    );
    
    if (result == true) {
      // Reload students if changes were made
      _loadStudents();
    }
  }
  
  Future<void> _confirmDeleteStudent(Student student) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text('Are you sure you want to delete ${student.fullName}?'),
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
        await dataService.deleteStudent(student.id);
        _loadStudents();
        
        // Show success message
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Student deleted successfully'),
            backgroundColor: AppTheme.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } catch (e) {
        _showErrorSnackBar('Failed to delete student');
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
                        'Students',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Manage student records',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).textTheme.bodySmall?.color,
                        ),
                      ),
                    ],
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _showAddEditStudentDialog(null),
                    icon: const Icon(Icons.add),
                    label: const Text('Add Student'),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: AppTheme.primaryColor,
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
                      hintText: 'Search students...',
                      prefixIcon: const Icon(Icons.search, color: AppTheme.primaryColor),
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
                      // Grade filter
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _selectedGrade,
                          decoration: InputDecoration(
                            labelText: 'Grade',
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            fillColor: Theme.of(context).cardTheme.color,
                            filled: true,
                          ),
                          items: _grades.map((grade) => DropdownMenuItem(
                            value: grade,
                            child: Text(grade),
                          )).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                _selectedGrade = value;
                                _applyFilters();
                              });
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 15),
                      
                      // Section filter
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _selectedSection,
                          decoration: InputDecoration(
                            labelText: 'Section',
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            fillColor: Theme.of(context).cardTheme.color,
                            filled: true,
                          ),
                          items: _sections.map((section) => DropdownMenuItem(
                            value: section,
                            child: Text(section),
                          )).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                _selectedSection = value;
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
            
            // Student list
            Expanded(
              child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredStudents.isEmpty
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
                            'No students found',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Theme.of(context).textTheme.bodySmall?.color,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextButton.icon(
                            onPressed: _loadStudents,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Refresh'),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      physics: const BouncingScrollPhysics(),
                      itemCount: _filteredStudents.length,
                      itemBuilder: (context, index) {
                        final student = _filteredStudents[index];
                        return _buildStudentCard(student, index);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStudentCard(Student student, int index) {
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
              onTap: () => _showStudentDetails(student),
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    // Student image
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: student.profileImageUrl != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                student.profileImageUrl!,
                                fit: BoxFit.cover,
                              ),
                            )
                          : Center(
                              child: Text(
                                student.firstName[0] + student.lastName[0],
                                style: TextStyle(
                                  color: AppTheme.primaryColor,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                    ),
                    const SizedBox(width: 16),
                    
                    // Student info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            student.fullName,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Grade ${student.grade}${student.section} | Roll No: ${student.rollNumber}',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Age: ${student.age} | Admission: ${DateFormat('MMM yyyy').format(student.admissionDate)}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    
                    // Action buttons
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      onSelected: (value) {
                        switch (value) {
                          case 'view':
                            _showStudentDetails(student);
                            break;
                          case 'edit':
                            _showAddEditStudentDialog(student);
                            break;
                          case 'delete':
                            _confirmDeleteStudent(student);
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

class StudentDetailsBottomSheet extends StatelessWidget {
  final Student student;
  
  const StudentDetailsBottomSheet({Key? key, required this.student}) : super(key: key);

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
          // Header with student name and close button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Student Details',
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
          
          // Student profile header
          Row(
            children: [
              // Student image
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: student.profileImageUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.network(
                          student.profileImageUrl!,
                          fit: BoxFit.cover,
                        ),
                      )
                    : Center(
                        child: Text(
                          student.firstName[0] + student.lastName[0],
                          style: TextStyle(
                            color: AppTheme.primaryColor,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
              ),
              const SizedBox(width: 16),
              
              // Basic student info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      student.fullName,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Roll No: ${student.rollNumber}',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Grade ${student.grade}${student.section}',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Student details
          Flexible(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle(context, 'Personal Information'),
                  _buildDetailItem(context, 'Age', '${student.age} years'),
                  _buildDetailItem(context, 'Date of Birth', DateFormat('MMMM d, yyyy').format(student.dateOfBirth)),
                  _buildDetailItem(context, 'Gender', student.gender),
                  _buildDetailItem(context, 'Address', student.address),
                  
                  _buildSectionTitle(context, 'Contact Information'),
                  _buildDetailItem(context, 'Phone', student.phone),
                  _buildDetailItem(context, 'Email', student.email),
                  _buildDetailItem(context, 'Guardian', student.guardianName),
                  _buildDetailItem(context, 'Guardian Contact', student.guardianContact),
                  
                  _buildSectionTitle(context, 'Academic Information'),
                  _buildDetailItem(context, 'Admission Date', DateFormat('MMMM d, yyyy').format(student.admissionDate)),
                  
                  // Additional info if any
                  if (student.additionalInfo.isNotEmpty) ...[  
                    _buildSectionTitle(context, 'Additional Information'),
                    ...student.additionalInfo.entries.map(
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
              color: AppTheme.primaryColor,
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

class AddEditStudentDialog extends StatefulWidget {
  final Student? student;
  
  const AddEditStudentDialog({Key? key, this.student}) : super(key: key);

  @override
  State<AddEditStudentDialog> createState() => _AddEditStudentDialogState();
}

class _AddEditStudentDialogState extends State<AddEditStudentDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _rollNumberController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _guardianNameController;
  late TextEditingController _guardianContactController;
  late TextEditingController _addressController;
  
  DateTime _selectedDateOfBirth = DateTime.now().subtract(const Duration(days: 365 * 10)); // Default to 10 years ago
  DateTime _selectedAdmissionDate = DateTime.now();
  String _selectedGender = 'Male';
  String _selectedGrade = '6';
  String _selectedSection = 'A';
  
  bool _isLoading = false;
  
  @override
  void initState() {
    super.initState();
    
    // Initialize controllers with student data if editing
    final student = widget.student;
    _firstNameController = TextEditingController(text: student?.firstName ?? '');
    _lastNameController = TextEditingController(text: student?.lastName ?? '');
    _rollNumberController = TextEditingController(text: student?.rollNumber ?? '');
    _phoneController = TextEditingController(text: student?.phone ?? '');
    _emailController = TextEditingController(text: student?.email ?? '');
    _guardianNameController = TextEditingController(text: student?.guardianName ?? '');
    _guardianContactController = TextEditingController(text: student?.guardianContact ?? '');
    _addressController = TextEditingController(text: student?.address ?? '');
    
    if (student != null) {
      _selectedDateOfBirth = student.dateOfBirth;
      _selectedAdmissionDate = student.admissionDate;
      _selectedGender = student.gender;
      _selectedGrade = student.grade;
      _selectedSection = student.section;
    }
  }
  
  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _rollNumberController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _guardianNameController.dispose();
    _guardianContactController.dispose();
    _addressController.dispose();
    super.dispose();
  }
  
  Future<void> _selectDateOfBirth() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDateOfBirth,
      firstDate: DateTime(1990),
      lastDate: DateTime.now(),
    );
    
    if (picked != null && picked != _selectedDateOfBirth) {
      setState(() {
        _selectedDateOfBirth = picked;
      });
    }
  }
  
  Future<void> _selectAdmissionDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedAdmissionDate,
      firstDate: DateTime(2010),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    
    if (picked != null && picked != _selectedAdmissionDate) {
      setState(() {
        _selectedAdmissionDate = picked;
      });
    }
  }
  
  Future<void> _saveStudent() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      
      try {
        final dataService = Provider.of<DataService>(context, listen: false);
        
        final student = Student(
          id: widget.student?.id,
          firstName: _firstNameController.text,
          lastName: _lastNameController.text,
          dateOfBirth: _selectedDateOfBirth,
          gender: _selectedGender,
          address: _addressController.text,
          phone: _phoneController.text,
          email: _emailController.text,
          guardianName: _guardianNameController.text,
          guardianContact: _guardianContactController.text,
          profileImageUrl: widget.student?.profileImageUrl,
          grade: _selectedGrade,
          section: _selectedSection,
          rollNumber: _rollNumberController.text,
          admissionDate: _selectedAdmissionDate,
          additionalInfo: widget.student?.additionalInfo ?? {},
        );
        
        if (widget.student == null) {
          // Add new student
          await dataService.addStudent(student);
        } else {
          // Update existing student
          await dataService.updateStudent(student);
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
    final isEditing = widget.student != null;
    final title = isEditing ? 'Edit Student' : 'Add New Student';
    
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
                    color: AppTheme.primaryColor,
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
                    color: AppTheme.primaryColor,
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
                const SizedBox(height: 16),
                
                // Guardian Name and Contact
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _guardianNameController,
                        decoration: const InputDecoration(
                          labelText: 'Guardian Name',
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter guardian name';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _guardianContactController,
                        decoration: const InputDecoration(
                          labelText: 'Guardian Contact',
                          prefixIcon: Icon(Icons.phone_outlined),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter guardian contact';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                
                // Academic Information
                Text(
                  'Academic Information',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
                const Divider(),
                const SizedBox(height: 16),
                
                // Roll Number
                TextFormField(
                  controller: _rollNumberController,
                  decoration: const InputDecoration(
                    labelText: 'Roll Number',
                    prefixIcon: Icon(Icons.numbers_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter roll number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                // Grade and Section
                Row(
                  children: [
                    // Grade
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedGrade,
                        decoration: const InputDecoration(
                          labelText: 'Grade',
                          prefixIcon: Icon(Icons.grade_outlined),
                        ),
                        items: ['5', '6', '7', '8', '9', '10', '11', '12'].map((grade) => DropdownMenuItem(
                          value: grade,
                          child: Text(grade),
                        )).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _selectedGrade = value;
                            });
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    
                    // Section
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedSection,
                        decoration: const InputDecoration(
                          labelText: 'Section',
                          prefixIcon: Icon(Icons.app_registration_outlined),
                        ),
                        items: ['A', 'B', 'C', 'D'].map((section) => DropdownMenuItem(
                          value: section,
                          child: Text(section),
                        )).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _selectedSection = value;
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Admission Date
                InkWell(
                  onTap: _selectAdmissionDate,
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Admission Date',
                      prefixIcon: Icon(Icons.calendar_today),
                    ),
                    child: Text(DateFormat('MMM d, yyyy').format(_selectedAdmissionDate)),
                  ),
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
                      onPressed: _isLoading ? null : _saveStudent,
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
