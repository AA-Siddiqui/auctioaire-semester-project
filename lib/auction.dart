import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AuctionPage extends StatelessWidget {
  const AuctionPage({super.key});

  String _formatDate(DateTime datetime) {
    final months = [
      "",
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec",
    ];
    return "${months[datetime.month]} ${datetime.day}, ${datetime.year} - ${datetime.hour.toString().padLeft(2, "0")}:${datetime.minute.toString().padLeft(2, "0")}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Auction Page'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/add');
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
            Expanded(
              child: StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection("auction")
                      // .where('endTime', isGreaterThan: Timestamp.now())
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return Center(child: CircularProgressIndicator());
                    }
                    final listings = snapshot.data!.docs;
                    return ListView.builder(
                      itemCount: listings.length,
                      itemBuilder: (context, index) {
                        final listing = listings[index];
                        return GestureDetector(
                          onTap: () => Navigator.pushNamed(
                            context,
                            "/item",
                            arguments: {...listing.data(), "id": listing.id},
                          ),
                          child: Container(
                            margin: EdgeInsets.only(bottom: 8),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.black26),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: ListTile(
                              leading: Image.network(
                                listing["imageUrl"],
                                width: 50,
                                height: 50,
                                fit: BoxFit.scaleDown,
                              ),
                              trailing: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                      "${max<num>(listing["amount"], (listing["currentBid"] ?? 0)).toStringAsFixed(1)} PKR"),
                                  Text("+ ${listing["increment"]}"),
                                ],
                              ),
                              title: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(listing["title"]),
                                  Text(() {
                                    final timestampStart =
                                        listing["startTime"] as Timestamp;
                                    final timestampEnd =
                                        listing["endTime"] as Timestamp;

                                    if (timestampStart.microsecondsSinceEpoch <
                                            Timestamp.now()
                                                .microsecondsSinceEpoch &&
                                        timestampEnd.microsecondsSinceEpoch >
                                            Timestamp.now()
                                                .microsecondsSinceEpoch) {
                                      return "Ends at ${_formatDate(DateTime.fromMicrosecondsSinceEpoch((timestampEnd).microsecondsSinceEpoch))}";
                                    }
                                    if (timestampEnd.microsecondsSinceEpoch <
                                        Timestamp.now()
                                            .microsecondsSinceEpoch) {
                                      return "Bidding ended! Winner is ${listing["highestBidder"]}";
                                    }
                                    return "Starts at ${_formatDate(DateTime.fromMicrosecondsSinceEpoch((timestampStart).microsecondsSinceEpoch))}";
                                  }()),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  }),
            ),
          ],
        ),
      ),
    );
  }
}
