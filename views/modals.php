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

<!-- MODAL 6: PROFIL SEKOLAH & REKENING RESMI (KEPSEK & TU) -->
<div id="schoolProfileModal" class="fixed inset-0 bg-black/60 z-50 flex items-center justify-center p-4 hidden">
    <div class="bg-white rounded-3xl p-5 w-full max-w-lg shadow-2xl max-h-[90vh] flex flex-col">
        <div class="flex items-center justify-between pb-3 border-b border-gray-100">
            <div>
                <h3 class="text-sm font-bold text-gray-800 flex items-center space-x-2">
                    <i class="fa-solid fa-school text-emerald-600"></i>
                    <span>Profil & Rekening Resmi Lembaga</span>
                </h3>
                <p class="text-[11px] text-gray-500">Identitas Sekolah, Kontak TU & Rekening Pembayaran</p>
            </div>
            <button onclick="closeModal('schoolProfileModal')" class="text-gray-400 hover:text-gray-600 text-lg">
                <i class="fa-solid fa-xmark"></i>
            </button>
        </div>

        <div class="flex-1 overflow-y-auto pr-1 mt-3 space-y-3.5 text-xs text-gray-700">
            <!-- Role Access Notice -->
            <div id="profileAccessNotice" class="p-2.5 bg-emerald-50 border border-emerald-100 rounded-xl flex items-center justify-between">
                <span class="text-[11px] text-emerald-800 font-medium flex items-center space-x-1.5">
                    <i class="fa-solid fa-shield-halved text-emerald-600"></i>
                    <span id="profileAccessRoleLabel">Mode Edit: Kepala Sekolah & Staff TU</span>
                </span>
                <span class="text-[10px] bg-emerald-200/60 text-emerald-800 font-bold px-2 py-0.5 rounded-full" id="profileRoleBadge">Staff TU</span>
            </div>

            <!-- Identitas Lembaga -->
            <div class="bg-gray-50 p-3 rounded-2xl border border-gray-100 space-y-2">
                <h4 class="font-bold text-gray-800 flex items-center space-x-1">
                    <i class="fa-solid fa-landmark text-gray-500"></i>
                    <span>Identitas Lembaga</span>
                </h4>
                <div>
                    <label class="block text-[11px] font-semibold text-gray-600 mb-0.5">Nama Sekolah</label>
                    <input type="text" id="profSchoolName" class="w-full text-xs border border-gray-300 rounded-xl p-2 bg-white focus:ring-2 focus:ring-emerald-500 font-semibold">
                </div>
                <div class="grid grid-cols-2 gap-2">
                    <div>
                        <label class="block text-[11px] font-semibold text-gray-600 mb-0.5">NPSN</label>
                        <input type="text" id="profNpsn" class="w-full text-xs border border-gray-300 rounded-xl p-2 bg-white focus:ring-2 focus:ring-emerald-500">
                    </div>
                    <div>
                        <label class="block text-[11px] font-semibold text-gray-600 mb-0.5">Telepon Kantor</label>
                        <input type="text" id="profPhone" class="w-full text-xs border border-gray-300 rounded-xl p-2 bg-white focus:ring-2 focus:ring-emerald-500">
                    </div>
                </div>
                <div>
                    <label class="block text-[11px] font-semibold text-gray-600 mb-0.5">Alamat Lengkap</label>
                    <textarea id="profAddress" rows="2" class="w-full text-xs border border-gray-300 rounded-xl p-2 bg-white focus:ring-2 focus:ring-emerald-500"></textarea>
                </div>
            </div>

            <!-- Rekening Bank & WhatsApp TU -->
            <div class="bg-emerald-50/50 p-3 rounded-2xl border border-emerald-100 space-y-2">
                <h4 class="font-bold text-emerald-900 flex items-center space-x-1">
                    <i class="fa-solid fa-building-columns text-emerald-600"></i>
                    <span>Rekening Resmi Pembayaran & WhatsApp TU</span>
                </h4>
                <div class="grid grid-cols-2 gap-2">
                    <div>
                        <label class="block text-[11px] font-semibold text-gray-600 mb-0.5">WhatsApp Resmi TU</label>
                        <input type="text" id="profTuWhatsapp" placeholder="6281234567890" class="w-full text-xs border border-gray-300 rounded-xl p-2 bg-white focus:ring-2 focus:ring-emerald-500 font-mono">
                    </div>
                    <div>
                        <label class="block text-[11px] font-semibold text-gray-600 mb-0.5">Nama Bendahara / TU</label>
                        <input type="text" id="profTuName" class="w-full text-xs border border-gray-300 rounded-xl p-2 bg-white focus:ring-2 focus:ring-emerald-500">
                    </div>
                </div>

                <!-- Bank 1 (BSI) -->
                <div class="p-2.5 bg-white rounded-xl border border-gray-200 space-y-1.5">
                    <span class="text-[11px] font-bold text-emerald-700 block">Rekening Utama (Bank 1)</span>
                    <div class="grid grid-cols-2 gap-2">
                        <input type="text" id="profBankName1" placeholder="Bank Syariah Indonesia" class="w-full text-xs border border-gray-200 rounded-lg p-1.5 font-medium">
                        <input type="text" id="profBankAcc1" placeholder="Nomor Rekening" class="w-full text-xs border border-gray-200 rounded-lg p-1.5 font-mono font-bold text-gray-800">
                    </div>
                    <input type="text" id="profBankHolder1" placeholder="Nama Pemilik Rekening (A.n)" class="w-full text-xs border border-gray-200 rounded-lg p-1.5 text-gray-600">
                </div>

                <!-- Bank 2 (Mandiri) -->
                <div class="p-2.5 bg-white rounded-xl border border-gray-200 space-y-1.5">
                    <span class="text-[11px] font-bold text-blue-700 block">Rekening Cadangan (Bank 2)</span>
                    <div class="grid grid-cols-2 gap-2">
                        <input type="text" id="profBankName2" placeholder="Bank Mandiri" class="w-full text-xs border border-gray-200 rounded-lg p-1.5 font-medium">
                        <input type="text" id="profBankAcc2" placeholder="Nomor Rekening" class="w-full text-xs border border-gray-200 rounded-lg p-1.5 font-mono font-bold text-gray-800">
                    </div>
                    <input type="text" id="profBankHolder2" placeholder="Nama Pemilik Rekening (A.n)" class="w-full text-xs border border-gray-200 rounded-lg p-1.5 text-gray-600">
                </div>
            </div>

            <!-- Pimpinan Sekolah -->
            <div class="bg-gray-50 p-3 rounded-2xl border border-gray-100 space-y-2">
                <h4 class="font-bold text-gray-800 flex items-center space-x-1">
                    <i class="fa-solid fa-user-tie text-gray-500"></i>
                    <span>Kepala Sekolah</span>
                </h4>
                <div class="grid grid-cols-2 gap-2">
                    <div>
                        <label class="block text-[11px] font-semibold text-gray-600 mb-0.5">Nama Kepala Sekolah</label>
                        <input type="text" id="profKepsekName" class="w-full text-xs border border-gray-300 rounded-xl p-2 bg-white focus:ring-2 focus:ring-emerald-500 font-semibold">
                    </div>
                    <div>
                        <label class="block text-[11px] font-semibold text-gray-600 mb-0.5">NIP / NIY</label>
                        <input type="text" id="profKepsekNip" class="w-full text-xs border border-gray-300 rounded-xl p-2 bg-white focus:ring-2 focus:ring-emerald-500">
                    </div>
                </div>
            </div>
        </div>

        <!-- MaoneArt Symmetrical 2-Column Buttons -->
        <div class="grid grid-cols-2 gap-3 w-full mt-4 pt-3 border-t border-gray-100">
            <button onclick="closeModal('schoolProfileModal')" class="w-full py-2.5 px-4 rounded-xl border border-gray-300 text-gray-700 font-bold text-xs hover:bg-gray-100 transition text-center">
                Tutup
            </button>
            <button onclick="saveSchoolProfile()" id="btnSaveSchoolProfile" class="w-full py-2.5 px-4 rounded-xl bg-emerald-600 text-white font-bold text-xs hover:bg-emerald-700 shadow-md transition text-center">
                Simpan Profil
            </button>
        </div>
    </div>
