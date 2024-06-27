import "package:flutter/material.dart";
import "package:phosphor_flutter/phosphor_flutter.dart";

class SortingAlbum extends StatelessWidget {
  const SortingAlbum({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SizedBox(
          child: Row(
            children: [
              const Text(
                'Name',
              ),
              const SizedBox(width: 10),
              Icon(
                PhosphorIcons.arrowUp(),
                size: 18,
                color: Colors.white,
              ),
            ],
          ),
        ),
        SizedBox(
          child: Row(
            children: [
              Icon(
                PhosphorIcons.shuffle(),
                size: 18,
                color: Colors.white,
              ),
              const SizedBox(width: 10),
              Icon(
                PhosphorIconsFill.listBullets,
                size: 18,
                color: Colors.white,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
