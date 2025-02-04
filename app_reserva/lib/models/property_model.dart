import 'address_model.dart';

class Property {
  final int? id;
  final int userId;
  int? addressId;
  final String title;
  final String description;
  final int number;
  final String? complement;
  final double price;
  final int maxGuest;
  final String? thumbnail;
  final double? rating;
  final Address? address;

  Property({
    this.id,
    required this.userId,
    this.addressId,
    required this.title,
    required this.description,
    required this.number,
    this.complement,
    required this.price,
    required this.maxGuest,
    this.thumbnail,
    this.rating,
    this.address,
  });

  factory Property.fromMap(Map<String, dynamic> map) {
    return Property(
      id: map['id'],
      userId: map['user_id'],
      addressId: map['address_id'],
      title: map['title'],
      description: map['description'],
      number: map['number'],
      complement: map['complement'],
      price: map['price'],
      maxGuest: map['max_guest'],
      thumbnail: map['thumbnail'],
      rating: map['avg_rating'],
      address: map['address_id'] != null ? Address.fromMap(map) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'address_id': addressId,
      'title': title,
      'description': description,
      'number': number,
      'complement': complement,
      'price': price,
      'max_guest': maxGuest,
      'thumbnail': thumbnail,
    };
  }
}