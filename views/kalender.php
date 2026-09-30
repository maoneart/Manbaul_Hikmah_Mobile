<!-- TAB 7: KALENDER & REKAP BULANAN -->
<div id="tab-kalender" class="space-y-4 hidden">
    <div class="bg-gradient-to-r from-teal-600 to-emerald-600 text-white p-4 rounded-2xl shadow-sm">
        <h2 class="text-base font-bold flex items-center space-x-2">
            <i class="fa-solid fa-calendar-days"></i>
            <span>Kalender Presensi Bulanan</span>
        </h2>
        <p class="text-xs text-teal-100 mt-1">Laporan komprehensif kehadiran santri dan siswa per periode.</p>
    </div>

    <div class="bg-white p-4 rounded-2xl border border-gray-200 shadow-sm text-center">
        <div class="flex items-center justify-between mb-4">
            <span class="text-xs font-bold text-gray-700">Bulan: September 2026</span>
            <button onclick="downloadCsvAttendance()" class="bg-emerald-600 text-white text-xs font-bold px-3 py-1.5 rounded-xl hover:bg-emerald-700 shadow flex items-center space-x-1">
                <i class="fa-solid fa-file-csv"></i>
                <span>Unduh CSV</span>
            </button>
        </div>

        <div class="grid grid-cols-7 gap-1 text-[11px] text-gray-500 font-semibold mb-2">
            <span>Sen</span><span>Sel</span><span>Rab</span><span>Kam</span><span>Jum</span><span>Sab</span><span>Ahad</span>
        </div>
        <div class="grid grid-cols-7 gap-1 text-xs" id="calendarDaysGrid">
            <!-- Populated by JS -->
        </div>
    </div>
</div>
