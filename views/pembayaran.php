<!-- TAB PEMBAYARAN: ADMINISTRASI KEUANGAN & SPP SEKOLAH -->
<div id="tab-pembayaran" class="space-y-4 hidden">
    <!-- Header Banner -->
    <div class="bg-gradient-to-r from-emerald-600 to-teal-600 text-white p-4 rounded-2xl shadow-sm">
        <div class="flex items-center justify-between">
            <div>
                <h2 class="text-base font-bold flex items-center space-x-2">
                    <i class="fa-solid fa-receipt"></i>
                    <span>Tagihan & SPP Sekolah</span>
                </h2>
                <p class="text-xs text-emerald-100 mt-1">SOP Pembayaran Formal & Verifikasi Rekening TU</p>
            </div>
            <button onclick="openSchoolProfileModal()" class="bg-white/20 hover:bg-white/30 text-white text-xs px-2.5 py-1.5 rounded-xl font-semibold backdrop-blur-sm transition flex items-center space-x-1">
                <i class="fa-solid fa-building-columns text-xs"></i>
                <span>Rekening TU</span>
            </button>
        </div>
    </div>

    <!-- Quick Info Rekening Sekolah -->
    <div class="bg-white p-3.5 rounded-2xl border border-gray-100 shadow-sm text-xs space-y-2">
        <div class="flex items-center justify-between font-bold text-gray-700">
            <span class="flex items-center space-x-1.5">
                <i class="fa-solid fa-circle-info text-emerald-600"></i>
                <span>Rekening Resmi Pembayaran</span>
            </span>
            <span class="text-[11px] text-gray-400 font-normal">A.n Yayasan Manbaul Hikmah</span>
        </div>
        <div class="grid grid-cols-2 gap-2 pt-1">
            <div class="bg-gray-50 p-2.5 rounded-xl border border-gray-100 flex flex-col justify-between">
                <div>
                    <span class="font-bold text-emerald-700 block text-[11px]" id="infoBankName1">BSI</span>
                    <span class="font-mono font-bold text-xs text-gray-800" id="infoBankAcc1">7188299102</span>
                </div>
                <button onclick="copyAccountNo('infoBankAcc1')" class="mt-1 text-[10px] text-emerald-600 font-semibold self-start hover:underline">
                    <i class="fa-regular fa-copy"></i> Salin No. Rek
                </button>
            </div>
            <div class="bg-gray-50 p-2.5 rounded-xl border border-gray-100 flex flex-col justify-between">
                <div>
                    <span class="font-bold text-blue-700 block text-[11px]" id="infoBankName2">Mandiri</span>
                    <span class="font-mono font-bold text-xs text-gray-800" id="infoBankAcc2">1560012345678</span>
                </div>
                <button onclick="copyAccountNo('infoBankAcc2')" class="mt-1 text-[10px] text-blue-600 font-semibold self-start hover:underline">
                    <i class="fa-regular fa-copy"></i> Salin No. Rek
                </button>
            </div>
        </div>
        <p class="text-[11px] text-gray-500 pt-1 leading-relaxed">
            *Setelah transfer, klik tombol <span class="font-bold text-emerald-600">"Konfirmasi Bayar"</span> untuk mengirim foto bukti ke WhatsApp TU sekolah.
        </p>
    </div>

    <!-- Filter Tab Bar -->
    <div class="flex space-x-1.5 overflow-x-auto hide-scrollbar pb-1 text-xs">
        <button onclick="filterBills('Semua')" id="btnFilterBillSemua" class="filter-bill-btn px-3 py-1.5 rounded-xl font-bold bg-emerald-600 text-white shadow-sm transition">
            Semua
        </button>
        <button onclick="filterBills('Menunggu Verifikasi')" id="btnFilterBillPending" class="filter-bill-btn px-3 py-1.5 rounded-xl font-bold bg-gray-100 text-gray-600 hover:bg-gray-200 transition flex items-center space-x-1">
            <span>Verifikasi TU</span>
            <span id="badgePendingCount" class="hidden bg-amber-500 text-white text-[10px] px-1.5 py-0.2 rounded-full font-bold">0</span>
        </button>
        <button onclick="filterBills('Belum Lunas')" id="btnFilterBillBelumLunas" class="filter-bill-btn px-3 py-1.5 rounded-xl font-bold bg-gray-100 text-gray-600 hover:bg-gray-200 transition">
            Belum Lunas
        </button>
        <button onclick="filterBills('Lunas')" id="btnFilterBillLunas" class="filter-bill-btn px-3 py-1.5 rounded-xl font-bold bg-gray-100 text-gray-600 hover:bg-gray-200 transition">
            Lunas
        </button>
    </div>

    <!-- Bills List Container -->
    <div id="billsContainer" class="space-y-3">
        <!-- Rendered via JavaScript -->
        <div class="text-center py-8 text-gray-400 text-xs">
            <i class="fa-solid fa-spinner fa-spin text-lg mb-2"></i>
            <p>Memuat daftar tagihan...</p>
        </div>
    </div>
</div>
