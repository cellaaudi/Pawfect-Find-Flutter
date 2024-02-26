class Breed {
  final int id;
  final String breed;
  final String group;
  final double heightMin;
  final double heightMax;
  final double weightMin;
  final double weightMax;
  final double lifeMin;
  final double lifeMax;
  final String origin;
  final String colour;
  final String attention;
  final String imgPuppy;
  final String imgAdult;

  Breed({
    required this.id,
    required this.breed,
    required this.group,
    required this.heightMin,
    required this.heightMax,
    required this.weightMin,
    required this.weightMax,
    required this.lifeMin,
    required this.lifeMax,
    required this.origin,
    required this.colour,
    required this.attention,
    required this.imgPuppy,
    required this.imgAdult,
  });

  factory Breed.fromJson(Map<String, dynamic> json) {
    return Breed(
      id: json['id'] as int, 
      breed: json['breed'] as String,
      group: json['group'] as String,
      heightMin: json['height_min'] as double,
      heightMax: json['height_max'] as double,
      weightMin: json['weight_min'] as double,
      weightMax: json['weight_max'] as double,
      lifeMin: json['life_min'] as double,
      lifeMax: json['life_max'] as double,
      origin: json['origin'] as String,
      colour: json['colour'] as String,
      attention: json['attention'] as String,
      imgPuppy: json['img_puppy'] as String,
      imgAdult: json['img_adult'] as String,
      );
  }
}
