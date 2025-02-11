import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:phr/const.dart';
import 'package:phr/controllers/app_controller.dart';
import 'package:phr/models/chartdata.dart';
import 'package:phr/models/glucose.dart';
import 'package:phr/pages/glucose/add_glucose.dart';
import 'package:phr/themes/theme.dart';
import 'package:phr/widgets/spline_chart.dart';
import 'package:phr/widgets/statsbox_widget.dart';

import 'glucose_history.dart';

class GlucosePage extends StatefulWidget {
  const GlucosePage({Key? key}) : super(key: key);

  @override
  _GlucosePageState createState() => _GlucosePageState();
}

class _GlucosePageState extends State<GlucosePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Blood Glucose"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // navigate tp add bmi page
              Get.to(() => const AddGlucosePage());
            },
          )
        ],
      ),
      body: LayoutBuilder(builder: (context, constraints) {
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: GetBuilder<AppController>(
              init: AppController(),
              builder: (controller) {
                return FutureBuilder(
                  future: controller.loadGlucose(),
                  builder: (BuildContext context,
                      AsyncSnapshot<Box<Glucose>> snapshot) {
                    if (snapshot.hasError) {
                      return const Center(
                        child: Text("Error"),
                      );
                    }

                    if (snapshot.hasData) {
                      var box = snapshot.data!;
                      if (box.values.isNotEmpty) {
                        // chart data
                        final List<ChartData> chartDataGlocose = [];

                        // convert iterable to list and sort
                        final boxList = box.values.toList();
                        boxList
                            .sort((a, b) => a.dateTime.compareTo(b.dateTime));

                        for (var item in boxList) {
                          // add chart data
                          chartDataGlocose.add(ChartData(
                              name: 'Glucose',
                              dateTime: item.dateTime,
                              value: item.unit.toDouble()));
                        }

                        final List<List<ChartData>> chartData = [
                          chartDataGlocose
                        ];

                        // boxList.forEach((i) {
                        //   log(i.level.toString());
                        // });

                        // return bmi info
                        return Column(
                          children: [
                            // statistics
                            Row(
                              children: [
                                StatsBoxWidget(
                                  width: ((constraints.maxWidth - 8) / 2),
                                  height: (constraints.maxWidth / 3) * 0.8,
                                  title: 'Glucose'.toUpperCase(),
                                  value: boxList.last.unit.toStringAsFixed(0),
                                  valueColor: listChartColor[0],
                                  subTitle: 'mg/dL',
                                ),
                                StatsBoxWidget(
                                  width: ((constraints.maxWidth - 8) / 2),
                                  height: (constraints.maxWidth / 3) * 0.8,
                                  title: 'A1C'.toUpperCase(),
                                  value: controller
                                      .glucoseToA1C(unit: boxList.last.unit)
                                      .toStringAsFixed(1),
                                  valueColor: listChartColor[1],
                                  subTitle: '%',
                                ),
                              ],
                            ),

                            // result
                            SizedBox(
                              child: Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "Result (" +
                                            glucoseWhenLabel[
                                                boxList.last.when] +
                                            ")",
                                        style: textTitleStyle,
                                      ),
                                      Text(
                                        glucoseTypeLabel[boxList.last.level],
                                        style: TextStyle(
                                          color: listGlucoseColor[
                                              boxList.last.level],
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            // graph
                            Card(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  const Padding(
                                    padding: EdgeInsets.all(16.0),
                                    child: Text(
                                      "Statistic",
                                      style: textTitleStyle,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: SizedBox(
                                      height: constraints.maxWidth,
                                      child: SplineChartWidget(
                                        chartData: chartData,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // history button
                            const SizedBox(height: 4.0),
                            SizedBox(
                              width: constraints.maxWidth - 16,
                              child: ElevatedButton(
                                style: buttonStyleRed,
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 16.0),
                                  child: Text("History"),
                                ),
                                onPressed: () {
                                  Get.to(() => const GlucoseHistoryPage());
                                },
                              ),
                            ),
                          ],
                        );
                      } else {
                        // return add data text
                        return SizedBox(
                          width: constraints.maxWidth,
                          child: const Card(
                            child: Center(
                              child: Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Text("No data, please add your data"),
                              ),
                            ),
                          ),
                        );
                      }
                    }

                    return Container();
                  },
                );
              },
            ),
          ),
        );
      }),
    );
  }
}
