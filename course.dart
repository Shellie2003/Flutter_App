import 'package:uuid/uuid.dart';

class Course {
  final String id;
  final String name;
  final String code;
  final String description;
  final String teacherId;
  final List<String> gradeLevel;
  final List<String> sections;
  final int credits;
  final String courseType; // 'Core', 'Elective', 'Enrichment', etc.
  final Map<String, dynamic> syllabus;
  final Map<String, dynamic> additionalInfo;
  
  Course({
    String? id,
    required this.name,
    required this.code,
    required this.description,
    required this.teacherId,
    required this.gradeLevel,
    required this.sections,
    required this.credits,
    required this.courseType,
    Map<String, dynamic>? syllabus,
    Map<String, dynamic>? additionalInfo,
  }) : 
    id = id ?? const Uuid().v4(),
    syllabus = syllabus ?? {},
    additionalInfo = additionalInfo ?? {};
  
  Course copyWith({
    String? name,
    String? code,
    String? description,
    String? teacherId,
    List<String>? gradeLevel,
    List<String>? sections,
    int? credits,
    String? courseType,
    Map<String, dynamic>? syllabus,
    Map<String, dynamic>? additionalInfo,
  }) {
    return Course(
      id: this.id,
      name: name ?? this.name,
      code: code ?? this.code,
      description: description ?? this.description,
      teacherId: teacherId ?? this.teacherId,
      gradeLevel: gradeLevel ?? this.gradeLevel,
      sections: sections ?? this.sections,
      credits: credits ?? this.credits,
      courseType: courseType ?? this.courseType,
      syllabus: syllabus ?? this.syllabus,
      additionalInfo: additionalInfo ?? this.additionalInfo,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'description': description,
      'teacherId': teacherId,
      'gradeLevel': gradeLevel,
      'sections': sections,
      'credits': credits,
      'courseType': courseType,
      'syllabus': syllabus,
      'additionalInfo': additionalInfo,
    };
  }
  
  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id'],
      name: json['name'],
      code: json['code'],
      description: json['description'],
      teacherId: json['teacherId'],
      gradeLevel: List<String>.from(json['gradeLevel']),
      sections: List<String>.from(json['sections']),
      credits: json['credits'],
      courseType: json['courseType'],
      syllabus: json['syllabus'],
      additionalInfo: json['additionalInfo'],
    );
  }
  
  // Generate mock data for demo purposes
  static List<Course> getMockData() {
    return [
      Course(
        name: 'Advanced Mathematics',
        code: 'MATH101',
        description: 'A comprehensive course covering algebraic concepts, geometry, and introductory calculus.',
        teacherId: '1', // Assuming Sarah Thompson's ID
        gradeLevel: ['6', '7', '8'],
        sections: ['A', 'B'],
        credits: 4,
        courseType: 'Core',
        syllabus: {
          'units': [
            {
              'title': 'Algebraic Expressions',
              'topics': ['Variables', 'Coefficients', 'Like Terms', 'Simplification']
            },
            {
              'title': 'Equations and Inequalities',
              'topics': ['Linear Equations', 'Quadratic Equations', 'Inequalities']
            },
            {
              'title': 'Geometry',
              'topics': ['Angles', 'Triangles', 'Circles', 'Area and Volume']
            },
          ]
        },
      ),
      Course(
        name: 'Physics Fundamentals',
        code: 'PHYS201',
        description: 'An introduction to basic physics principles, mechanics, and energy.',
        teacherId: '2', // Assuming David Rodriguez's ID
        gradeLevel: ['9', '10'],
        sections: ['A', 'B'],
        credits: 3,
        courseType: 'Core',
        syllabus: {
          'units': [
            {
              'title': 'Mechanics',
              'topics': ['Newton\'s Laws', 'Motion', 'Forces']
            },
            {
              'title': 'Energy',
              'topics': ['Potential Energy', 'Kinetic Energy', 'Conservation of Energy']
            },
            {
              'title': 'Waves',
              'topics': ['Wave Properties', 'Sound', 'Light']
            },
          ]
        },
      ),
      Course(
        name: 'English Literature',
        code: 'ENG301',
        description: 'A study of classic and contemporary literature with focus on analysis and interpretation.',
        teacherId: '3', // Assuming Emily Chen's ID
        gradeLevel: ['6', '7', '8'],
        sections: ['B'],
        credits: 3,
        courseType: 'Core',
        syllabus: {
          'units': [
            {
              'title': 'Short Stories',
              'topics': ['Elements of Fiction', 'Theme', 'Character Analysis']
            },
            {
              'title': 'Poetry',
              'topics': ['Poetic Devices', 'Forms of Poetry', 'Interpretation']
            },
            {
              'title': 'Novels',
              'topics': ['Plot Development', 'Setting', 'Narrative Voice']
            },
          ]
        },
      ),
      Course(
        name: 'Chemistry',
        code: 'CHEM401',
        description: 'A study of chemical principles, reactions, and laboratory techniques.',
        teacherId: '4', // Assuming Michael Okonkwo's ID
        gradeLevel: ['10', '11', '12'],
        sections: ['A', 'B'],
        credits: 4,
        courseType: 'Core',
        syllabus: {
          'units': [
            {
              'title': 'Atomic Structure',
              'topics': ['Atoms', 'Elements', 'Periodic Table']
            },
            {
              'title': 'Chemical Bonding',
              'topics': ['Ionic Bonds', 'Covalent Bonds', 'Molecular Geometry']
            },
            {
              'title': 'Chemical Reactions',
              'topics': ['Balancing Equations', 'Types of Reactions', 'Stoichiometry']
            },
          ]
        },
      ),
      Course(
        name: 'World History',
        code: 'HIST101',
        description: 'An exploration of major events, civilizations, and developments throughout world history.',
        teacherId: '5', // Assuming Sophia Kim's ID
        gradeLevel: ['7', '8', '9'],
        sections: ['A'],
        credits: 3,
        courseType: 'Core',
        syllabus: {
          'units': [
            {
              'title': 'Ancient Civilizations',
              'topics': ['Mesopotamia', 'Egypt', 'Greece', 'Rome']
            },
            {
              'title': 'Middle Ages',
              'topics': ['Feudalism', 'Medieval Europe', 'Islamic World']
            },
            {
              'title': 'Modern Era',
              'topics': ['Renaissance', 'Industrial Revolution', 'World Wars']
            },
          ]
        },
      ),
    ];
  }
}
