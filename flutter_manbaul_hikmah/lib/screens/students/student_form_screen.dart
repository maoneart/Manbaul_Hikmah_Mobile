import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/student.dart';
import '../../providers/school_provider.dart';
import '../../theme/app_theme.dart';

class StudentFormScreen extends StatefulWidget {
  final Student? student;

  const StudentFormScreen({super.key, this.student});

  @override
  State<StudentFormScreen> createState() => _StudentFormScreenState();
}

class _StudentFormScreenState extends State<StudentFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameCtrl;
  late TextEditingController _nisnCtrl;
  late TextEditingController _studentNikCtrl;
  late TextEditingController _ttlCtrl;
  late TextEditingController _addressCtrl;
  late TextEditingController _parentNameCtrl;
  late TextEditingController _parentPhoneCtrl;
  late TextEditingController _parentNikCtrl;
  late TextEditingController _admissionDateCtrl;
  late TextEditingController _graduationDateCtrl;

  late String _selectedGender;
  late String _selectedClass;
  late String _selectedStatus;
  bool _isLoading = false;

  final List<String> _classList = [
    'Kelas 1A', 'Kelas 1B', 'Kelas 1C',
    'Kelas 2A', 'Kelas 2B', 'Kelas 2C',
    'Kelas 3A', 'Kelas 3B', 'Kelas 3C',
    'Kelas 4A', 'Kelas 4B', 'Kelas 4C',
    'Kelas 5A', 'Kelas 5B', 'Kelas 5C',
    'Kelas 6A', 'Kelas 6B', 'Kelas 6C',
    'Kelas 7A', 'Kelas 7B',
    'Kelas 8A', 'Kelas 9A',
  ];

  @override
  void initState() {
    super.initState();
    final s = widget.student;

    _nameCtrl = TextEditingController(text: s?.name ?? '');
    _nisnCtrl = TextEditingController(text: s?.nisn ?? '');
    _studentNikCtrl = TextEditingController(text: s?.studentNik ?? '');
    _ttlCtrl = TextEditingController(text: s?.birthPlaceDate != '-' ? (s?.birthPlaceDate ?? '') : '');
    _addressCtrl = TextEditingController(text: s?.address != '-' ? (s?.address ?? '') : '');
    _parentNameCtrl = TextEditingController(text: s?.parentName ?? '');
    _parentPhoneCtrl = TextEditingController(text: s?.parentPhone != '-' ? (s?.parentPhone ?? '') : '');
    _parentNikCtrl = TextEditingController(text: s?.parentNik ?? '');

    // Format Tanggal Masuk (SOP)
    final initialAdmission = s?.admissionDate.isNotEmpty == true
        ? s!.admissionDate
        : '${DateTime.now().year}-07-15';
    _admissionDateCtrl = TextEditingController(text: initialAdmission);

    // Format Tanggal Lulus
    _graduationDateCtrl = TextEditingController(text: s?.graduationDate ?? '');

    _selectedGender = s?.gender ?? 'L';
    _selectedClass = s != null && _classList.contains(s.className) ? s.className : _classList.first;
    _selectedStatus = s?.status ?? 'Aktif';
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _nisnCtrl.dispose();
    _studentNikCtrl.dispose();
    _ttlCtrl.dispose();
    _addressCtrl.dispose();
    _parentNameCtrl.dispose();
    _parentPhoneCtrl.dispose();
    _parentNikCtrl.dispose();
    _admissionDateCtrl.dispose();
    _graduationDateCtrl.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, TextEditingController ctrl, {DateTime? initialDate}) async {
    DateTime initial = initialDate ?? DateTime.now();
    if (ctrl.text.isNotEmpty) {
      final parsed = DateTime.tryParse(ctrl.text);
      if (parsed != null) initial = parsed;
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(2035),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF00B14F),
              onPrimary: Colors.white,
              onSurface: Color(0xFF1C1C1E),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final y = picked.year.toString().padLeft(4, '0');
      final m = picked.month.toString().padLeft(2, '0');
      final d = picked.day.toString().padLeft(2, '0');
      setState(() {
        ctrl.text = '$y-$m-$d';
      });
    }
  }

  Future<void> _saveStudent() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Harap lengkapi semua kolom wajib dengan benar.'),
          backgroundColor: Color(0xFFFF3B30),
        ),
      );
      return;
    }

    // Validasi tambahan jika status Lulus
    if (_selectedStatus == 'Lulus' && _graduationDateCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tanggal Lulus wajib diisi untuk siswa yang telah lulus.'),
          backgroundColor: Color(0xFFFF3B30),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    final provider = Provider.of<SchoolProvider>(context, listen: false);

    try {
      final admissionDate = _admissionDateCtrl.text.trim();
      final entryYear = admissionDate.length >= 4 ? admissionDate.substring(0, 4) : '2024';

      if (widget.student == null) {
        // Mode Tambah
        await provider.addStudent(
          _nisnCtrl.text.trim(),
          _nameCtrl.text.trim(),
          _selectedGender,
          _selectedClass,
          _parentNameCtrl.text.trim(),
          _parentPhoneCtrl.text.trim(),
          studentNik: _studentNikCtrl.text.trim(),
          parentNik: _parentNikCtrl.text.trim(),
          address: _addressCtrl.text.trim().isNotEmpty ? _addressCtrl.text.trim() : '-',
          entryYear: entryYear,
          admissionDate: admissionDate,
          status: _selectedStatus,
          graduationDate: _selectedStatus == 'Lulus' ? _graduationDateCtrl.text.trim() : '',
          birthPlaceDate: _ttlCtrl.text.trim().isNotEmpty ? _ttlCtrl.text.trim() : '-',
        );
      } else {
        // Mode Edit
        await provider.updateStudent(
          id: widget.student!.id,
          name: _nameCtrl.text.trim(),
          gender: _selectedGender,
          className: _selectedClass,
          parentName: _parentNameCtrl.text.trim(),
          parentPhone: _parentPhoneCtrl.text.trim(),
          studentNik: _studentNikCtrl.text.trim(),
          parentNik: _parentNikCtrl.text.trim(),
          address: _addressCtrl.text.trim().isNotEmpty ? _addressCtrl.text.trim() : '-',
          entryYear: entryYear,
          admissionDate: admissionDate,
          status: _selectedStatus,
          graduationDate: _selectedStatus == 'Lulus' ? _graduationDateCtrl.text.trim() : '',
          birthPlaceDate: _ttlCtrl.text.trim().isNotEmpty ? _ttlCtrl.text.trim() : '-',
        );
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.student == null
              ? 'Siswa baru berhasil didaftarkan dan disinkronkan ke server!'
              : 'Data siswa berhasil diperbarui dan disinkronkan!'),
          backgroundColor: const Color(0xFF00B14F),
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Terjadi kesalahan: $e'),
          backgroundColor: const Color(0xFFFF3B30),
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.student != null;

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(CupertinoIcons.chevron_back, color: Color(0xFF1C1C1E), size: 28),
          tooltip: 'Kembali ke Daftar Siswa',
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isEdit ? 'Edit Data Siswa' : 'Pendaftaran Siswa Baru',
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1C1C1E),
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          physics: const BouncingScrollPhysics(),
          children: [
            // Header Info Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF00B14F).withOpacity(0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF00B14F).withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00B14F),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      isEdit ? Icons.edit_note_rounded : Icons.person_add_alt_1_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isEdit ? 'Perbarui Profil Siswa SOP' : 'Pendaftaran Induk Siswa Baru',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1C1C1E),
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Pastikan NIK Orang Tua diisi lengkap untuk menghubungkan akun wali murid secara akurat.',
                          style: TextStyle(fontSize: 11.5, color: Color(0xFF3C3C43), height: 1.3),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // SEKSI 1: IDENTITAS SISWA
            _buildSectionHeader('1. IDENTITAS POKOK SISWA', Icons.badge_outlined),
            _buildCardGroup([
              _buildTextFormField(
                controller: _nameCtrl,
                label: 'Nama Lengkap Siswa *',
                hint: 'Contoh: Ahmad Fauzi Pratama',
                icon: Icons.person_outline_rounded,
                validator: (val) => val == null || val.trim().isEmpty ? 'Nama siswa wajib diisi' : null,
              ),
              const Divider(height: 1),
              _buildTextFormField(
                controller: _nisnCtrl,
                label: 'NISN (Nomor Induk Siswa Nasional) *',
                hint: 'Contoh: 0081234561 (10 Digit)',
                icon: Icons.pin_outlined,
                keyboardType: TextInputType.number,
                enabled: !isEdit, // NISN unik tidak diubah saat edit
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'NISN wajib diisi';
                  if (val.trim().length < 5) return 'NISN minimal 5 digit';
                  return null;
                },
              ),
              const Divider(height: 1),
              _buildTextFormField(
                controller: _studentNikCtrl,
                label: 'NIK Siswa (Nomor Induk Kependudukan)',
                hint: 'Contoh: 3275012301180002 (16 Digit)',
                icon: Icons.credit_card_rounded,
                keyboardType: TextInputType.number,
              ),
              const Divider(height: 1),
              // Gender Radio Selector
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    const Icon(Icons.wc_rounded, size: 20, color: Color(0xFF8E8E93)),
                    const SizedBox(width: 12),
                    const Text('Jenis Kelamin *', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1C1C1E))),
                    const Spacer(),
                    _buildGenderOption('L', 'Laki-laki', const Color(0xFF007AFF)),
                    const SizedBox(width: 12),
                    _buildGenderOption('P', 'Perempuan', const Color(0xFFFF2D55)),
                  ],
                ),
              ),
              const Divider(height: 1),
              _buildTextFormField(
                controller: _ttlCtrl,
                label: 'Tempat, Tanggal Lahir',
                hint: 'Contoh: Bekasi, 12 Januari 2018',
                icon: Icons.cake_outlined,
              ),
              const Divider(height: 1),
              // Kelas Dropdown
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Row(
                  children: [
                    const Icon(Icons.school_outlined, size: 20, color: Color(0xFF8E8E93)),
                    const SizedBox(width: 12),
                    const Text('Rombel / Kelas *', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1C1C1E))),
                    const Spacer(),
                    DropdownButton<String>(
                      value: _selectedClass,
                      underline: const SizedBox(),
                      borderRadius: BorderRadius.circular(12),
                      items: _classList.map((c) => DropdownMenuItem(value: c, child: Text(c, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)))).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedClass = val);
                      },
                    ),
                  ],
                ),
              ),
            ]),
            const SizedBox(height: 18),

            // SEKSI 2: STATUS & MASA BELAJAR
            _buildSectionHeader('2. STATUS & MASA BELAJAR (SOP)', Icons.event_note_rounded),
            _buildCardGroup([
              // Tanggal Masuk (DatePicker)
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                leading: const Icon(Icons.calendar_today_rounded, size: 20, color: Color(0xFF00B14F)),
                title: const Text('Tanggal Masuk Sekolah *', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                subtitle: Text(
                  _admissionDateCtrl.text.isNotEmpty ? _admissionDateCtrl.text : 'Pilih Tanggal Masuk',
                  style: TextStyle(
                    fontSize: 13,
                    color: _admissionDateCtrl.text.isNotEmpty ? const Color(0xFF00B14F) : Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                trailing: const Icon(CupertinoIcons.chevron_right, size: 18, color: Colors.grey),
                onTap: () => _selectDate(context, _admissionDateCtrl),
              ),
              const Divider(height: 1),
              // Status Siswa Dropdown
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Row(
                  children: [
                    const Icon(Icons.verified_outlined, size: 20, color: Color(0xFF8E8E93)),
                    const SizedBox(width: 12),
                    const Text('Status Siswa *', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1C1C1E))),
                    const Spacer(),
                    DropdownButton<String>(
                      value: _selectedStatus,
                      underline: const SizedBox(),
                      borderRadius: BorderRadius.circular(12),
                      items: ['Aktif', 'Lulus', 'Pindah'].map((st) {
                        Color badgeColor = const Color(0xFF00B14F);
                        if (st == 'Lulus') badgeColor = const Color(0xFF007AFF);
                        if (st == 'Pindah') badgeColor = const Color(0xFFFF9500);

                        return DropdownMenuItem(
                          value: st,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: badgeColor.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              st,
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: badgeColor),
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedStatus = val);
                      },
                    ),
                  ],
                ),
              ),
              // Conditional: Tanggal Lulus (Hanya muncul jika Status == 'Lulus')
              if (_selectedStatus == 'Lulus') ...[
                const Divider(height: 1),
                Container(
                  color: const Color(0xFF007AFF).withOpacity(0.04),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    leading: const Icon(Icons.school_rounded, size: 20, color: Color(0xFF007AFF)),
                    title: const Text('Tanggal Kelulusan Resmi (SOP) *', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF007AFF))),
                    subtitle: Text(
                      _graduationDateCtrl.text.isNotEmpty ? _graduationDateCtrl.text : 'Ketuk untuk atur Tanggal Lulus',
                      style: TextStyle(
                        fontSize: 13,
                        color: _graduationDateCtrl.text.isNotEmpty ? const Color(0xFF007AFF) : const Color(0xFFFF3B30),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    trailing: const Icon(CupertinoIcons.chevron_right, size: 18, color: Color(0xFF007AFF)),
                    onTap: () => _selectDate(context, _graduationDateCtrl),
                  ),
                ),
              ],
            ]),
            const SizedBox(height: 18),

            // SEKSI 3: DATA ORANG TUA / WALI (MULTI-ANAK RESOLVER)
            _buildSectionHeader('3. DATA ORANG TUA / WALI (KUNCI MULTI-ANAK)', Icons.family_restroom_rounded),
            _buildCardGroup([
              _buildTextFormField(
                controller: _parentNikCtrl,
                label: 'NIK Orang Tua / Wali *',
                hint: 'Contoh: 3275011201780001 (16 Digit)',
                icon: Icons.fingerprint_rounded,
                keyboardType: TextInputType.number,
                helperText: 'Kunci unik pengait multi-anak pada 1 akun wali murid.',
              ),
              const Divider(height: 1),
              _buildTextFormField(
                controller: _parentNameCtrl,
                label: 'Nama Lengkap Orang Tua / Wali *',
                hint: 'Contoh: H. Rahmat / Ibu Siti',
                icon: Icons.person_search_rounded,
                validator: (val) => val == null || val.trim().isEmpty ? 'Nama orang tua wajib diisi' : null,
              ),
              const Divider(height: 1),
              _buildTextFormField(
                controller: _parentPhoneCtrl,
                label: 'No. WhatsApp / HP Wali *',
                hint: 'Contoh: 081234567893',
                icon: Icons.phone_android_rounded,
                keyboardType: TextInputType.phone,
                validator: (val) => val == null || val.trim().isEmpty ? 'No. WhatsApp wali wajib diisi' : null,
              ),
            ]),
            const SizedBox(height: 18),

            // SEKSI 4: ALAMAT TINGGAL
            _buildSectionHeader('4. ALAMAT DOMISILI TINGGAL', Icons.home_work_outlined),
            _buildCardGroup([
              _buildTextFormField(
                controller: _addressCtrl,
                label: 'Alamat Lengkap',
                hint: 'Jl. KH. Noer Ali No. 12, RT 02 / RW 04, Karang Satria',
                icon: Icons.location_on_outlined,
                maxLines: 2,
              ),
            ]),
            const SizedBox(height: 24),

            // TOMBOL AKSI 100% SIMETRIS 2-KOLOM (MAONEART STANDARD)
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isLoading ? null : () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      side: BorderSide(color: Colors.grey.shade400),
                    ),
                    child: const Text(
                      'Batal',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF3C3C43),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveStudent,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00B14F),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : Text(
                            isEdit ? 'Simpan Perubahan' : 'Daftarkan Siswa',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: const Color(0xFF00B14F)),
          const SizedBox(width: 6),
          Text(
            title,
            style: const TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.bold,
              color: Color(0xFF8E8E93),
              letterSpacing: 0.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardGroup(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    bool enabled = true,
    String? helperText,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        enabled: enabled,
        style: TextStyle(
          fontSize: 14,
          color: enabled ? const Color(0xFF1C1C1E) : Colors.grey.shade600,
          fontWeight: FontWeight.w600,
        ),
        decoration: InputDecoration(
          icon: Icon(icon, size: 20, color: const Color(0xFF8E8E93)),
          labelText: label,
          hintText: hint,
          helperText: helperText,
          helperStyle: const TextStyle(fontSize: 11, color: Color(0xFF00B14F)),
          hintStyle: TextStyle(fontSize: 12.5, color: Colors.grey.shade400),
          labelStyle: TextStyle(fontSize: 13, color: Colors.grey.shade600),
          border: InputBorder.none,
          isDense: true,
        ),
        validator: validator,
      ),
    );
  }

  Widget _buildGenderOption(String value, String label, Color color) {
    final isSelected = _selectedGender == value;
    return InkWell(
      onTap: () => setState(() => _selectedGender = value),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.12) : const Color(0xFFF2F2F7),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isSelected ? color : Colors.transparent),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isSelected ? color : Colors.grey.shade600),
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(fontSize: 12, color: isSelected ? color : Colors.grey.shade700, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
            ),
          ],
        ),
      ),
    );
  }
}
