<!-- MODALS -->

<!-- MODAL 1: TRANSAKSI TABUNGAN (SETOR / TARIK) -->
<div id="transactionModal" class="fixed inset-0 bg-black/60 z-50 flex items-center justify-center p-4 hidden">
    <div class="bg-white rounded-3xl p-5 w-full max-w-sm shadow-2xl">
        <div class="flex items-center justify-between pb-3 border-b border-gray-100">
            <h3 class="text-sm font-bold text-gray-800" id="transModalTitle">Setor Tabungan Siswa</h3>
            <button onclick="closeModal('transactionModal')" class="text-gray-400 hover:text-gray-600 text-lg">
                <i class="fa-solid fa-xmark"></i>
            </button>
        </div>

        <div class="mt-4 space-y-3">
            <div>
                <label class="block text-xs font-semibold text-gray-700 mb-1">Pilih Siswa</label>
                <select id="transStudentSelect" class="w-full text-xs border border-gray-300 rounded-xl p-2.5 focus:ring-2 focus:ring-gojek">
                </select>
            </div>

            <div>
                <label class="block text-xs font-semibold text-gray-700 mb-1">Nominal (Rp)</label>
                <input type="number" id="transAmountInput" placeholder="Contoh: 50000" class="w-full text-sm font-bold border border-gray-300 rounded-xl p-2.5 focus:ring-2 focus:ring-gojek">
                <div class="grid grid-cols-4 gap-1.5 mt-2">
                    <button type="button" onclick="setTransAmount(10000)" class="text-[10px] bg-gray-100 font-semibold py-1 rounded-lg hover:bg-gray-200">10rb</button>
                    <button type="button" onclick="setTransAmount(20000)" class="text-[10px] bg-gray-100 font-semibold py-1 rounded-lg hover:bg-gray-200">20rb</button>
                    <button type="button" onclick="setTransAmount(50000)" class="text-[10px] bg-gray-100 font-semibold py-1 rounded-lg hover:bg-gray-200">50rb</button>
                    <button type="button" onclick="setTransAmount(100000)" class="text-[10px] bg-gray-100 font-semibold py-1 rounded-lg hover:bg-gray-200">100rb</button>
                </div>
            </div>

            <div>
                <label class="block text-xs font-semibold text-gray-700 mb-1">Keterangan / Catatan</label>
                <input type="text" id="transNotesInput" placeholder="Contoh: Tabungan rutin mingguan" value="Tabungan rutin" class="w-full text-xs border border-gray-300 rounded-xl p-2.5 focus:ring-2 focus:ring-gojek">
            </div>

            <button onclick="submitTransaction()" id="submitTransBtn" class="w-full bg-gojek text-white text-xs font-bold py-3 rounded-xl hover:bg-gojek-dark shadow transition mt-2">
                Konfirmasi Transaksi
            </button>
        </div>
    </div>
</div>

<!-- MODAL 2: BUKU MUTASI SISWA -->
<div id="passbookModal" class="fixed inset-0 bg-black/60 z-50 flex items-center justify-center p-4 hidden">
    <div class="bg-white rounded-3xl p-5 w-full max-w-md shadow-2xl max-h-[85vh] flex flex-col">
        <div class="flex items-center justify-between pb-3 border-b border-gray-100">
            <div>
                <h3 class="text-sm font-bold text-gray-800" id="passbookStudentName">Buku Mutasi Siswa</h3>
                <p class="text-[11px] text-gray-500" id="passbookSubtitle">Riwayat setor & penarikan</p>
            </div>
            <button onclick="closeModal('passbookModal')" class="text-gray-400 hover:text-gray-600 text-lg">
                <i class="fa-solid fa-xmark"></i>
            </button>
        </div>

        <div class="p-3 bg-green-50 rounded-2xl my-3 text-center border border-green-100">
            <span class="text-xs text-green-700 font-medium">Saldo Tabungan Saat Ini</span>
            <div class="text-xl font-black text-green-800" id="passbookCurrentBalance">Rp 0</div>
        </div>

        <div class="flex-1 overflow-y-auto divide-y divide-gray-100 pr-1" id="passbookHistoryList">
        </div>
    </div>
