import 'package:app_reserva/models/adress.dart';
import 'package:app_reserva/models/booking.dart';
import 'package:app_reserva/models/property.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:app_reserva/models/user.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseService {
  static Database? _db;
  static final DatabaseService instance = DatabaseService._constructor();
  DatabaseService._constructor();

  Future<Database> get database async {
    if (_db != null) {
      return _db!;
    } else {
      _db = await getDatabase();
      return _db!;
    }
  }

  Future<Database> getDatabase() async {
    String databasePath = '';
    if (kIsWeb) {
      databasePath = 'reserva_db.db';
    } else {
      final databaseDirPath = await getApplicationDocumentsDirectory();
      databasePath = join(databaseDirPath.path, '', 'reserva_db.db');
    }
    final database = await openDatabase(
      databasePath,
      version: 1,
      onCreate: (db, version) {
        db.execute('''
        CREATE TABLE user(
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name VARCHAR NOT NULL,
    email VARCHAR NOT NULL,
    password VARCHAR NOT NULL
);

INSERT INTO user(name, email, password) VALUES('Teste 1', 'teste1@teste', '123456');
INSERT INTO user(name, email, password) VALUES('Teste 2', 'teste2@teste', '123456');
INSERT INTO user(name, email, password) VALUES('Teste 3', 'teste3@teste', '123456');
INSERT INTO user(name, email, password) VALUES('Teste 4', 'teste4@teste', '123456');
INSERT INTO user(name, email, password) VALUES('Teste 5', 'teste5@teste', '123456');

CREATE TABLE address(
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    cep VARCHAR NOT NULL UNIQUE,
    logradouro VARCHAR NOT NULL,
    bairro VARCHAR NOT NULL,
    localidade VARCHAR NOT NULL,
    uf VARCHAR NOT NULL,
    estado VARCHAR NOT NULL
);

INSERT INTO address(cep, logradouro, bairro, localidade, uf, estado) VALUES('01001000', 'Praça da Sé', 'Sé', 'São Paulo', 'SP', 'São Paulo');
INSERT INTO address(cep, logradouro, bairro, localidade, uf, estado) VALUES('24210346', 'Avenida General Milton Tavares de Souza', 'Gragoatá', 'Niterói', 'RJ', 'Rio de Janeiro');

CREATE TABLE property(
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL,
	address_id INTEGER NOT NULL,
    title VARCHAR NOT NULL,
    description VARCHAR NOT NULL,
	number INTEGER NOT NULL,
    complement VARCHAR,
    price REAL NOT NULL,
    max_guest INTEGER NOT NULL,
    thumbnail VARCHAR NOT NULL,
    FOREIGN KEY(user_id) REFERENCES user(id),
	FOREIGN KEY(address_id) REFERENCES address(id)
);

INSERT INTO property(user_id, address_id, title, description, number, complement, price, max_guest, thumbnail) VALUES(1, 1, 'Apartamento Quarto Privativo', 'Apartamento perto do Centro com 2 quartos, cozinha e lavanderia.', 100, 'Apto 305', 120.0, 2, 'image_path');
INSERT INTO property(user_id, address_id, title, description, number, complement, price, max_guest, thumbnail) VALUES(1, 1, 'Hotel Ibis', 'Quarto Básico com cama casal.', 200, NULL, 220.0, 2, 'image_path');
INSERT INTO property(user_id, address_id, title, description, number, complement, price, max_guest, thumbnail) VALUES(1, 2, 'Pousada X', 'Quarto Básico com cama casal e cama de solteiro.', 300, NULL, 320.0, 3, 'image_path');
INSERT INTO property(user_id, address_id, title, description, number, complement, price, max_guest, thumbnail) VALUES(1, 2, 'Chalé perto de praia', 'Quarto com cama casal.', 400, NULL, 420.0, 2, 'image_path');


CREATE TABLE images(
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    property_id INTEGER NOT NULL,
    path VARCHAR NOT NULL,    
	FOREIGN KEY(property_id) REFERENCES property(id)
);

INSERT INTO images(property_id, path) VALUES(1, 'image_path_1' );
INSERT INTO images(property_id, path) VALUES(1, 'image_path_2' );
INSERT INTO images(property_id, path) VALUES(1, 'image_path_3' );
INSERT INTO images(property_id, path) VALUES(2, 'image_path_1' );
INSERT INTO images(property_id, path) VALUES(2, 'image_path_2' );
INSERT INTO images(property_id, path) VALUES(2, 'image_path_3' );

CREATE TABLE booking(
    id INTEGER PRIMARY KEY AUTOINCREMENT,
	user_id INTEGER NOT NULL,
	property_id INTEGER NOT NULL,
    checkin_date VARCHAR NOT NULL,
	checkout_date VARCHAR NOT NULL,
    total_days INTEGER NOT NULL,
    total_price REAL NOT NULL,
    amount_guest INTEGER NOT NULL,
    rating REAL,
	FOREIGN KEY(user_id) REFERENCES user(id),
	FOREIGN KEY(property_id) REFERENCES property(id)
);

INSERT INTO booking(user_id, property_id, checkin_date, checkout_date, total_days, total_price, amount_guest, rating) VALUES(4, 1, '2025-02-01', '2025-02-03', 2, 240.0, 2, NULL);

INSERT INTO booking(user_id, property_id, checkin_date, checkout_date, total_days, total_price, amount_guest, rating) VALUES(4, 2, '2025-04-01', '2025-04-03', 2, 480.0, 1, NULL);
INSERT INTO booking(user_id, property_id, checkin_date, checkout_date, total_days, total_price, amount_guest, rating) VALUES(3, 3, '2025-05-09', '2025-05-15', 6, 1920.0, 2, NULL);
INSERT INTO booking(user_id, property_id, checkin_date, checkout_date, total_days, total_price, amount_guest, rating) VALUES(5, 3, '2025-09-09', '2025-09-15', 6, 1920.0, 2, NULL);
INSERT INTO booking(user_id, property_id, checkin_date, checkout_date, total_days, total_price, amount_guest, rating) VALUES(1, 4, '2025-09-09', '2025-09-15', 6, 2520.0, 2, NULL);


select user.name, property.title, booking.checkin_date, booking.checkout_date, booking.total_price from booking left join user on booking.user_id = user.id left join property on property.id = booking.property_id;

select property.title, address.logradouro, address.bairro, address.localidade, address.uf, property.number, property.complement, property.price from property left join address on address.id = property.address_id;

select property.title, images.path from property left join images on property.id = images.property_id;

select id, checkin_date, strftime('%d', checkin_date) as 'Day' from booking where strftime('%m', checkin_date) = '04';
''');
      },
    );
    return database;
  }

  Future<User> createUser(String name, String password, String email) async {
    final db = await database;
    final id = await db.rawInsert(
        'INSERT INTO user(name, email, password) VALUES(?, ?, ?)',
        [name, email, password]);
    return User(id: id, name: name, email: email, password: password);
  }

  Future<List<Property>> getPropertiesByUserId(int userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'property',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
    return await Future.wait(maps.map((map) async {
      double avgRating = await getAvgRating(map['id']);
      return Property(
          id: map['id'],
          user_id: map['user_id'],
          address_id: map['address_id'],
          title: map['title'],
          description: map['description'],
          number: map['number'],
          complement:
              map['complement'] != null ? map['complement'] as String : "",
          price: map['price'],
          max_guest: map['max_guest'],
          thumbnail: map['thumbnail'],
          rating: avgRating);
    }));
  }

  Future<User?> login(String email, String password) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'user',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );
    if (maps.isNotEmpty) {
      return User(
        id: maps.first['id'],
        name: maps.first['name'],
        email: maps.first['email'],
        password: maps.first['password'],
      );
    }
    return null;
  }

  Future<Address> getAdressById(int addressId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'address',
      where: 'id = ?',
      whereArgs: [addressId],
    );
    if (maps.isNotEmpty) {
      return Address(
        id: maps.first['id'],
        cep: maps.first['cep'],
        logradouro: maps.first['logradouro'],
        bairro: maps.first['bairro'],
        localidade: maps.first['localidade'],
        uf: maps.first['uf'],
        estado: maps.first['estado'],
      );
    }
    return Address(
      id: 0,
      cep: '',
      logradouro: '',
      bairro: '',
      localidade: '',
      uf: '',
      estado: '',
    );
  }

  Future<List<Property>> searchProperties({
    String? uf,
    String? cidade,
    String? bairro,
    DateTime? checkin,
    DateTime? checkout,
    int? amountGuest,
  }) async {
    final db = await database;
    List<String> conditions = [];
    List<dynamic> args = [];
    if (uf != null && uf.isNotEmpty) {
      conditions.add("address.uf = ?");
      args.add(uf);
    }
    if (cidade != null && cidade.isNotEmpty) {
      conditions.add("address.localidade = ?");
      args.add(cidade);
    }
    if (bairro != null && bairro.isNotEmpty) {
      conditions.add("address.bairro = ?");
      args.add(bairro);
    }
    if (amountGuest != null) {
      conditions.add("property.max_guest >= ?");
      args.add(amountGuest);
    }
    final whereClause =
        conditions.isNotEmpty ? "WHERE ${conditions.join(" AND ")}" : "";
    final results = await db.rawQuery('''
      SELECT property.*
      FROM property
      JOIN address ON property.address_id = address.id
      $whereClause
    ''', args);
    List<Property> propertiesList = [];
    for (var property in results) {
      double avgRating = await getAvgRating(property['id'] as int);
      propertiesList.add(Property(
          id: property['id'] as int,
          user_id: property['user_id'] as int,
          address_id: property['address_id'] as int,
          title: property['title'] as String,
          description: property['description'] as String,
          number: property['number'] as int,
          complement: property['complement'] != null
              ? property['complement'] as String
              : "",
          price: property['price'] as double,
          max_guest: property['max_guest'] as int,
          thumbnail: property['thumbnail'] as String,
          rating: avgRating));
    }
    return propertiesList;
  }

  Future<double> getAvgRating(int propertyId) async {
    final db = await database;
    final result = await db.rawQuery(
      "SELECT AVG(rating) as avg_rating FROM booking WHERE property_id = ?",
      [propertyId],
    );
    final avgRating = result.isNotEmpty && result.first['avg_rating'] != null
        ? result.first['avg_rating'] as double
        : 0.0;
    return avgRating;
  }

  Future<void> createBooking(
      {required int userId,
      required Property property,
      required DateTime checkin,
      required DateTime checkout,
      required int amountGuest}) async {
    final db = await database;
    final totalDays = checkout.difference(checkin).inDays;
    final totalPrice = totalDays * property.price;
    await db.rawInsert(
      'INSERT INTO booking(user_id, property_id, checkin_date, checkout_date, total_days, total_price, amount_guest) VALUES(?, ?, ?, ?, ?, ?, ?)',
      [
        userId,
        property.id,
        checkin.toIso8601String().substring(0, 10),
        checkout.toIso8601String().substring(0, 10),
        totalDays,
        totalPrice,
        amountGuest,
      ],
    );
  }

  Future<void> cancelBooking(int bookingId) async {
    final db = await database;
    await db.delete(
      'booking',
      where: 'id = ?',
      whereArgs: [bookingId],
    );
  }

  Future<List<Booking>> getBookings(int userId) async {
    final db = await database;
    final bookings =
        await db.rawQuery('SELECT * FROM booking WHERE user_id = ?', [userId]);

    final List<Booking> bookingsList = [];
    for (var booking in bookings) {
      bookingsList.add(Booking(
        id: booking['id'] as int,
        user_id: booking['user_id'] as int,
        property_id: booking['property_id'] as int,
        checkin_date: booking['checkin_date'] as String,
        checkout_date: booking['checkout_date'] as String,
        total_days: booking['total_days'] as int,
        total_price: booking['total_price'] as double,
        amount_guests: booking['amount_guest'] as int,
        rating: booking['rating'] != null ? booking['rating'] as double : 0.0,
      ));
    }
    return bookingsList;
  }

  Future<Property?> getPropertyById(int propertyId) async {
    final db = await database;
    final results =
        await db.query('property', where: 'id = ?', whereArgs: [propertyId]);
    if (results.isNotEmpty) {
      final prop = results.first;
      double avgRating = await getAvgRating(prop['id'] as int);
      return Property(
        id: prop['id'] as int,
        user_id: prop['user_id'] as int,
        address_id: prop['address_id'] as int,
        title: prop['title'] as String,
        description: prop['description'] as String,
        number: prop['number'] as int,
        complement:
            prop['complement'] != null ? prop['complement'] as String : "",
        price: prop['price'] as double,
        max_guest: prop['max_guest'] as int,
        thumbnail: prop['thumbnail'] as String,
        rating: avgRating,
      );
    }
    return null;
  }
}
