import 'package:flutter/material.dart';
import 'package:todo_flutter/data/database.dart';
import 'package:todo_flutter/write.dart';

import 'data/todo.dart';
import 'data/util.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Todo Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const MyHomePage(title: 'Todo Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final dbHelper = DatabaseHelper.instance;
  int selectIndex = 0;

  List<Todo> todos = [];

  void getTodayTodo() async {
    todos = await dbHelper.getTodoByDate(Utils.getFormatTime(DateTime.now()));
    setState(() {});
  }

  void getAllTodo() async {
    allTodo = await dbHelper.getAllTodo();
    setState(() {});
  }

  @override
  void initState() {
    getTodayTodo();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        // AppBar 를 활용하여 상단의 시간, 배터리 등의 라인 아래부터 시작할 수 있음
        preferredSize: const Size.fromHeight(0),
        child: AppBar(),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
        onPressed: () async {
          // 화면 이동
          Todo _ = await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (BuildContext ctx) => TodoWritePage(
                todo: Todo(
                  title: "",
                  color: 0,
                  memo: "",
                  done: 0,
                  category: "",
                  date: Utils.getFormatTime(DateTime.now()),
                ),
              ),
            ),
          );

          getTodayTodo();
        },
      ),
      body: getPage(),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.today_outlined), label: "오늘"),
          BottomNavigationBarItem(icon: Icon(Icons.assignment_outlined), label: "기록"),
          BottomNavigationBarItem(icon: Icon(Icons.more_horiz), label: "더보기"),
        ],
        currentIndex: selectIndex,
        onTap: (idx) {
          if (idx == 1) {
            getAllTodo();
          }
          setState(() {
            selectIndex = idx;
          });
        },
      ),
    );
  }

  Widget getPage() {
    if (selectIndex == 0) {
      return getMain();
    } else {
      return getHistory();
    }
  }

  Widget getMain() {
    return ListView.builder(
      // builder 를 사용할 때 if statement 로 return 을 하게 된다면,
      // itemCount 개수에 맞게 혹은 마지막 조건은 else 로 표시할 것 -> null 반환이 예상될 경우 app build 가 되지 않음
      itemCount: 4,
      itemBuilder: (BuildContext ctx, int idx) {
        if (idx == 0) {
          return Container(
            child: const Text(
              "오늘 하루",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 20), // 고정값은 항상 const 를 사용하는 것을 권장
          );
        } else if (idx == 1) {
          List<Todo> undone = todos.where((t) {
            return t.done == 0;
          }).toList();

          return Column(
            children: List.generate(
              undone.length,
              (_idx) {
                Todo t = undone[_idx];
                return InkWell(
                  child: TodoCardWidget(t: t),
                  onTap: () async {
                    setState(() {
                      if (t.done == 0) {
                        t.done = 1;
                      } else {
                        t.done = 0;
                      }
                    });
                    // Update card status (Done | Undone)
                    await dbHelper.insertTodo(t);
                  },
                  onLongPress: () async {
                    // 수정
                    Todo _ = await Navigator.of(context).push(
                      MaterialPageRoute(builder: (BuildContext ctx) => TodoWritePage(todo: t)),
                    );
                    setState(() {});
                  },
                );
              },
            ),
          );
        } else if (idx == 2) {
          return Container(
            child: const Text(
              "완료된 하루",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 20), // 고정값은 항상 const 를 사용하는 것을 권장
          );
        } else if (idx == 3) {
          List<Todo> done = todos.where((t) {
            return t.done == 1;
          }).toList();

          return Column(
            children: List.generate(
              done.length,
              (_idx) {
                Todo t = done[_idx];
                return InkWell(
                  child: TodoCardWidget(t: t),
                  onTap: () async {
                    setState(() {
                      if (t.done == 0) {
                        t.done = 1;
                      } else {
                        t.done = 0;
                      }
                    });
                    // Update card status (Done | Undone)
                    await dbHelper.insertTodo(t);
                  },
                  onLongPress: () async {
                    // 수정
                    Todo _ = await Navigator.of(context).push(
                      MaterialPageRoute(builder: (BuildContext ctx) => TodoWritePage(todo: t)),
                    );
                    setState(() {});
                  },
                );
              },
            ),
          );
        }
        return Container();
      },
    );
  }

  List<Todo> allTodo = [];

  Widget getHistory() {
    return ListView.builder(
      itemCount: allTodo.length,
      itemBuilder: (BuildContext ctx, int idx) {
        return TodoCardWidget(t: allTodo[idx]);
      },
    );
  }
}

class TodoCardWidget extends StatelessWidget {
  final Todo t;

  const TodoCardWidget({Key? key, required this.t}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    int now = Utils.getFormatTime(DateTime.now());
    DateTime time = Utils.numToDateTime(t.date);

    return Container(
      decoration: BoxDecoration(color: Color(t.color), borderRadius: BorderRadius.circular(16)),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12), // Container 내의 간격
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 20), // Container 간의 간격
      child: Column(
        // 왼쪽 정렬 (default: center)
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(t.title, style: const TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
              Text(t.done == 0 ? "미완료" : "완료", style: const TextStyle(color: Colors.white)),
            ],
          ),
          Container(
            height: 8,
          ),
          Text(
            t.memo,
            style: const TextStyle(color: Colors.white),
          ),
          now == t.date
              ? Container()
              : Text(
                  "${time.month}월 ${time.day}일",
                  style: const TextStyle(color: Colors.white),
                ),
        ],
      ),
    );
  }
}
