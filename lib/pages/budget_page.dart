import 'package:budget_tracker/json/day_month.dart';
import 'package:budget_tracker/theme/colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_randomcolor/flutter_randomcolor.dart';
import 'package:hexcolor/hexcolor.dart';

class BudgetPage extends StatefulWidget {
  const BudgetPage({Key? key}) : super(key: key);

  @override
  _BudgetPageState createState() => _BudgetPageState();
}

class _BudgetPageState extends State<BudgetPage> {
  int activeMonth = 5;

  Stream<QuerySnapshot> _fetchBudgetsStream() {
    FirebaseAuth auth = FirebaseAuth.instance;
    String userId = auth.currentUser!.uid;
    String selectedMonthYear =
        months[activeMonth]['numday'] + '/' + months[activeMonth]['label'];

    return FirebaseFirestore.instance
        .collection('transactions')
        .where('user_id', isEqualTo: userId)
        .where('month_year', isEqualTo: selectedMonthYear)
        .where('type', isEqualTo: "Budget")
        .snapshots();
  }

  Stream<QuerySnapshot> _fetchExpensesStream(
      String budgetName, String selectedMonthYear, String userId) {
    return FirebaseFirestore.instance
        .collection('transactions')
        .where('user_id', isEqualTo: userId)
        .where('month_year', isEqualTo: selectedMonthYear)
        .where('type', isEqualTo: "Expense")
        .where('name', isEqualTo: budgetName)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: grey.withOpacity(0.05),
      body: StreamBuilder<QuerySnapshot>(
        stream: _fetchBudgetsStream(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<Map<String, dynamic>> budgets = snapshot.data!.docs
                .map((doc) => doc.data() as Map<String, dynamic>)
                .toList();
            return getBody(budgets);
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error fetching budgets: ${snapshot.error}'),
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }

  Widget getBody(List<Map<String, dynamic>> budgets) {
    FirebaseAuth auth = FirebaseAuth.instance;
    String userId = auth.currentUser!.uid;
    String selectedMonthYear =
        months[activeMonth]['numday'] + '/' + months[activeMonth]['label'];
    var size = MediaQuery.of(context).size;

    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(color: white, boxShadow: [
              BoxShadow(
                color: grey.withOpacity(0.02),
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
                        "Budget",
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
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(months.length, (index) {
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              activeMonth = index;
                            });
                          },
                          child: SizedBox(
                            width: (MediaQuery.of(context).size.width - 40) / 6,
                            child: Column(
                              children: [
                                Text(
                                  months[index]['label'],
                                  style: const TextStyle(fontSize: 10),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                      color: activeMonth == index
                                          ? primary
                                          : black.withOpacity(0.02),
                                      borderRadius: BorderRadius.circular(5),
                                      border: Border.all(
                                          color: activeMonth == index
                                              ? primary
                                              : black.withOpacity(0.1))),
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 12, right: 12, top: 7, bottom: 7),
                                    child: Text(
                                      months[index]['day'],
                                      style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                          color: activeMonth == index
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
            height: 20,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 20),
            child: Column(
                children: List.generate(budgets.length, (index) {
              String budgetName = budgets[index]['name'];
              double budgetAmount = budgets[index]['amount'];
              return StreamBuilder<QuerySnapshot>(
                stream:
                    _fetchExpensesStream(budgetName, selectedMonthYear, userId),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    List<Map<String, dynamic>> expenses = snapshot.data!.docs
                        .map((doc) => doc.data() as Map<String, dynamic>)
                        .toList();
                    double totalExpense =
                        expenses.fold(0.0, (sum, item) => sum + item['amount']);
                    double percentage = (totalExpense / budgetAmount) * 100;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                            color: white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: grey.withOpacity(0.02),
                                spreadRadius: 10,
                                blurRadius: 3,
                              ),
                            ]),
                        child: Padding(
                          padding: const EdgeInsets.only(
                              left: 25, right: 25, bottom: 25, top: 25),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                budgets[index]['name'],
                                style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 13,
                                    color: const Color(0xff67727d)
                                        .withOpacity(0.6)),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        "\$${totalExpense.toStringAsFixed(2)}",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20,
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 8,
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(top: 3),
                                        child: Text(
                                          "${percentage.toStringAsFixed(2)}%",
                                          style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                              fontSize: 13,
                                              color: Color(0xff67727d)
                                                  .withOpacity(0.6)),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 3),
                                    child: Text(
                                      "\$${budgets[index]['amount'].toStringAsFixed(2)}",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 13,
                                          color: Color(0xff67727d)
                                              .withOpacity(0.6)),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 15,
                              ),
                              Stack(
                                children: [
                                  Container(
                                    width: (size.width - 40),
                                    height: 4,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(5),
                                        color:
                                            Color(0xff67727d).withOpacity(0.1)),
                                  ),
                                  Container(
                                    width: (size.width - 40) *
                                        (percentage /
                                            100), // modified to the real percentage
                                    height: 4,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(5),
                                        color: HexColor(RandomColor.getColor(Options(format: Format.hex, colorType: ColorType.random)))),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    );
                  } else if (snapshot.hasError) {
                    return Text('Error fetching expenses: ${snapshot.error}');
                  } else {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                },
              );
            })),
          )
        ],
      ),
    );
  }
}
