import 'package:flutter/material.dart';

class ReportEditScreen extends StatefulWidget {
  final Map<String, String>? report;
  const ReportEditScreen({super.key, this.report});

  @override
  State<ReportEditScreen> createState() => _ReportEditScreenState();
}

class _ReportEditScreenState extends State<ReportEditScreen> {
  late TextEditingController _userController;
  late TextEditingController _reasonController;
  late TextEditingController _dateController;
  String _status = 'Chưa xử lý';

  @override
  void initState() {
    super.initState();
    _userController = TextEditingController(text: widget.report?['user'] ?? '');
    _reasonController = TextEditingController(
      text: widget.report?['reason'] ?? '',
    );
    _dateController = TextEditingController(text: widget.report?['date'] ?? '');
    _status = widget.report?['status'] ?? 'Chưa xử lý';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.report == null ? 'Thêm báo cáo' : 'Sửa báo cáo'),
        backgroundColor: Colors.pinkAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            TextField(
              controller: _userController,
              decoration: const InputDecoration(
                labelText: 'Người bị báo cáo',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _reasonController,
              decoration: const InputDecoration(
                labelText: 'Lý do',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.report),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _dateController,
              decoration: const InputDecoration(
                labelText: 'Ngày',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.date_range),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _status,
              decoration: const InputDecoration(
                labelText: 'Trạng thái',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.info),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'Chưa xử lý',
                  child: Text('Chưa xử lý'),
                ),
                DropdownMenuItem(value: 'Đã xử lý', child: Text('Đã xử lý')),
              ],
              onChanged: (value) {
                setState(() {
                  _status = value!;
                });
              },
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pinkAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context, {
                    'user': _userController.text,
                    'reason': _reasonController.text,
                    'date': _dateController.text,
                    'status': _status,
                  });
                },
                child: Text(
                  widget.report == null ? 'Thêm mới' : 'Lưu thay đổi',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