</div>

<!-- MODAL 7: KONFIRMASI PEMBAYARAN TAGIHAN (WALI MURID & TU) -->
<div id="billPaymentModal" class="fixed inset-0 bg-black/60 z-50 flex items-center justify-center p-4 hidden">
    <div class="bg-white rounded-3xl p-5 w-full max-w-sm shadow-2xl">
        <div class="flex items-center justify-between pb-3 border-b border-gray-100">
            <div>
                <h3 class="text-sm font-bold text-gray-800">Pembayaran Tagihan Sekolah</h3>
                <p class="text-[11px] text-gray-500" id="payModalBillSubtitle">SPP Bulanan</p>
            </div>
            <button onclick="closeModal('billPaymentModal')" class="text-gray-400 hover:text-gray-600 text-lg">
                <i class="fa-solid fa-xmark"></i>
            </button>
        </div>

        <input type="hidden" id="payModalBillId" value="0">

        <!-- Total Tagihan Card -->
        <div class="p-3.5 bg-emerald-50 border border-emerald-100 rounded-2xl my-3 flex items-center justify-between">
            <div>
                <span class="text-[11px] text-emerald-800 font-semibold block">Total yang Harus Dibayar</span>
                <span class="text-xs text-gray-500" id="payModalStudentName">Nama Siswa</span>
            </div>
            <div class="text-lg font-black text-emerald-700" id="payModalAmountText">Rp 0</div>
        </div>

        <!-- Pilihan Metode Pembayaran -->
        <div class="space-y-2 mt-2">
            <label class="block text-xs font-bold text-gray-700 mb-1">Pilih Metode Pembayaran</label>

            <!-- 1. Transfer Bank (Rekomendasi) -->
            <label class="flex items-start p-2.5 border border-emerald-200 bg-emerald-50/40 rounded-xl cursor-pointer hover:bg-emerald-50 transition">
                <input type="radio" name="payMethodOption" value="Transfer Bank" checked onchange="togglePayMethodView('transfer')" class="mt-0.5 text-emerald-600 focus:ring-emerald-500">
                <div class="ml-2.5 text-xs flex-1">
                    <span class="font-bold text-gray-800 block">Transfer Bank Syariah (BSI / Mandiri)</span>
                    <span class="text-[11px] text-gray-500">Kirim bukti transfer ke WhatsApp TU sekolah</span>
                </div>
            </label>

            <!-- 2. Tunai di TU -->
            <label class="flex items-start p-2.5 border border-gray-200 bg-white rounded-xl cursor-pointer hover:bg-gray-50 transition">
                <input type="radio" name="payMethodOption" value="Tunai di TU" onchange="togglePayMethodView('tunai')" class="mt-0.5 text-emerald-600 focus:ring-emerald-500">
                <div class="ml-2.5 text-xs flex-1">
                    <span class="font-bold text-gray-800 block">Tunai di Loket TU</span>
                    <span class="text-[11px] text-gray-500">Bayar langsung di loket Tata Usaha sekolah</span>
                </div>
            </label>

            <!-- 3. EduPay Tabungan -->
            <label class="flex items-start p-2.5 border border-gray-200 bg-white rounded-xl cursor-pointer hover:bg-gray-50 transition">
                <input type="radio" name="payMethodOption" value="EduPay Tabungan" onchange="togglePayMethodView('edupay')" class="mt-0.5 text-emerald-600 focus:ring-emerald-500">
                <div class="ml-2.5 text-xs flex-1">
                    <span class="font-bold text-gray-800 block">EduPay Saldo Tabungan</span>
                    <span class="text-[11px] text-gray-500" id="payModalEduPayBalance">Potong langsung saldo tabungan siswa</span>
                </div>
            </label>
        </div>

        <!-- Dynamic Method Instructions Container -->
        <div id="payTransferInstructions" class="mt-3 p-3 bg-gray-50 rounded-xl border border-gray-200 text-xs space-y-1.5">
            <span class="font-bold text-gray-800 block text-[11px]">Rekening Tujuan:</span>
            <div class="flex items-center justify-between font-mono bg-white p-2 rounded-lg border border-gray-100">
                <span class="text-emerald-700 font-bold" id="payModalBank1">BSI: 7188299102</span>
                <button onclick="copyAccountNo('payModalBank1')" class="text-emerald-600 text-[10px] font-bold hover:underline">Salin</button>
            </div>
            <p class="text-[10px] text-gray-500 leading-tight">
                *Setelah klik tombol di bawah, WhatsApp TU sekolah akan terbuka otomatis dengan format pesan siap kirim.
            </p>
        </div>

        <div id="payTunaiInstructions" class="mt-3 p-3 bg-gray-50 rounded-xl border border-gray-200 text-xs hidden">
            <p class="text-[11px] text-gray-600 leading-relaxed">
                Pembayaran tunai dilakukan langsung di loket Tata Usaha sekolah (Senin - Jumat, 07:00 - 15:00 WIB). Petugas TU akan mencetak kuitansi lunas untuk Anda.
            </p>
        </div>

        <div id="payEduPayInstructions" class="mt-3 p-3 bg-gray-50 rounded-xl border border-gray-200 text-xs hidden">
            <p class="text-[11px] text-gray-600 leading-relaxed">
                Saldo tabungan siswa akan otomatis terpotong sejumlah tagihan dan kuitansi lunas langsung terbit.
            </p>
        </div>

        <!-- MaoneArt Symmetrical 2-Column Buttons -->
        <div class="grid grid-cols-2 gap-3 w-full mt-4 pt-3 border-t border-gray-100">
            <button onclick="closeModal('billPaymentModal')" class="w-full py-2.5 px-4 rounded-xl border border-gray-300 text-gray-700 font-bold text-xs hover:bg-gray-100 transition text-center">
                Batal
            </button>
            <button onclick="executeBillPayment()" id="btnSubmitBillPayment" class="w-full py-2.5 px-4 rounded-xl bg-emerald-600 text-white font-bold text-xs hover:bg-emerald-700 shadow-md transition text-center flex items-center justify-center space-x-1.5">
                <i class="fa-brands fa-whatsapp text-sm" id="payBtnIcon"></i>
                <span id="payBtnText">Kirim Bukti WA</span>
            </button>
        </div>
    </div>
