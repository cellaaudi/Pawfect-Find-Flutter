class Breed {
  final int id;
  final String breed;

  Breed({
    required this.id,
    required this.breed,
  });

  factory Breed.fromJson(Map<String, dynamic> json) {
    return Breed(id: json['id'] as int, breed: json['breed'] as String);
  }
}
