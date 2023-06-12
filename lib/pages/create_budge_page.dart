import 'package:budget_tracker/json/create_budget_json.dart';
import 'package:budget_tracker/theme/colors.dart';
import 'package:budget_tracker/widget/HorizontalShips.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CreateBudgetPage extends StatefulWidget {
  const CreateBudgetPage({super.key});

  @override
  _CreateBudgetPageState createState() => _CreateBudgetPageState();
}

class _CreateBudgetPageState extends State<CreateBudgetPage> {
  int activeType = 0;
  int activeCategory = 0;

  final TextEditingController _budgetName = TextEditingController(text: "");
  final TextEditingController _budgetPrice = TextEditingController(text: "\$1500.00");
  DateTime? selectedDate;
  String? selectedBudget;


  final _firestore = FirebaseFirestore.instance;
  // Store budget names for the current month
  List<String> currentMonthBudgets = [];

  Future<void> _createBudget() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    final date = selectedDate ?? DateTime.now();
    final monthYear = DateFormat('MM/yyyy').format(date);

    final existingBudgets = await _firestore.collection('transactions')
        .where('user_id', isEqualTo: userId)
        .where('name', isEqualTo: _budgetName?.text)
        .where('type', isEqualTo: "Budget")
        .where('month_year', isEqualTo: monthYear)
        .get();

    if (existingBudgets.docs.isNotEmpty) {
      throw Exception('You have already created a budget with this name for this month.');
    } else {
      await _firestore.collection('transactions').add({
        'user_id': userId,
        'name': _budgetName?.text,
        'type': "Budget",
        'amount': double.parse(double.parse(_budgetPrice.text.substring(1)).toStringAsFixed(2)),
        'icon': categories[activeCategory]['icon'],
        'date': date,
        'month_year': monthYear
      });
    }
  }

  Future<void> _createExpense() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    final date = selectedDate ?? DateTime.now();
    final monthYear = DateFormat('MM/yyyy').format(date);

    if (selectedBudget == null) {
      throw Exception('Please select a budget for this expense.');
    } else {
      await _firestore.collection('transactions').add({
        'user_id': userId,
        'name': selectedBudget,
        'type': "Expense",
        'amount': double.parse(double.parse(_budgetPrice.text.substring(1)).toStringAsFixed(2)),
        'icon': categories[activeCategory]['icon'],
        'date': date,
        'month_year': monthYear
      });
    }
  }

  void _updateActiveType(int index) {
    setState(() {
      activeType = index;
      // Update budget names when type changes
      _updateCurrentMonthBudgets();
      print("it has been clicked! you got : ${types[activeType]['name']}");
    });
  }
  void _updateActiveCategory(int index) {
    setState(() {
      activeCategory = index;
      print("it has been clicked! you got : ${categories[activeCategory]['name']}");
    });
  }
  Future<void> _updateCurrentMonthBudgets() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    final date = DateTime.now();
    final monthYear = DateFormat('MM/yyyy').format(date);

    final budgetDocs = await _firestore.collection('transactions')
        .where('user_id', isEqualTo: userId)
        .where('type', isEqualTo: "Budget")
        .where('month_year', isEqualTo: monthYear)
        .get();

    setState(() {
      currentMonthBudgets = budgetDocs.docs.map((doc) => doc['name']).toList().cast<String>();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white,
      body: SafeArea(child: getBody(),),
    );
  }

  Widget getBody() {
    var size = MediaQuery.of(context).size;
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Padding(
                padding: EdgeInsets.all(32.0),
                child: Text(
                  "Add transaction",
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: black),
                ),
              ),
              IconButton(
                  onPressed: () {
                    FirebaseAuth.instance.signOut();
                  },
                  icon: const Icon(Icons.logout)),
            ],
          ),
          Container(
            decoration: BoxDecoration(color: white, boxShadow: [
              BoxShadow(
                color: grey.withOpacity(0.05),
                spreadRadius: 10,
                blurRadius: 3,
              ),
            ]),
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.only(top: 25, left: 25,bottom: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Transaction type",
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black54),
                  ),
                  const SizedBox(height: 10,),
                  HorizontalShips(shipLength: types.length, data: types, onTypeSelected: _updateActiveType),
                ],
              ),
            )
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 20, top: 30),
            child: Text(
              "Choose category",
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: black.withOpacity(0.5)),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          HorizontalShips(shipLength: categories.length, data: categories, onTypeSelected: _updateActiveCategory),
          const SizedBox(
            height: 30,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "budget name",
                  style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                      color: Color(0xff67727d)),
                ),
                types[activeType]['name'] == 'Budget'
                    ? TextField(
                  controller: _budgetName,
                  cursorColor: black,
                  style: const TextStyle(
                      fontSize: 17, fontWeight: FontWeight.bold, color: black),
                  decoration: const InputDecoration(
                      hintText: "Enter Budget Name", border: InputBorder.none),
                )
                    : DropdownButton<String>(
                  value: selectedBudget,
                  icon: const Icon(Icons.arrow_drop_down),
                  items: currentMonthBudgets.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  hint: Text('Select Budget'),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedBudget = newValue;
                    });
                  },
                ),
                const SizedBox(
                  height: 5,
                ),
                const Text(
                  "Transaction Date",
                  style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                      color: Color(0xff67727d)),
                ),
                TextField(
                  onTap: () async {
                    DateTime? pickedDate;
                    if (types[activeType]['name'] == 'Expense') {
                      pickedDate = await showDatePicker(
                        context: context,
                        initialDate: selectedDate ?? DateTime.now(),
                        firstDate: DateTime(2015, 8),
                        lastDate: DateTime(2101),
                      );

                      if (pickedDate != null) {
                        final pickedTime = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.fromDateTime(selectedDate ?? DateTime.now()),
                        );
                        if (pickedTime != null) {
                          pickedDate = DateTime(
                            pickedDate.year,
                            pickedDate.month,
                            pickedDate.day,
                            pickedTime.hour,
                            pickedTime.minute,
                          );
                        }
                      }
                    } else {
                      pickedDate = await showDatePicker(
                        context: context,
                        initialDate: selectedDate ?? DateTime.now(),
                        firstDate: DateTime(2015, 8),
                        lastDate: DateTime(2101),
                        initialDatePickerMode: DatePickerMode.year,
                      );
                    }

                    if (pickedDate != null) {
                      setState(() {
                        selectedDate = pickedDate;
                      });
                    }
                  },
                  controller: TextEditingController(text: selectedDate?.toIso8601String() ?? ''),
                  readOnly: true,
                ),

                const SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: (size.width - 140),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Enter budget",
                            style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 13,
                                color: Color(0xff67727d)),
                          ),
                          TextField(
                            controller: _budgetPrice,
                            cursorColor: black,
                            style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: black),
                            decoration: const InputDecoration(
                                hintText: "Enter Budget",
                                border: InputBorder.none),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                    GestureDetector(
                      onTap: () async {
                        try {
                          if (types[activeType]['name'] == 'Budget') {
                            await _createBudget();
                          } else if (types[activeType]['name'] == 'Expense') {
                            await _createExpense();
                          }                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Record added successfully!'),
                              backgroundColor: green,
                              duration: Duration(seconds: 5),
                            ),
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(e.toString().split(': ')[1]),
                              duration: Duration(seconds: 5),
                              backgroundColor: red,
                            ),
                          );
                        }
                      },
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                            color: primary,
                            borderRadius: BorderRadius.circular(15)),
                        child: const Icon(
                          Icons.arrow_forward,
                          color: white,
                        ),
                      ),
                    )

                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
