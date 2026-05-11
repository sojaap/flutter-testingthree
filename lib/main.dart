import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Biodata Mahasiswa',
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Inter',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0061FF),
          primary: const Color(0xFF0061FF),
          surface: const Color(0xFFF1F5F9),
        ),
      ),
      home: const FormScreen(),
    );
  }
}

typedef Mahasiswa = ({
  String nama,
  String ttl,
  String gender,
  String alamat,
  String agama,
  String pendidikan,
  String hp,
  String email,
});

class FormScreen extends StatefulWidget {
  const FormScreen({super.key});

  @override
  State<FormScreen> createState() => _FormScreenState();
}

class _FormScreenState extends State<FormScreen> {
  final _formKey = GlobalKey<FormState>();


  final _ctrl = (
    nama: TextEditingController(),
    ttl: TextEditingController(),
    alamat: TextEditingController(),
    agama: TextEditingController(),
    hp: TextEditingController(),
    email: TextEditingController(),
  );

  String _gender = 'Laki-laki';
  String _pendidikan = 'S1';

  @override
  void dispose() {
    _ctrl.nama.dispose();
    _ctrl.ttl.dispose();
    _ctrl.alamat.dispose();
    _ctrl.agama.dispose();
    _ctrl.hp.dispose();
    _ctrl.email.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final data = (
        nama: _ctrl.nama.text,
        ttl: _ctrl.ttl.text,
        gender: _gender,
        alamat: _ctrl.alamat.text,
        agama: _ctrl.agama.text,
        pendidikan: _pendidikan,
        hp: _ctrl.hp.text,
        email: _ctrl.email.text,
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DisplayProfileScreen(data: data),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Biodata",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF1E3A8A),
                  ),
                ),
                const Text(
                  "Mahasiswa",
                  style: TextStyle(fontSize: 24, color: Color(0xFF64748B)),
                ),
                const SizedBox(height: 24),
                _buildFormCard("Data Diri", [
                  _buildInput(_ctrl.nama, "Nama Lengkap", Icons.person_outline),
                  _buildInput(
                    _ctrl.ttl,
                    "Tempat, Tanggal Lahir",
                    Icons.calendar_today_outlined,
                  ),
                  _buildInput(_ctrl.agama, "Agama", Icons.mosque_outlined),
                  _buildGenderSelector(),
                ]),
                const SizedBox(height: 12),
                _buildFormCard("Kontak & Pendidikan", [
                  _buildInput(
                    _ctrl.alamat,
                    "Alamat",
                    Icons.map_outlined,
                    maxLines: 2,
                  ),
                  _buildInput(
                    _ctrl.hp,
                    "WhatsApp",
                    Icons.phone_android_outlined,
                    keyboard: TextInputType.phone,
                  ),
                  _buildInput(
                    _ctrl.email,
                    "Email",
                    Icons.email_outlined,
                    keyboard: TextInputType.emailAddress,
                  ),
                  _buildPendidikanDropdown(),
                ]),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0061FF),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Tampilkan Profil",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormCard(String title, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: Color(0xFF1E3A8A),
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInput(
    TextEditingController controller,
    String label,
    IconData icon, {
    int maxLines = 1,
    bool optional = false,
    TextInputType keyboard = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboard,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: const Color(0xFF0061FF), size: 18),
          filled: true,
          fillColor: const Color(0xFFF8FAFC),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
        ),
        validator: (v) =>
            (!optional && (v == null || v.isEmpty)) ? "Wajib diisi" : null,
      ),
    );
  }

  Widget _buildGenderSelector() {
    return Row(
      children: ['Laki-laki', 'Perempuan'].map((e) {
        bool isSel = _gender == e;
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _gender = e),
            child: Container(
              margin: EdgeInsets.only(right: e == 'Laki-laki' ? 8 : 0),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isSel
                    ? const Color(0xFF0061FF)
                    : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: Text(
                e,
                style: TextStyle(
                  color: isSel ? Colors.white : const Color(0xFF64748B),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPendidikanDropdown() {
    return DropdownButtonFormField<String>(
      value: _pendidikan,
      decoration: InputDecoration(
        labelText: "Pendidikan",
        prefixIcon: const Icon(
          Icons.school_outlined,
          color: Color(0xFF0061FF),
          size: 18,
        ),
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
      items: [
        'SMA/SMK',
        'Diploma',
        'S1',
        'S2',
        'S3',
      ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
      onChanged: (v) => setState(() => _pendidikan = v!),
    );
  }
}

class DisplayProfileScreen extends StatelessWidget {
  final Mahasiswa data;
  const DisplayProfileScreen({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(title: const Text("Profil Mahasiswa"), centerTitle: true),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 40),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF0061FF), Color(0xFF60A5FA)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 4),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                      image: const DecorationImage(
                        image: AssetImage('lib/assets/russell-re.jpeg'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    data.nama.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    data.email,
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildDetailCard("Biodata Diri", [
                    _buildDetailRow(Icons.cake_outlined, "TTL", data.ttl),
                    _buildDetailRow(Icons.wc_outlined, "Gender", data.gender),
                    _buildDetailRow(Icons.mosque_outlined, "Agama", data.agama),
                    _buildDetailRow(Icons.map_outlined, "Alamat", data.alamat),
                  ]),
                  const SizedBox(height: 12),
                  _buildDetailCard("Akademik & Kontak", [
                    _buildDetailRow(
                      Icons.school_outlined,
                      "Pendidikan",
                      data.pendidikan,
                    ),
                    _buildDetailRow(
                      Icons.phone_android_outlined,
                      "WhatsApp",
                      data.hp,
                    ),
                  ]),
                  const SizedBox(height: 24),
                  OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Kembali"),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailCard(String title, List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 18, color: const Color(0xFF0061FF)),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 10, color: Colors.grey),
              ),
              Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }
}
