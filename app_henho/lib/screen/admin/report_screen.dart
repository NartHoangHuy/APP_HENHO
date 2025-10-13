import 'package:flutter/material.dart';
import 'report_edit_screen.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

//test git lần thứ n
class _ReportScreenState extends State<ReportScreen> {
  List<Map<String, String>> reports = [
    {
      'user': 'Nguyễn Văn A',
      'reason': 'Spam tin nhắn',
      'status': 'Chưa xử lý',
      'date': '12/10/2025',
    },
    {
      'user': 'Mai Lan',
      'reason': 'Ngôn từ không phù hợp',
      'status': 'Đã xử lý',
      'date': '10/10/2025',
    },
    {
      'user': 'Hoàng Nam',
      'reason': 'Ảnh không hợp lệ',
      'status': 'Chưa xử lý',
      'date': '09/10/2025',
    },
  ];

  void _deleteReport(int index) {
    setState(() {
      reports.removeAt(index);
    });
  }

  void _editReport(int index) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReportEditScreen(report: reports[index]),
      ),
    );
    if (result != null) {
      setState(() {
        reports[index] = result;
      });
    }
  }

  void _addReport() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ReportEditScreen()),
    );
    if (result != null) {
      setState(() {
        reports.add(result);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý báo cáo'),
        backgroundColor: Colors.pinkAccent,
        actions: [
          IconButton(icon: const Icon(Icons.add), onPressed: _addReport),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Danh sách báo cáo vi phạm',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.separated(
                itemCount: reports.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final report = reports[index];
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 4,
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.pink.shade100,
                          child: const Icon(Icons.report, color: Colors.pink),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            report['user']!,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            report['reason']!,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          report['date']!,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black54,
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: report['status'] == 'Đã xử lý'
                                ? Colors.green.shade100
                                : Colors.orange.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            report['status']!,
                            style: TextStyle(
                              color: report['status'] == 'Đã xử lý'
                                  ? Colors.green
                                  : Colors.orange,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.check, color: Colors.green),
                          onPressed: () => _editReport(index),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteReport(index),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
