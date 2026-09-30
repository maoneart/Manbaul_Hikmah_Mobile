<!-- TAB 2: PRESENSI & SCANNER QR -->
<div id="tab-presensi" class="space-y-4 hidden">
    <div class="bg-gradient-to-r from-gojek to-emerald-600 text-white p-4 rounded-2xl shadow-sm">
        <h2 class="text-base font-bold flex items-center space-x-2">
            <i class="fa-solid fa-camera"></i>
            <span>Pemindai Presensi QR</span>
        </h2>
        <p class="text-xs text-green-100 mt-1">Arahkan kamera ke QR Code Name Tag siswa atau gunakan simulasi scan instan.</p>
    </div>

    <!-- Camera Container -->
    <div class="bg-white p-4 rounded-2xl border border-gray-200 shadow-sm text-center">
        <div id="reader" class="w-full max-w-sm mx-auto overflow-hidden rounded-xl border-2 border-dashed border-gray-300"></div>

        <div class="flex flex-wrap items-center justify-center gap-2 mt-3">
            <button onclick="startQrScanner()" id="startCamBtn" class="bg-gojek text-white text-xs font-semibold px-4 py-2 rounded-xl hover:bg-gojek-dark shadow transition flex items-center space-x-1.5">
                <i class="fa-solid fa-video"></i>
                <span>Buka Kamera Scan</span>
            </button>
            <button onclick="stopQrScanner()" id="stopCamBtn" class="bg-red-500 text-white text-xs font-semibold px-4 py-2 rounded-xl hover:bg-red-600 shadow transition hidden flex items-center space-x-1.5">
                <i class="fa-solid fa-video-slash"></i>
                <span>Tutup Kamera</span>
            </button>
        </div>

        <!-- Shortcut: Simulasi Scan Siswa -->
        <div class="mt-4 p-3 bg-gray-50 rounded-xl border border-gray-200 text-left">
            <label class="block text-xs font-bold text-gray-700 mb-1">
                <i class="fa-solid fa-wand-magic-sparkles text-purple-600"></i> Tes Simulasi Scan Siswa (Tanpa Kamera Fisik):
            </label>
            <div class="flex space-x-2">
                <select id="simulatedStudentSelect" class="flex-1 text-xs border border-gray-300 rounded-lg p-2 focus:ring-1 focus:ring-gojek">
                </select>
                <button onclick="simulateScanSelected()" class="bg-purple-600 text-white text-xs font-bold px-3 py-2 rounded-lg hover:bg-purple-700 transition">
                    Scan!
                </button>
            </div>
        </div>

        <!-- Scan Result Feedback Box -->
        <div id="scanResultBox" class="mt-3 p-3 rounded-xl border hidden transition"></div>
    </div>

    <!-- Daftar Presensi Hari Ini & Pengaturan Manual (S/I/A) -->
    <div class="bg-white p-4 rounded-2xl border border-gray-200 shadow-sm">
        <div class="flex items-center justify-between mb-3">
            <h3 class="text-sm font-bold text-gray-800">Daftar Kehadiran Siswa Hari Ini</h3>
            <span class="text-xs text-gray-500 font-medium" id="attendanceClassLabel">Kelas 7A</span>
        </div>

        <div class="overflow-x-auto">
            <table class="w-full text-left text-xs">
                <thead class="bg-gray-50 text-gray-600 uppercase font-semibold">
                    <tr>
                        <th class="p-2">Siswa</th>
                        <th class="p-2">Status</th>
                        <th class="p-2 text-center">Ubah Manual</th>
                    </tr>
                </thead>
                <tbody id="attendanceTableBody" class="divide-y divide-gray-100">
                    <!-- Populated via JS -->
                </tbody>
            </table>
        </div>
    </div>
</div>
