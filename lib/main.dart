// Copyright 2018 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';
import 'package:vector_math/vector_math.dart' as VectorMath;


void main() => runApp(Shogi());

class Shogi extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _State();
  }
}

class _State extends State<Shogi> {
  double bottom_length = 1.0;
  double mu = 1.1;
  double degree_top = 144.0;
  double degree_under = 81.0;

  List<double> coord_top = [0.0, 0.0];
  List<double> coord_middle_l = [0.0, 0.0];
  List<double> coord_middle_r = [0.0, 0.0];
  List<double> coord_bottom_l = [0.0, 0.0];
  List<double> coord_bottom_r = [0.0, 0.0];

  void update()
  {
    var radian_under = VectorMath.radians(degree_under);
    var radian_top_half = VectorMath.radians(0.5 * degree_top);
    var short_line = (bottom_length * (mu * cos(radian_under) - 0.5 * sin(radian_under))) / cos(VectorMath.radians(0.5 * degree_top + degree_under));
    this.coord_top = [0, 0];
    this.coord_middle_l = [- short_line * sin(radian_top_half), short_line * cos(radian_top_half)];
    this.coord_middle_r = [short_line * sin(radian_top_half), short_line * cos(radian_top_half)];
    this.coord_bottom_l = [- 0.5 * bottom_length, mu * bottom_length];
    this.coord_bottom_r = [0.5 * bottom_length, mu * bottom_length];
  }

  @override
  Widget build(BuildContext context) {
    update();
    return MaterialApp(
      title: '将棋駒デザイン',
      home: Scaffold(
        appBar: AppBar(
          title: Text('将棋駒デザイン'),
        ),
        body: SingleChildScrollView( 
        child:Column(
          children: <Widget>[
            SelectableText(
              """

              将棋の駒のデザイン用のサイトです。
              http://rskmoi.hatenablog.com/entry/2018/01/21/104029
              の実装です。blenderで駒を作るときなどにお使い下さい。
              スライドバーで好みの形を作って"Copy to Clipboard"ボタンでコピーすることを想定しています。
              なんか微妙なサイトで申し訳ないです。もっと技術磨いて出直してきます。
              """, 
              textAlign: TextAlign.left),
            Center(child:Text("底辺の長さ：${this.bottom_length}")),
            Slider(
              value: this.bottom_length,
              min: 0.1,
              max: 100.0,
              divisions: 999,
              onChanged: (double value){
                setState(() {
                  this.bottom_length = value;
                  update();
                });
              },
            ),
            Center(child:Text("底辺と高さの比：${this.mu}")),
            Slider(
              value: this.mu,
              min: 0.8,
              max: 1.5,
              divisions: 700,
              onChanged: (double value){
                setState(() {
                  this.mu = value;
                  update();
                });
              },
            ),
            Center(child:Text("頂角の角度：${this.degree_top}")),
            Slider(
              value: this.degree_top,
              min: 100,
              max: 180,
              divisions: 800,
              onChanged: (double value){
                setState(() {
                  this.degree_top = value;
                  update();
                });
              },
            ),
            Center(child:Text("底角の角度：${this.degree_under}")),
            Slider(
              value: this.degree_under,
              min: 70,
              max: 90,
              divisions: 200,
              onChanged: (double value){
                setState(() {
                  this.degree_under = value;
                  update();
                });
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                CustomPaint(
                  size: Size(500, 500), //child:や親ウィジェットがない場合はここでサイズを指定できる
                  painter: _MyPainter(this.coord_top, this.coord_middle_l, this.coord_middle_r, this.coord_bottom_l, this.coord_bottom_r, this.bottom_length
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                SizedBox(
                  width: 500, 
                  child: SelectableText(
                  """
                  底辺の長さ：${this.bottom_length}
                  底辺と高さの比：${this.mu}
                  頂角の角度：${this.degree_top}
                  底角の角度：${this.degree_under}
                  頂角の座標：${this.coord_top}
                  中角(左)の座標: ${this.coord_middle_l}
                  中角(右)の座標: ${this.coord_middle_r}
                  底角(左)の座標: ${this.coord_bottom_l}
                  底角(右)の座標: ${this.coord_bottom_r}
                  """,
                  )
                ),
                RaisedButton(
                  child: Text("Copy to Clipboard"),
                  shape: StadiumBorder(),
                  onPressed: () 
                  {
                    final data = ClipboardData(
                      text: 
                        """
                        底辺の長さ：${this.bottom_length}
                        底辺と高さの比：${this.mu}
                        頂角の角度：${this.degree_top}
                        底角の角度：${this.degree_under}
                        頂角の座標：${this.coord_top}
                        中角(左)の座標: ${this.coord_middle_l}
                        中角(右)の座標: ${this.coord_middle_r}
                        底角(左)の座標: ${this.coord_bottom_l}
                        底角(右)の座標: ${this.coord_bottom_r}
                        """);
                    Clipboard.setData(data);
                  },
                ),
              ],
              ),
            ],
            ),
            ]

        ),
      ),
    )
    );
  }
}

class _MyPainter extends CustomPainter {
  // ※ コンストラクタに引数を持たせたい場合はこんな感じで
  List<double> coord_top;
  List<double> coord_middle_l;
  List<double> coord_middle_r;
  List<double> coord_bottom_l;
  List<double> coord_bottom_r;
  double bottom_length;

  _MyPainter(this.coord_top, this.coord_middle_l, this.coord_middle_r, this.coord_bottom_l, this.coord_bottom_r, this.bottom_length);

  // 実際の描画処理を行うメソッド
  @override
  void paint(Canvas canvas, Size size) {
    var display_bottom_length = 300;
    var display_ratio = display_bottom_length / bottom_length;
    var top_x = 250.0;
    var top_y = 50.0;
    var top = Offset(top_x, top_y);
    var middle_l = Offset(top_x + coord_middle_l[0] * display_ratio, top_y + coord_middle_l[1] * display_ratio);
    var middle_r = Offset(top_x + coord_middle_r[0] * display_ratio, top_y + coord_middle_r[1] * display_ratio);
    var bottom_l = Offset(top_x + coord_bottom_l[0] * display_ratio, top_y + coord_bottom_l[1] * display_ratio);
    var bottom_r = Offset(top_x + coord_bottom_r[0] * display_ratio, top_y + coord_bottom_r[1] * display_ratio);

    final paint = Paint();
    paint.color = Colors.blue;
    canvas.drawCircle(top, 5, paint);
    canvas.drawCircle(middle_l, 5, paint);
    canvas.drawCircle(middle_r, 5, paint);
    canvas.drawCircle(bottom_l, 5, paint);
    canvas.drawCircle(bottom_r, 5, paint);
    canvas.drawLine(top, middle_l, paint);
    canvas.drawLine(middle_l, bottom_l, paint);
    canvas.drawLine(bottom_l, bottom_r, paint);
    canvas.drawLine(bottom_r, middle_r, paint);
    canvas.drawLine(middle_r, top, paint);
  }

  // 再描画のタイミングで呼ばれるメソッド
  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}