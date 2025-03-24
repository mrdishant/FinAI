from flask import Flask, jsonify, request
import requests
import os
import re
import json
app = Flask(__name__)

users = []

@app.route("/summary", methods=["GET"])
def get_summary():
    stock = request.args.get('stock')
    print(stock)
    sum = 'https://idchat-api-containerapp01-dev.orangepebble-16234c4b.switzerlandnorth.azurecontainerapps.io/summary?query'
    sparams = {
        "query": stock
    }
    response = requests.post(sum, params=sparams)
    res = response.json()
    data = json.loads(res["object"])
    jdata = json.loads(data["data"][0])
    val = list(jdata.values())[0]
    stockDetails= {}
    stockDetails['open'] = float(val["open"])
    stockDetails['close'] = float(val["close"])
    stockDetails['high'] =  float(val["high"])
    stockDetails['low']= float(val["low"])
    stockDetails['ticker_symbol'] = val["Ticker symbol"]
    stockDetails['vol']= val["vol"]
    return {"stockDetails":stockDetails}

@app.route("/recommendation", methods=["GET"])
def get_recommendation():
    user = request.args.get('user')
    print(user)
    query=""
    if user is not None:
        user = getUserByName(user)
        print(user)
        query = 'I have invested in the following stocks in portfolio: '+str(user['stocks'])+' Based on these stocks, can you show me top 5 stocks based companies in similar sectors or industries. Answer in a json format with only first names of the companies:-  {“company1”: “Name of company”,}'
    
    print(query)
    url = ("https://idchat-api-containerapp01-dev.orangepebble-16234c4b."
           f"switzerlandnorth.azurecontainerapps.io//query?query={query}")

    response = requests.post(url)
    out = response.json()["messages"][-1]["content"]
    match = re.search(r"```json\n(.*?)\n```", out, re.DOTALL)

    if match:
        json_str = match.group(1)  # Extract JSON part
        company_data = json.loads(json_str)  # Convert to dictionary
        company_list = list(company_data.values())  # Get company names as a list
        print(company_list)
        ohlc_url = "https://idchat-api-containerapp01-dev.orangepebble-16234c4b.switzerlandnorth.azurecontainerapps.io/query?query"
        fin_list = []
        # item = item.split(' ')
        params = {
            "query": "Get me the 52 weeks high, low and price of followinfg"+str(company_list)+" stocks. Answer in a json format with only first names of the companies:-  { 'name of the company': {'52high':'52 week high value of that company','52low':'52 week low value of that company','price':'latest price that company',}"}

        headers = {
            "accept": "application/json"
        }
        response = requests.post(ohlc_url, headers=headers, params=params,data={})  # Empty data payload
        if 'error' not in response:
            fin_list.append(response.json())
            res = response.json()
            # print(res["messages"][-1]["content"])
        print(fin_list)
        # for item in company_list:
        #     item = item.split(' ')
        #     params = {
        #         "query": "Get me the 52 weeks high, low and latest price of "+item[0]+" stock. Answer in a json format with only first names of the companies:-  { 'name of the company': {'52high':'52 week high value of that company','52low':'52 week low value of that company','price':'latest price that company',}}"}

        #     headers = {
        #         "accept": "application/json"
        #     }
        #     response = requests.post(url, headers=headers, params=params,data={})  # Empty data payload
        #     if 'error' not in response:
        #         fin_list.append(item[0])
        #         res = response.json()
        #         print(res["messages"][-1]["content"])
        # print(fin_list)
    else:
        print("No valid JSON found in input.")
        

@app.route("/ohlcv", methods=["GET"])
def get_ohlcv():
    q = request.args.get('q')
    first = request.args.get('first')
    last = request.args.get('last')
    url = ("https://idchat-api-containerapp01-dev.orangepebble-16234c4b."
           "switzerlandnorth.azurecontainerapps.io//ohlcv"
           f"?query={q}&first={first}")
    if last:
        url = f"{url}&last={last}"
    response = requests.post(url)
    return response.json()
    

@app.route("/messages", methods=["GET"])
def get_messages():
    file_path = request.args.get('q')
    if os.path.exists(file_path):
        with open(file_path, "r", encoding="utf-8") as file:
            data = json.load(file)
            return data

    return {"messages":[]}
    


@app.route("/users", methods=["GET"])
def get_users():
    response = users
    return {"users":response}


@app.route("/query", methods=["GET"])
def get_response():
    q  = request.args.get('q')
    file_path = request.args.get('f')
    user = request.args.get('user')
    print(user)
    query=""
    if user is not None:
        user = getUserByName(user)
        print(user)
        # query = f"My Customer {user['name']} has following stocks in portfolio: {user['stocks']} "
        query = f"My Customer has following details {user}"
    
    print(file_path)
    data = {
         "messages":[]
    }
    if os.path.exists(file_path):
        with open(file_path, "r", encoding="utf-8") as file:
                data = json.load(file)

    data['messages'].append({
                    "text":q,
                    "sender":"user"
    })

    # for message in data['messages']:
    #     if message['sender']=="ai":
    #         query += "\nAnswer:"
    #     else:
    #         query += "\nQuestion:"

    #     query += message['text']
    query += "\nNow tell me: "+q
    print(query)
    
    url = ("https://idchat-api-containerapp01-dev.orangepebble-16234c4b."
           f"switzerlandnorth.azurecontainerapps.io//query?query={query}")

    response = requests.post(url)
    print(response.json())
    r = response.json()
    data['messages'].append({
                    "text":response.json()['messages'][-1]['content'],
                    "sender":"ai"
    })
    # if len(r['messages'])>=4:
    #     data['messages'].append({
    #                 "text":response.json()['messages'][3]['content'],
    #                 "sender":"ai"
    #     })
    # else:
    #     data['messages'].append({
    #             "text":response.json()['messages'][1]['content'],
    #             "sender":"ai"
    # })   
    with open(file_path, "w", encoding="utf-8") as file:
        file.write(json.dumps(data))
    return data

def getUserByName(user_name):
    for user in users:
        if user['name'] == user_name:
            return user

if __name__ == "__main__":
    with open("users.json", "r", encoding="utf-8") as file:
        users = json.load(file)
    app.run(debug=True)
