import 'package:flutter/material.dart';

/// A themed set of objects to "collect" with Sankofa Lens. Membership is
/// decided by keyword-matching the recognised English label, since the
/// on-device model returns generic labels (e.g. "Dog", "Food", "Chair").
class LensCollection {
  final String id;
  final String name;
  final IconData icon;
  final List<String> keywords;
  final int goal;
  const LensCollection(this.id, this.name, this.icon, this.keywords,
      {this.goal = 5});

  bool matches(String english) {
    final s = english.toLowerCase();
    return keywords.any((k) => s.contains(k));
  }
}

const List<LensCollection> kLensCollections = [
  LensCollection('animals', 'Animals', Icons.pets, [
    'dog', 'cat', 'bird', 'animal', 'pet', 'horse', 'cow', 'goat', 'sheep',
    'chicken', 'fish', 'insect', 'butterfly', 'lizard', 'snake', 'mammal',
    'wildlife', 'rabbit', 'monkey', 'turtle'
  ]),
  LensCollection('food', 'Food & drink', Icons.restaurant, [
    'food', 'fruit', 'vegetable', 'dish', 'meal', 'drink', 'bread', 'rice',
    'meat', 'dessert', 'snack', 'produce', 'banana', 'plantain', 'egg',
    'coffee', 'tea', 'soup', 'cake', 'juice'
  ]),
  LensCollection('home', 'Home', Icons.chair_outlined, [
    'furniture', 'chair', 'table', 'bed', 'couch', 'sofa', 'lamp', 'cup',
    'plate', 'bottle', 'kitchen', 'door', 'window', 'appliance', 'clock',
    'book', 'bowl', 'mirror', 'rug', 'curtain'
  ]),
  LensCollection('nature', 'Nature', Icons.park_outlined, [
    'tree', 'flower', 'plant', 'sky', 'cloud', 'water', 'beach', 'mountain',
    'leaf', 'grass', 'sun', 'garden', 'landscape', 'river', 'forest', 'rock',
    'sea', 'sand', 'wood'
  ]),
  LensCollection('travel', 'Travel & street', Icons.directions_bus_outlined, [
    'car', 'vehicle', 'bus', 'road', 'building', 'bicycle', 'motorcycle',
    'boat', 'train', 'sign', 'street', 'traffic', 'wheel', 'tire', 'bridge',
    'market', 'shop', 'station'
  ]),
  LensCollection('people', 'People & style', Icons.checkroom_outlined, [
    'person', 'clothing', 'shoe', 'hat', 'dress', 'shirt', 'bag', 'glasses',
    'face', 'hand', 'jewelry', 'fashion', 'watch', 'scarf', 'sandal', 'cloth',
    'kente', 'beads'
  ]),
];

/// Number of distinct objects collected toward [c] from saved English labels.
int collectionCount(LensCollection c, Iterable<String> englishLabels) =>
    englishLabels.where(c.matches).toSet().length;

/// A milestone badge based on the total number of distinct finds.
class LensMilestone {
  final String name;
  final IconData icon;
  final int threshold;
  const LensMilestone(this.name, this.icon, this.threshold);
}

const List<LensMilestone> kLensMilestones = [
  LensMilestone('First find', Icons.auto_awesome, 1),
  LensMilestone('Explorer', Icons.explore_outlined, 5),
  LensMilestone('Collector', Icons.collections_bookmark_outlined, 15),
  LensMilestone('Curator', Icons.workspace_premium_outlined, 30),
];
