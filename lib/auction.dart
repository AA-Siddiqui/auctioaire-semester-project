import 'package:flutter/material.dart';

class AuctionPage extends StatelessWidget {
  const AuctionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Auction Page'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, 'add');
        },
        child: Icon(Icons.add),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Welcome to the Auction!',
                style: TextStyle(fontSize: 24),
              ),
            ),
            // const SizedBox(
            //   height: 50,
            //   child: SingleChildScrollView(
            //     child: Row(
            //       spacing: 8,
            //       children: [
            //         Chip(label: Text("lol")),
            //         Chip(label: Text("lol")),
            //         Chip(label: Text("lol")),
            //       ],
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
