import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fl_chart/fl_chart.dart';

class FinalDashboardScreen extends StatefulWidget {
  final String listId;
  final String listName;
  final String email;

  const FinalDashboardScreen({
    super.key,
    required this.listId,
    required this.listName,
    required this.email,
  });

  @override
  State<FinalDashboardScreen> createState() => _FinalDashboardScreenState();
}

class _FinalDashboardScreenState extends State<FinalDashboardScreen> {
  bool isLoading = false;
  bool showCalls = false;
  int pending = 0;
  int called = 0;
  int rescheduled = 0;
  List<dynamic> calls = [];

  @override
  void initState() {
    super.initState();
    fetchDashboardData();
  }

  Future<void> fetchDashboardData() async {
    setState(() => isLoading = true);
    try {
      final uri = Uri.parse(
        "https://mock-api.calleyacd.com/api/list/${widget.listId}",
      );

      final request = http.Request("GET", uri)
        ..headers['Content-Type'] = 'application/json'
        ..body = jsonEncode({"email": widget.email});

      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          pending = data['pending'] ?? 0;
          called = data['called'] ?? 0;
          rescheduled = data['rescheduled'] ?? 0;
          calls = data['calls'] ?? [];
        });
      } else {
        final error = jsonDecode(response.body);
        showError(error['message'] ?? "Error fetching dashboard data");
      }
    } catch (e) {
      showError("Something went wrong: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  void showError(String msg) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("❌ $msg")));
  }

  @override
  Widget build(BuildContext context) {
    final total = pending + called + rescheduled;

    return Scaffold(
      appBar: AppBar(title: Text("Dashboard")),
      drawer: buildCustomDrawer(),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: fetchDashboardData,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.listName,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "$total CALLS",
                              style: const TextStyle(
                                fontSize: 22,
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const CircleAvatar(
                          backgroundColor: Colors.blue,
                          radius: 24,
                          child: Text(
                            "S",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  AspectRatio(
                    aspectRatio: 1.3,
                    child: PieChart(
                      PieChartData(
                        sections: [
                          PieChartSectionData(
                            color: Colors.orange,
                            value: pending.toDouble(),
                            title: '',
                            radius: 40,
                          ),
                          PieChartSectionData(
                            color: Colors.green,
                            value: called.toDouble(),
                            title: '',
                            radius: 40,
                          ),
                          PieChartSectionData(
                            color: Colors.purple,
                            value: rescheduled.toDouble(),
                            title: '',
                            radius: 40,
                          ),
                        ],
                        sectionsSpace: 4,
                        centerSpaceRadius: 30,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      buildMiniStatCard(
                        "Pending",
                        pending,
                        Colors.orange.shade100,
                        Colors.orange,
                      ),
                      buildMiniStatCard(
                        "Done",
                        called,
                        Colors.green.shade100,
                        Colors.green,
                      ),
                      buildMiniStatCard(
                        "Schedule",
                        rescheduled,
                        Colors.purple.shade100,
                        Colors.purple,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => setState(() => showCalls = !showCalls),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Start Calling Now",
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (showCalls) ...[
                    const Text(
                      "📞 Call Entries",
                      style: TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 8),
                    ...calls.map(buildCallTile),
                  ],
                ],
              ),
            ),
    );
  }

  Widget buildMiniStatCard(
    String label,
    int count,
    Color bgColor,
    Color textColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(10),
      width: 100,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
          ),
          Text("$count Calls", style: TextStyle(color: textColor)),
        ],
      ),
    );
  }

  Widget buildCallTile(dynamic call) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        leading: const Icon(Icons.person),
        title: Text("${call['FirstName']} ${call['LastName']}"),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Phone: ${call['Phone']}"),
            Text("Status: ${call['status']}"),
            if (call['calledAt'] != null)
              Text("Called At: ${call['calledAt']}"),
            if (call['feedback'] != null) Text("Feedback: ${call['feedback']}"),
          ],
        ),
        trailing: Icon(
          Icons.circle,
          color: call['status'] == 'called'
              ? Colors.green
              : call['status'] == 'rescheduled'
              ? Colors.purple
              : Colors.orange,
        ),
      ),
    );
  }

  Drawer buildCustomDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(color: Colors.blue),
            accountName: const Text("Abhi • Personal"),
            accountEmail: Text(widget.email),
            currentAccountPicture: const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person, color: Colors.blue),
            ),
          ),
          buildDrawerItem(Icons.flag, "Getting Started"),
          buildDrawerItem(Icons.sync, "Sync Data"),
          buildDrawerItem(Icons.emoji_events, "Gamification"),
          buildDrawerItem(Icons.bug_report, "Send Logs"),
          buildDrawerItem(Icons.settings, "Settings"),
          buildDrawerItem(Icons.help_outline, "Help?"),
          buildDrawerItem(Icons.cancel, "Cancel Subscription"),
          const Divider(),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text("App Info", style: TextStyle(color: Colors.grey)),
          ),
          buildDrawerItem(Icons.info, "About Us"),
          buildDrawerItem(Icons.privacy_tip, "Privacy Policy"),
          buildDrawerItem(Icons.verified, "Version 1.0"),
          buildDrawerItem(Icons.share, "Share App"),
          buildDrawerItem(Icons.logout, "Logout"),
        ],
      ),
    );
  }

  ListTile buildDrawerItem(IconData icon, String title) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue),
      title: Text(title),
      onTap: () {},
    );
  }
}
