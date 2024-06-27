import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class PlaylistsPage extends StatelessWidget {
  const PlaylistsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            PhosphorIconsDuotone.listPlus,
            size: 80,
            color: Colors.purple.shade200,
          ),
          Text(
            'No playlist found',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(
            height: 10,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Text(
              'You can either create a new playlist or import a playlist by clicking on the \'+\' button',
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