</div>

<!-- MODAL 3: BUAT PENGUMUMAN KEPSEK -->
<div id="createAnnouncementModal" class="fixed inset-0 bg-black/60 z-50 flex items-center justify-center p-4 hidden">
    <div class="bg-white rounded-3xl p-5 w-full max-w-sm shadow-2xl">
        <div class="flex items-center justify-between pb-3 border-b border-gray-100">
            <h3 class="text-sm font-bold text-gray-800">Buat Pengumuman Baru (Kepsek)</h3>
            <button onclick="closeModal('createAnnouncementModal')" class="text-gray-400 hover:text-gray-600 text-lg">
                <i class="fa-solid fa-xmark"></i>
            </button>
        </div>

        <div class="mt-4 space-y-3">
            <div>
                <label class="block text-xs font-semibold text-gray-700 mb-1">Target Penerima</label>
                <select id="annTargetSelect" class="w-full text-xs border border-gray-300 rounded-xl p-2.5 focus:ring-2 focus:ring-rose-500">
                    <option value="all">Semua (Guru & Wali Murid)</option>
                    <option value="teachers">Khusus Dewan Guru & Wali Kelas</option>
                    <option value="parents">Khusus Seluruh Wali Murid</option>
                </select>
            </div>

            <div>
                <label class="block text-xs font-semibold text-gray-700 mb-1">Kategori</label>
                <select id="annCategorySelect" class="w-full text-xs border border-gray-300 rounded-xl p-2.5 focus:ring-2 focus:ring-rose-500">
                    <option value="Akademik">Akademik & Ujian</option>
                    <option value="Kegiatan">Kegiatan Pesantren / Sekolah</option>
                    <option value="Libur">Informasi Libur</option>
                    <option value="Administrasi">Administrasi / Tabungan</option>
                </select>
            </div>

            <div>
                <label class="block text-xs font-semibold text-gray-700 mb-1">Judul Pengumuman</label>
                <input type="text" id="annTitleInput" placeholder="Contoh: Pelaksanaan Ujian Semester" class="w-full text-xs border border-gray-300 rounded-xl p-2.5 focus:ring-2 focus:ring-rose-500">
            </div>

            <div>
                <label class="block text-xs font-semibold text-gray-700 mb-1">Isi Pesan</label>
                <textarea id="annContentInput" rows="3" placeholder="Tulis rincian pengumuman..." class="w-full text-xs border border-gray-300 rounded-xl p-2.5 focus:ring-2 focus:ring-rose-500"></textarea>
            </div>

            <button onclick="submitAnnouncement()" class="w-full bg-rose-600 text-white text-xs font-bold py-3 rounded-xl hover:bg-rose-700 shadow transition">
                Publikasikan Pengumuman
            </button>
        </div>
    </div>
</div>

