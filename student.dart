import 'package:uuid/uuid.dart';

class Student {
  final String id;
  final String firstName;
  final String lastName;
  final DateTime dateOfBirth;
  final String gender;
  final String address;
  final String phone;
  final String email;
  final String guardianName;
  final String guardianContact;
  final String? profileImageUrl;
  final String grade;
  final String section;
  final String rollNumber;
  final DateTime admissionDate;
  final Map<String, dynamic> additionalInfo;
  
  Student({
    String? id,
    required this.firstName,
    required this.lastName,
    required this.dateOfBirth,
    required this.gender,
    required this.address,
    required this.phone,
    required this.email,
    required this.guardianName,
    required this.guardianContact,
    this.profileImageUrl,
    required this.grade,
    required this.section,
    required this.rollNumber,
    required this.admissionDate,
    Map<String, dynamic>? additionalInfo,
  }) : 
    id = id ?? const Uuid().v4(),
    additionalInfo = additionalInfo ?? {};
  
  String get fullName => '$firstName $lastName';
  
  int get age {
    final today = DateTime.now();
    int age = today.year - dateOfBirth.year;
    if (today.month < dateOfBirth.month || 
        (today.month == dateOfBirth.month && today.day < dateOfBirth.day)) {
      age--;
    }
    return age;
  }
  
  Student copyWith({
    String? firstName,
    String? lastName,
    DateTime? dateOfBirth,
    String? gender,
    String? address,
    String? phone,
    String? email,
    String? guardianName,
    String? guardianContact,
    String? profileImageUrl,
    String? grade,
    String? section,
    String? rollNumber,
    DateTime? admissionDate,
    Map<String, dynamic>? additionalInfo,
  }) {
    return Student(
      id: this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      guardianName: guardianName ?? this.guardianName,
      guardianContact: guardianContact ?? this.guardianContact,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      grade: grade ?? this.grade,
      section: section ?? this.section,
      rollNumber: rollNumber ?? this.rollNumber,
      admissionDate: admissionDate ?? this.admissionDate,
      additionalInfo: additionalInfo ?? this.additionalInfo,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'dateOfBirth': dateOfBirth.toIso8601String(),
      'gender': gender,
      'address': address,
      'phone': phone,
      'email': email,
      'guardianName': guardianName,
      'guardianContact': guardianContact,
      'profileImageUrl': profileImageUrl,
      'grade': grade,
      'section': section,
      'rollNumber': rollNumber,
      'admissionDate': admissionDate.toIso8601String(),
      'additionalInfo': additionalInfo,
    };
  }
  
  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      id: json['id'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      dateOfBirth: DateTime.parse(json['dateOfBirth']),
      gender: json['gender'],
      address: json['address'],
      phone: json['phone'],
      email: json['email'],
      guardianName: json['guardianName'],
      guardianContact: json['guardianContact'],
      profileImageUrl: json['profileImageUrl'],
      grade: json['grade'],
      section: json['section'],
      rollNumber: json['rollNumber'],
      admissionDate: DateTime.parse(json['admissionDate']),
      additionalInfo: json['additionalInfo'],
    );
  }
  
  // Generate mock data for demo purposes
  static List<Student> getMockData() {
    return [
      Student(
        firstName: 'Emma',
        lastName: 'Wilson',
        dateOfBirth: DateTime(2010, 5, 15),
        gender: 'Female',
        address: '123 Maple Street, Springfield',
        phone: '555-123-4567',
        email: 'emma.wilson@email.com',
        guardianName: 'Robert Wilson',
        guardianContact: '555-987-6543',
        grade: '6',
        section: 'A',
        rollNumber: '6A-001',
        admissionDate: DateTime(2022, 9, 1),
      ),
      Student(
        firstName: 'Noah',
        lastName: 'Martinez',
        dateOfBirth: DateTime(2011, 3, 22),
        gender: 'Male',
        address: '456 Oak Avenue, Riverdale',
        phone: '555-234-5678',
        email: 'noah.martinez@email.com',
        guardianName: 'Elena Martinez',
        guardianContact: '555-876-5432',
        grade: '5',
        section: 'B',
        rollNumber: '5B-002',
        admissionDate: DateTime(2021, 9, 1),
      ),
      Student(
        firstName: 'Olivia',
        lastName: 'Johnson',
        dateOfBirth: DateTime(2009, 11, 8),
        gender: 'Female',
        address: '789 Pine Road, Lakeside',
        phone: '555-345-6789',
        email: 'olivia.johnson@email.com',
        guardianName: 'Michael Johnson',
        guardianContact: '555-765-4321',
        grade: '7',
        section: 'A',
        rollNumber: '7A-003',
        admissionDate: DateTime(2022, 9, 1),
      ),
      Student(
        firstName: 'Liam',
        lastName: 'Garcia',
        dateOfBirth: DateTime(2010, 7, 30),
        gender: 'Male',
        address: '321 Cedar Lane, Hillcrest',
        phone: '555-456-7890',
        email: 'liam.garcia@email.com',
        guardianName: 'Sofia Garcia',
        guardianContact: '555-654-3210',
        grade: '6',
        section: 'B',
        rollNumber: '6B-004',
        admissionDate: DateTime(2021, 9, 1),
      ),
      Student(
        firstName: 'Ava',
        lastName: 'Brown',
        dateOfBirth: DateTime(2011, 9, 14),
        gender: 'Female',
        address: '654 Elm Street, Maplewood',
        phone: '555-567-8901',
        email: 'ava.brown@email.com',
        guardianName: 'James Brown',
        guardianContact: '555-543-2109',
        grade: '5',
        section: 'A',
        rollNumber: '5A-005',
        admissionDate: DateTime(2022, 9, 1),
      ),
      Student(
        firstName: 'Lucas',
        lastName: 'Davis',
        dateOfBirth: DateTime(2009, 2, 5),
        gender: 'Male',
        address: '987 Birch Boulevard, Oakdale',
        phone: '555-678-9012',
        email: 'lucas.davis@email.com',
        guardianName: 'Patricia Davis',
        guardianContact: '555-432-1098',
        grade: '7',
        section: 'B',
        rollNumber: '7B-006',
        admissionDate: DateTime(2021, 9, 1),
      ),
    ];
  }
}
