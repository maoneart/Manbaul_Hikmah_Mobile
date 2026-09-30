        </main>

        <!-- BOTTOM NAVIGATION BAR (ALA GOJEK) -->
        <nav class="bg-white border-t border-gray-200 fixed bottom-0 left-0 right-0 max-w-md md:max-w-3xl lg:max-w-4xl mx-auto z-40 px-2 py-2 flex justify-around shadow-2xl">
            <button onclick="openTab('beranda')" class="nav-btn active flex flex-col items-center text-gojek" data-tab="beranda">
                <i class="fa-solid fa-house text-lg"></i>
                <span class="text-[10px] font-semibold mt-1">Beranda</span>
            </button>
            <button onclick="openTab('presensi')" class="nav-btn flex flex-col items-center text-gray-400 hover:text-gojek" data-tab="presensi">
                <i class="fa-solid fa-qrcode text-lg"></i>
                <span class="text-[10px] font-semibold mt-1">Presensi</span>
            </button>
            <button onclick="openTab('tabungan')" class="nav-btn flex flex-col items-center text-gray-400 hover:text-gojek" data-tab="tabungan">
                <i class="fa-solid fa-piggy-bank text-lg"></i>
                <span class="text-[10px] font-semibold mt-1">Tabungan</span>
            </button>
            <button onclick="openTab('pengumuman')" class="nav-btn flex flex-col items-center text-gray-400 hover:text-gojek" data-tab="pengumuman">
                <i class="fa-solid fa-bullhorn text-lg"></i>
                <span class="text-[10px] font-semibold mt-1">Warta</span>
            </button>
            <button onclick="openTab('siswa')" class="nav-btn flex flex-col items-center text-gray-400 hover:text-gojek" data-tab="siswa">
                <i class="fa-solid fa-user-graduate text-lg"></i>
                <span class="text-[10px] font-semibold mt-1">Siswa</span>
            </button>
        </nav>

        <?php require_once __DIR__ . '/modals.php'; ?>

    </div>

    <!-- Application Engine Script -->
    <script src="assets/js/app.js"></script>
</body>
</html>
