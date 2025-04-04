import 'dart:convert';

import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

import '../models/student.dart';
import '../models/teacher.dart';
import '../models/course.dart';

class DataService {
  static const String _studentsKey = 'students';
  static const String _teachersKey = 'teachers';
  static const String _coursesKey = 'courses';
  
  // STUDENT METHODS
  Future<List<Student>> getStudents() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final studentsJson = prefs.getStringList(_studentsKey);
      
      if (studentsJson == null || studentsJson.isEmpty) {
        // Load mock data for demo
        final students = Student.getMockData();
        saveStudents(students);
        return students;
      }
      
      return studentsJson
          .map((json) => Student.fromJson(jsonDecode(json)))
          .toList();
    } catch (e) {
      print('Error getting students: $e');
      return [];
    }
  }
  
  Future<void> saveStudents(List<Student> students) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final studentsJson = students
          .map((student) => jsonEncode(student.toJson()))
          .toList();
      
      await prefs.setStringList(_studentsKey, studentsJson);
    } catch (e) {
      print('Error saving students: $e');
    }
  }
  
  Future<Student?> getStudentById(String id) async {
    final students = await getStudents();
    return students.firstWhere((student) => student.id == id, orElse: () => throw Exception('Student not found'));
  }
  
  Future<void> addStudent(Student student) async {
    final students = await getStudents();
    students.add(student);
    await saveStudents(students);
  }
  
  Future<void> updateStudent(Student updatedStudent) async {
    final students = await getStudents();
    final index = students.indexWhere((student) => student.id == updatedStudent.id);
    
    if (index != -1) {
      students[index] = updatedStudent;
      await saveStudents(students);
    } else {
      throw Exception('Student not found');
    }
  }
  
  Future<void> deleteStudent(String id) async {
    final students = await getStudents();
    students.removeWhere((student) => student.id == id);
    await saveStudents(students);
  }
  
  // TEACHER METHODS
  Future<List<Teacher>> getTeachers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final teachersJson = prefs.getStringList(_teachersKey);
      
      if (teachersJson == null || teachersJson.isEmpty) {
        // Load mock data for demo
        final teachers = Teacher.getMockData();
        saveTeachers(teachers);
        return teachers;
      }
      
      return teachersJson
          .map((json) => Teacher.fromJson(jsonDecode(json)))
          .toList();
    } catch (e) {
      print('Error getting teachers: $e');
      return [];
    }
  }
  
  Future<void> saveTeachers(List<Teacher> teachers) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final teachersJson = teachers
          .map((teacher) => jsonEncode(teacher.toJson()))
          .toList();
      
      await prefs.setStringList(_teachersKey, teachersJson);
    } catch (e) {
      print('Error saving teachers: $e');
    }
  }
  
  Future<Teacher?> getTeacherById(String id) async {
    final teachers = await getTeachers();
    return teachers.firstWhere((teacher) => teacher.id == id, orElse: () => throw Exception('Teacher not found'));
  }
  
  Future<void> addTeacher(Teacher teacher) async {
    final teachers = await getTeachers();
    teachers.add(teacher);
    await saveTeachers(teachers);
  }
  
  Future<void> updateTeacher(Teacher updatedTeacher) async {
    final teachers = await getTeachers();
    final index = teachers.indexWhere((teacher) => teacher.id == updatedTeacher.id);
    
    if (index != -1) {
      teachers[index] = updatedTeacher;
      await saveTeachers(teachers);
    } else {
      throw Exception('Teacher not found');
    }
  }
  
  Future<void> deleteTeacher(String id) async {
    final teachers = await getTeachers();
    teachers.removeWhere((teacher) => teacher.id == id);
    await saveTeachers(teachers);
  }
  
  // COURSE METHODS
  Future<List<Course>> getCourses() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final coursesJson = prefs.getStringList(_coursesKey);
      
      if (coursesJson == null || coursesJson.isEmpty) {
        // Load mock data for demo
        final courses = Course.getMockData();
        saveCourses(courses);
        return courses;
      }
      
      return coursesJson
          .map((json) => Course.fromJson(jsonDecode(json)))
          .toList();
    } catch (e) {
      print('Error getting courses: $e');
      return [];
    }
  }
  
  Future<void> saveCourses(List<Course> courses) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final coursesJson = courses
          .map((course) => jsonEncode(course.toJson()))
          .toList();
      
      await prefs.setStringList(_coursesKey, coursesJson);
    } catch (e) {
      print('Error saving courses: $e');
    }
  }
  
  Future<Course?> getCourseById(String id) async {
    final courses = await getCourses();
    return courses.firstWhere((course) => course.id == id, orElse: () => throw Exception('Course not found'));
  }
  
  Future<void> addCourse(Course course) async {
    final courses = await getCourses();
    courses.add(course);
    await saveCourses(courses);
  }
  
  Future<void> updateCourse(Course updatedCourse) async {
    final courses = await getCourses();
    final index = courses.indexWhere((course) => course.id == updatedCourse.id);
    
    if (index != -1) {
      courses[index] = updatedCourse;
      await saveCourses(courses);
    } else {
      throw Exception('Course not found');
    }
  }
  
  Future<void> deleteCourse(String id) async {
    final courses = await getCourses();
    courses.removeWhere((course) => course.id == id);
    await saveCourses(courses);
  }
  
  // EXPORT/BACKUP DATA
  Future<String> exportData() async {
    try {
      final students = await getStudents();
      final teachers = await getTeachers();
      final courses = await getCourses();
      
      final exportData = {
        'students': students.map((s) => s.toJson()).toList(),
        'teachers': teachers.map((t) => t.toJson()).toList(),
        'courses': courses.map((c) => c.toJson()).toList(),
      };
      
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/la_pepiniere_backup.json');
      await file.writeAsString(jsonEncode(exportData));
      
      return file.path;
    } catch (e) {
      print('Error exporting data: $e');
      throw Exception('Failed to export data');
    }
  }
  
  // IMPORT DATA FROM BACKUP
  Future<void> importData(String filePath) async {
    try {
      final file = File(filePath);
      final jsonString = await file.readAsString();
      final data = jsonDecode(jsonString);
      
      // Parse and save students
      final studentsList = (data['students'] as List)
          .map((json) => Student.fromJson(json))
          .toList();
      await saveStudents(studentsList);
      
      // Parse and save teachers
      final teachersList = (data['teachers'] as List)
          .map((json) => Teacher.fromJson(json))
          .toList();
      await saveTeachers(teachersList);
      
      // Parse and save courses
      final coursesList = (data['courses'] as List)
          .map((json) => Course.fromJson(json))
          .toList();
      await saveCourses(coursesList);
      
    } catch (e) {
      print('Error importing data: $e');
      throw Exception('Failed to import data');
    }
  }
  
  // CLEAR ALL DATA
  Future<void> clearAllData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_studentsKey);
      await prefs.remove(_teachersKey);
      await prefs.remove(_coursesKey);
    } catch (e) {
      print('Error clearing data: $e');
    }
  }
}
