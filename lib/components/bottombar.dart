import 'package:flutter/material.dart';

class BottomBar extends StatelessWidget {
  const BottomBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      color: Color.fromRGBO(134, 93, 255, 1),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.home, size: 35),
            color: Color.fromRGBO(227, 132, 255, 1),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.search, size: 35),
            color: Color.fromRGBO(227, 132, 255, 1),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.add_box, size: 35),
            color: Color.fromRGBO(227, 132, 255, 1),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.favorite, size: 35),
            color: Color.fromRGBO(227, 132, 255, 1),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.person_outline, size: 35),
            color: Color.fromRGBO(227, 132, 255, 1),
          ),
        ],
      ),
    );
  }
}
