class Address {
  final int? id;
  final String cep;
  final String logradouro;
  final String bairro;
  final String localidade;
  final String uf;
  final String estado;

  Address(
      {this.id,
      required this.cep,
      required this.logradouro,
      required this.bairro,
      required this.localidade,
      required this.uf,
      required this.estado});

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
        cep: json['cep'] ?? '',
        logradouro: json['logradouro'] ?? '',
        bairro: json['bairro'] ?? '',
        localidade: json['localidade'] ?? '',
        uf: json['uf'] ?? '',
        estado: json['estado'] ?? '');
  }

  factory Address.fromMap(Map<String, dynamic> map) {
    return Address(
      id: map['id'],
      cep: map['cep'],
      logradouro: map['logradouro'],
      bairro: map['bairro'],
      localidade: map['localidade'],
      uf: map['uf'],
      estado: map['estado'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'cep': cep,
      'logradouro': logradouro,
      'bairro': bairro,
      'localidade': localidade,
      'uf': uf,
      'estado': estado,
    };
  }
}
