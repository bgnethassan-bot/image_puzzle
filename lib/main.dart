import 'package:flutter/material.dart';
import 'dart:async';

void main() => runApp(const PuzzleApp());

class PuzzleApp extends StatelessWidget {
  const PuzzleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'لعبة البازل',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        useMaterial3: true,
      ),
      home: const MainScreen(),
    );
  }
}

// ==================== الشاشة الرئيسية (تحتوي على التبويبات) ====================
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const PuzzleHomeScreen(),
    const AboutScreen(),
  ];

  final List<String> _titles = [
    '🧩 لعبة البازل',
    '📞 تواصل معنا',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _titles[_selectedIndex],
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
        elevation: 0,
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.deepPurple,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.grid_3x3),
            label: 'اللعبة',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.contact_page),
            label: 'تواصل',
          ),
        ],
      ),
    );
  }
}

// ==================== شاشة اللعبة ====================
class PuzzleHomeScreen extends StatefulWidget {
  const PuzzleHomeScreen({super.key});

  @override
  State<PuzzleHomeScreen> createState() => _PuzzleHomeScreenState();
}

class _PuzzleHomeScreenState extends State<PuzzleHomeScreen> {
  int _rows = 3;
  int _cols = 3;
  List<int> _pieces = [];
  bool _isGameComplete = false;
  int _moves = 0;
  int _timeSpent = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _initGame();
  }

  void _initGame() {
    setState(() {
      _isGameComplete = false;
      _moves = 0;
      _timeSpent = 0;
      _timer?.cancel();
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (!_isGameComplete && mounted) {
          setState(() => _timeSpent++);
        }
      });
      _generatePuzzle();
    });
  }

  void _generatePuzzle() {
    int totalPieces = _rows * _cols;
    _pieces = List.generate(totalPieces, (i) => i);
    _pieces.shuffle();

    int inversions = 0;
    for (int i = 0; i < totalPieces; i++) {
      for (int j = i + 1; j < totalPieces; j++) {
        if (_pieces[i] > _pieces[j] && _pieces[j] != totalPieces - 1) {
          inversions++;
        }
      }
    }
    if (inversions % 2 == 1) {
      int temp = _pieces[0];
      _pieces[0] = _pieces[1];
      _pieces[1] = temp;
    }
  }

  bool _checkWin() {
    for (int i = 0; i < _pieces.length; i++) {
      if (_pieces[i] != i) return false;
    }
    return true;
  }

  void _movePiece(int index) {
    if (_isGameComplete) return;

    int emptyIndex = _pieces.indexOf(_pieces.length - 1);
    int row = index ~/ _cols;
    int emptyRow = emptyIndex ~/ _cols;
    int col = index % _cols;
    int emptyCol = emptyIndex % _cols;

    if ((row == emptyRow && (col - emptyCol).abs() == 1) ||
        (col == emptyCol && (row - emptyRow).abs() == 1)) {
      setState(() {
        int temp = _pieces[index];
        _pieces[index] = _pieces[emptyIndex];
        _pieces[emptyIndex] = temp;
        _moves++;
        if (_checkWin()) {
          _isGameComplete = true;
          _timer?.cancel();
        }
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    double boardSize = screenWidth < screenHeight
        ? screenWidth - 32
        : screenHeight - 200;

    if (boardSize > 400) boardSize = 400;

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.deepPurple[50],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildInfoCard(Icons.straighten, 'الأبعاد', "${_rows}x${_cols}"),
                _buildInfoCard(Icons.touch_app, 'الحركات', '$_moves'),
                _buildInfoCard(Icons.timer, 'الوقت', '${_timeSpent ~/ 60}:${(_timeSpent % 60).toString().padLeft(2, '0')}'),
              ],
            ),
          ),

          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildSizeButton('3x3', 3),
              const SizedBox(width: 12),
              _buildSizeButton('4x4', 4),
              const SizedBox(width: 12),
              _buildSizeButton('5x5', 5),
            ],
          ),

          const SizedBox(height: 16),

          Container(
            width: boardSize,
            height: boardSize,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade400,
                  blurRadius: 8,
                  offset: const Offset(2, 2),
                ),
              ],
            ),
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: _cols,
                childAspectRatio: 1,
              ),
              itemCount: _pieces.length,
              itemBuilder: (context, index) => GestureDetector(
                onTap: () => _movePiece(index),
                child: _buildPiece(index, _cols),
              ),
            ),
          ),

          const SizedBox(height: 16),

          if (_isGameComplete)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.deepPurple, Colors.purple],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const Icon(Icons.emoji_events, size: 32, color: Colors.white),
                  const SizedBox(height: 4),
                  Text(
                    '🎉 مبروك! 🎉',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'الحركات: $_moves  |  الوقت: ${_timeSpent ~/ 60}:${(_timeSpent % 60).toString().padLeft(2, '0')}',
                    style: const TextStyle(fontSize: 12, color: Colors.white70),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _initGame,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.deepPurple,
                      minimumSize: const Size(100, 36),
                    ),
                    child: const Text('لعبة جديدة', style: TextStyle(fontSize: 14)),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, color: Colors.deepPurple, size: 22),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.deepPurple)),
      ],
    );
  }

  Widget _buildSizeButton(String text, int size) {
    bool isSelected = _rows == size;
    return ElevatedButton(
      onPressed: () {
        setState(() {
          _rows = size;
          _cols = size;
          _initGame();
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? Colors.deepPurple : Colors.grey[300],
        foregroundColor: isSelected ? Colors.white : Colors.deepPurple,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        minimumSize: const Size(60, 36),
        padding: const EdgeInsets.symmetric(horizontal: 12),
      ),
      child: Text(text, style: const TextStyle(fontSize: 14)),
    );
  }

  Widget _buildPiece(int index, int gridSize) {
    int value = _pieces[index];
    bool isEmpty = value == _pieces.length - 1;

    List<Color> colors = [
      const Color(0xFFFF6B6B),
      const Color(0xFF4ECDC4),
      const Color(0xFF45B7D1),
      const Color(0xFF96CEB4),
      const Color(0xFFFFEAA7),
      const Color(0xFFDDA0DD),
      const Color(0xFF98D8C8),
      const Color(0xFFF7D794),
      const Color(0xFFEA868F),
    ];

    if (isEmpty) {
      return Container(
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey[400]!),
        ),
      );
    }

    double fontSize = gridSize <= 3 ? 24 : (gridSize <= 4 ? 18 : 14);

    return Container(
      margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: colors[value % colors.length],
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 2,
            offset: const Offset(1, 1),
          ),
        ],
      ),
      child: Center(
        child: Text(
          "${value + 1}",
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: value % 2 == 0 ? Colors.white : Colors.deepPurple,
          ),
        ),
      ),
    );
  }
}

