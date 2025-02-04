import 'package:app_reserva/database/database_helper.dart';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';

class AuthProvider with ChangeNotifier {
  User? _currentUser;
  bool _isLoggedIn = false;

  User? get currentUser => _currentUser;
  bool get isLoggedIn => _isLoggedIn;

  Future<bool> login(String email, String password) async {
    final db = await DatabaseHelper().database;
    
    final users = await db.query(
      'user', 
      where: 'email = ? AND password = ?', 
      whereArgs: [email, password]
    );

    if (users.isNotEmpty) {
      _currentUser = User.fromMap(users.first);
      _isLoggedIn = true;
      notifyListeners();
      return true;
    }
    
    return false;
  }

  Future<bool> register(String name, String email, String password) async {
    final db = await DatabaseHelper().database;
    
    try {
      final id = await db.insert('user', {
        'name': name,
        'email': email,
        'password': password
      });

      _currentUser = User(id: id, name: name, email: email);
      _isLoggedIn = true;
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  void logout() {
    _currentUser = null;
    _isLoggedIn = false;
    notifyListeners();
  }
}