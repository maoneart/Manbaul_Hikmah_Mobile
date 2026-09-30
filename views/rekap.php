<!-- TAB 8: REKAP & LAPORAN -->
<div id="tab-rekap" class="space-y-4 hidden">
    <div class="bg-gradient-to-r from-orange-500 to-amber-500 text-white p-4 rounded-2xl shadow-sm">
        <h2 class="text-base font-bold flex items-center space-x-2">
            <i class="fa-solid fa-chart-pie"></i>
            <span>Rekap & Ekspor Laporan</span>
        </h2>
        <p class="text-xs text-orange-100 mt-1">Ekspor data kehadiran dan keuangan tabungan siswa.</p>
    </div>

    <div class="grid grid-cols-1 md:grid-cols-2 gap-3">
        <div class="bg-white p-4 rounded-2xl border border-gray-200 shadow-sm">
            <h4 class="text-xs font-bold text-gray-800 mb-1">Laporan Presensi Siswa</h4>
            <p class="text-[11px] text-gray-500 mb-3">Unduh data kehadiran lengkap dengan jam scan dan catatan izin/sakit.</p>
            <button onclick="downloadCsvAttendance()" class="w-full bg-gojek text-white text-xs font-bold py-2 rounded-xl hover:bg-gojek-dark shadow flex items-center justify-center space-x-1.5">
                <i class="fa-solid fa-file-excel"></i>
                <span>Download CSV Presensi</span>
            </button>
        </div>

        <div class="bg-white p-4 rounded-2xl border border-gray-200 shadow-sm">
            <h4 class="text-xs font-bold text-gray-800 mb-1">Laporan Tabungan Siswa</h4>
            <p class="text-[11px] text-gray-500 mb-3">Rekapitulasi saldo tabungan seluruh siswa dan total kas titipan.</p>
            <button onclick="downloadCsvSavings()" class="w-full bg-amber-600 text-white text-xs font-bold py-2 rounded-xl hover:bg-amber-700 shadow flex items-center justify-center space-x-1.5">
                <i class="fa-solid fa-file-invoice-dollar"></i>
                <span>Download CSV Tabungan</span>
            </button>
        </div>
    </div>
</div>
