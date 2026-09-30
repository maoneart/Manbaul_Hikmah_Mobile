<!-- TAB 1: BERANDA / DASHBOARD -->
<div id="tab-beranda" class="space-y-6">
    <!-- 8-Grid Menu Layanan Sekolah (Ala Gojek) -->
    <div>
        <div class="flex items-center justify-between mb-3 px-1">
            <h2 class="text-sm font-bold text-gray-800">Layanan Manbaul Hikmah</h2>
            <span class="text-xs text-gojek font-semibold cursor-pointer">Fitur Unggulan</span>
        </div>

        <div class="grid grid-cols-4 gap-y-4 gap-x-2 text-center">
            <div onclick="openTab('presensi')" class="flex flex-col items-center cursor-pointer group">
                <div class="w-14 h-14 bg-gradient-to-tr from-green-500 to-emerald-400 text-white rounded-2xl flex items-center justify-center shadow-md group-hover:scale-105 transition">
                    <i class="fa-solid fa-camera text-xl"></i>
                </div>
                <span class="text-[11px] font-medium text-gray-700 mt-1.5 leading-tight">Presensi QR</span>
            </div>

            <div onclick="openTab('siswa')" class="flex flex-col items-center cursor-pointer group">
                <div class="w-14 h-14 bg-gradient-to-tr from-blue-500 to-cyan-400 text-white rounded-2xl flex items-center justify-center shadow-md group-hover:scale-105 transition">
                    <i class="fa-solid fa-user-graduate text-xl"></i>
                </div>
                <span class="text-[11px] font-medium text-gray-700 mt-1.5 leading-tight">Data Siswa</span>
            </div>

            <div onclick="openTab('nametag')" class="flex flex-col items-center cursor-pointer group">
                <div class="w-14 h-14 bg-gradient-to-tr from-purple-500 to-indigo-400 text-white rounded-2xl flex items-center justify-center shadow-md group-hover:scale-105 transition">
                    <i class="fa-solid fa-id-card-clip text-xl"></i>
                </div>
                <span class="text-[11px] font-medium text-gray-700 mt-1.5 leading-tight">Kartu QR</span>
            </div>

            <div onclick="openTab('tabungan')" class="flex flex-col items-center cursor-pointer group">
                <div class="w-14 h-14 bg-gradient-to-tr from-amber-500 to-yellow-400 text-white rounded-2xl flex items-center justify-center shadow-md group-hover:scale-105 transition">
                    <i class="fa-solid fa-piggy-bank text-xl"></i>
                </div>
                <span class="text-[11px] font-medium text-gray-700 mt-1.5 leading-tight">Tabungan</span>
            </div>

            <div onclick="openTab('pengumuman')" class="flex flex-col items-center cursor-pointer group">
                <div class="w-14 h-14 bg-gradient-to-tr from-rose-500 to-pink-400 text-white rounded-2xl flex items-center justify-center shadow-md group-hover:scale-105 transition">
                    <i class="fa-solid fa-bullhorn text-xl"></i>
                </div>
                <span class="text-[11px] font-medium text-gray-700 mt-1.5 leading-tight">Pengumuman</span>
            </div>

            <div onclick="openTab('kalender')" class="flex flex-col items-center cursor-pointer group">
                <div class="w-14 h-14 bg-gradient-to-tr from-teal-500 to-emerald-400 text-white rounded-2xl flex items-center justify-center shadow-md group-hover:scale-105 transition">
                    <i class="fa-solid fa-calendar-days text-xl"></i>
                </div>
                <span class="text-[11px] font-medium text-gray-700 mt-1.5 leading-tight">Kalender</span>
            </div>

            <div onclick="openTab('rekap')" class="flex flex-col items-center cursor-pointer group">
                <div class="w-14 h-14 bg-gradient-to-tr from-orange-500 to-amber-400 text-white rounded-2xl flex items-center justify-center shadow-md group-hover:scale-105 transition">
                    <i class="fa-solid fa-chart-pie text-xl"></i>
                </div>
                <span class="text-[11px] font-medium text-gray-700 mt-1.5 leading-tight">Rekap Export</span>
            </div>

            <div onclick="openModal('infoModal')" class="flex flex-col items-center cursor-pointer group">
                <div class="w-14 h-14 bg-gradient-to-tr from-gray-600 to-gray-400 text-white rounded-2xl flex items-center justify-center shadow-md group-hover:scale-105 transition">
                    <i class="fa-solid fa-gear text-xl"></i>
                </div>
                <span class="text-[11px] font-medium text-gray-700 mt-1.5 leading-tight">Pengaturan</span>
            </div>
        </div>
    </div>

    <!-- Carousel Banner Pengumuman & Berita (Ala Gojek) -->
    <div>
        <div class="flex items-center justify-between mb-2.5 px-1">
            <h2 class="text-sm font-bold text-gray-800">Warta Manbaul Hikmah</h2>
            <span onclick="openTab('pengumuman')" class="text-xs text-gojek font-semibold cursor-pointer">Lihat Semua</span>
        </div>

        <div class="flex space-x-3 overflow-x-auto hide-scrollbar pb-1" id="announcementCardsContainer">
            <!-- Dynamic announcement cards -->
        </div>
    </div>

    <!-- Rekap Cepat Presensi Hari Ini -->
    <div class="bg-white p-4 rounded-2xl border border-gray-100 shadow-sm">
        <div class="flex items-center justify-between mb-3">
            <div class="flex items-center space-x-2">
                <div class="w-8 h-8 rounded-full bg-green-100 text-gojek flex items-center justify-center text-sm">
                    <i class="fa-solid fa-clipboard-user"></i>
                </div>
                <div>
                    <h3 class="text-sm font-bold text-gray-800">Presensi Kelas 7A Hari Ini</h3>
                    <p class="text-[11px] text-gray-500" id="currentDateStr">29 September 2026</p>
                </div>
            </div>
            <button onclick="openTab('presensi')" class="text-xs bg-gojek/10 text-gojek font-semibold px-2.5 py-1 rounded-lg hover:bg-gojek/20">
                Kelola Presensi
            </button>
        </div>

        <div class="grid grid-cols-4 gap-2 text-center text-xs">
            <div class="bg-green-50 p-2 rounded-xl border border-green-100">
                <span class="block text-lg font-bold text-green-700" id="countHadir">6</span>
                <span class="text-[11px] text-green-600 font-medium">Hadir</span>
            </div>
            <div class="bg-blue-50 p-2 rounded-xl border border-blue-100">
                <span class="block text-lg font-bold text-blue-700" id="countSakit">1</span>
                <span class="text-[11px] text-blue-600 font-medium">Sakit</span>
            </div>
            <div class="bg-amber-50 p-2 rounded-xl border border-amber-100">
                <span class="block text-lg font-bold text-amber-700" id="countIzin">1</span>
                <span class="text-[11px] text-amber-600 font-medium">Izin</span>
            </div>
            <div class="bg-rose-50 p-2 rounded-xl border border-rose-100">
                <span class="block text-lg font-bold text-rose-700" id="countAlfa">0</span>
                <span class="text-[11px] text-rose-600 font-medium">Alfa</span>
            </div>
        </div>
    </div>

    <!-- Feed Aktivitas Terakhir -->
    <div>
        <div class="flex items-center justify-between mb-2.5 px-1">
            <h2 class="text-sm font-bold text-gray-800">Aktivitas Terbaru</h2>
            <span class="text-xs text-gray-500">Real-time</span>
        </div>

        <div class="bg-white rounded-2xl border border-gray-100 shadow-sm divide-y divide-gray-50" id="recentActivityList">
            <!-- Populated by JS -->
        </div>
    </div>
</div>
