<!-- TAB 4: BUKU TABUNGAN SISWA -->
<div id="tab-tabungan" class="space-y-4 hidden">
    <div class="bg-gradient-to-r from-amber-500 to-yellow-500 text-white p-4 rounded-2xl shadow-sm">
        <h2 class="text-base font-bold flex items-center space-x-2">
            <i class="fa-solid fa-piggy-bank"></i>
            <span>Buku Tabungan Digital Siswa</span>
        </h2>
        <p class="text-xs text-amber-100 mt-1">Pencatatan setoran, penarikan, dan cek saldo riil santri & siswa.</p>
    </div>

    <!-- Tombol Transaksi Cepat -->
    <div class="grid grid-cols-2 gap-2">
        <button onclick="openModal('transactionModal'); setTransType('setor');" class="bg-gojek text-white p-3 rounded-2xl font-bold text-xs shadow flex items-center justify-center space-x-2 hover:bg-gojek-dark transition">
            <i class="fa-solid fa-arrow-down-to-bracket text-sm"></i>
            <span>+ Setor Tabungan</span>
        </button>
        <button onclick="openModal('transactionModal'); setTransType('tarik');" class="bg-rose-500 text-white p-3 rounded-2xl font-bold text-xs shadow flex items-center justify-center space-x-2 hover:bg-rose-600 transition">
            <i class="fa-solid fa-arrow-up-from-bracket text-sm"></i>
            <span>- Tarik Tabungan</span>
        </button>
    </div>

    <!-- Daftar Saldo Siswa -->
    <div class="bg-white p-4 rounded-2xl border border-gray-200 shadow-sm">
        <h3 class="text-sm font-bold text-gray-800 mb-3">Daftar Saldo Siswa (Kelas 7A)</h3>
        <div class="divide-y divide-gray-100" id="savingsStudentList">
            <!-- Populated via JS -->
        </div>
    </div>
</div>
