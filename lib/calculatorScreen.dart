import 'package:calculator/buttonValues.dart';
import 'package:flutter/material.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String num_1 = "";
  String num_2 = "";
  String operator = "";

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child:
            isLandscape
                ? _buildLandscapeLayout(screenSize)
                : _buildPortraitLayout(screenSize),
      ),
    );
  }

  Widget _buildPortraitLayout(Size screenSize) {
    return Column(
      children: [
        // Output
        Expanded(child: _buildOutputSection()),
        // Buttons
        _buildButtonsGrid(screenSize, isLandscape: false),
      ],
    );
  }

  Widget _buildLandscapeLayout(Size screenSize) {
    return Row(
      children: [
        // Buttons take 70% of width in landscape
        Expanded(
          flex: 7,
          child: _buildButtonsGrid(screenSize, isLandscape: true),
        ),
        // Output takes 30% of width in landscape
        Expanded(flex: 3, child: _buildOutputSection()),
      ],
    );
  }

  Widget _buildOutputSection() {
    return SingleChildScrollView(
      reverse: true,
      child: Container(
        alignment: Alignment.bottomRight,
        padding: const EdgeInsets.all(16),
        child: Text(
          "$num_1$operator$num_2".isEmpty ? "0" : "$num_1$operator$num_2",
          style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
          textAlign: TextAlign.end,
        ),
      ),
    );
  }

  Widget _buildButtonsGrid(Size screenSize, {required bool isLandscape}) {
    // Calculate button dimensions based on orientation
    final buttonWidth =
        isLandscape
            ? screenSize.width *
                0.7 /
                4 // 4 buttons per row in landscape
            : screenSize.width / 4; // 4 buttons per row in portrait

    final buttonHeight =
        isLandscape
            ? screenSize.height /
                5 // 5 rows in landscape
            : screenSize.width /
                5; // Make button height same as width in portrait

    return Wrap(
      children:
          Btn.buttonValues
              .map(
                (value) => SizedBox(
                  width:
                      value == Btn.n0
                          ? buttonWidth *
                              2 // Zero button is double width
                          : buttonWidth,
                  height: buttonHeight,
                  child: buildButton(value),
                ),
              )
              .toList(),
    );
  }

  Widget buildButton(value) {
    return Padding(
      padding: const EdgeInsets.all(4),
      child: Material(
        color: getBtnColor(value),
        clipBehavior: Clip.hardEdge,
        shape: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.white24),
          borderRadius: BorderRadius.circular(100),
        ),
        child: InkWell(
          onTap: () => onBtnTap(value),
          child: Center(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
            ),
          ),
        ),
      ),
    );
  }

  void onBtnTap(String value) {
    if (value == Btn.del) {
      delete();
      return;
    }

    if (value == Btn.clr) {
      num_1 = "";
      num_2 = "";
      operator = "";
      setState(() {});
      return;
    }

    if (value == Btn.per) {
      convertToPercentage();
      return;
    }

    if (value == Btn.calculate) {
      calculate();
      return;
    }
    appendValue(value);
  }

  void calculate() {
    if (num_1.isEmpty) return;
    if (num_2.isEmpty) return;
    if (operator.isEmpty) return;

    double num1 = double.parse(num_1);
    double num2 = double.parse(num_2);

    var result = 0.0;

    switch (operator) {
      case Btn.add:
        result = num1 + num2;
        break;
      case Btn.subtract:
        result = num1 - num2;
        break;
      case Btn.multiply:
        result = num1 * num2;
        break;
      case Btn.divide:
        result = num1 / num2;
        break;
    }

    setState(() {
      num_1 = result.toString();
      if (num_1.endsWith(".0")) {
        num_1 = num_1.substring(0, num_1.length - 2);
      }
    });
    operator = "";
    num_2 = "";
  }

  void convertToPercentage() {
    if (num_1.isNotEmpty && operator.isNotEmpty && num_2.isNotEmpty) {
      calculate();
    }

    if (operator.isNotEmpty) {
      return;
    }

    final number = double.parse(num_1);
    setState(() {
      num_1 = "${number / 100}";
      operator = "";
      num_2 = "";
    });
  }

  void delete() {
    if (num_2.isNotEmpty) {
      num_2 = num_2.substring(0, num_2.length - 1);
    } else if (operator.isNotEmpty) {
      operator = "";
    } else if (num_1.isNotEmpty) {
      num_1 = num_1.substring(0, num_1.length - 1);
    }

    setState(() {});
  }

  void appendValue(String value) {
    if (value != Btn.dot && int.tryParse(value) == null) {
      if (operator.isNotEmpty && num_1.isNotEmpty) {}
      operator = value;
    } else if (num_1.isEmpty || operator.isEmpty) {
      if (value == Btn.dot && num_1.contains(Btn.dot)) return;
      if (value == Btn.dot && (num_1.isEmpty || num_1 == Btn.n0)) {
        value = "0.";
      }
      num_1 += value;
    } else if (num_2.isEmpty || operator.isNotEmpty) {
      if (value == Btn.dot && num_2.contains(Btn.dot)) return;
      if (value == Btn.dot && (num_2.isEmpty || num_2 == Btn.n0)) {
        value = "0.";
      }
      num_2 += value;
    }
    setState(() {});
  }

  Color getBtnColor(value) {
    return [Btn.del, Btn.clr].contains(value)
        ? Colors.blueGrey
        : [
          Btn.per,
          Btn.multiply,
          Btn.add,
          Btn.subtract,
          Btn.divide,
          Btn.calculate,
        ].contains(value)
        ? Colors.orange
        : Colors.black87;
  }
}