<!-- MODAL 4: TAMBAH SISWA BARU -->
<div id="addStudentModal" class="fixed inset-0 bg-black/60 z-50 flex items-center justify-center p-4 hidden">
    <div class="bg-white rounded-3xl p-5 w-full max-w-sm shadow-2xl">
        <div class="flex items-center justify-between pb-3 border-b border-gray-100">
            <h3 class="text-sm font-bold text-gray-800">Tambah Siswa Baru</h3>
            <button onclick="closeModal('addStudentModal')" class="text-gray-400 hover:text-gray-600 text-lg">
                <i class="fa-solid fa-xmark"></i>
            </button>
        </div>

        <div class="mt-4 space-y-2.5">
            <div>
                <label class="block text-[11px] font-semibold text-gray-700 mb-0.5">NISN (10 Digit)</label>
                <input type="text" id="newNisnInput" placeholder="0081234599" class="w-full text-xs border border-gray-300 rounded-xl p-2">
            </div>
            <div>
                <label class="block text-[11px] font-semibold text-gray-700 mb-0.5">Nama Lengkap Siswa</label>
                <input type="text" id="newNameInput" placeholder="Nama Murid" class="w-full text-xs border border-gray-300 rounded-xl p-2">
            </div>
            <div class="grid grid-cols-2 gap-2">
                <div>
                    <label class="block text-[11px] font-semibold text-gray-700 mb-0.5">Kelas</label>
                    <select id="newClassInput" class="w-full text-xs border border-gray-300 rounded-xl p-2">
                        <option value="Kelas 7A">Kelas 7A</option>
                        <option value="Kelas 7B">Kelas 7B</option>
                        <option value="Kelas 8A">Kelas 8A</option>
                        <option value="Kelas 9A">Kelas 9A</option>
                    </select>
                </div>
                <div>
                    <label class="block text-[11px] font-semibold text-gray-700 mb-0.5">Jenis Kelamin</label>
                    <select id="newGenderInput" class="w-full text-xs border border-gray-300 rounded-xl p-2">
                        <option value="L">Laki-laki</option>
                        <option value="P">Perempuan</option>
                    </select>
                </div>
            </div>
            <div>
                <label class="block text-[11px] font-semibold text-gray-700 mb-0.5">Nama Wali Murid</label>
                <input type="text" id="newParentNameInput" placeholder="Nama Orang Tua" class="w-full text-xs border border-gray-300 rounded-xl p-2">
            </div>
            <div>
                <label class="block text-[11px] font-semibold text-gray-700 mb-0.5">No. WhatsApp Wali</label>
                <input type="text" id="newParentPhoneInput" placeholder="0812xxxxxxxx" class="w-full text-xs border border-gray-300 rounded-xl p-2">
            </div>

            <button onclick="submitNewStudent()" class="w-full bg-blue-600 text-white text-xs font-bold py-2.5 rounded-xl hover:bg-blue-700 shadow transition mt-1">
                Simpan & Generate QR Name Tag
            </button>
        </div>
    </div>
</div>

<!-- MODAL 5: INFO & PENGATURAN -->
<div id="infoModal" class="fixed inset-0 bg-black/60 z-50 flex items-center justify-center p-4 hidden">
    <div class="bg-white rounded-3xl p-5 w-full max-w-sm shadow-2xl">
        <div class="flex items-center justify-between pb-3 border-b border-gray-100">
            <h3 class="text-sm font-bold text-gray-800">Manbaul Hikmah Mobile</h3>
            <button onclick="closeModal('infoModal')" class="text-gray-400 hover:text-gray-600 text-lg">
                <i class="fa-solid fa-xmark"></i>
            </button>
        </div>

        <div class="mt-4 text-xs text-gray-600 space-y-3">
            <div class="p-3 bg-gray-50 rounded-xl">
                <p class="font-bold text-gray-800">Versi: 1.0.0 (Release Build)</p>
                <p class="text-[11px] text-gray-500 mt-0.5">Framework: Flutter Cross-Platform & Laragon PHP/MySQL Backend</p>
            </div>

            <p>Aplikasi ini dirancang untuk memudahkan absensi berbasis QR Code Name Tag, pengelolaan tabungan santri/siswa, serta jalur komunikasi langsung dari Kepala Sekolah ke Wali Kelas dan Wali Murid.</p>

            <div class="pt-2 border-t border-gray-100 flex flex-col space-y-2">
                <button onclick="downloadBackupJson()" class="w-full bg-gray-800 text-white font-bold py-2 rounded-xl text-xs hover:bg-black transition">
                    <i class="fa-solid fa-download mr-1"></i> Backup Data (JSON)
                </button>
                <button onclick="closeModal('infoModal')" class="w-full bg-gray-100 text-gray-700 font-bold py-2 rounded-xl text-xs hover:bg-gray-200 transition">
                    Tutup
                </button>
            </div>
        </div>
    </div>
</div>
