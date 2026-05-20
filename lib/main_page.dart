import 'package:flutter/material.dart';
import 'database_helper.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  List<Map<String, dynamic>> _students = [];
  bool _isLoading = true;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _refreshStudentList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _refreshStudentList() async {
    setState(() => _isLoading = true);
    final data = await _dbHelper.getStudents();
    setState(() {
      _students = data;
      _isLoading = false;
    });
  }

  List<Map<String, dynamic>> get _filteredStudents {
    if (_searchQuery.trim().isEmpty) return _students;
    final query = _searchQuery.toLowerCase();
    return _students.where((student) {
      final nama = (student['nama'] ?? '').toString().toLowerCase();
      final pendidikan = (student['pendidikan'] ?? '').toString().toLowerCase();
      final alamat = (student['alamat'] ?? '').toString().toLowerCase();
      final email = (student['email'] ?? '').toString().toLowerCase();
      return nama.contains(query) ||
          pendidikan.contains(query) ||
          alamat.contains(query) ||
          email.contains(query);
    }).toList();
  }

  Map<String, int> get _pendidikanStats {
    final stats = <String, int>{};
    for (final s in _students) {
      final pendidikan = s['pendidikan']?.toString().isNotEmpty == true ? s['pendidikan'] : 'Lainnya';
      stats[pendidikan] = (stats[pendidikan] ?? 0) + 1;
    }
    return stats;
  }

  void _showDeleteDialog(int id, String nama) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: const [
            Icon(Icons.warning_amber_rounded, color: Colors.red, size: 28),
            SizedBox(width: 10),
            Text(
              "Hapus Mahasiswa",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E3A8A),
              ),
            ),
          ],
        ),
        content: Text(
          "Apakah Anda yakin ingin menghapus data mahasiswa bernama '$nama'? Tindakan ini tidak dapat dibatalkan.",
          style: const TextStyle(color: Color(0xFF64748B), height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Batal", style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              await _dbHelper.deleteStudent(id);
              _refreshStudentList();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        const Icon(Icons.check_circle_outline, color: Colors.white),
                        const SizedBox(width: 10),
                        Expanded(child: Text("Data $nama berhasil dihapus")),
                      ],
                    ),
                    backgroundColor: Colors.redAccent,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                );
              }
            },
            child: const Text("Hapus", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            _buildStatsBar(),
            _buildSearchBar(),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredStudents.isEmpty
                      ? _buildEmptyState()
                      : _buildStudentList(),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const StudentFormPage(),
            ),
          );
          if (result == true) {
            _refreshStudentList();
          }
        },
        backgroundColor: const Color(0xFF0061FF),
        foregroundColor: Colors.white,
        elevation: 4,
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          "Tambah Mahasiswa",
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      color: const Color(0xFFF1F5F9),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                "Manajemen",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF1E3A8A),
                  letterSpacing: -0.5,
                ),
              ),
              Text(
                "Biodata Mahasiswa",
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                )
              ],
            ),
            child: IconButton(
              icon: const Icon(Icons.refresh_rounded, color: Color(0xFF0061FF)),
              onPressed: _refreshStudentList,
              tooltip: "Refresh Data",
            ),
          )
        ],
      ),
    );
  }

  Widget _buildStatsBar() {
    if (_students.isEmpty) return const SizedBox.shrink();
    final stats = _pendidikanStats;

    return Container(
      height: 70,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _buildStatCard("Total", _students.length.toString(), const Color(0xFF0061FF), Icons.people_rounded),
          ...stats.entries.map((entry) {
            IconData icon = Icons.school_rounded;
            Color cardColor = const Color(0xFF1E3A8A);
            if (entry.key.toLowerCase().contains("informatika")) {
              icon = Icons.computer_rounded;
              cardColor = const Color(0xFF0D9488);
            } else if (entry.key.toLowerCase().contains("sistem")) {
              icon = Icons.analytics_rounded;
              cardColor = const Color(0xFF7C3AED);
            } else if (entry.key.toLowerCase().contains("komputer")) {
              icon = Icons.developer_board_rounded;
              cardColor = const Color(0xFFEA580C);
            }
            return _buildStatCard(entry.key, entry.value.toString(), cardColor, icon);
          }),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.15), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.01),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(width: 12),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (v) => setState(() => _searchQuery = v),
          decoration: InputDecoration(
            hintText: "Cari mahasiswa, pendidikan, atau alamat...",
            hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
            prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF0061FF)),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear_rounded, color: Color(0xFF64748B)),
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _searchQuery = '');
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFDBEAFE), width: 4),
                ),
                child: const Icon(
                  Icons.people_outline_rounded,
                  size: 64,
                  color: Color(0xFF0061FF),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                _searchQuery.isNotEmpty ? "Tidak Ada Hasil" : "Data Mahasiswa Kosong",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E3A8A),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _searchQuery.isNotEmpty
                    ? "Kata kunci '$_searchQuery' tidak cocok dengan data mana pun. Silakan coba pencarian lain."
                    : "Silakan tambahkan data mahasiswa baru dengan mengetuk tombol '+' di bawah.",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF64748B),
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStudentList() {
    final list = _filteredStudents;
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 80),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final student = list[index];
        final String nama = student['nama'] ?? '';
        final String email = student['email'] ?? '';
        final String pendidikan = student['pendidikan'] ?? '';
        final String alamat = student['alamat'] ?? '';
        final int id = student['id'];

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => StudentDetailPage(student: student),
                  ),
                ).then((_) => _refreshStudentList());
              },
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Column( 
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Profile Image Asset Container
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: const Color(0xFFDBEAFE), width: 2),
                            image: const DecorationImage(
                              image: AssetImage('lib/assets/russell-re.jpeg'),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Information Text
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                nama,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1E3A8A),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Wrap( 
                                spacing: 8,
                                runSpacing: 4,
                                children: [
                                  if (pendidikan.isNotEmpty)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFEFF6FF),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        pendidikan,
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: Color(0xFF0061FF),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  if (alamat.isNotEmpty)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF1F5F9),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        alamat,
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: Color(0xFF64748B),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              if (email.isNotEmpty) ...[
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    const Icon(Icons.email_outlined, size: 13, color: Color(0xFF94A3B8)),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        email,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF64748B),
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ]
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    // Action Buttons Row (Detail, Edit, Delete)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // View Profile Button
                        IconButton(
                          icon: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: Color(0xFFECFDF5),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.visibility_rounded, color: Color(0xFF059669), size: 18),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => StudentDetailPage(student: student),
                              ),
                            ).then((_) => _refreshStudentList());
                          },
                          tooltip: "Lihat Profil",
                        ),
                        // Edit Button
                        IconButton(
                          icon: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: Color(0xFFEFF6FF),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.edit_rounded, color: Color(0xFF0061FF), size: 18),
                          ),
                          onPressed: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => StudentFormPage(student: student),
                              ),
                            );
                            if (result == true) {
                              _refreshStudentList();
                            }
                          },
                          tooltip: "Edit",
                        ),
                        // Delete Button
                        IconButton(
                          icon: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: Color(0xFFFEF2F2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.delete_outline_rounded, color: Color(0xFFDC2626), size: 18),
                          ),
                          onPressed: () => _showDeleteDialog(id, nama),
                          tooltip: "Hapus",
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}


