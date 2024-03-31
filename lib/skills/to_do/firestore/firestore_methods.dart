import 'package:cloud_firestore/cloud_firestore.dart';

import '/skills/to_do/models/task_model.dart';

class Firestore {
  static final _firestore = FirebaseFirestore.instance;
  static const _tasks = 'tasks';
  // static const _tasks = 'tasksTest'; // for testing

  static Future<String> addTask(Task task) async {
    try {
      DocumentReference docRef =
          await _firestore.collection(_tasks).add(task.toFirestore());
      return docRef.id;
    } catch (e) {
      print(e);
      return '';
    }
  }

  static Future<bool> updateTask(Task task) async {
    try {
      await _firestore
          .collection(_tasks)
          .doc(task.id)
          .update(task.toFirestore());
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  static Future<void> deleteTask(String taskId) async {
    try {
      await _firestore.collection(_tasks).doc(taskId).delete();
    } catch (e) {
      print(e);
    }
  }

  static Future<void> deleteSubTask(
      String parentTaskId, String subTaskId) async {
    try {
      await _firestore.collection(_tasks).doc(parentTaskId).update({
        TaskFields.subTasks: FieldValue.arrayRemove([subTaskId])
      });
    } catch (e) {
      print(e);
    }
  }

  static Future<void> addSubTask(String parentTaskId, String subTaskId) async {
    try {
      await _firestore.collection(_tasks).doc(parentTaskId).update({
        TaskFields.subTasks: FieldValue.arrayUnion([subTaskId])
      });
    } catch (e) {
      print(e);
    }
  }

  static Future<void> reorderSubTask(
      String parentTaskId, List<String> subTasks) async {
    try {
      await _firestore
          .collection(_tasks)
          .doc(parentTaskId)
          .update({TaskFields.subTasks: subTasks});
    } catch (e) {
      print(e);
    }
  }

  static Future<Task?> getTask(String taskId) async {
    try {
      DocumentSnapshot docSnapshot =
          await _firestore.collection(_tasks).doc(taskId).get();
      if (docSnapshot.exists) {
        return Task.fromFirestore(docSnapshot);
      } else {
        print('No task found with id $taskId');
        return null;
      }
    } catch (e) {
      print('Error getting task: $e');
      return null;
    }
  }

  static Future<List<Task>> getTasks() async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection(_tasks)
          .where(TaskFields.isDone, isEqualTo: false)
          .where(TaskFields.parentTaskId, isNull: true)
          .get();
      return querySnapshot.docs.map((doc) => Task.fromFirestore(doc)).toList();
    } catch (e) {
      print(e);
      return [];
    }
  }
}
