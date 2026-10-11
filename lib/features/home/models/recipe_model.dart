import 'package:equatable/equatable.dart';

class RecipeModel extends Equatable {
  final int id;
  final String name;
  final List<String> ingredients;
  final List<String> instructions;
  final int prepTimeMinutes;
  final int cookTimeMinutes;
  final int servings;
  final String difficulty;
  final String cuisine;
  final int caloriesPerServing;
  final List<String> tags;
  final int userId;
  final String image;
  final double rating;
  final int reviewCount;
  final List<String> mealType;
  final double price;
  final bool isFavorite;

  const RecipeModel({
    required this.id,
    required this.name,
    required this.ingredients,
    required this.instructions,
    required this.prepTimeMinutes,
    required this.cookTimeMinutes,
    required this.servings,
    required this.difficulty,
    required this.cuisine,
    required this.caloriesPerServing,
    required this.tags,
    required this.userId,
    required this.image,
    required this.rating,
    required this.reviewCount,
    required this.mealType,
    required this.price,
    this.isFavorite = false,
  });

  RecipeModel copyWith({
    bool? isFavorite,
  }) {
    return RecipeModel(
      id: id,
      name: name,
      ingredients: ingredients,
      instructions: instructions,
      prepTimeMinutes: prepTimeMinutes,
      cookTimeMinutes: cookTimeMinutes,
      servings: servings,
      difficulty: difficulty,
      cuisine: cuisine,
      caloriesPerServing: caloriesPerServing,
      tags: tags,
      userId: userId,
      image: image,
      rating: rating,
      reviewCount: reviewCount,
      mealType: mealType,
      price: price,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  factory RecipeModel.fromJson(Map<String, dynamic> json) {
    // Generate realistic price if not present (DummyJSON doesn't provide price on recipes)
    final idVal = json['id'] is int ? json['id'] as int : int.tryParse(json['id']?.toString() ?? '1') ?? 1;
    final rawPrice = json['price'] != null
        ? (json['price'] as num).toDouble()
        : (10.0 + (idVal * 7.25) % 95.0);

    return RecipeModel(
      id: idVal,
      name: json['name'] as String? ?? 'Delicious Dish',
      ingredients: (json['ingredients'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      instructions: (json['instructions'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      prepTimeMinutes: json['prepTimeMinutes'] as int? ?? 15,
      cookTimeMinutes: json['cookTimeMinutes'] as int? ?? 15,
      servings: json['servings'] as int? ?? 2,
      difficulty: json['difficulty'] as String? ?? 'Easy',
      cuisine: json['cuisine'] as String? ?? 'International',
      caloriesPerServing: json['caloriesPerServing'] as int? ?? 250,
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      userId: json['userId'] as int? ?? 1,
      image: json['image'] as String? ?? '',
      rating: (json['rating'] is num) ? (json['rating'] as num).toDouble() : 4.5,
      reviewCount: json['reviewCount'] as int? ?? 20,
      mealType: (json['mealType'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      price: json['price'] != null
          ? (json['price'] as num).toDouble()
          : double.parse(rawPrice.toStringAsFixed(1)),
      isFavorite: false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'ingredients': ingredients,
      'instructions': instructions,
      'prepTimeMinutes': prepTimeMinutes,
      'cookTimeMinutes': cookTimeMinutes,
      'servings': servings,
      'difficulty': difficulty,
      'cuisine': cuisine,
      'caloriesPerServing': caloriesPerServing,
      'tags': tags,
      'userId': userId,
      'image': image,
      'rating': rating,
      'reviewCount': reviewCount,
      'mealType': mealType,
      'price': price,
      'isFavorite': isFavorite,
    };
  }

  @override
  List<Object?> get props => [
        id,
        name,
        image,
        rating,
        price,
        isFavorite,
      ];
}
