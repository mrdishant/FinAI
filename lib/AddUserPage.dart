import 'package:flutter/material.dart';

class AddNewUser extends StatefulWidget {
  const AddNewUser({super.key});

  @override
  State<AddNewUser> createState() => _AddNewUserState();
}

class _AddNewUserState extends State<AddNewUser> {
  TextEditingController nameController = TextEditingController();
  TextEditingController investmentPurposeController = TextEditingController();
  TextEditingController riskAppetiteController = TextEditingController();
  TextEditingController annualIncomeController = TextEditingController();
  TextEditingController investmentDurationController = TextEditingController();
  TextEditingController preferredCompanyTypeController = TextEditingController();
  TextEditingController preferredInvestmentRegionsController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        backgroundColor: Colors.white,
        centerTitle: true,
        leading: CloseButton(),
        title: Text("Welcome new Customer!"),
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "Let's get started",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                    labelText: "Name",
                    hintText: "User's name",
                    border: OutlineInputBorder()),
              ),
              SizedBox(height: 10),
              TextField(
                controller: investmentPurposeController,
                decoration: InputDecoration(
                    labelText: "Investment Purpose",
                    hintText: "Wealth Growth, Retirement, etc.",
                    border: OutlineInputBorder()),
              ),
              SizedBox(height: 10),
              TextField(
                controller: riskAppetiteController,
                decoration: InputDecoration(
                    labelText: "Risk Appetite",
                    hintText: "Low, Moderate, High",
                    border: OutlineInputBorder()),
              ),
              SizedBox(height: 10),
              TextField(
                controller: annualIncomeController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                    labelText: "Annual Income",
                    hintText: "Enter annual income",
                    border: OutlineInputBorder()),
              ),
              SizedBox(height: 10),
              TextField(
                controller: investmentDurationController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                    labelText: "Investment Duration (Years)",
                    hintText: "Enter duration in years",
                    border: OutlineInputBorder()),
              ),
              SizedBox(height: 10),
              TextField(
                controller: preferredCompanyTypeController,
                decoration: InputDecoration(
                    labelText: "Preferred Company Type",
                    hintText: "Small Cap, Large Cap, etc.",
                    border: OutlineInputBorder()),
              ),
              SizedBox(height: 10),
              TextField(
                controller: preferredInvestmentRegionsController,
                decoration: InputDecoration(
                    labelText: "Preferred Investment Regions",
                    hintText: "Asia, Australia, Europe, etc.",
                    border: OutlineInputBorder()),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  child: TextButton(onPressed: (){}, child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text("Proceed", style: TextStyle(
                      fontSize: 20
                    ),),
                  ),style: TextButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,

                  )),
                ),

              )
            ],
          ),
        ),
      ),
    );
  }
}
