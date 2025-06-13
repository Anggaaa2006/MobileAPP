class AddBillScreen extends StatefulWidget {
  @override
  _AddBillScreenState createState() => _AddBillScreenState();
}

class _AddBillScreenState extends State<AddBillScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  DateTime _dueDate = DateTime.now().add(Duration(days: 7));

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _dueDate) {
      setState(() => _dueDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Tambah Tagihan")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: _titleController, decoration: InputDecoration(labelText: "Nama Tagihan")),
            TextField(controller: _amountController, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: "Jumlah")),
            ListTile(
              title: Text("Tanggal Jatuh Tempo: ${DateFormat('dd/MM/yyyy').format(_dueDate)}"),
              trailing: Icon(Icons.calendar_today),
              onTap: () => _selectDate(context),
            ),
            ElevatedButton(
              onPressed: () async {
                await BillService().addBill(
                  FirebaseAuth.instance.currentUser!.uid,
                  {
                    'title': _titleController.text,
                    'amount': int.parse(_amountController.text),
                    'dueDate': _dueDate,
                    'isPaid': false,
                  },
                );
                Navigator.pop(context);
              },
              child: Text("Simpan Tagihan"),
            ),
          ],
        ),
      ),
    );
  }
}