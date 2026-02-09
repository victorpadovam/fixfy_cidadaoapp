import 'package:flutter/material.dart';

Widget iconeChatComContador(int totalNaoLidas) {
  return Stack(
    children: [
      Icon(Icons.chat_bubble_outline),
      if (totalNaoLidas > 0)
        Positioned(
          right: 0,
          child: Container(
            padding: EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.red,
              shape: BoxShape.circle,
            ),
            child: Text(
              '$totalNaoLidas',
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
              ),
            ),
          ),
        ),
    ],
  );
}
