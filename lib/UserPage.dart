import 'dart:convert' as convert;
import 'package:financial_ai/LoadingDialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:pie_chart/pie_chart.dart';

import 'ChatPage.dart';
import 'StockDetailsPage.dart';
import 'Util.dart';

class Userpage extends StatefulWidget {
  var user;

  Userpage(this.user);

  @override
  State<Userpage> createState() => _UserpageState();
}

String capitalizeFirstLetter(String text) {
  if (text.isEmpty) return text;
  return text[0].toUpperCase() + text.substring(1);
}

class _UserpageState extends State<Userpage> {
  Map<String, double> dataMap = {};

  List<Color> colorList =[
    Colors.deepOrangeAccent,
    Colors.greenAccent,
    Colors.pinkAccent,
    Colors.redAccent,
    Colors.deepPurpleAccent,
    Colors.blueAccent,
    Colors.amberAccent,
  ];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // fetchOHLCV();
    });

  }

  @override
  Widget build(BuildContext context) {
    var user = widget.user;
    // print(jsonResponse['object']);

    List list = user['stocks'];

    list.forEach((v){
      dataMap[capitalizeFirstLetter(v['name'])]=double.tryParse(v['number'].toString())!;
    });

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: BackButton(),
        title: Text(
          user['name'],
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [

                  Row(
                    children: [
                      Expanded(
                        child: TextTile(
                          'Investment Purpose',
                          user['investment_purpose'],
                        ),
                      ),
                      Expanded(
                        child: TextTile(
                          'Annual Income',
                          ("\$" +
                              NumberFormat()
                                  .format(user['annual_income'])
                                  .toString()),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: TextTile(
                          'Risk Appetite',
                          user['risk_appetite'],
                          borderColor: colorAsPerRisk(user['risk_appetite']),
                        ),
                      ),
                      Expanded(
                        child: TextTile(
                          'Investment Duration',
                          user['investment_duration_years'].toString() +
                              " years",
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  stockData != null
                      ? Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: StockTable(
                          stockData: (stockData ?? []),
                          company: stockDataCompany,
                        ),
                      )
                      : Container(),

                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "Portfolio",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black, // Dark color
                        fontSize: 20,
                      ),
                    ),
                  ),
                  PieChart(
                    dataMap:dataMap,
                    animationDuration: Duration(milliseconds: 800),
                    chartLegendSpacing: 40,
                    chartRadius: MediaQuery.of(context).size.width / 2,
                    colorList: colorList,
                    initialAngleInDegree: 0,
                    chartType: ChartType.ring,
                    ringStrokeWidth: 32,
                    centerText: "Portfolio",
                    legendOptions: LegendOptions(
                      showLegendsInRow: false,
                      legendPosition: LegendPosition.right,
                      showLegends: true,
                      legendShape: BoxShape.circle,
                      legendTextStyle: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    chartValuesOptions: ChartValuesOptions(
                      showChartValueBackground: true,
                      showChartValues: true,
                      showChartValuesInPercentage: true,
                      showChartValuesOutside: false,
                      decimalPlaces: 1,
                    ),
                    // gradientList: ---To add gradient colors---
                    // emptyColorGradient: ---Empty Color gradient---
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    "Stocks",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  ListView.builder(
                    itemCount: list.length,
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      var stock = list[index];
                      stock['name'] = capitalizeFirstLetter(stock['name']);
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            CupertinoPageRoute(
                              builder:
                                  (context) => Stockdetailspage(stock['name']),
                            ),
                          );
                        },
                        child: Card(
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          margin: EdgeInsets.symmetric(vertical: 8),
                          elevation: 1,
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.purple.shade50,
                              foregroundColor: Colors.grey.shade500,
                              child: Text(stock['name'][0] + stock['name'][1]),
                            ),
                            title: Text(
                              capitalizeFirstLetter(stock["name"].toString()),
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              'Tap to view details',
                              style: TextStyle(color: Colors.grey),
                            ),
                            trailing:Column(
                              children: [
                                Text(
                                  stock['number'].toString(),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black, // Dark color
                                    fontSize: 20,
                                  ),
                                ),
                                Text(
                                  " shares",
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 14,
                                  ),
                                ),
                              ],

                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  SizedBox(
                    height: 100,
                  )

                  // dataFetched?SfCartesianChart(
                  //     primaryXAxis: CategoryAxis(),
                  //     // Chart title
                  //     title: ChartTitle(text: 'Half yearly sales analysis'),
                  //     // Enable legend
                  //     legend: Legend(isVisible: true),
                  //     // Enable tooltip
                  //     tooltipBehavior: TooltipBehavior(enable: true),
                  //     series: <CartesianSeries<dynamic, dynamic>>[
                  //       LineSeries<dynamic, dynamic>(
                  //           dataSource: list,
                  //           xValueMapper: (sales, d) {
                  //             print(sales['stockData']values[0].date);
                  //             print(d);
                  //             return sales[d]['stockData'].date;
                  //             },
                  //           yValueMapper: (sales, d) => sales[d]['stockData'].close,
                  //           name: 'Sales',
                  //           // Enable data label
                  //           dataLabelSettings: DataLabelSettings(isVisible: true))
                  //     ]):Container(),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: MediaQuery.of(context).size.width,
              padding: EdgeInsets.all(20),
              child: TextButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    CupertinoPageRoute(
                      builder:
                          (context) =>
                              Chatpage(user['file'], user: user['name']),
                      fullscreenDialog: true,
                    ),
                  );
                },
                label: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "Chat with FinAI",
                    style: TextStyle(fontSize: 18),
                  ),
                ),
                icon: Icon(CupertinoIcons.text_bubble),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.purple.shade200,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void showDateFilterDialog(
    BuildContext context, {
    required String title,
    required Function(DateTime?, DateTime?) onSubmit,
  }) {
    DateTime? fromDate = DateTime.now().subtract(Duration(days: 1));
    DateTime? toDate = DateTime.now().subtract(Duration(days: 1));

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
          content: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    title: Text(
                      fromDate == null
                          ? "Select From Date"
                          : "From: ${DateFormat('yyyy-MM-dd').format(fromDate!)}",
                    ),
                    trailing: Icon(Icons.calendar_today),
                    onTap: () async {
                      DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        setState(() => fromDate = picked);
                      }
                    },
                  ),
                  ListTile(
                    title: Text(
                      toDate == null
                          ? "Select To Date"
                          : "To:    ${DateFormat('yyyy-MM-dd').format(toDate!)}",
                    ),
                    trailing: Icon(Icons.calendar_today),
                    onTap: () async {
                      DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        setState(() => toDate = picked);
                      }
                    },
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                onSubmit(fromDate, toDate);
              },
              child: Text("Submit"),
            ),
          ],
        );
      },
    );
  }

  var stockData;
  var stockDataCompany;

  Future<dynamic> callOHLCV(
    stock,
    DateTime? from,
    DateTime? to,
    bool returnResult,
  ) async {
    String url_string = base_url + 'ohlcv?q=' + stock;

    if (from != null) {
      url_string =
          url_string + "&first=" + DateFormat("dd.MM.yyyy").format(from);
    }
    if (to != null) {
      url_string = url_string + "&last=" + DateFormat("dd.MM.yyyy").format(to);
    }

    var url = Uri.parse(url_string);

    // Await the http get response, then decode the json-formatted response.
    if (!returnResult) {
      LoadingDialog.show(context);
    }
    var response = await http.get(url);
    if (!returnResult) {
      LoadingDialog.dismiss(context);
    }
    if (response.statusCode == 200) {
      var jsonResponse =
          convert.jsonDecode(response.body) as Map<String, dynamic>;
      if (!returnResult) {
        stockDataCompany = stock;
        stockData = getOHLCV(jsonResponse);
        setState(() {});
      } else {
        return getOHLCV(jsonResponse);
      }
    } else {
      print('Request failed with status: ${response.statusCode}.');
    }
  }

  getOHLCV(jsonResponse) {
    Map<String, dynamic> a =
        convert.jsonDecode(jsonResponse['object']) as Map<String, dynamic>;
    Map<String, dynamic> b =
        convert.jsonDecode(a['data']) as Map<String, dynamic>;
    Map<String, dynamic> c =
        convert.jsonDecode(b.values.firstOrNull) as Map<String, dynamic>;
    List result = [];
    int i = 0;
    for (var item in c.values) {
      var result_map = item;
      result_map['date'] = DateFormat(
        "dd-MM-yyyy",
      ).format(DateTime.parse(c.keys.elementAt(i++).toString()));
      result.add(result_map);
    }
    return result;
  }

  bool dataFetched = false;

  void fetchOHLCV() async {
    List list = widget.user['stocks'];
    for (var stock in list) {
      stock['stockData'] = await callOHLCV(
        stock['name'],
        DateTime.now().subtract(Duration(days: 20)),
        DateTime.now(),
        true,
      );
    }
    dataFetched = true;
    setState(() {});
  }

  TextTile(String s, value, {borderColor}) {
    double margin = 0;
    if (borderColor != null) {
      margin = 3;
    }
    borderColor ??= Colors.purple.shade50;
    return Card(
      color: borderColor,
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              s,
              style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
            ),
            Text(
              value,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  colorAsPerRisk(value) {
    switch (value) {
      case "High":
        return Colors.red.shade200;
      case "Moderate":
        return Colors.orange.shade200;
      case "Low":
        return Colors.green.shade200;
    }
  }
}

class StockTable extends StatelessWidget {
  final List<dynamic> stockData;
  final String company;

  StockTable({required this.stockData, required this.company});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          "$company's Stock Overview",
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columns: const [
              DataColumn(label: Text('Date')),
              DataColumn(label: Text('Open')),
              DataColumn(label: Text('Close')),
              DataColumn(label: Text('High')),
              DataColumn(label: Text('Low')),
            ],
            rows:
                stockData.map((data) {
                  return DataRow(
                    cells: [
                      DataCell(Text(data['date'].toString())),
                      DataCell(Text(data['open'].toString())),
                      DataCell(Text(data['close'].toString())),
                      DataCell(Text(data['high'].toString())),
                      DataCell(Text(data['low'].toString())),
                    ],
                  );
                }).toList(),
          ),
        ),
      ],
    );
  }
}

// highest return 5%
// where it goes doesn't matter
// risk mitigation
//     loyal company
//     carbon emission
//     less pollution
//
//
//     total ->
// zara
// three funds in europe
// demanding/
// latest news
//     his knowledge
//     complement his skills

//c7b8eddde1347a0bfaa8edf15269db2c7a9646c7
