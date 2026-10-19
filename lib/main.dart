import 'package:flutter/material.dart';

void main() {
  runApp(const HasebtiApp());
}

class HasebtiApp extends StatelessWidget {
  const HasebtiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'حاسبتي',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFF101713),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF20C879),
          brightness: Brightness.dark,
        ),
      ),
      home: const CalculatorScreen(),
    );
  }
}

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() =>
      _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String display = '0';

  double? firstNumber;
  String? operation;

  bool startNewNumber = false;

  final Color green = const Color(0xFF20C879);
  final Color background = const Color(0xFF101713);
  final Color buttonColor = const Color(0xFF202B24);

  void pressNumber(String number) {
    setState(() {
      if (display == 'خطأ' || startNewNumber) {
        display = number == '.' ? '0.' : number;
        startNewNumber = false;
        return;
      }

      if (number == '.') {
        if (!display.contains('.')) {
          display += '.';
        }
        return;
      }

      if (display == '0') {
        display = number;
      } else {
        if (display.length < 15) {
          display += number;
        }
      }
    });
  }

  double currentValue() {
    return double.tryParse(display) ?? 0;
  }

  String formatNumber(double number) {
    if (!number.isFinite) {
      return 'خطأ';
    }

    if (number.abs() < 0.000000001) {
      return '0';
    }

    if (number.abs() >= 1e15) {
      return number.toStringAsExponential(6);
    }

    String result = number.toStringAsFixed(8);

    if (result.contains('.')) {
      result = result.replaceAll(RegExp(r'0+$'), '');
      result = result.replaceAll(RegExp(r'\.$'), '');
    }

    return result;
  }

  double calculate(double a, double b, String op) {
    switch (op) {
      case '+':
        return a + b;
      case '-':
        return a - b;
      case '×':
        return a * b;
      case '÷':
        if (b == 0) {
          return double.nan;
        }
        return a / b;
      default:
        return b;
    }
  }

  void pressOperation(String op) {
    setState(() {
      if (display == 'خطأ') {
        clearAll();
      }

      final value = currentValue();

      if (operation != null &&
          firstNumber != null &&
          !startNewNumber) {
        final result = calculate(
          firstNumber!,
          value,
          operation!,
        );

        display = formatNumber(result);

        if (display == 'خطأ') {
          firstNumber = null;
          operation = null;
          startNewNumber = true;
          return;
        }

        firstNumber = double.tryParse(display);
      } else {
        firstNumber = value;
      }

      operation = op;
      startNewNumber = true;
    });
  }

  void pressEquals() {
    setState(() {
      if (operation == null || firstNumber == null) {
        return;
      }

      final secondNumber = currentValue();

      final result = calculate(
        firstNumber!,
        secondNumber,
        operation!,
      );

      display = formatNumber(result);

      firstNumber = null;
      operation = null;
      startNewNumber = true;
    });
  }

  void clearAll() {
    display = '0';
    firstNumber = null;
    operation = null;
    startNewNumber = false;
  }

  void pressClear() {
    setState(() {
      clearAll();
    });
  }

  void pressBackspace() {
    setState(() {
      if (display == 'خطأ' || startNewNumber) {
        display = '0';
        startNewNumber = false;
        return;
      }

      if (display.length > 1) {
        display = display.substring(0, display.length - 1);

        if (display == '-') {
          display = '0';
        }
      } else {
        display = '0';
      }
    });
  }

  void pressPercent() {
    setState(() {
      if (display == 'خطأ') {
        clearAll();
        return;
      }

      display = formatNumber(currentValue() / 100);
      startNewNumber = true;
    });
  }

  void pressSign() {
    setState(() {
      if (display == 'خطأ' || currentValue() == 0) {
        return;
      }

      display = formatNumber(-currentValue());
    });
  }

  void onButtonPressed(String value) {
    switch (value) {
      case 'مسح':
        pressClear();
        break;

      case 'حذف':
        pressBackspace();
        break;

      case '%':
        pressPercent();
        break;

      case '+/-':
        pressSign();
        break;

      case '+':
      case '-':
      case '×':
      case '÷':
        pressOperation(value);
        break;

      case '=':
        pressEquals();
        break;

      case '.':
        pressNumber('.');
        break;

      default:
        pressNumber(value);
    }
  }

  Widget buildButton(String label) {
    final bool isOperation =
        ['+', '-', '×', '÷', '='].contains(label);

    final bool isSpecial =
        ['مسح', 'حذف', '%', '+/-'].contains(label);

    final Color color;

    if (label == '=') {
      color = green;
    } else if (isOperation) {
      color = const Color(0xFF28513A);
    } else if (isSpecial) {
      color = const Color(0xFF344238);
    } else {
      color = buttonColor;
    }

    return Padding(
      padding: const EdgeInsets.all(5),
      child: Material(
        color: color,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => onButtonPressed(label),
          child: Center(
            child: label == 'حذف'
                ? const Icon(
                    Icons.backspace_outlined,
                    color: Colors.white,
                    size: 25,
                  )
                : Text(
                    label,
                    style: TextStyle(
                      color: label == '='
                          ? Colors.black
                          : Colors.white,
                      fontSize: label.length > 2 ? 18 : 25,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 12,
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.calculate_rounded,
                    color: green,
                    size: 30,
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'حاسبتي',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 27,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              Text(
                'حساباتك بسهولة',
                style: TextStyle(
                  color: green.withValues(alpha: 0.85),
                  fontSize: 14,
                ),
              ),

              const SizedBox(height: 20),

              Expanded(
                flex: 2,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: const Color(0xFF19231C),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                      color: green.withValues(alpha: 0.25),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'النتيجة',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 16,
                        ),
                      ),

                      const Spacer(),

                      Directionality(
                        textDirection: TextDirection.ltr,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerRight,
                          child: Text(
                            display,
                            maxLines: 1,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 52,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 14),

              Expanded(
                flex: 4,
                child: Directionality(
                  textDirection: TextDirection.ltr,
                  child: GridView.count(
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 4,
                    childAspectRatio: screenWidth / 4 / 78,
                    children: [
                      'مسح',
                      'حذف',
                      '%',
                      '÷',
                      '7',
                      '8',
                      '9',
                      '×',
                      '4',
                      '5',
                      '6',
                      '-',
                      '1',
                      '2',
                      '3',
                      '+',
                      '+/-',
                      '0',
                      '.',
                      '=',
                    ].map(buildButton).toList(),
                  ),
                ),
              ),

              const SizedBox(height: 8),

              Text(
                'حاسبتي • بسيطة وسريعة',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.4),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}