import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import 'package:data_persistence_networking_app/providers/fitness_provider.dart';

import 'firebase_options.dart';
import 'models/fitness_model.dart';
import 'services/storage_service.dart';
import 'screens/exercise_detail_screen.dart';


class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<List<Food>> fetchFoods() async {
    try {
      QuerySnapshot snapshot = await _db.collection('foods').get();
      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return Food(
          name: data['name'] ?? 'Unknown',
          calories: data['calories'] ?? 0,
          protein: (data['protein'] ?? 0).toDouble(),
          fat: (data['fat'] ?? 0).toDouble(),
          carbs: (data['carbs'] ?? 0).toDouble(),
        );
      }).toList();
    } catch (e) {
      throw Exception('Failed to load foods from Firestore: $e');
    }
  }
}

class LocalDbService {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('favorites.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE favorites (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            imageUrl TEXT NOT NULL
          )
        ''');
      },
    );
  }

  Future<void> addFavorite(String title, String imageUrl) async {
    final db = await database;
    await db.insert(
      'favorites',
      {'title': title, 'imageUrl': imageUrl},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getFavorites() async {
    final db = await database;
    return await db.query('favorites');
  }

  Future<void> removeFavorite(int id) async {
    final db = await database;
    await db.delete('favorites', where: 'id = ?', whereArgs: [id]);
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    ChangeNotifierProvider(
      create: (context) => FitnessProvider(),
      child: const FitApp(),
    ),
  );
}

class FitApp extends StatelessWidget {
  const FitApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.deepPurple, useMaterial3: true, scaffoldBackgroundColor: Colors.grey[300]),
      home: const MainNavigationScreen(),
    );
  }
}


class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});
  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;
  final StorageService _storage = StorageService();
  String _userName = "User";

  @override
  void initState() {
    super.initState();
    _loadName();
  }

  _loadName() async {
    String name = await _storage.getName();
    setState(() => _userName = name);
  }

  @override
  Widget build(BuildContext context) {
    final fitnessProvider = Provider.of<FitnessProvider>(context);

    final List<Widget> _screens = [
      WorkoutTab(userName: _userName),
      NutritionTab(fitnessProvider: fitnessProvider),
      const FavoritesTab(),
      ProfileTab(onNameChanged: _loadName),
    ];

    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        title: Text("Fit Diary: $_userName"),
        actions: [
          StreamBuilder<int>(
            stream: fitnessProvider.burnedCaloriesStream,
            builder: (context, snapshot) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Center(
                  child: Text(
                    "🔥 ${snapshot.data ?? 0} kcal",
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.orange),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        selectedItemColor: Colors.deepPurple,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.fitness_center), label: "Workout"),
          BottomNavigationBarItem(icon: Icon(Icons.restaurant_menu), label: "Nutrition"),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: "Favorites"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}


class WorkoutTab extends StatefulWidget {
  final String userName;
  const WorkoutTab({super.key, required this.userName});

  @override
  State<WorkoutTab> createState() => _WorkoutTabState();
}

class _WorkoutTabState extends State<WorkoutTab> {
  final Map<String, List<Exercise>> workoutData = {
    "Glutes": [
      Exercise(title: "Glute Bridge", imageUrl: "https://avatars.mds.yandex.net/i?id=feded7145cf3becd4de0a765e64ea6702d59be3a-10139465-images-thumbs&n=13", instructions: "Lie on your back, lift your hips toward the ceiling, squeeze, and lower."),
      Exercise(title: "Bulgarian Split Squats", imageUrl: "https://avatars.mds.yandex.net/i?id=90e87534adaf02a666c23365beca28fd7c9a2093-4374574-images-thumbs&n=13", instructions: "Place one foot behind you on a bench and squat with the other leg."),
    ],
    "Chest": [
      Exercise(title: "Bench Press", imageUrl: "https://avatars.mds.yandex.net/i?id=e402319368ba5a09d24ac40599794bc1770a9906-5886141-images-thumbs&n=13", instructions: "Lie on a bench and press the barbell upward until your arms are extended."),
      Exercise(title: "Push-ups", imageUrl: "https://avatars.mds.yandex.net/i?id=ee49b4ed527f9e9772c2ba85b795b28d42a01979-13226847-images-thumbs&n=13", instructions: "Keep your body in a straight line and lower yourself by bending your elbows."),
    ],
    "Back": [
      Exercise(title: "Lat Pulldowns", imageUrl: "https://avatars.mds.yandex.net/i?id=106564aa5a9761e1c1f0f5dfbd51022c463191a573dc91dc-11956207-images-thumbs&n=13", instructions: "Pull the bar down to your upper chest while squeezing your shoulder blades."),
      Exercise(title: "Seated Cable Rows", imageUrl: "https://avatars.mds.yandex.net/i?id=c913bc7ee0852cad4f68a0687d11a1f5cfd29e14-7549525-images-thumbs&n=13", instructions: "Pull the handle toward your waist while keeping your back straight."),
    ],
    "Shoulders": [
      Exercise(title: "Overhead Press", imageUrl: "https://avatars.mds.yandex.net/i?id=5308a56b8b2f1db0e3e0a4b4979f47da575e76c6-10995265-images-thumbs&n=13", instructions: "Push the dumbbells or barbell directly overhead until your arms are straight."),
      Exercise(title: "Lateral Raises", imageUrl: "https://avatars.mds.yandex.net/i?id=cedd4245f77051f80d49246f26ba7f3b-4080015-images-thumbs&n=13", instructions: "Lift the weights out to your sides until they reach shoulder height."),
    ],
    "Legs": [
      Exercise(title: "Leg Extensions", imageUrl: "https://ice-profy.ru/wp-content/uploads/2023/06/5.jpeg", instructions: "Sit in the machine and extend your legs until they are straight, then lower slowly."),
      Exercise(title: "Squats", imageUrl: "https://avatars.mds.yandex.net/i?id=5dc0bcc0727c965267afdf75be64b23a3e98745a-9229208-images-thumbs&n=13", instructions: "Lower your hips as if sitting in a chair, keeping your chest up."),
      Exercise(title: "Leg Press", imageUrl: "https://avatars.mds.yandex.net/i?id=a99884acea2ba733e0619609c438a562a159da2d-12938298-images-thumbs&n=13", instructions: "Push the platform away using your legs, then slowly bring it back."),
    ],
    "Biceps": [
      Exercise(title: "Dumbbell Curls", imageUrl: "https://avatars.mds.yandex.net/i?id=267936f7e7ee43ac1329fd1fdcfb7f947a5bf222-4298456-images-thumbs&n=13", instructions: "Curl the weights toward your shoulders while keeping elbows tucked."),
    ],
    "Triceps": [
      Exercise(title: "Tricep Dips", imageUrl: "https://avatars.mds.yandex.net/i?id=1eca940f4b3abbae05fdc57237fff59ea9eb8fb4-4936819-images-thumbs&n=13", instructions: "Lower your body using your arms on a bench, then push back up."),
    ]
  };

  final List<WorkoutPlan> horizontalPlans = [
    WorkoutPlan(
      tag: "Block 1",
      title: "Leg Day",
      imgUrl: "https://m.media-amazon.com/images/I/61xQsD1lVaL._AC_UF1000,1000_QL80_.jpg",
      exercises: [
        BlockExercise(name: "Barbell Squats", imageUrl: "https://avatars.mds.yandex.net/i?id=5dc0bcc0727c965267afdf75be64b23a3e98745a-9229208-images-thumbs&n=13"),
        BlockExercise(name: "Leg Press", imageUrl: "https://avatars.mds.yandex.net/i?id=a99884acea2ba733e0619609c438a562a159da2d-12938298-images-thumbs&n=13"),
      ],
    ),
    WorkoutPlan(
      tag: "Block 2",
      title: "Arm Day",
      imgUrl: "https://i.ytimg.com/vi/2PohL-eJT6w/maxresdefault.jpg",
      exercises: [
        BlockExercise(name: "Dumbbell Curls", imageUrl: "https://avatars.mds.yandex.net/i?id=267936f7e7ee43ac1329fd1fdcfb7f947a5bf222-4298456-images-thumbs&n=13"),
        BlockExercise(name: "Tricep Dips", imageUrl: "https://avatars.mds.yandex.net/i?id=1eca940f4b3abbae05fdc57237fff59ea9eb8fb4-4936819-images-thumbs&n=13"),
      ],
    ),
    WorkoutPlan(
      tag: "Block 3",
      title: "Full Body",
      imgUrl: "https://i.ytimg.com/vi/wRgdl4SGWIw/maxresdefault.jpg",
      exercises: [
        BlockExercise(name: "Deadlifts", imageUrl: "https://avatars.mds.yandex.net/i?id=9ea536440e21379e403d1f37e19f95701a590216-10810237-images-thumbs&n=13"),
        BlockExercise(name: "Push-ups", imageUrl: "https://avatars.mds.yandex.net/i?id=ee49b4ed527f9e9772c2ba85b795b28d42a01979-13226847-images-thumbs&n=13"),
        BlockExercise(name: "Plank", imageUrl: "https://avatars.mds.yandex.net/i?id=84e3146e4921616c68e3d8c1995a97926b485987-10121543-images-thumbs&n=13"),
      ],
    ),
    WorkoutPlan(
      tag: "Block 4",
      title: "Back Day",
      imgUrl: "https://i.ytimg.com/vi/lcZJxl_ihyA/maxresdefault.jpg",
      exercises: [
        BlockExercise(name: "Lat Pulldowns", imageUrl: "https://avatars.mds.yandex.net/i?id=106564aa5a9761e1c1f0f5dfbd51022c463191a573dc91dc-11956207-images-thumbs&n=13"),
        BlockExercise(name: "Seated Cable Rows", imageUrl: "https://avatars.mds.yandex.net/i?id=c913bc7ee0852cad4f68a0687d11a1f5cfd29e14-7549525-images-thumbs&n=13"),
        BlockExercise(name: "Pull-ups", imageUrl: "https://avatars.mds.yandex.net/i?id=b5606d4e207b1d40003b41317540a9c693a90623-10807537-images-thumbs&n=13"),
      ],
    ),
  ];

  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.70, initialPage: 1000);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 10),
        SizedBox(
          height: 180,
          child: PageView.builder(
            controller: _pageController,
            itemBuilder: (context, index) {
              final plan = horizontalPlans[index % horizontalPlans.length];
              return _buildHorizontalCard(context, plan);
            },
          ),
        ),
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Align(alignment: Alignment.centerLeft, child: Text("Categories", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
        ),
        Expanded(
          child: ListView(
            children: workoutData.keys.map((category) => ListTile(
              leading: const Icon(Icons.fitness_center, color: Colors.deepPurple),
              title: Text(category),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(
                  builder: (context) => ExerciseDetailScreen(categoryName: category, exercises: workoutData[category]!),
                ));
              },
            )).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildHorizontalCard(BuildContext context, WorkoutPlan plan) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => BlockDetailScreen(plan: plan)));
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          image: DecorationImage(image: NetworkImage(plan.imgUrl), fit: BoxFit.cover),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(begin: Alignment.bottomCenter, end: Alignment.topCenter, colors: [Colors.black.withOpacity(0.8), Colors.transparent]),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(plan.title, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
              const Text("View Routine", style: TextStyle(color: Colors.white70)),
            ],
          ),
        ),
      ),
    );
  }
}

class BlockDetailScreen extends StatelessWidget {
  final WorkoutPlan plan;
  final LocalDbService _dbService = LocalDbService();

  BlockDetailScreen({super.key, required this.plan});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(plan.title)),
      body: ListView.builder(
        itemCount: plan.exercises.length,
        itemBuilder: (context, index) {
          final ex = plan.exercises[index];
          return Card(
            margin: const EdgeInsets.all(10),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                Image.network(ex.imageUrl, height: 200, width: double.infinity, fit: BoxFit.cover),
                ListTile(
                  title: Text(ex.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  trailing: IconButton(
                    icon: const Icon(Icons.favorite_border, color: Colors.deepPurple),
                    onPressed: () async {

                      await _dbService.addFavorite(ex.name, ex.imageUrl);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("${ex.name} added to Favorites!")),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}


class NutritionTab extends StatefulWidget {
  final FitnessProvider fitnessProvider;
  const NutritionTab({super.key, required this.fitnessProvider});
  @override
  State<NutritionTab> createState() => _NutritionTabState();
}

class _NutritionTabState extends State<NutritionTab> {
  final FirestoreService _firestoreService = FirestoreService();
  late Future<List<Food>> _foodFuture;

  @override
  void initState() {
    super.initState();
    _foodFuture = _firestoreService.fetchFoods();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        StreamBuilder<int>(
          stream: widget.fitnessProvider.burnedCaloriesStream,
          builder: (context, snapshot) {
            int burned = snapshot.data ?? 0;
            int eaten = widget.fitnessProvider.totalCalories;
            int goal = 2400;
            int remaining = goal - eaten + burned;

            return Container(
              width: double.infinity,
              margin: const EdgeInsets.all(15),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.deepPurple, Colors.purpleAccent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(color: Colors.deepPurple.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8)),
                ],
              ),
              child: Column(
                children: [
                  const Text("Daily Calorie Balance", style: TextStyle(color: Colors.white70, fontSize: 16)),
                  const SizedBox(height: 10),
                  Text("$remaining kcal left", style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _statWidgetCard("Eaten", "$eaten", Icons.restaurant),
                      _statWidgetCard("Burned", "$burned", Icons.local_fire_department),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
          margin: const EdgeInsets.symmetric(horizontal: 15),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _statWidget("Proteins", "${widget.fitnessProvider.totalProtein.toStringAsFixed(1)}g", Colors.blue),
              _statWidget("Fats", "${widget.fitnessProvider.totalFat.toStringAsFixed(1)}g", Colors.red),
              _statWidget("Carbs", "${widget.fitnessProvider.totalCarbs.toStringAsFixed(1)}g", Colors.green),
              IconButton(icon: const Icon(Icons.refresh, color: Colors.grey), onPressed: () => widget.fitnessProvider.clearFoods()),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: FutureBuilder<List<Food>>(
            future: _foodFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
              if (snapshot.hasError) return Center(child: Text("Loading error: ${snapshot.error}"));

              final foods = snapshot.data ?? [];
              if (foods.isEmpty) return const Center(child: Text("No food found in Firestore."));

              return ListView.builder(
                padding: const EdgeInsets.only(top: 10),
                itemCount: foods.length,
                itemBuilder: (context, index) {
                  final food = foods[index];
                  final isSelected = widget.fitnessProvider.selectedFoods.contains(food);
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 6),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    color: isSelected ? Colors.deepPurple.shade50 : Colors.white,
                    child: CheckboxListTile(
                      activeColor: Colors.deepPurple,
                      checkboxShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                      title: Text(food.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text("🔥 ${food.calories} kcal | P: ${food.protein}g"),
                      value: isSelected,
                      onChanged: (bool? value) => widget.fitnessProvider.toggleFood(food),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _statWidget(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
      ],
    );
  }

  Widget _statWidgetCard(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.white70, size: 18),
        const SizedBox(width: 5),
        Text("$label: $value", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
      ],
    );
  }
}


class FavoritesTab extends StatefulWidget {
  const FavoritesTab({super.key});

  @override
  State<FavoritesTab> createState() => _FavoritesTabState();
}

class _FavoritesTabState extends State<FavoritesTab> {
  final LocalDbService _dbService = LocalDbService();
  List<Map<String, dynamic>> _favorites = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    try {
      final data = await _dbService.getFavorites();
      setState(() {
        _favorites = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Database Error: $e"), backgroundColor: Colors.red),
      );
      print("DATABASE ERROR: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());

    if (_favorites.isEmpty) {
      return const Center(child: Text("No favorite exercises saved yet.", style: TextStyle(fontSize: 16, color: Colors.grey)));
    }

    return ListView.builder(
      itemCount: _favorites.length,
      itemBuilder: (context, index) {
        final item = _favorites[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: ListTile(
            contentPadding: const EdgeInsets.all(10),
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(item['imageUrl'], width: 60, height: 60, fit: BoxFit.cover),
            ),
            title: Text(item['title'], style: const TextStyle(fontWeight: FontWeight.bold)),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
              onPressed: () async {
                await _dbService.removeFavorite(item['id']);
                _loadFavorites();
              },
            ),
          ),
        );
      },
    );
  }
}


class ProfileTab extends StatefulWidget {
  final VoidCallback onNameChanged;
  const ProfileTab({super.key, required this.onNameChanged});
  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  final StorageService _storage = StorageService();

  final _nameController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  _loadUserData() async {
    String name = await _storage.getName();
    var metrics = await _storage.getMetrics();
    setState(() {
      _nameController.text = name;
      _heightController.text = metrics['height']!;
      _weightController.text = metrics['weight']!;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          const CircleAvatar(
              radius: 50,
              backgroundColor: Colors.deepPurple,
              child: Icon(Icons.person, size: 50, color: Colors.white)
          ),
          const SizedBox(height: 25),

          _buildInput(_nameController, "Name", Icons.edit),
          const SizedBox(height: 15),

          _buildInput(_heightController, "Height (cm)", Icons.height, keyboardType: TextInputType.number),
          const SizedBox(height: 15),

          _buildInput(_weightController, "Weight (kg)", Icons.monitor_weight_outlined, keyboardType: TextInputType.number),

          const SizedBox(height: 30),

          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))
            ),
            onPressed: () async {
              await _storage.saveName(_nameController.text);
              await _storage.saveMetrics(_heightController.text, _weightController.text);
              widget.onNameChanged();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Data updated successfully!")),
              );
            },
            child: const Text("Update Profile", style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }

  Widget _buildInput(TextEditingController controller, String label, IconData icon, {TextInputType? keyboardType}) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.deepPurple),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}