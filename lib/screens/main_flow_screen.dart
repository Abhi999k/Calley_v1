import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'final_dashboard_screen.dart';

class MainFlowScreen extends StatefulWidget {
  final String userId;
  final String email;
  final String username;

  const MainFlowScreen({
    super.key,
    required this.userId,
    required this.email,
    required this.username,
  });

  @override
  State<MainFlowScreen> createState() => _MainFlowScreenState();
}

class _MainFlowScreenState extends State<MainFlowScreen> {
  List<dynamic> callingLists = [];
  bool isFetching = false;

  @override
  void initState() {
    super.initState();
    fetchCallingLists();
  }

  Future<void> fetchCallingLists() async {
    setState(() => isFetching = true);
    try {
      final uri = Uri.parse(
        "https://mock-api.calleyacd.com/api/list?userId=${widget.userId}",
      );

      var request = http.Request("GET", uri);
      request.headers['Content-Type'] = 'application/json';
      request.body = jsonEncode({'email': widget.email});

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      print("Status: ${response.statusCode}");
      print("Response: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Single object response, wrap in a list
        setState(() {
          callingLists = [data];
        });
      } else {
        final error = jsonDecode(response.body);
        showError(error['message'] ?? "Failed to fetch list");
      }
    } catch (e) {
      showError("Something went wrong: $e");
    } finally {
      setState(() => isFetching = false);
    }
  }

  void showError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("❌ $message")));
  }

  void showCallingListModal() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Text(
                  "Select Calling List",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: fetchCallingLists,
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (isFetching)
              const Center(child: CircularProgressIndicator())
            else if (callingLists.isEmpty)
              const Center(child: Text("No calling list found."))
            else
              ...callingLists.map(
                (list) => Card(
                  child: ListTile(
                    title: Text(list['name'] ?? 'Unnamed List'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      Navigator.pop(context);

                      final listId = list['_id'];
                      final listName = list['name'];

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => FinalDashboardScreen(
                            listId: listId,
                            listName: listName,
                            email: widget.email,
                          ),
                        ),
                      );

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("📞 Selected: $listName")),
                      );
                    },
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard"),
        leading: const Icon(Icons.menu),
        actions: const [Icon(Icons.notifications), SizedBox(width: 10)],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: buildDashboardUI(),
      ),
    );
  }

  Widget buildDashboardUI() {
    return SingleChildScrollView(
      child: Column(
        children: [
          buildUserCard(),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.indigo.shade700,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "LOAD NUMBERS TO CALL",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  "Visit https://app.getcalley.com to upload numbers that you wish to call using Calley Mobile App.",
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.call),
                  label: const Text(
                    "Start Calling Now",
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: showCallingListModal,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    iconColor: Colors.white,
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              IconButton(
                icon: const FaIcon(
                  FontAwesomeIcons.whatsapp,
                  color: Colors.green,
                  size: 28,
                ),
                onPressed: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildUserCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.blue.shade600,
        borderRadius: BorderRadius.circular(12),
      ),
      width: double.infinity,
      child: Row(
        children: [
          const CircleAvatar(radius: 28, child: Icon(Icons.person)),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Hello ${widget.username}",
                style: const TextStyle(color: Colors.white, fontSize: 18),
              ),
              Text(widget.email, style: const TextStyle(color: Colors.white70)),
            ],
          ),
        ],
      ),
    );
  }
}
