import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> seedRoutes() async {
  final db = FirebaseFirestore.instance;
  final routes = db.collection('routes');

  final List<Map<String, dynamic>> data = [
    {
      'destination': 'Ayala Center Cebu',
      'origin': 'Carbon Market',
      'tags': ['13C', 'via 13C'],
      'fare': 15,
      'stars': 4.5,
      'upvotes': 134,
      'tips': 'Ride 13C from Carbon. Tell the driver to drop you off at Ayala. Very direct route, no transfers needed.',
      'steps': [
        {'jeepCode': '13C', 'description': 'Ride from Carbon Market going to Ayala Center Cebu.', 'fare': 'P15'},
      ],
      'postedBy': 'user_001',
      'postedByName': 'Juan D.',
      'createdAt': FieldValue.serverTimestamp(),
    },
    {
      'destination': 'SM Seaside Cebu',
      'origin': 'Carbon Market',
      'tags': ['13C → 04L', 'SM City–MyBus to Seaside'],
      'fare': 60,
      'stars': 4.0,
      'upvotes': 98,
      'tips': 'Take 13C to SM City first, then ride MyBus going to Seaside. MyBus is air-conditioned and very comfortable.',
      'steps': [
        {'jeepCode': '13C', 'description': 'Ride from Carbon to SM City Cebu.', 'fare': 'P15'},
        {'jeepCode': 'MyBus', 'description': 'Board MyBus at SM City going to SM Seaside.', 'fare': 'P45'},
      ],
      'postedBy': 'user_002',
      'postedByName': 'Maria S.',
      'createdAt': FieldValue.serverTimestamp(),
    },
    {
      'destination': 'Il Corso',
      'origin': 'Carbon Market',
      'tags': ['13C → Ayala', '04L → MyBus to Il Corso'],
      'fare': 80,
      'stars': 3.0,
      'upvotes': 61,
      'tips': 'A bit mahal but okay. MyBus from SM City goes directly to Il Corso. Expect 30–45 mins travel time.',
      'steps': [
        {'jeepCode': '13C', 'description': 'Ride from Carbon to Ayala Center.', 'fare': 'P15'},
        {'jeepCode': '04L', 'description': 'Transfer to 04L jeep going to SM City.', 'fare': 'P15'},
        {'jeepCode': 'MyBus', 'description': 'Ride MyBus from SM City to Il Corso.', 'fare': 'P50'},
      ],
      'postedBy': 'user_003',
      'postedByName': 'Renz M.',
      'createdAt': FieldValue.serverTimestamp(),
    },
    {
      'destination': 'Anjo World',
      'origin': 'Carbon Market',
      'tags': ['13C → Ayala', '04L → MyBus to Anjo World'],
      'fare': 80,
      'stars': 4.5,
      'upvotes': 87,
      'tips': 'Best to go early on weekends — Anjo World gets packed by noon. MyBus is the most convenient option.',
      'steps': [
        {'jeepCode': '13C', 'description': 'Ride from Carbon to Ayala Center.', 'fare': 'P15'},
        {'jeepCode': '04L', 'description': 'Transfer to 04L going to SM City.', 'fare': 'P15'},
        {'jeepCode': 'MyBus', 'description': 'Ride MyBus from SM City to Anjo World.', 'fare': 'P50'},
      ],
      'postedBy': 'user_004',
      'postedByName': 'Lia T.',
      'createdAt': FieldValue.serverTimestamp(),
    },
    {
      'destination': 'SM City Cebu',
      'origin': 'Carbon Market',
      'tags': ['13C → Ayala', '04L → SM City'],
      'fare': 30,
      'stars': 5.0,
      'upvotes': 203,
      'tips': 'Super dali. 13C from Carbon to Ayala, then 04L to SM City. Both jeeps are frequent so no long waiting.',
      'steps': [
        {'jeepCode': '13C', 'description': 'Ride from Carbon to Ayala Center.', 'fare': 'P15'},
        {'jeepCode': '04L', 'description': 'Transfer to 04L jeep going to SM City Cebu.', 'fare': 'P15'},
      ],
      'postedBy': 'user_005',
      'postedByName': 'Carlo B.',
      'createdAt': FieldValue.serverTimestamp(),
    },
    {
      'destination': 'IT Park',
      'origin': 'Carbon Market',
      'tags': ['13C → IT Park'],
      'fare': 17,
      'stars': 5.0,
      'upvotes': 176,
      'tips': 'Very direct. 13C passes through IT Park on its route. Just tell the driver "IT Park" and he will drop you off at the entrance.',
      'steps': [
        {'jeepCode': '13C', 'description': 'Ride from Carbon Market directly to IT Park.', 'fare': 'P17'},
      ],
      'postedBy': 'user_001',
      'postedByName': 'Juan D.',
      'createdAt': FieldValue.serverTimestamp(),
    },
    {
      'destination': 'SM J Mall',
      'origin': 'Consolacion',
      'tags': ['01B Consolacion'],
      'fare': 18,
      'stars': 4.5,
      'upvotes': 55,
      'tips': 'Ride early in the morning to avoid traffic near Carbon. The jeep drops you off near the mall entrance. Very affordable for a one-ride trip.',
      'steps': [
        {'jeepCode': '01B', 'description': 'Ride from Consolacion terminal going to Carbon. SM J Mall is along the route.', 'fare': 'P18'},
      ],
      'postedBy': 'user_006',
      'postedByName': 'Bea R.',
      'createdAt': FieldValue.serverTimestamp(),
    },
  ];

  for (final route in data) {
    await routes.add(route);
  }

  print('✅ Seeded ${data.length} routes successfully.');
}