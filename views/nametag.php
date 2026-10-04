<!-- TAB 3: GENERATOR & CETAK NAME TAG QR -->
<div id="tab-nametag" class="space-y-4 hidden">
    <div class="bg-gradient-to-r from-purple-600 to-indigo-600 text-white p-4 rounded-2xl shadow-sm">
        <h2 class="text-base font-bold flex items-center space-x-2">
            <i class="fa-solid fa-id-card"></i>
            <span>Cetak Name Tag & Kartu Pelajar Digital</span>
        </h2>
        <p class="text-xs text-purple-100 mt-1">Pilih siswa untuk menampilkan name tag ber-QR code resolusi tinggi yang siap dicetak.</p>
    </div>

    <div class="bg-white p-4 rounded-2xl border border-gray-200 shadow-sm">
        <label class="block text-xs font-bold text-gray-700 mb-1.5">Pilih Siswa:</label>
        <select id="nameTagStudentSelect" onchange="renderSelectedNameTag(this.value)" class="w-full text-xs border border-gray-300 rounded-xl p-2.5 focus:ring-2 focus:ring-purple-500">
        </select>

        <!-- Preview Kartu Name Tag (Printable ID Card) -->
        <div class="mt-6 flex justify-center">
            <div id="printable-name-tag" class="w-72 bg-gradient-to-b from-emerald-800 via-teal-900 to-gray-900 text-white rounded-3xl p-5 shadow-2xl border-4 border-amber-400 relative overflow-hidden text-center">
                <div class="absolute -top-10 -right-10 w-28 h-28 bg-white/10 rounded-full blur-xl"></div>
                
                <!-- Header Sekolah -->
                <div class="flex items-center justify-center space-x-2 border-b border-white/20 pb-3">
                    <div class="w-8 h-8 bg-amber-400 text-emerald-950 font-black rounded-lg flex items-center justify-center text-sm shadow">
                        MH
                    </div>
                    <div class="text-left">
                        <h4 class="text-xs font-black tracking-wider uppercase text-amber-300">MANBAUL HIKMAH</h4>
                        <p class="text-[9px] text-gray-200">Kartu Pelajar & Presensi Digital</p>
                    </div>
                </div>

                <!-- Foto Avatar Siswa -->
                <div class="mt-4 flex justify-center">
                    <div class="w-20 h-20 rounded-full border-4 border-amber-400 bg-emerald-700 flex items-center justify-center shadow-lg text-amber-200 text-3xl font-bold" id="cardAvatar">
                        A
                    </div>
                </div>

                <!-- Identitas Siswa -->
                <div class="mt-3">
                    <h3 class="text-sm font-extrabold text-white" id="cardStudentName">Ahmad Fauzi</h3>
                    <p class="text-xs text-amber-300 font-semibold" id="cardStudentClass">Kelas 7A</p>
                    <p class="text-[10px] text-gray-300 mt-0.5">NISN: <span id="cardStudentNisn">0081234561</span></p>
                </div>

                <!-- QR Code Container -->
                <div class="mt-4 bg-white p-2.5 rounded-2xl shadow-inner inline-block mx-auto border-2 border-amber-300">
                    <div id="cardQrCode"></div>
                </div>
                <p class="text-[9px] text-amber-200 font-medium mt-1">Scan untuk Presensi & Tabungan</p>

                <!-- Footer -->
                <div class="mt-4 pt-2 border-t border-white/20 text-[9px] text-gray-400 flex justify-between items-center px-1">
                    <span>T.A 2026/2027</span>
                    <span>Official Digital ID</span>
                </div>
            </div>
        </div>

        <!-- Tombol Cetak / Unduh -->
        <div class="mt-5 flex space-x-2">
            <button onclick="window.print()" class="flex-1 bg-purple-600 text-white text-xs font-bold py-2.5 rounded-xl hover:bg-purple-700 transition shadow flex items-center justify-center space-x-2">
                <i class="fa-solid fa-print"></i>
                <span>Cetak Name Tag Ini</span>
            </button>
            <button onclick="showAlertModal({ title: 'Cetak Massal', message: 'Fitur cetak kartu seluruh kelas siap di-export atau dicetak!', type: 'info' })" class="bg-gray-100 text-gray-700 text-xs font-bold px-3 py-2.5 rounded-xl hover:bg-gray-200 transition">
                Cetak 1 Kelas
            </button>
        </div>
    </div>
</div>
