import 'package:uuid/uuid.dart';

class Teacher {
  final String id;
  final String firstName;
  final String lastName;
  final DateTime dateOfBirth;
  final String gender;
  final String address;
  final String phone;
  final String email;
  final String qualification;
  final String position;
  final DateTime joiningDate;
  final List<String> subjectsTaught;
  final List<String> classesTaught;
  final String? profileImageUrl;
  final Map<String, dynamic> additionalInfo;
  
  Teacher({
    String? id,
    required this.firstName,
    required this.lastName,
    required this.dateOfBirth,
    required this.gender,
    required this.address,
    required this.phone,
    required this.email,
    required this.qualification,
    required this.position,
    required this.joiningDate,
    required this.subjectsTaught,
    required this.classesTaught,
    this.profileImageUrl,
    Map<String, dynamic>? additionalInfo,
  }) : 
    id = id ?? const Uuid().v4(),
    additionalInfo = additionalInfo ?? {};
  
  String get fullName => '$firstName $lastName';
  
  int get yearsOfService {
    final today = DateTime.now();
    int years = today.year - joiningDate.year;
    if (today.month < joiningDate.month || 
        (today.month == joiningDate.month && today.day < joiningDate.day)) {
      years--;
    }
    return years;
  }
  
  Teacher copyWith({
    String? firstName,
    String? lastName,
    DateTime? dateOfBirth,
    String? gender,
    String? address,
    String? phone,
    String? email,
    String? qualification,
    String? position,
    DateTime? joiningDate,
    List<String>? subjectsTaught,
    List<String>? classesTaught,
    String? profileImageUrl,
    Map<String, dynamic>? additionalInfo,
  }) {
    return Teacher(
      id: this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      qualification: qualification ?? this.qualification,
      position: position ?? this.position,
      joiningDate: joiningDate ?? this.joiningDate,
      subjectsTaught: subjectsTaught ?? this.subjectsTaught,
      classesTaught: classesTaught ?? this.classesTaught,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
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
      'qualification': qualification,
      'position': position,
      'joiningDate': joiningDate.toIso8601String(),
      'subjectsTaught': subjectsTaught,
      'classesTaught': classesTaught,
      'profileImageUrl': profileImageUrl,
      'additionalInfo': additionalInfo,
    };
  }
  
  factory Teacher.fromJson(Map<String, dynamic> json) {
    return Teacher(
      id: json['id'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      dateOfBirth: DateTime.parse(json['dateOfBirth']),
      gender: json['gender'],
      address: json['address'],
      phone: json['phone'],
      email: json['email'],
      qualification: json['qualification'],
      position: json['position'],
      joiningDate: DateTime.parse(json['joiningDate']),
      subjectsTaught: List<String>.from(json['subjectsTaught']),
      classesTaught: List<String>.from(json['classesTaught']),
      profileImageUrl: json['profileImageUrl'],
      additionalInfo: json['additionalInfo'],
    );
  }
  
  // Generate mock data for demo purposes
  static List<Teacher> getMockData() {
    return [
      Teacher(
        firstName: 'Sarah',
        lastName: 'Thompson',
        dateOfBirth: DateTime(1985, 7, 12),
        gender: 'Female',
        address: '123 University Ave, Collegetown',
        phone: '555-111-2222',
        email: 'sarah.thompson@lapepiniere.edu',
        qualification: 'Ph.D. in Mathematics',
        position: 'Head of Mathematics Department',
        joiningDate: DateTime(2015, 8, 15),
        subjectsTaught: ['Mathematics', 'Advanced Algebra'],
        classesTaught: ['6A', '7A', '8A'],
        profileImageUrl: null,
      ),
      Teacher(
        firstName: 'David',
        lastName: 'Rodriguez',
        dateOfBirth: DateTime(1982, 3, 24),
        gender: 'Male',
        address: '456 College Street, Academyville',
        phone: '555-333-4444',
        email: 'david.rodriguez@lapepiniere.edu',
        qualification: 'M.Sc. in Physics',
        position: 'Science Teacher',
        joiningDate: DateTime(2018, 9, 1),
        subjectsTaught: ['Physics', 'General Science'],
        classesTaught: ['9A', '9B', '10A'],
        profileImageUrl: null,
      ),
      Teacher(
        firstName: 'Emily',
        lastName: 'Chen',
        dateOfBirth: DateTime(1990, 11, 5),
        gender: 'Female',
        address: '789 Scholar Lane, Learnington',
        phone: '555-555-6666',
        email: 'emily.chen@lapepiniere.edu',
        qualification: 'M.A. in English Literature',
        position: 'English Teacher',
        joiningDate: DateTime(2019, 8, 20),
        subjectsTaught: ['English Literature', 'Grammar'],
        classesTaught: ['6B', '7B', '8B'],
        profileImageUrl: null,
      ),
      Teacher(
        firstName: 'Michael',
        lastName: 'Okonkwo',
        dateOfBirth: DateTime(1978, 5, 18),
        gender: 'Male',
        address: '321 Educator Road, Teacherville',
        phone: '555-777-8888',
        email: 'michael.okonkwo@lapepiniere.edu',
        qualification: 'M.Sc. in Chemistry',
        position: 'Science Department Coordinator',
        joiningDate: DateTime(2010, 7, 30),
        subjectsTaught: ['Chemistry', 'Biology'],
        classesTaught: ['10B', '11A', '12A'],
        profileImageUrl: null,
      ),
      Teacher(
        firstName: 'Sophia',
        lastName: 'Kim',
        dateOfBirth: DateTime(1988, 9, 27),
        gender: 'Female',
        address: '654 Instructor Avenue, Schoolville',
        phone: '555-999-0000',
        email: 'sophia.kim@lapepiniere.edu',
        qualification: 'B.A. in History',
        position: 'History Teacher',
        joiningDate: DateTime(2020, 8, 10),
        subjectsTaught: ['History', 'Social Studies'],
        classesTaught: ['7A', '8A', '9A'],
        profileImageUrl: null,
      ),
    ];
  }
}
