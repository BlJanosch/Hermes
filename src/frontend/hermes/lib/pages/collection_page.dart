import 'package:flutter/material.dart';
import 'package:hermes/components/bottom_nav_bar.dart';
import 'package:hermes/components/sammelkarte.dart';


class CollectionPage extends StatelessWidget {
  const CollectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            color: Color.fromRGBO(187, 164, 48, 1.00),
            width: double.infinity,
            padding: EdgeInsets.only(top: 45),
            child: Column(
              children: [
                Text(
                  "Deine Sammelkarten",
                  style: TextStyle(fontSize: 35, fontFamily: "Sans"),
                ),
                Wrap(
                  children: [
                    MySammelkarte(),
                                       
                  ],
                )
              ],
            )
          ),
          Positioned(
            bottom: 130.0,
            left: 0,
            right: 0,
            child: Center(
              child: FloatingActionButton(
                onPressed: scan,
                backgroundColor: Colors.black.withOpacity(0.5),
                child: Icon(
                  Icons.add,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          Positioned(
          bottom: 10.0,
          left: 5,
          right: 5,
          child: MyBottomNavBar(
            currentIndex: 1,
          ),
          ),
        ]

      ),
    );
  }

  void scan(){}
}