// ==================== شاشة تواصل معنا (مع بياناتك الشخصية) ====================
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.deepPurple.shade50,
            Colors.purple.shade50,
          ],
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // صورة رمزية
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.deepPurple.withOpacity(0.3),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: const CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.deepPurple,
                      child: Icon(
                        Icons.person,
                        size: 60,
                        color: Colors.white,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // اسم المصمم
                  const Text(
                    'Hassan Eltayeb Elshiekh',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 8),

                  // عنوان المصمم
                  const Text(
                    'مطور تطبيقات Flutter',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // معلومات الاتصال
                  _buildContactItem(
                    context: context,
                    icon: Icons.email,
                    label: 'البريد الإلكتروني',
                    value: 'hassangroupcom@hotmail.com',
                  ),

                  const SizedBox(height: 12),

                  _buildContactItem(
                    context: context,
                    icon: Icons.phone,
                    label: 'رقم الجوال',
                    value: '0550601674',
                  ),

                  const SizedBox(height: 24),

                  // زر نسخ البريد
                  ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('تم نسخ البريد الإلكتروني'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    icon: const Icon(Icons.copy),
                    label: const Text('نسخ البريد الإلكتروني'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // زر الاتصال
                  OutlinedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('جاري فتح تطبيق الاتصال...'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    icon: const Icon(Icons.phone),
                    label: const Text('اتصل الآن'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.deepPurple,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // حقوق الملكية
                  Text(
                    '© 2025 جميع الحقوق محفوظة',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContactItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.deepPurple,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.copy, color: Colors.deepPurple, size: 20),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('تم نسخ $label'),
                  duration: const Duration(seconds: 1),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}