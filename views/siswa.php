<!-- TAB 6: DATA SISWA -->
<div id="tab-siswa" class="space-y-4 hidden">
    <div class="bg-gradient-to-r from-blue-600 to-cyan-600 text-white p-4 rounded-2xl shadow-sm flex items-center justify-between">
        <div>
            <h2 class="text-base font-bold flex items-center space-x-2">
                <i class="fa-solid fa-users"></i>
                <span>Data Siswa & Wali Kelas</span>
            </h2>
            <p class="text-xs text-blue-100 mt-1">Kelola data murid, NISN, dan kontak orang tua santri.</p>
        </div>
        <button onclick="openModal('addStudentModal')" class="bg-white text-blue-600 text-xs font-bold px-3 py-2 rounded-xl shadow hover:bg-gray-100 transition">
            + Siswa Baru
        </button>
    </div>

    <div class="bg-white p-4 rounded-2xl border border-gray-200 shadow-sm">
        <div class="divide-y divide-gray-100" id="fullStudentList">
            <!-- Populated by JS -->
        </div>
    </div>
</div>
