import 'package:app_reserva/database/database_helper.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import '../models/property_model.dart';
import '../services/via_cep_service.dart';

class PropertyProvider with ChangeNotifier {
  List<Property> _properties = [];
  List<Property> get properties => _properties;

  Future<List<Property>> searchProperties({
    String? uf,
    String? city,
    String? neighborhood,
    DateTime? checkIn,
    DateTime? checkOut,
    int? guests,
  }) async {
    final db = await DatabaseHelper().database;

    String query = '''
      SELECT p.*, a.*, 
      (SELECT AVG(rating) FROM booking WHERE property_id = p.id) as avg_rating
      FROM property p
      JOIN address a ON p.address_id = a.id
      WHERE 1=1
    ''';

    List<dynamic> args = [];

    if (uf != null) {
      query += ' AND a.uf = ?';
      args.add(uf);
    }
    if (city != null) {
      query += ' AND a.localidade = ?';
      args.add(city);
    }
    if (neighborhood != null) {
      query += ' AND a.bairro = ?';
      args.add(neighborhood);
    }
    if (guests != null) {
      query += ' AND p.max_guest >= ?';
      args.add(guests);
    }

    // Add date availability check (if check-in and check-out provided)
    if (checkIn != null && checkOut != null) {
      query += ''' 
        AND p.id NOT IN (
          SELECT DISTINCT property_id 
          FROM booking 
          WHERE (
            (checkin_date <= ? AND checkout_date >= ?) OR
            (checkin_date <= ? AND checkout_date >= ?)
          )
        )
      ''';
      args.addAll([
        DateFormat('yyyy-MM-dd').format(checkIn),
        DateFormat('yyyy-MM-dd').format(checkIn),
        DateFormat('yyyy-MM-dd').format(checkOut),
        DateFormat('yyyy-MM-dd').format(checkOut)
      ]);
    }

    final results = await db.rawQuery(query, args);
    
    _properties = results.map((map) => Property.fromMap(map)).toList();
    notifyListeners();
    return _properties;
  }

  Future<Property?> getPropertyDetails(int propertyId) async {
    final db = await DatabaseHelper().database;
    
    final results = await db.rawQuery('''
      SELECT p.*, a.*, 
      (SELECT AVG(rating) FROM booking WHERE property_id = p.id) as avg_rating,
      (SELECT path FROM images WHERE property_id = p.id) as additional_images
      FROM property p
      JOIN address a ON p.address_id = a.id
      WHERE p.id = ?
    ''', [propertyId]);

    return results.isNotEmpty ? Property.fromMap(results.first) : null;
  }

  Future<bool> createProperty(Property property, String cep) async {
    final db = await DatabaseHelper().database;
    
    // First, get or create address
    final addressInfo = await ViaCepService().getAddressByCep(cep);
    
    if (addressInfo == null) return false;

    // Start a transaction
    return db.transaction((txn) async {
      // Insert address if not exists
      final addressId = await txn.insert(
        'address', 
        addressInfo.toMap(), 
        conflictAlgorithm: ConflictAlgorithm.replace
      );

      // Insert property with address ID
      property.addressId = addressId;
      final propertyId = await txn.insert('property', property.toMap());

      // Insert thumbnail and additional images if any
      if (property.thumbnail != null) {
        await txn.insert('images', {
          'property_id': propertyId,
          'path': property.thumbnail
        });
      }
    }).then((_) => true).catchError((_) => false);
  }
}