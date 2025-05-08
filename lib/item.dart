import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ItemPage extends StatefulWidget {
  final Map<String, dynamic> data;
  const ItemPage(this.data, {super.key});

  @override
  State<ItemPage> createState() => _ItemPageState();
}

class _ItemPageState extends State<ItemPage> {
  String formatDurationFromNow(Timestamp start) {
    int diffMillis =
        start.millisecondsSinceEpoch - Timestamp.now().millisecondsSinceEpoch;

    // If the duration is negative, set to 0
    Duration duration = Duration(milliseconds: diffMillis < 0 ? 0 : diffMillis);

    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String hours = twoDigits(duration.inHours);
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String seconds = twoDigits(duration.inSeconds.remainder(60));

    return "$hours:$minutes:$seconds";
  }

  String timeRemainingToStart = "";
  String timeRemainingToEnd = "";
  Timer? _timer;
  Map<String, dynamic>? lastestData;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(
      Duration(seconds: 1),
      (timer) => setState(() {
        timeRemainingToStart = formatDurationFromNow(
            lastestData?["startTime"] ?? widget.data["startTime"]);
        timeRemainingToEnd = formatDurationFromNow(
            lastestData?["endTime"] ?? widget.data["endTime"]);
      }),
    );
    FirebaseFirestore.instance
        .collection("auction")
        .doc(lastestData?["id"] ?? widget.data["id"])
        .snapshots()
        .listen((data) {
      setState(() {
        lastestData = {...(data.data() ?? widget.data), "id": data.id};
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Listing"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              width: MediaQuery.sizeOf(context).width - 24,
              child: Center(
                child: Column(
                  spacing: 8,
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.network(
                      lastestData?["imageUrl"] ?? widget.data["imageUrl"],
                      height: 350,
                      fit: BoxFit.fitWidth,
                    ),
                    Text(
                      lastestData?["title"] ?? widget.data["title"],
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Starting Bid",
                            style: TextStyle(
                              fontSize: 16,
                            ),
                          ),
                          Text(
                              "${lastestData?["amount"] ?? widget.data["amount"]} PKR",
                              style: TextStyle(fontSize: 16)),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Increment",
                            style: TextStyle(
                              fontSize: 16,
                            ),
                          ),
                          Text(
                              "${lastestData?["increment"] ?? widget.data["increment"]} PKR",
                              style: TextStyle(fontSize: 16)),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Current Bid",
                            style: TextStyle(
                              fontSize: 16,
                            ),
                          ),
                          Text(
                              "${lastestData?["currentBid"] ?? widget.data["currentBid"]} PKR",
                              style: TextStyle(fontSize: 16)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            ((lastestData?["endTime"] ?? widget.data["endTime"])
                        .microsecondsSinceEpoch >=
                    Timestamp.now().microsecondsSinceEpoch)
                ? ((lastestData?["highestBidder"] ??
                            widget.data["highestBidder"]) !=
                        FirebaseAuth.instance.currentUser?.email)
                    ? ElevatedButton(onPressed: () async {
                        final Timestamp start = lastestData?["startTime"] ??
                            widget.data["startTime"];
                        final Timestamp end =
                            lastestData?["endTime"] ?? widget.data["endTime"];
                        if (start.microsecondsSinceEpoch >
                            Timestamp.now().microsecondsSinceEpoch) {
                          return;
                        }
                        if (end.microsecondsSinceEpoch <
                            Timestamp.now().microsecondsSinceEpoch) {
                          return;
                        }
                        FirebaseFirestore.instance
                            .collection("auction")
                            .doc(lastestData?["id"] ?? widget.data["id"])
                            .update(
                          {
                            "currentBid": max<num>(
                                    (lastestData?["amount"] ??
                                        widget.data["amount"]),
                                    (lastestData?["currentBid"] ??
                                        widget.data["currentBid"])) +
                                (lastestData?["increment"] ??
                                    widget.data["increment"]),
                            "highestBidder":
                                FirebaseAuth.instance.currentUser!.email,
                          },
                        ).then((_) {
                          FirebaseFirestore.instance
                              .collection("auction")
                              .doc(lastestData?["id"] ?? widget.data["id"])
                              .get()
                              .then((data) {
                            setState(() {
                              lastestData = {
                                ...(data.data() ?? widget.data),
                                "id": data.id
                              };
                            });
                          });
                        });
                      }, child: Text(() {
                        final Timestamp start = lastestData?["startTime"] ??
                            widget.data["startTime"];
                        final Timestamp end =
                            lastestData?["endTime"] ?? widget.data["endTime"];

                        if (start.microsecondsSinceEpoch >
                            Timestamp.now().microsecondsSinceEpoch) {
                          return "Starting in $timeRemainingToStart";
                        }
                        if (end.microsecondsSinceEpoch <
                            Timestamp.now().microsecondsSinceEpoch) {
                          return "Bidding Ended";
                        }
                        return "Bid Now, Ending in $timeRemainingToEnd";
                      }()))
                    : Text("You are highest bidder")
                : Text(
                    "Voting closed!\n${(lastestData?["currentBid"] ?? widget.data["currentBid"]) == 0 ? "Nobody" : (lastestData?["highestBidder"] ?? widget.data["highestBidder"])} won"),
          ],
        ),
      ),
    );
  }
}
