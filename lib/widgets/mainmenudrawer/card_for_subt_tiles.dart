import 'package:flutter/material.dart';

class CardForSubtTiles extends StatelessWidget {
  const CardForSubtTiles({
    super.key,
    required this.icon,
    required this.text,

    required this.ontap,
  });
  final IconData icon;
  final String text;

  final void Function() ontap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
      child: Material(
        elevation: 1,
        borderRadius: BorderRadius.circular(10),
        color: Colors.grey[100],
        child: ListTile(
          leading: Icon(icon, color: Colors.blue),
          title: Text(text),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          onTap: () {
            Navigator.pop(context); // close drawer first
            Future.delayed(Duration(milliseconds: 200), () {
              ontap(); // then navigate
            });

            // Add your navigation logic here
          },
        ),
      ),
    );
  }
}