class StudentDetailPage extends StatelessWidget {
  final Map<String, dynamic> student;
  const StudentDetailPage({Key? key, required this.student}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String nama = student['nama'] ?? '';
    final String tempatTanggalLahir = student['tempat_tanggal_lahir'] ?? '-';
    final String jenisKelamin = student['jenis_kelamin'] ?? '-';
    final String alamat = student['alamat'] ?? '-';
    final String agama = student['agama'] ?? '-';
    final String pendidikan = student['pendidikan'] ?? '-';
    final String nomorHp = student['nomor_hp'] ?? '-';
    final String email = student['email'] ?? '-';
    final int id = student['id'];

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        title: const Text("Profil Mahasiswa", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
        backgroundColor: const Color(0xFF0061FF),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_rounded, color: Colors.white),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => StudentFormPage(student: student),
                ),
              );
              if (result == true && context.mounted) {
                Navigator.pop(context, true); // Pop back to refresh MainPage
              }
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            // Top Cover with Image Profile
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 40),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF0061FF), Color(0xFF60A5FA)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    width: 130,
                    height: 130,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 4),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
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
                    nama.toUpperCase(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      pendidikan,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Profile Detail Cards
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildDetailCard("Informasi Pribadi & Kontak", [
                    _buildDetailRow(Icons.person_rounded, "Nama Lengkap", nama),
                    _buildDetailRow(Icons.calendar_today_rounded, "Tempat, Tanggal Lahir", tempatTanggalLahir),
                    _buildDetailRow(Icons.wc_rounded, "Jenis Kelamin", jenisKelamin),
                    _buildDetailRow(Icons.map_rounded, "Alamat", alamat),
                    _buildDetailRow(Icons.book_rounded, "Agama", agama),
                    _buildDetailRow(Icons.school_rounded, "Pendidikan", pendidikan),
                    _buildDetailRow(Icons.phone_rounded, "Nomor HP", nomorHp),
                    _buildDetailRow(Icons.email_rounded, "Email", email),
                  ]),
                  const SizedBox(height: 24),
                  // Delete Button inside Detail Page
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red, width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            title: const Text("Hapus Mahasiswa", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A))),
                            content: Text("Apakah Anda yakin ingin menghapus data mahasiswa bernama '$nama'?"),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx),
                                child: const Text("Batal", style: TextStyle(color: Color(0xFF64748B))),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                                onPressed: () async {
                                  Navigator.pop(ctx);
                                  await DatabaseHelper.instance.deleteStudent(id);
                                  if (context.mounted) {
                                    Navigator.pop(context, true); // Pop back to MainPage with reload
                                  }
                                },
                                child: const Text("Hapus", style: TextStyle(fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                        );
                      },
                      icon: const Icon(Icons.delete_outline_rounded),
                      label: const Text("Hapus Mahasiswa", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    ),
                  ),
                  const SizedBox(height: 40),
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF94A3B8),
              fontSize: 11,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Color(0xFFEFF6FF),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 20, color: const Color(0xFF0061FF)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8), fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Color(0xFF1E3A8A),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Student Form Page
