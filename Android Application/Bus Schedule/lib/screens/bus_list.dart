import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:busoptimizer/helpers/shared_prefs.dart';

class BusListView extends StatefulWidget {
  static const String id = "BusListViewScreen";
  const BusListView({Key? key}) : super(key: key);

  @override
  State<BusListView> createState() => _BusListViewState();
}

class _BusListViewState extends State<BusListView> {
  late String source;
  late String destination;
  bool isValidInput = true;
  int sourceInd = 0;
  int destinationInd = 0;
  Map data = {};
  Map indexingOfData = {};
  Future<String> getData() async {
    String url =
        "http://ec2-44-201-223-168.compute-1.amazonaws.com:4000/getBusesBySrcDest?src=" +
            source.replaceAll("\"", "").toLowerCase() +
            "&dest=" +
            destination.replaceAll("\"", "").toLowerCase();
    final response = await http.get(Uri.parse(url));

    this.setState(() {
      print(url);
      try {
        data = jsonDecode(response.body);
      } catch (error) {
        String apiData = response.body;
        if (apiData == "Invalid") {
          isValidInput = false;
        }
        print(apiData);
      }
      print(data);

      int ind = 0;
      for (var i in data.keys) {
        indexingOfData[ind] = i;
        ind++;
      }
      for (var i in data.keys) {
        for (int j = 0; j < data[i].length; j++) {
          // print(data[i][j]);
          if (data[i][j] is String) {
            continue;
          }
          print(data[i][j][0]);
          if (data[i][j][0].toLowerCase() == source) {
            // print("worked");
            sourceInd = j;
            break;
          }
        }

        for (int j = 0; j < data[i].length; j++) {
          if (data[i][j] is String) {
            continue;
          }
          if (data[i][j][0].toLowerCase() == destination) {
            destinationInd = j;
            break;
          }
        }
      }
    });
    return "Success!";
  }

  @override
  void initState() {
    super.initState();
    source = getSourceAndDestination('source');
    destination = getSourceAndDestination('destination');
    source = "hingoli";
    destination = "sangli";

    /// this need to removed
    this.getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Mapbox Cabs'),
          actions: const [
            CircleAvatar(
                backgroundImage: AssetImage('assets/image/person.jpg')),
          ],
        ),
        body: isValidInput
            ? ListView.builder(
                itemCount: data == null ? 0 : data.length,
                itemBuilder: (BuildContext cxt, int index) {
                  return Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                          color: Colors.blue[700],
                          borderRadius: BorderRadius.circular(12)),
                      width: double.infinity,
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'SOURCE',
                                    style: TextStyle(
                                        fontSize: 12, color: Colors.white),
                                  ),
                                  Text(
                                    source.replaceAll("\"", "").toUpperCase(),
                                    style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              const Text(
                                '→',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 24),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  const Text(
                                    'DESTINATION',
                                    style: TextStyle(
                                        fontSize: 12, color: Colors.white),
                                  ),
                                  Text(
                                    destination
                                        .replaceAll("\"", "")
                                        .toUpperCase(),
                                    style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 8,
                          ),
                          Row(
                            children: [
                              const Icon(
                                Icons.directions,
                                color: Colors.white,
                              ),
                              const SizedBox(
                                width: 5,
                              ),
                              Expanded(
                                child: Text(
                                  " 258KM ,via " +
                                      data[indexingOfData[index]]
                                              [destinationInd - 1]
                                          [0], // hear need to add kilometer
                                  maxLines: 2,

                                  style: const TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          Row(
                            children: [
                              const Icon(
                                Icons.directions_bus,
                                color: Colors.white,
                              ),
                              const SizedBox(
                                width: 5,
                              ),
                              Text(
                                "JBCL, 50 seater, AC",
                                style: const TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          Row(
                            children: [
                              const Icon(
                                Icons.access_time_rounded,
                                color: Colors.white,
                              ),
                              const SizedBox(
                                width: 5,
                              ),
                              Text(
                                // data['start_time'].toString(),
                                data[indexingOfData[index]][0],
                                style: const TextStyle(color: Colors.white),
                              ),
                              const SizedBox(
                                width: 16,
                              ),
                              const Icon(
                                Icons.timelapse_rounded,
                                color: Colors.white,
                              ),
                              const SizedBox(
                                width: 5,
                              ),
                              Text(
                                // data['duration'].toString(),
                                "duration",
                                style: const TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                })
            : Center(
                child: Text("Oops sorry we dont have route for this cities"),
              ));
  }
}
