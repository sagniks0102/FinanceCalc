import 'dart:math';

void main() {
  double basicSalary = 30000;
  double employeeContrib = 12.0;
  double employerEpfRate = 3.67;
  double salaryGrowth = 5.0;
  double years = 34;
  double rate = 8.25;
  double r = rate / 100 / 12;

  double corpus = 0;
  double invested = 0;

  for (int y = 0; y < years.toInt(); y++) {
    double salary = basicSalary * pow(1 + salaryGrowth / 100, y);
    double monthlyTotal = salary * (employeeContrib + employerEpfRate) / 100;

    double yearlyInterest = 0;
    for (int m = 0; m < 12; m++) {
      invested += monthlyTotal;
      yearlyInterest += corpus * r;
      corpus += monthlyTotal;
    }
    corpus += yearlyInterest;
  }

  print("Method 1 Corpus: " + corpus.toStringAsFixed(0));
  print("Method 1 Invested: " + invested.toStringAsFixed(0));
}
