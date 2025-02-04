import 'package:app_reserva/models/adress.dart';

class Property {
  final int id;
  final int user_id;
  final int address_id;
  final String title;
  final String description;
  final int number;
  final String complement;
  final double price;
  final int max_guest;
  String thumbnail = 'image_path';
  final double rating;

  Property(
      {required this.id,
      required this.user_id,
      required this.address_id,
      required this.title,
      required this.description,
      required this.number,
      required this.complement,
      required this.price,
      required this.max_guest,
      this.thumbnail = 'image_path',
      Address? address,
      required this.rating});

  factory Property.fromMap(Map<String, dynamic> map) {
    return Property(
      id: map['id'],
      user_id: map['user_id'],
      address_id: map['address_id'],
      title: map['title'],
      description: map['description'],
      number: map['number'],
      complement: map['complement'],
      price: map['price'],
      max_guest: map['max_guest'],
      thumbnail: map['thumbnail'],
      address: map['address_id'] != null ? Address.fromMap(map) : null,
      rating: map['rating'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'user_id': user_id,
      'address_id': address_id,
      'title': title,
      'description': description,
      'number': number,
      'complement': complement,
      'price': price,
      'max_guest': max_guest,
      'thumbnail': thumbnail,
      'rating': rating,
    };
  }
}
