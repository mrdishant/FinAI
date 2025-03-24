import 'dart:convert' as convert;

import 'package:financial_ai/UserPage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import 'LineSample.dart';
import 'LoadingDialog.dart';
import 'Util.dart';

class Stockdetailspage extends StatefulWidget {
  String stock;

  Stockdetailspage(this.stock);

  @override
  State<Stockdetailspage> createState() => _StockdetailspageState();
}

class _StockdetailspageState extends State<Stockdetailspage> {
  NumberFormat numberFormat = NumberFormat.currency(symbol: "\$");
  String stockName = "";

  var stockDetails;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    stockName = widget.stock.toLowerCase();
    // fetchStockDetails();


    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchSummary();
    });

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        leading: CloseButton(),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              capitalizeFirstLetter(stockName),
              style: TextStyle(
                color: Colors.black,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              (stockDetails?['ticker_symbol']??"").toString().trim(),
              style: TextStyle(color: Colors.black, fontSize: 14),
            ),
          ],
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      backgroundColor: Colors.white,
      body: stockDetails!=null?Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      capitalizeFirstLetter(stockName),
                      textAlign: TextAlign.start,
                      style: TextStyle(color: Colors.black, fontSize: 22),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      numberFormat.format(stockDetails['close']),
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(

                        children: [
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.grey),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text("Overview", style: TextStyle()),
                            ),
                          ),

                          Row(
                            children: [
                              Expanded(
                                child: ListTile(
                                  title: Text("Open Price"),
                                  subtitle: Text(
                                    numberFormat.format(stockDetails['open']),
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: ListTile(
                                  title: Text("Close Price"),
                                  subtitle: Text(
                                    numberFormat.format(stockDetails['close']),
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          Row(
                            children: [
                              Expanded(
                                child: ListTile(
                                  title: Text("Today' low"),
                                  subtitle: Text(
                                    numberFormat.format(stockDetails['low']),
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: ListTile(
                                  title: Text("Today' high"),
                                  subtitle: Text(
                                    numberFormat.format(stockDetails['high']),
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),


                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  stockData != null
                      ? Padding(
                    padding: const EdgeInsets.all(8.0),
                    child:
                    LineChartSample12(stockData),
                    // StockTable(
                    //   stockData: (stockData ?? []),
                    //   company: stockDataCompany,
                    // ),
                  )
                      : Center(child: CircularProgressIndicator()),


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
                  showDateFilterDialog(
                    context,
                    title: stockName,
                    onSubmit: (from, to) {
                      callOHLCV(stockName, from, to, false);
                    },
                  );
                },
                label: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "Get Historical Data",
                    style: TextStyle(fontSize: 18),
                  ),
                ),
                icon: Icon(CupertinoIcons.search),
                style: TextButton.styleFrom(
                    foregroundColor: Colors.purple,
                    backgroundColor: Colors.white,
                    side: BorderSide(color: Colors.purpleAccent.shade100),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                    )
                ),
              ),
            ),
          ),
        ],
      ):Center(child: CircularProgressIndicator()),
    );
  }

  void showDateFilterDialog(
      BuildContext context, {
        required String title,
        required Function(DateTime?, DateTime?) onSubmit,
      }) {
    DateTime? fromDate ;
    DateTime? toDate;

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
                        lastDate: DateTime.now(),
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
                        lastDate: DateTime.now(),
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
    stockData=null;
    setState(() {

    });
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

    var response = await http.get(url);

    if (response.statusCode == 200) {
      var jsonResponse =
          convert.jsonDecode(response.body) as Map<String, dynamic>;
      if (!returnResult) {
        stockDataCompany = stock;
        stockData = getOHLCV(jsonResponse);
        // stockData = stockData.reversed.toList();
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
      result_map['date_actual'] = DateTime.parse(c.keys.elementAt(i++).toString());
      result_map['date'] = DateFormat(
        "dd-MM-yyyy",
      ).format(result_map['date_actual']);

      result.add(result_map);
    }
    return result;
  }

  void fetchSummary() async {
    var url = Uri.parse(base_url + 'summary?stock='+stockName);

    // Await the http get response, then decode the json-formatted response.
    var response = await http.get(url);
    if (response.statusCode == 200) {
      var jsonResponse =
      convert.jsonDecode(response.body) as Map<String, dynamic>;
      stockDetails = jsonResponse['stockDetails'];
      print(stockDetails);
      DateTime? fromDate = DateTime.now().subtract(Duration(days: 30));
      DateTime? toDate = DateTime.now().subtract(Duration(days: 1));
      callOHLCV(stockName, fromDate, toDate, false);
    } else {
      print('Request failed with status: ${response.statusCode}.');
    }
  }
}

class StockTable extends StatelessWidget {
  final List<dynamic> stockData;
  final String company;

  StockTable({required this.stockData, required this.company});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Column(
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
                columnSpacing: 16,
                columns: const [
                  DataColumn(label: Text('Date', style: TextStyle(
                    fontWeight: FontWeight.bold
                  ),)),
                  DataColumn(label: Text('Open' ,style: TextStyle(
                      fontWeight: FontWeight.bold
                  ),)),
                  DataColumn(label: Text('Close',style: TextStyle(
                      fontWeight: FontWeight.bold
                  ),)),
                  DataColumn(label: Text('High',style: TextStyle(
                      fontWeight: FontWeight.bold
                  ),)),
                  DataColumn(label: Text('Low',style: TextStyle(
                      fontWeight: FontWeight.bold
                  ),))
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
        ),
      ),
    );
  }
}
