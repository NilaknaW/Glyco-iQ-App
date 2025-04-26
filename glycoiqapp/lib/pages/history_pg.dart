import 'package:flutter/material.dart';
import '../helper/database_helper.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../helper/pdf_helper.dart';
import 'package:open_file/open_file.dart';
import 'package:share_plus/share_plus.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<Map<String, dynamic>> history = [];

  @override
  void initState() {
    super.initState();
    loadHistory();
  }

  void loadHistory() async {
    final data = await DatabaseHelper().getHistory();
    setState(() => history = data);
  }

  //insert random data for glucose level
  // void addHistory(String date, String time, String glucose_level) async {
  //   await DatabaseHelper().insertGlucose(date, time, glucose_level);
  //   loadHistory();
  // }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            graphBlock(),
            shareBlock(),
            historyBlock(),
          ],
        ),
      ),
    );
  }

  Widget graphBlock() {
    return Container(
      padding: const EdgeInsets.only(bottom: 10),
      child: Card.filled(
        child: Column(
          // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const ListTile(title: Center(child: Text('Past Week'))),
            pastWeekGraph(), // add graph here
            // Placeholder(
            //   fallbackHeight: 200,
            // ) // add graph here
          ],
        ),
      ),
    );
  }

  Widget shareBlock() {
    return Container(
      padding: const EdgeInsets.only(bottom: 10),
      child: Card.filled(
        child: Column(
          children: [
            const ListTile(title: Center(child: Text('Share'))),
            shareButton(
                const Text('Share'), const Icon(Icons.share), shareData),
            shareButton(const Text('Download'), const Icon(Icons.download),
                downloadData),
          ],
        ),
      ),
    );
  }

  void shareData() async {
    // final db = await DatabaseHelper.instance.database;
    // final history = await getLast30DaysHistory(db);
    final pdfFile = await generateGlucosePDF(history);
    await Share.shareXFiles([XFile(pdfFile.path)], text: 'My glucose data');
  }

  void downloadData() async {
    // final db = await DatabaseHelper.instance.database;
    // final history = await getLast30DaysHistory(db);
    final pdfFile = await generateGlucosePDF(history);
    OpenFile.open(pdfFile.path); // or show a toast/snackbar for confirmation
  }

  Widget shareButton(Text text, Icon icon, void Function()? onPressed) {
    return Container(
      padding: const EdgeInsets.only(left: 20, right: 20, bottom: 5),
      child: FilledButton(
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [text, icon],
        ),
      ),
    );
  }

  Widget historyBlock() {
    return Container(
      padding: const EdgeInsets.only(bottom: 10),
      child: Card.filled(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const ListTile(title: Center(child: Text('History'))),
            historyLogs(),
          ],
        ),
      ),
    );
  }

  Widget historyLogs() {
    // return the list of logs
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.only(left: 4, right: 4, bottom: 4),
          child: ListTile(
            title: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Date'),
                Text('Time'),
                Text('Glucose (mmol/L)'),
              ],
            ),
            textColor: Color.fromRGBO(21, 76, 121, 1),
            // tileColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
        for (var record in history)
          Padding(
            padding: EdgeInsets.only(left: 4, right: 4, bottom: 4),
            child: ListTile(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(record['date']),
                  Text(record['time']),
                  Text(record['glucose']),
                ],
              ),
              tileColor: Colors.blueGrey[50],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
      ],
    );
  }

  List<Map<String, dynamic>> getPastWeekLogs() {
    final seenDates = <String>{};
    final recent7 = <Map<String, dynamic>>[];

    for (final record in history) {
      final date = record['date'];
      if (!seenDates.contains(date)) {
        seenDates.add(date);
        recent7.add(record);
        if (recent7.length == 7) break;
      }
    }

    return recent7.toList(); // To maintain chronological order
  }

  Widget pastWeekGraph() {
    // Example data
    // final now = DateTime.now();
    // final dates =
    // List.generate(7, (index) => now.subtract(Duration(days: 6 - index)));
    // final values = [90.0, 110.0, 100.0, 95.0, 105.0, 120.0, 115.0];
    List dates = <DateTime>[];
    List values = <double>[];
    int i = 0;

    for (var entry in history) {
      final date = DateTime.parse(entry['date']);
      if (!dates.contains(date)) {
        dates.add(date);
        values.add(
            double.parse(entry['glucose'])); // Assuming glucose is in mmol/L

        i++;
        if (i == 7) break; // Limit to 7 entries
      }
    }

    dates = dates.reversed.toList(); // Reverse the order
    values = values.reversed.toList(); // Reverse the order

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
          color: const Color.fromRGBO(21, 76, 121, 0.8), // dark background
          borderRadius: BorderRadius.circular(10),
        ),
        child: SizedBox(
          height: 250,
          child: Padding(
            padding: const EdgeInsets.all(16), // 👈 adds 16px around chart
            child: LineChart(
              LineChartData(
                minY: 2.0,
                maxY: 10.0,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: true,
                  getDrawingHorizontalLine: (value) => FlLine(
                    // color: Colors.white10,
                    // strokeWidth: 1,
                    color: value == 7.8 ? Colors.amberAccent : Colors.white10,
                    strokeWidth: value == 7.8 ? 2 : 1,
                    dashArray: value == 7.8 ? [5, 5] : null,
                  ),
                  getDrawingVerticalLine: (value) => const FlLine(
                    color: Colors.white10,
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '${value.toDouble()}',
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 12),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        int index = value.toInt();
                        if (index >= 0 && index < dates.length) {
                          String formatted =
                              DateFormat('MMMd').format(dates[index]);
                          return Text(
                            formatted,
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 10),
                          );
                        } else {
                          return const Text('');
                        }
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border.all(color: Colors.white24),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: List.generate(
                      values.length,
                      (index) => FlSpot(index.toDouble(), values[index]),
                    ),
                    isCurved: true,
                    gradient: const LinearGradient(
                      colors: [Colors.cyanAccent, Colors.greenAccent],
                    ),
                    barWidth: 4,
                    isStrokeCapRound: true,
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          Colors.cyanAccent.withOpacity(0.3),
                          Colors.greenAccent.withOpacity(0.1),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) =>
                          FlDotCirclePainter(
                        radius: 4,
                        color: Colors.white,
                        strokeWidth: 2,
                        strokeColor: Colors.cyanAccent,
                      ),
                    ),
                  ),
                ],
                rangeAnnotations: RangeAnnotations(
                  horizontalRangeAnnotations: [
                    HorizontalRangeAnnotation(
                      y1: 4.0,
                      y2: 7.8,
                      color: Colors.greenAccent
                          .withOpacity(0.2), // Normal range shading
                    ),
                  ],
                  verticalRangeAnnotations: [], // Optional
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
