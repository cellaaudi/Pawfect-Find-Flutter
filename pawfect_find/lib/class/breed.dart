class Breed {
  final String breed;

  Breed({
    required this.breed,
  });

  factory Breed.fromJson(Map<String, dynamic> json) {
    return Breed(breed: json['breed'] as String);
  }
}
