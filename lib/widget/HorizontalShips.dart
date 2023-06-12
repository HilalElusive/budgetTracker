import 'package:budget_tracker/theme/colors.dart';
import 'package:flutter/material.dart';

class HorizontalShips extends StatefulWidget {
  final int shipLength;
  final List data;
  final ValueChanged<int> onTypeSelected;
  const HorizontalShips({Key? key, required this.shipLength, required this.data, required this.onTypeSelected}) : super(key: key);

  @override
  State<HorizontalShips> createState() => _HorizontalShipsState();
}

class _HorizontalShipsState extends State<HorizontalShips> {
  int activeCategory = 0;
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
          children: List.generate(widget.shipLength, (index) {
            return GestureDetector(
              onTap: () {
                setState(() {
                  activeCategory = index;
                  widget.onTypeSelected(index);
                });
              },
              child: Padding(
                padding: const EdgeInsets.only(
                  left: 10,
                ),
                child: Container(
                  margin: const EdgeInsets.only(
                    left: 10,
                  ),
                  width: 150,
                  height: 130,
                  decoration: BoxDecoration(
                      color: white,
                      border: Border.all(
                          width: 2,
                          color: activeCategory == index
                              ? primary
                              : Colors.transparent),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: grey.withOpacity(0.01),
                          spreadRadius: 10,
                          blurRadius: 3,
                        ),
                      ]),
                  child: Padding(
                    padding: const EdgeInsets.only(
                        left: 25, right: 25, top: 20, bottom: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: grey.withOpacity(0.15)),
                            child: Center(
                              child: Image.asset(
                                widget.data[index]['icon'],
                                width: 30,
                                height: 30,
                                fit: BoxFit.contain,
                              ),
                            )),
                        Text(
                          widget.data[index]['name'],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            );
          })),
    );
  }
}
