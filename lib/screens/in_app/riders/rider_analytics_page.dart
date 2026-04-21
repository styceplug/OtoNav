import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:fl_chart/fl_chart.dart'; // THE CHART PACKAGE
import 'package:intl/intl.dart';
import 'package:otonav/controllers/user_controller.dart';
import 'package:otonav/model/user_model.dart';
import 'package:otonav/utils/colors.dart';
import 'package:otonav/utils/dimensions.dart';

class RiderAnalyticsPage extends StatelessWidget {
  const RiderAnalyticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: const Text("Analytics", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: GetBuilder<UserController>(
          builder: (userController) {
            final user = userController.userModel.value;
            final analytics = user?.jobAnalytics;

            if (user == null || analytics == null) {
              return const Center(child: Text("Analytics data not available"));
            }

            final summary = analytics.summary;

            return SingleChildScrollView(
              padding: EdgeInsets.all(Dimensions.width20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // 1. PERFORMANCE SCORE GAUGE
                  Center(
                    child: Column(
                      children: [
                        SizedBox(
                          height: 140,
                          width: 140,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              CircularProgressIndicator(
                                value: analytics.performanceScore / 100, // Assuming 0-100
                                strokeWidth: 12,
                                backgroundColor: Colors.grey[200],
                                color: AppColors.primaryColor,
                                strokeCap: StrokeCap.round,
                              ),
                              Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "${analytics.performanceScore}",
                                      style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.primaryColor),
                                    ),
                                    const Text("Score", style: TextStyle(color: Colors.grey, fontSize: 12)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 15),
                        Text("Overall Performance", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey[800])),
                      ],
                    ),
                  ),
                  SizedBox(height: Dimensions.height30),

                  // 2. DETAILED METRICS GRID
                  const Text("All-Time Metrics", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: Dimensions.height15),
                  GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                    childAspectRatio: 2.2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _metricTile("Total Orders", "${summary['totalOrders'] ?? 0}", Iconsax.box, Colors.blue),
                      _metricTile("Cancelled", "${summary['cancelledOrders'] ?? 0}", Iconsax.close_circle, Colors.red),
                      _metricTile("Avg Delivery", "${summary['averageDeliveryTime'] ?? 0}m", Iconsax.clock, Colors.orange),
                      _metricTile("Total Distance", "${summary['totalDeliveryDistance'] ?? 0}km", Iconsax.routing, Colors.indigo),
                    ],
                  ),
                  SizedBox(height: Dimensions.height30),

                  // 3. DAILY BREAKDOWN CHART (Bar Chart)
                  if (analytics.dailyBreakdown.isNotEmpty) ...[
                    const Text("This Week's Activity", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(height: Dimensions.height20),
                    SizedBox(
                      height: 200,
                      child: _buildBarChart(analytics.dailyBreakdown),
                    ),
                    SizedBox(height: Dimensions.height30),
                  ],

                  // 4. RECENT ORDERS LIST
                  const Text("Recent Orders", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: Dimensions.height15),
                  if (analytics.recentOrders.isEmpty)
                    const Text("No recent orders found.", style: TextStyle(color: Colors.grey)),
                  ...analytics.recentOrders.map((order) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, border: Border.all(color: Colors.grey[200]!)),
                            child: const Icon(Iconsax.box, color: Colors.blueAccent),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(order.orderNumber ?? "Unknown", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                Text(order.packageDescription ?? "Package", style: const TextStyle(color: Colors.grey, fontSize: 13)),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                order.status?.replaceAll('_', ' ').capitalizeFirst ?? "Pending",
                                style: TextStyle(
                                  color: order.status == 'completed' ? Colors.green : Colors.orange,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                              if (order.createdAt != null)
                                Text(DateFormat('MMM d, h:mm a').format(order.createdAt!), style: const TextStyle(color: Colors.grey, fontSize: 11)),
                            ],
                          )
                        ],
                      ),
                    );
                  }),
                  SizedBox(height: Dimensions.height50), // Padding for scroll
                ],
              ),
            );
          }
      ),
    );
  }

  // Helper for metrics grid
  Widget _metricTile(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: color)),
                Text(title, style: TextStyle(fontSize: 11, color: Colors.grey[700]), overflow: TextOverflow.ellipsis),
              ],
            ),
          )
        ],
      ),
    );
  }

  // Helper to build the Bar Chart using fl_chart
  Widget _buildBarChart(List<DailyBreakdown> breakdown) {
    // Limit to last 7 days to avoid squished charts
    final data = breakdown.length > 7 ? breakdown.sublist(breakdown.length - 7) : breakdown;

    // 1. Calculate the dynamic Max Y once so we can share it
    final double dynamicMaxY = data.isEmpty ? 10 : data.map((e) => e.orders.toDouble()).reduce((a, b) => a > b ? a : b) + 2;

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: dynamicMaxY, // <-- Uses the shared variable
        barTouchData: BarTouchData(enabled: false),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= data.length) return const SizedBox();
                final date = data[value.toInt()].date;
                if (date == null) return const SizedBox();
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(DateFormat('E').format(date), style: const TextStyle(color: Colors.grey, fontSize: 12)),
                );
              },
            ),
          ),
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        barGroups: data.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: item.orders.toDouble(),
                color: AppColors.primaryColor,
                width: 16,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                backDrawRodData: BackgroundBarChartRodData(
                  show: true,
                  toY: dynamicMaxY, // <-- FIX: Background now respects the chart boundary!
                  color: Colors.grey[100],
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}