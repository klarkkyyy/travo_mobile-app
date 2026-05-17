import 'package:cloud_firestore/cloud_firestore.dart';

class RouteStep {
  final String description;
  final String fare;
  final String jeepCode;
  final String dropOff;

  RouteStep({
    required this.description,
    required this.fare,
    required this.jeepCode,
    required this.dropOff,
  });

  factory RouteStep.fromMap(Map<String, dynamic> map) {
    return RouteStep(
      description: map['description'] ?? '',
      fare: map['fare'] ?? '',
      jeepCode: map['jeepCode'] ?? '',
      dropOff: map['dropOff'] ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
        'description': description,
        'fare': fare,
        'jeepCode': jeepCode,
        'dropOff': dropOff,
      };
}

class RoutePost {
  final String id;
  final String destination;
  final String origin;
  final List<String> tags;
  final int fare;
  final double stars;
  final int upvotes;
  final String tips;
  final String postedBy;
  final String postedByName;
  final DateTime createdAt;
  final List<RouteStep> steps;

  RoutePost({
    required this.id,
    required this.destination,
    required this.origin,
    required this.tags,
    required this.fare,
    required this.stars,
    required this.upvotes,
    required this.tips,
    required this.postedBy,
    required this.postedByName,
    required this.createdAt,
    required this.steps,
  });

  factory RoutePost.fromDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;

    final rawSteps = d['steps'] as List<dynamic>? ?? [];
    final steps = rawSteps
        .map((s) => RouteStep.fromMap(Map<String, dynamic>.from(s)))
        .toList();

    final ts = d['createdAt'];
    final createdAt =
        ts != null ? (ts as Timestamp).toDate() : DateTime.now();

    return RoutePost(
      id: doc.id,
      destination: d['destination'] ?? '',
      origin: d['origin'] ?? '',
      tags: List<String>.from(d['tags'] ?? []),
      fare: (d['fare'] is int)
          ? d['fare']
          : int.tryParse(d['fare'].toString()) ?? 0,
      stars: (d['stars'] ?? 0).toDouble(),
      upvotes: d['upvotes'] ?? 0,
      tips: d['tips'] ?? '',
      postedBy: d['postedBy'] ?? '',
      postedByName: d['postedByName'] ?? '',
      createdAt: createdAt,
      steps: steps,
    );
  }
}