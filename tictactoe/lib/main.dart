import 'package:flutter/material.dart';
import 'package:tictactoe/utils.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TiX - ToO',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MainPage(title: 'TiX - ToO'),
    );
  }
}

class MainPage extends StatefulWidget {
  final String title;

  const MainPage({
    required this.title,
  });

  @override
  _MainPageState createState() => _MainPageState();
}

class Player {
  static const none = '';
  static const X = 'X';
  static const O = 'O';
}

class _MainPageState extends State<MainPage> {
  static final countMatrix = 3;
  static final double size = 92;

  int x_score = 0;
  int o_score = 0;

  String lastMove = Player.none;
  List<List<String>> matrix = [];

  @override
  void initState() {
    super.initState();
    setEmptyField();
  }

  void setEmptyField() {
    setState(() {
      lastMove = Player.none;
      matrix = List.generate(
          countMatrix, (_) => List.generate(countMatrix, (_) => Player.none));
    });
  }

  void resetScore() {
    setState(() {
      x_score = 0;
      o_score = 0;
    });
  }

  String getCurrentTurn() {
    final currentTurn = lastMove == Player.X ? Player.O : Player.X;
    return currentTurn;
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: Text(widget.title),
          backgroundColor: getFieldColor(getCurrentTurn()).withAlpha(150),
          actions: [
            Center(
              child: Text(
                'Score: ',
                style: TextStyle(fontSize: 22),
              ),
            ),
            scoreBoard(Player.X, x_score),
            scoreBoard(Player.O, o_score),
          ],
        ),
        body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: Utils.modelBuilder(matrix, (x, value) => buildRow(x))),
        bottomNavigationBar: BottomAppBar(
          child: Container(
            height: 70,
            color: getFieldColor(getCurrentTurn()),
            child: Center(
              child: Text("${getCurrentTurn()} Turn",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 32,
                      color: Colors.white,
                      fontWeight: FontWeight.bold)),
            ),
          ),
        ),
      );

  Widget scoreBoard(String player, int score) {
    return Container(
      margin: EdgeInsets.all(2),
      child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            primary: getFieldColor(player),
          ),
          onPressed: () {
            if (score != 0) showResetDialog();
          },
          child: Text(
            "$score",
            style: TextStyle(fontSize: 22),
          )),
    );
  }

  Widget buildRow(int x) {
    final values = matrix[x];

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: Utils.modelBuilder(values, (y, model) => buildField(x, y)),
    );
  }

  Color getFieldColor(String value) {
    switch (value) {
      case Player.O:
        return Colors.deepPurple;
      case Player.X:
        return Colors.blueGrey;
      default:
        return Colors.white;
    }
  }

  Widget buildField(int x, int y) {
    final value = matrix[x][y];
    final color = getFieldColor(value);

    return Container(
      margin: EdgeInsets.all(4),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
            primary: color, minimumSize: Size(size, size)),
        child: Text(
          value,
          style: TextStyle(fontSize: 32, color: Colors.white),
        ),
        onPressed: () => selectField(x, y, value),
      ),
    );
  }

  void selectField(int x, int y, String value) {
    if (value == Player.none) {
      final newValue = lastMove == Player.X ? Player.O : Player.X;

      setState(() {
        lastMove = newValue;
        matrix[x][y] = newValue;
      });

      if (isWinner(x, y)) {
        showEndDialog("Player $newValue Won");
        setState(() {
          if (newValue == Player.X) {
            x_score += 1;
          } else {
            o_score += 1;
          }
        });
      } else if (isEnd()) {
        showEndDialog("Draw");
      }
    }
  }

  bool isEnd() =>
      matrix.every((values) => values.every((value) => value != Player.none));

  bool isWinner(int x, int y) {
    var col = 0, row = 0, diag = 0, rdiag = 0;
    final player = matrix[x][y];
    final n = countMatrix;

    for (int i = 0; i < n; i++) {
      if (matrix[x][i] == player) col++;
      if (matrix[i][y] == player) row++;
      if (matrix[i][i] == player) diag++;
      if (matrix[i][n - i - 1] == player) rdiag++;
    }

    return row == n || col == n || diag == n || rdiag == n;
  }

  Future showEndDialog(String title) => showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
            title: Text(title),
            content: Text("Press button to Restart the game"),
            actions: [
              ElevatedButton(
                  onPressed: () {
                    setEmptyField();
                    Navigator.of(context).pop();
                  },
                  child: Text("Restart"))
            ],
          ));

  Future showResetDialog() => showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
            title: Text("Reset the score?"),
            actions: [
              ElevatedButton(
                  style: ElevatedButton.styleFrom(primary: Colors.red),
                  onPressed: () {
                    resetScore();
                    Navigator.of(context).pop();
                  },
                  child: Text("Yes")),
              ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text("No")),
            ],
          ));
}