</div>

<!-- MODAL 8: VERIFIKASI PEMBAYARAN TU -->
<div id="verifyBillModal" class="fixed inset-0 bg-black/60 z-50 flex items-center justify-center p-4 hidden">
    <div class="bg-white rounded-3xl p-5 w-full max-w-sm shadow-2xl">
        <div class="flex items-center justify-between pb-3 border-b border-gray-100">
            <div>
                <h3 class="text-sm font-bold text-gray-800">Verifikasi Pembayaran TU</h3>
                <p class="text-[11px] text-gray-500">Pencocokan Mutasi Bank & Status Lunas</p>
            </div>
            <button onclick="closeModal('verifyBillModal')" class="text-gray-400 hover:text-gray-600 text-lg">
                <i class="fa-solid fa-xmark"></i>
            </button>
        </div>

        <input type="hidden" id="verifyModalBillId" value="0">

        <div class="mt-3 p-3 bg-amber-50 border border-amber-200 rounded-2xl text-xs space-y-2">
            <div class="flex items-center space-x-2 text-amber-800 font-bold">
                <i class="fa-solid fa-circle-exclamation text-amber-600"></i>
                <span>Menunggu Verifikasi Mutasi Rekening</span>
            </div>
            <div class="bg-white p-2.5 rounded-xl border border-amber-100 space-y-1">
                <div class="flex justify-between text-gray-600">
                    <span>Siswa:</span>
                    <span class="font-bold text-gray-800" id="verifyStudentName">-</span>
                </div>
                <div class="flex justify-between text-gray-600">
                    <span>Kelas:</span>
                    <span class="font-bold text-gray-800" id="verifyClassName">-</span>
                </div>
                <div class="flex justify-between text-gray-600">
                    <span>Tagihan:</span>
                    <span class="font-bold text-gray-800" id="verifyCategoryName">-</span>
                </div>
                <div class="flex justify-between text-gray-600 border-t border-gray-100 pt-1">
                    <span>Nominal:</span>
                    <span class="font-black text-emerald-700 text-sm" id="verifyAmountText">Rp 0</span>
                </div>
            </div>
            <p class="text-[11px] text-gray-500 leading-tight">
                Pastikan dana sudah benar-benar masuk ke rekening resmi sekolah (BSI / Mandiri) atau telah diterima secara tunai di loket TU sebelum memverifikasi.
            </p>
        </div>

        <!-- Symmetrical 2-Column Buttons -->
        <div class="grid grid-cols-2 gap-3 w-full mt-4 pt-3 border-t border-gray-100">
            <button onclick="closeModal('verifyBillModal')" class="w-full py-2.5 px-4 rounded-xl border border-gray-300 text-gray-700 font-bold text-xs hover:bg-gray-100 transition text-center">
                Batal
            </button>
            <button onclick="confirmBillLunas()" class="w-full py-2.5 px-4 rounded-xl bg-emerald-600 text-white font-bold text-xs hover:bg-emerald-700 shadow-md transition text-center">
                Verifikasi Lunas
            </button>
        </div>
    </div>