class StudentFormPage extends StatefulWidget {
  final Map<String, dynamic>? student;
  const StudentFormPage({Key? key, this.student}) : super(key: key);

  @override
  State<StudentFormPage> createState() => _StudentFormPageState();
}

class _StudentFormPageState extends State<StudentFormPage> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _namaController;
  late TextEditingController _ttlController;
  late TextEditingController _alamatController;
  late TextEditingController _noHpController;
  late TextEditingController _emailController;

  String? _jenisKelamin;
  String? _agama;
  String? _pendidikan;

  final List<String> _jenisKelaminOptions = ['Laki-laki', 'Perempuan'];
  final List<String> _agamaOptions = ['Islam', 'Kristen', 'Katolik', 'Hindu', 'Buddha', 'Konghucu'];
  final List<String> _pendidikanOptions = ['S1 Teknik Informatika', 'S1 Sistem Informasi', 'S1 Teknik Komputer', 'D3 Manajemen Informatika', 'S1 Akuntansi', 'S1 Manajemen', 'Lainnya'];

  bool get isEdit => widget.student != null;

  @override
  void initState() {
    super.initState();
    _namaController = TextEditingController(text: widget.student?['nama'] ?? '');
    _ttlController = TextEditingController(text: widget.student?['tempat_tanggal_lahir'] ?? '');
    _alamatController = TextEditingController(text: widget.student?['alamat'] ?? '');
    _noHpController = TextEditingController(text: widget.student?['nomor_hp'] ?? '');
    _emailController = TextEditingController(text: widget.student?['email'] ?? '');
    
    _jenisKelamin = widget.student?['jenis_kelamin'];
    if (_jenisKelamin != null && !_jenisKelaminOptions.contains(_jenisKelamin)) _jenisKelaminOptions.add(_jenisKelamin!);
    
    _agama = widget.student?['agama'];
    if (_agama != null && !_agamaOptions.contains(_agama)) _agamaOptions.add(_agama!);

    _pendidikan = widget.student?['pendidikan'];
    if (_pendidikan != null && !_pendidikanOptions.contains(_pendidikan)) _pendidikanOptions.add(_pendidikan!);
  }

  @override
  void dispose() {
    _namaController.dispose();
    _ttlController.dispose();
    _alamatController.dispose();
    _noHpController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _saveForm() async {
    if (_formKey.currentState!.validate()) {
      final studentData = {
        'nama': _namaController.text.trim(),
        'tempat_tanggal_lahir': _ttlController.text.trim(),
        'jenis_kelamin': _jenisKelamin ?? '',
        'alamat': _alamatController.text.trim(),
        'agama': _agama ?? '',
        'pendidikan': _pendidikan ?? '',
        'nomor_hp': _noHpController.text.trim(),
        'email': _emailController.text.trim(),
      };

      if (isEdit) {
        studentData['id'] = widget.student!['id'];
        await DatabaseHelper.instance.updateStudent(studentData);
      } else {
        await DatabaseHelper.instance.insertStudent(studentData);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: Colors.white),
                const SizedBox(width: 10),
                Expanded(child: Text(isEdit ? "Perubahan berhasil disimpan" : "Data mahasiswa berhasil ditambahkan")),
              ],
            ),
            backgroundColor: const Color(0xFF059669),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
        Navigator.pop(context, true);
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline_rounded, color: Colors.white),
                const SizedBox(width: 10),
                const Expanded(child: Text("Mohon lengkapi semua data wajib yang ditandai merah!")),
              ],
            ),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        title: Text(
          isEdit ? "Edit Mahasiswa" : "Tambah Mahasiswa",
          style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A)),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF1E3A8A)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Visual Indicator Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFEFF6FF), Color(0xFFDBEAFE)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFBFDBFE), width: 1),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isEdit ? Icons.edit_note_rounded : Icons.person_add_alt_1_rounded,
                          color: const Color(0xFF0061FF),
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isEdit ? "Perbarui Data Biodata" : "Masukkan Data Biodata Baru",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: Color(0xFF1E3A8A),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              isEdit
                                  ? "Ubah data di formulir bawah untuk memperbarui profil mahasiswa."
                                  : "Lengkapi semua data di formulir bawah untuk mendaftarkan mahasiswa baru.",
                              style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), height: 1.3),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                // Form Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Formulir Biodata",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Color(0xFF1E3A8A),
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildInput(
                        _namaController,
                        "Nama",
                        Icons.person_outline,
                      ),
                      _buildInput(
                        _ttlController,
                        "Tempat, Tanggal Lahir",
                        Icons.calendar_today_outlined,
                      ),
                      _buildDropdown(
                        "Jenis Kelamin",
                        Icons.wc_outlined,
                        _jenisKelamin,
                        _jenisKelaminOptions,
                        (val) => setState(() => _jenisKelamin = val),
                      ),
                      _buildInput(
                        _alamatController,
                        "Alamat",
                        Icons.map_outlined,
                        maxLines: 2,
                      ),
                      _buildDropdown(
                        "Agama",
                        Icons.book_outlined,
                        _agama,
                        _agamaOptions,
                        (val) => setState(() => _agama = val),
                      ),
                      _buildDropdown(
                        "Pendidikan",
                        Icons.school_outlined,
                        _pendidikan,
                        _pendidikanOptions,
                        (val) => setState(() => _pendidikan = val),
                      ),
                      _buildInput(
                        _noHpController,
                        "Nomor HP",
                        Icons.phone_outlined,
                        keyboard: TextInputType.phone,
                      ),
                      _buildInput(
                        _emailController,
                        "Email",
                        Icons.email_outlined,
                        keyboard: TextInputType.emailAddress,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                // Save Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _saveForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0061FF),
                      foregroundColor: Colors.white,
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      isEdit ? "Simpan Perubahan" : "Simpan Data Mahasiswa",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
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

  Widget _buildInput(
    TextEditingController controller,
    String label,
    IconData icon, {
    int maxLines = 1,
    bool optional = false,
    TextInputType keyboard = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboard,
        style: const TextStyle(fontSize: 15, color: Color(0xFF1E3A8A), fontWeight: FontWeight.w600),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13, fontWeight: FontWeight.w500),
          prefixIcon: Icon(icon, color: const Color(0xFF0061FF), size: 20),
          filled: true,
          fillColor: const Color(0xFFF8FAFC),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF0061FF), width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.redAccent, width: 1),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        ),
        validator: (v) =>
            (!optional && (v == null || v.trim().isEmpty)) ? "$label wajib diisi" : null,
      ),
    );
  }

  Widget _buildDropdown(
    String label,
    IconData icon,
    String? value,
    List<String> options,
    Function(String?) onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        initialValue: value,
        icon: const Icon(Icons.arrow_drop_down_rounded, color: Color(0xFF0061FF)),
        style: const TextStyle(fontSize: 15, color: Color(0xFF1E3A8A), fontWeight: FontWeight.w600),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13, fontWeight: FontWeight.w500),
          prefixIcon: Icon(icon, color: const Color(0xFF0061FF), size: 20),
          filled: true,
          fillColor: const Color(0xFFF8FAFC),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF0061FF), width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.redAccent, width: 1),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        ),
        items: options.map((String option) {
          return DropdownMenuItem<String>(
            value: option,
            child: Text(option),
          );
        }).toList(),
        onChanged: onChanged,
        validator: (v) => v == null || v.isEmpty ? "$label wajib diisi" : null,
      ),
    );
  }
}
