import 'dart:convert' as convert;

import 'package:financial_ai/AddUserPage.dart';
import 'package:financial_ai/ChatPage.dart';
import 'package:financial_ai/UserPage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import 'StockDetailsPage.dart';
import 'Util.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  List users = [];
  bool _showSearchBar = false;
  TextEditingController _searchController = TextEditingController();
  NumberFormat numberFormat = NumberFormat.currency(symbol: "\$");

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 100,
        backgroundColor: Colors.white,
        title: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Hello,", style: TextStyle(fontSize: 30)),
              Text(
                "Mark Grayson!",
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                _showSearchBar = !_showSearchBar;
              });
            },
            icon: Icon(CupertinoIcons.search),
          ),
        ],
      ),
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (context) => Chatpage("mark.json"),
              fullscreenDialog: true,
            ),
          );
        },
        child: Icon(CupertinoIcons.text_bubble),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.person_add),
            label: "New Customer",
          ),
        ],
        onTap: (index) {
          if (index == 1) {
            Navigator.push(
              context,
              CupertinoPageRoute(builder: (context) => AddNewUser()),
            );
          }
        },
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_showSearchBar)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: TextField(
                    onSubmitted: (value) {
                      searchByCompanyName();
                    },
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: "Search by Company Name...",
                      border: OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(Icons.send),
                        onPressed: () {
                          searchByCompanyName();
                          // Handle search submission
                        },
                      ),
                    ),
                  ),
                ),

              Text("Here are your clients...", style: TextStyle(fontSize: 20)),

              ListView.builder(
                itemCount: users.length,
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  var user = users[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        CupertinoPageRoute(
                          builder: (context) => Userpage(user),
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
                          child: Text(fetchUserCredentials(user['name'])),
                        ),
                        title: Text(
                          user["name"],
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          getTotalStocksText(user['stocks']),
                          style: TextStyle(color: Colors.grey),
                        ),
                        trailing: Text(
                          // "\$${user["value"].toStringAsFixed(2)}",
                          numberFormat.format(user['value']),
                          style: TextStyle(
                            color:
                                user["value"] < 0 ? Colors.red : Colors.green,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void fetchUsers() async {
    var url = Uri.parse(base_url + 'users');

    // Await the http get response, then decode the json-formatted response.
    var response = await http.get(url);
    if (response.statusCode == 200) {
      var jsonResponse =
          convert.jsonDecode(response.body) as Map<String, dynamic>;
      users = jsonResponse['users'];
      print(users);
      setState(() {});
    } else {
      print('Request failed with status: ${response.statusCode}.');
    }
  }

  String fetchUserCredentials(String user) {
    var names = user.split(" ");
    if (names.length > 1) {
      return "${names[0][0]}${names[1][0]}";
    }
    return "${names[0][0]}${names[0][1]}";
  }

  String getTotalStocksText(List user) {
    return "has ${user.length} total stocks";
  }

  void searchByCompanyName() {
    if (_searchController.text.isEmpty) {
      return;
    }
    var query = _searchController.text;
    Navigator.push(
      context,
      CupertinoPageRoute(builder: (context) => Stockdetailspage(query)),
    );
    _searchController.clear();
    setState(() {
      _showSearchBar = false;
    });
  }
}
