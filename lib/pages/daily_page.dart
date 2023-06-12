import 'package:budget_tracker/json/day_month.dart';
import 'package:budget_tracker/theme/colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DailyPage extends StatefulWidget {
  const DailyPage({super.key});

  @override
  _DailyPageState createState() => _DailyPageState();
}

class _DailyPageState extends State<DailyPage> {
  int activeDay = 3;
  final user = FirebaseAuth.instance.currentUser; // Get the current user
  List<Map<String, dynamic>> daily = []; // We will populate this from Firestore
  bool isFirstLoad = true;

  Stream<List<Map<String, dynamic>>> fetchTransactions() {
    // parse the string to a DateTime
    var format = DateFormat("MM/dd/yyyy");
    DateTime selectedDate = format.parse(days[activeDay]['fullday']);
    // convert the DateTime to a Timestamp
    Timestamp startTimestamp = Timestamp.fromDate(DateTime(
        selectedDate.year, selectedDate.month, selectedDate.day, 0, 0, 0));
    Timestamp endTimestamp = Timestamp.fromDate(DateTime(
        selectedDate.year, selectedDate.month, selectedDate.day, 23, 59, 59));

    return FirebaseFirestore.instance
        .collection('transactions')
        .where('user_id', isEqualTo: user?.uid)
        .where('type',isEqualTo: "Expense")
        .where('date', isGreaterThanOrEqualTo: startTimestamp)
        .where('date', isLessThanOrEqualTo: endTimestamp)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => doc.data())
            .cast<Map<String, dynamic>>()
            .toList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: grey.withOpacity(0.05),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: fetchTransactions(),
        builder: (BuildContext context,
            AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              isFirstLoad) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            // After first load, set isFirstLoad to false
            if (isFirstLoad) {
              isFirstLoad = false;
            }
            return getBody(snapshot.data!);
          }
        },
      ),
    );
  }

  Widget getBody(List<Map<String, dynamic>> data) {
    var size = MediaQuery.of(context).size;
    double totalAmount = data.fold(0.0, (previous, current) => previous + current['amount']);
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(color: white, boxShadow: [
              BoxShadow(
                color: grey.withOpacity(0.01),
                spreadRadius: 10,
                blurRadius: 3,
              ),
            ]),
            child: Padding(
              padding: const EdgeInsets.only(
                  top: 60, right: 20, left: 20, bottom: 25),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Daily Transaction",
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: black),
                      ),
                      IconButton(
                          onPressed: () {
                            FirebaseAuth.instance.signOut();
                          },
                          icon: const Icon(Icons.logout))
                    ],
                  ),
                  const SizedBox(
                    height: 25,
                  ),
                  Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: List.generate(days.length, (index) {
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              activeDay = index;
                              fetchTransactions(); // Fetch data again when a new day is selected
                            });
                          },
                          child: Container(
                            width: (MediaQuery.of(context).size.width - 40) / 7,
                            child: Column(
                              children: [
                                Text(
                                  days[index]['label'],
                                  style: TextStyle(fontSize: 10),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Container(
                                  width: 30,
                                  height: 30,
                                  decoration: BoxDecoration(
                                      color: activeDay == index
                                          ? primary
                                          : Colors.transparent,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                          color: activeDay == index
                                              ? primary
                                              : black.withOpacity(0.1))),
                                  child: Center(
                                    child: Text(
                                      days[index]['day'],
                                      style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                          color: activeDay == index
                                              ? white
                                              : black),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        );
                      }))
                ],
              ),
            ),
          ),
          const SizedBox(
            height: 30,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 20),
            child: Column(
                children: List.generate(data.length, (index) {
              return Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: (size.width - 40) * 0.7,
                        child: Row(
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: grey.withOpacity(0.1),
                              ),
                              child: Center(
                                child: Image.asset(
                                  data[index]['icon'],
                                  width: 30,
                                  height: 30,
                                ),
                              ),
                            ),
                            SizedBox(width: 15),
                            Container(
                              width: (size.width - 90) * 0.5,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    data[index]['name'],
                                    style: const TextStyle(
                                        fontSize: 15,
                                        color: black,
                                        fontWeight: FontWeight.w500),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: 5),
                                  Text(
                                    DateFormat('E h a')
                                        .format(data[index]['date'].toDate()),
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: black.withOpacity(0.5),
                                        fontWeight: FontWeight.w400),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                      Container(
                        width: (size.width - 40) * 0.3,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              "\$${data[index]['amount'].toStringAsFixed(2)}",
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                  color: Colors.green),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.only(left: 65, top: 8),
                    child: Divider(
                      thickness: 0.8,
                    ),
                  )
                ],
              );
            })),
          ),
          SizedBox(
            height: 10,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 20, bottom: 10),
            child: Row(
              children: [
                Spacer(),
                Padding(
                  padding: const EdgeInsets.only(right: 80),
                  child: Text(
                    "Total",
                    style: TextStyle(
                        fontSize: 16,
                        color: black.withOpacity(0.4),
                        fontWeight: FontWeight.w600),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Spacer(),
                Padding(
                  padding: const EdgeInsets.only(top: 5),
                  child: Text(
                    "\$${totalAmount.toStringAsFixed(2)}",
                    style: const TextStyle(
                        fontSize: 20,
                        color: black,
                        fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
