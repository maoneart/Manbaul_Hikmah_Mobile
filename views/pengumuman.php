<!-- TAB 5: PENGUMUMAN KEPSEK -->
<div id="tab-pengumuman" class="space-y-4 hidden">
    <div class="bg-gradient-to-r from-rose-600 to-pink-600 text-white p-4 rounded-2xl shadow-sm flex items-center justify-between">
        <div>
            <h2 class="text-base font-bold flex items-center space-x-2">
                <i class="fa-solid fa-bullhorn"></i>
                <span>Pengumuman Kepala Sekolah</span>
            </h2>
            <p class="text-xs text-rose-100 mt-1">Komunikasi resmi dari Kepala Sekolah ke Wali Kelas dan Wali Murid.</p>
        </div>
        <button onclick="openModal('createAnnouncementModal')" id="createAnnouncementBtn" class="bg-white text-rose-600 text-xs font-bold px-3 py-2 rounded-xl shadow hover:bg-gray-100 transition">
            + Buat Baru
        </button>
    </div>

    <!-- Filter Pengumuman -->
    <div class="flex space-x-2">
        <button onclick="filterAnnouncements('all')" class="ann-filter-btn active text-xs font-semibold px-3 py-1.5 rounded-full bg-gojek text-white" data-filter="all">Semua</button>
        <button onclick="filterAnnouncements('teachers')" class="ann-filter-btn text-xs font-semibold px-3 py-1.5 rounded-full bg-gray-200 text-gray-700" data-filter="teachers">Khusus Guru</button>
        <button onclick="filterAnnouncements('parents')" class="ann-filter-btn text-xs font-semibold px-3 py-1.5 rounded-full bg-gray-200 text-gray-700" data-filter="parents">Khusus Wali Murid</button>
    </div>

    <div class="space-y-3" id="announcementsListContainer">
        <!-- Populated via JS -->
    </div>
</div>
