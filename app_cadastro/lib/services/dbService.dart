import 'package:app_cadastro/models/property.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:app_cadastro/models/user.dart';
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

  Future<Property> addProperty(
      int userId,
      String cep,
      String logradouro,
      String bairro,
      String localidade,
      String uf,
      String estado,
      String title,
      String description,
      int number,
      String complement,
      double price,
      int maxGuest,
      String thumbnail) async {
    final db = await database;
    int propertyId = 0;
    int addressId = 0;
    await db.transaction((txn) async {
      final address =
          await txn.rawQuery('SELECT id FROM address WHERE cep = ?', [cep]);

      if (address.isNotEmpty) {
        addressId = address.first['id'] as int;
      } else {
        addressId = await txn.rawInsert(
            'INSERT INTO address(cep, logradouro, bairro, localidade, uf, estado) VALUES(?, ?, ?, ?, ?, ?)',
            [cep, logradouro, bairro, localidade, uf, estado]);
      }
      propertyId = await txn.rawInsert(
          'INSERT INTO property(user_id, address_id, title, description, number, complement, price, max_guest, thumbnail) VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?)',
          [
            userId,
            addressId,
            title,
            description,
            number,
            complement,
            price,
            maxGuest,
            thumbnail
          ]);
    });

    return Property(
        id: propertyId,
        user_id: userId,
        address_id: addressId,
        title: title,
        description: description,
        number: number,
        complement: complement,
        price: price,
        max_guest: maxGuest,
        thumbnail: thumbnail);
  }

  Future<void> addImg(int propertyId, List<String> images) async {
    final db = await database;
    await db.transaction((t) async {
      for (var image in images) {
        await t.rawInsert('INSERT INTO images(property_id, path) VALUES(?, ?)',
            [propertyId, image]);
      }
    });
  }

  Future<List<Property>> getPropertiesByUserId(int userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'property',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
    return List.generate(maps.length, (i) {
      return Property(
        id: maps[i]['id'],
        user_id: maps[i]['user_id'],
        address_id: maps[i]['address_id'],
        title: maps[i]['title'],
        description: maps[i]['description'],
        number: maps[i]['number'],
        complement: maps[i]['complement'] != null
            ? maps[i]['complement'] as String
            : "",
        price: maps[i]['price'],
        max_guest: maps[i]['max_guest'],
        thumbnail: maps[i]['thumbnail'],
      );
    });
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

  Future<void> deletePropertyAndImages(int propertyId) async {
    final db = await database;
    await db.transaction((txn) async {
      final List<Map<String, dynamic>> result = await txn.query(
        'property',
        columns: ['address_id'],
        where: 'id = ?',
        whereArgs: [propertyId],
      );
      if (result.isNotEmpty) {
        // Deleta imagens
        await txn.delete('images',
            where: 'property_id = ?', whereArgs: [propertyId]);
        // Deleta propriedade
        await txn.delete('property', where: 'id = ?', whereArgs: [propertyId]);
      }
    });
  }

  Future<void> editProperty({
    required int propertyId,
    required String title,
    required String description,
    required int number,
    String? complement,
    required double price,
    required int max_guest,
    required String thumbnail,
    required String cep,
    required String logradouro,
    required String bairro,
    required String localidade,
    required String uf,
    required String estado,
    required List<String> images,
  }) async {
    final db = await database;
    await db.transaction((txn) async {
      final List<Map<String, dynamic>> result = await txn.query(
        'property',
        columns: ['address_id'],
        where: 'id = ?',
        whereArgs: [propertyId],
      );
      if (result.isEmpty) {
        throw Exception('Property not found');
      }
      final addressId = result.first['address_id'];
      await txn.update(
        'address',
        {
          'cep': cep,
          'logradouro': logradouro,
          'bairro': bairro,
          'localidade': localidade,
          'uf': uf,
          'estado': estado,
        },
        where: 'id = ?',
        whereArgs: [addressId],
      );
      await txn.update(
        'property',
        {
          'title': title,
          'description': description,
          'number': number,
          'complement': complement,
          'price': price,
          'max_guest': max_guest,
          'thumbnail': thumbnail,
        },
        where: 'id = ?',
        whereArgs: [propertyId],
      );
      await txn.delete(
        'images',
        where: 'property_id = ?',
        whereArgs: [propertyId],
      );
      for (var image in images) {
        await txn.rawInsert(
          'INSERT INTO images(property_id, path) VALUES(?, ?)',
          [propertyId, image],
        );
      }
    });
  }
}