</div>

<!-- MODAL 9: KUITANSI PEMBAYARAN RESMI -->
<div id="billReceiptModal" class="fixed inset-0 bg-black/60 z-50 flex items-center justify-center p-4 hidden">
    <div class="bg-white rounded-3xl p-5 w-full max-w-md shadow-2xl max-h-[95vh] flex flex-col">
        <div class="flex items-center justify-between pb-3 border-b border-gray-100">
            <div class="flex items-center space-x-2">
                <div class="w-8 h-8 rounded-xl bg-emerald-100 text-emerald-600 flex items-center justify-center text-sm shadow-sm">
                    <i class="fa-solid fa-receipt"></i>
                </div>
                <div>
                    <h3 class="text-sm font-bold text-gray-800">Kuitansi Pembayaran Sah</h3>
                    <p class="text-[10px] text-gray-400" id="receiptInvoiceNo">INV-MH-20261001-0001</p>
                </div>
            </div>
            <button onclick="closeModal('billReceiptModal')" class="text-gray-400 hover:text-gray-600 text-lg">
                <i class="fa-solid fa-xmark"></i>
            </button>
        </div>

        <!-- Receipt Card Container (Printable Formal Letterhead & Receipt) -->
        <div class="my-3 p-4 bg-gray-50 rounded-2xl border border-gray-200 text-xs space-y-3 font-sans overflow-y-auto" id="printableReceiptCard">
            <!-- Kop Surat Resmi -->
            <div class="text-center pb-2 border-b-2 border-double border-gray-800">
                <h3 class="font-black text-sm text-gray-900 tracking-wide uppercase" id="receiptSchoolName">SDIT MANBAUL HIKMAH</h3>
                <p class="text-[10px] text-gray-600 leading-tight mt-0.5" id="receiptSchoolAddr">Jl. KH. Noer Ali No. 45, Karang Satria, Tambun Utara, Bekasi, Jawa Barat</p>
                <div class="text-[9px] text-gray-500 font-medium mt-0.5 flex items-center justify-center space-x-2">
                    <span id="receiptSchoolNpsn">NPSN: 20260001</span>
                    <span>•</span>
                    <span id="receiptSchoolPhone">Telp: 021-88997766</span>
                </div>
            </div>

            <div class="text-center pt-1">
                <span class="inline-block px-3 py-0.5 bg-emerald-100 text-emerald-900 font-black text-[11px] rounded tracking-wider uppercase border border-emerald-300">
                    TANDA BUKTI PEMBAYARAN SAH
                </span>
            </div>

            <!-- Detail Transaksi -->
            <div class="space-y-1.5 text-[11px] pt-1">
                <div class="flex justify-between py-0.5 border-b border-gray-100">
                    <span class="text-gray-500">Nomor Transaksi:</span>
                    <span class="font-mono font-bold text-gray-800" id="receiptInvoiceDetail">-</span>
                </div>
                <div class="flex justify-between py-0.5 border-b border-gray-100">
                    <span class="text-gray-500">Nama Siswa / Santri:</span>
                    <span class="font-bold text-gray-900" id="receiptStudentName">-</span>
                </div>
                <div class="flex justify-between py-0.5 border-b border-gray-100">
                    <span class="text-gray-500">Kelas / Rombel:</span>
                    <span class="font-bold text-gray-800" id="receiptClassName">-</span>
                </div>
                <div class="flex justify-between py-0.5 border-b border-gray-100">
                    <span class="text-gray-500">Uraian Pembayaran:</span>
                    <span class="font-bold text-gray-800" id="receiptCategory">-</span>
                </div>
                <div class="flex justify-between py-0.5 border-b border-gray-100">
                    <span class="text-gray-500">Metode Bayar:</span>
                    <span class="font-bold text-emerald-700" id="receiptMethod">-</span>
                </div>
                <div class="flex justify-between py-0.5 border-b border-gray-100">
                    <span class="text-gray-500">Waktu Pembayaran:</span>
                    <span class="font-semibold text-gray-700" id="receiptPaidDate">-</span>
                </div>
                <div class="flex justify-between py-0.5">
                    <span class="text-gray-500">Status Pembayaran:</span>
                    <span class="inline-flex items-center text-emerald-700 font-black tracking-wide">
                        <i class="fa-solid fa-circle-check text-xs mr-1"></i> LUNAS (TERVERIFIKASI)
                    </span>
                </div>
            </div>

            <!-- Total Box -->
            <div class="bg-gradient-to-r from-emerald-600 to-emerald-700 text-white p-2.5 rounded-xl text-center shadow-inner">
                <span class="text-[10px] uppercase tracking-wider block opacity-90 font-medium">TOTAL NOMINAL DITERIMA</span>
                <span class="text-lg font-black tracking-tight" id="receiptAmount">Rp 0</span>
            </div>

            <!-- Kolom Tanda Tangan & Cap Sah -->
            <div class="pt-3 border-t border-dashed border-gray-300 grid grid-cols-2 gap-2 text-center text-[10px]">
                <div>
                    <span class="text-gray-500 block">Penyetor / Wali Murid</span>
                    <div class="h-10 flex items-center justify-center">
                        <span class="text-[9px] text-gray-400 italic">( Tanda Tangan )</span>
                    </div>
                    <span class="font-bold text-gray-800 border-t border-gray-300 pt-0.5 block mx-2" id="receiptSignStudent">Wali Murid</span>
                </div>
                <div>
                    <span class="text-gray-500 block">Petugas Tata Usaha</span>
                    <div class="h-10 flex items-center justify-center">
                        <span class="text-[9px] text-emerald-700 font-black tracking-widest border border-emerald-400 px-1 py-0.5 rounded bg-emerald-50/50 uppercase">SAH • LUNAS</span>
                    </div>
                    <span class="font-bold text-gray-800 border-t border-gray-300 pt-0.5 block mx-2" id="receiptVerifiedBy">Staff TU</span>
                </div>
            </div>
        </div>

        <!-- MaoneArt Symmetrical 2-Column Buttons -->
        <div class="grid grid-cols-2 gap-3 w-full mt-3 pt-2 border-t border-gray-100">
            <button onclick="closeModal('billReceiptModal')" class="w-full py-2.5 px-4 rounded-xl border border-gray-300 text-gray-700 font-bold text-xs hover:bg-gray-100 transition text-center">
                Tutup
            </button>
            <button onclick="printReceiptPdf()" class="w-full py-2.5 px-4 rounded-xl bg-gray-900 text-white font-bold text-xs hover:bg-black transition text-center flex items-center justify-center space-x-1.5 shadow-md">
                <i class="fa-solid fa-file-pdf text-rose-400"></i>
                <span>Cetak / Simpan PDF</span>
            </button>
        </div>
    </div>
</div>

