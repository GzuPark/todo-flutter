import 'package:flutter/material.dart';

import 'data/todo.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
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
  List<Todo> todos = [
    Todo(
        title: "패스트캠퍼스 강의듣기",
        memo: "앱개발 입문강의 듣기",
        color: Colors.redAccent.value,
        done: 0,
        category: "공부",
        date: 20210709),
    Todo(
        title: "패스트캠퍼스 강의듣기 2",
        memo: "앱개발 입문강의 듣기",
        color: Colors.blueAccent.value,
        done: 0,
        category: "공부",
        date: 20210709),
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        // AppBar 를 활용하여 상단의 시간, 배터리 등의 라인 아래부터 시작할 수 있음
        child: AppBar(),
        preferredSize: const Size.fromHeight(0),
      ),
      body: ListView.builder(
        // builder 를 사용할 때 if statement 로 return 을 하게 된다면,
        // itemCount 개수에 맞게 혹은 마지막 조건은 else 로 표시할 것 -> null 반환이 예상될 경우 app build 가 되지 않음
        itemCount: 2,
        itemBuilder: (BuildContext ctx, int idx) {
          if (idx == 0) {
            return Container(
              child: const Text("오늘하루", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 20), // 고정값은 항상 const 를 사용하는 것을 권장
            );
          } else {
            return Column(
                children: List.generate(todos.length, (_idx) {
              Todo t = todos[_idx];
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
                          Text(t.title,
                              style: const TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
                          Text(t.done == 0 ? "미완료" : "완료", style: const TextStyle(color: Colors.white)),
                        ],
                      ),
                      Container(
                        height: 8,
                      ),
                      Text(t.memo, style: const TextStyle(color: Colors.white))
                    ],
                  ));
            }));
          }
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.today_outlined), label: "오늘"),
          BottomNavigationBarItem(icon: Icon(Icons.assignment_outlined), label: "기록"),
          BottomNavigationBarItem(icon: Icon(Icons.more_horiz), label: "더보기"),
        ],
      ),
    );
  }
}
