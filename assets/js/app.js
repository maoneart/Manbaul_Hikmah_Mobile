/**
 * Manbaul Hikmah Mobile - Client Application Engine Part 1
 * Data State, Audio Chime, Navigation & Modals
 */

const DEFAULT_STUDENTS = [
    { id: 1, nisn: '0081234561', name: 'Ahmad Fauzi', gender: 'L', class_name: 'Kelas 7A', parent_name: 'H. Rahmat', parent_phone: '081234567893', balance: 150000, qr_code_token: 'MH-STD-0081234561' },
    { id: 2, nisn: '0081234562', name: 'Fatimah Az-Zahra', gender: 'P', class_name: 'Kelas 7A', parent_name: 'M. Yusuf', parent_phone: '081234567894', balance: 275000, qr_code_token: 'MH-STD-0081234562' },
    { id: 3, nisn: '0081234563', name: 'Muhammad Bilal', gender: 'L', class_name: 'Kelas 7A', parent_name: 'Drs. Supriyanto', parent_phone: '081234567895', balance: 85000, qr_code_token: 'MH-STD-0081234563' },
    { id: 4, nisn: '0081234564', name: 'Aisyah Humaira', gender: 'P', class_name: 'Kelas 7A', parent_name: 'Agus Salim', parent_phone: '081234567896', balance: 320000, qr_code_token: 'MH-STD-0081234564' },
    { id: 5, nisn: '0081234565', name: 'Zaid bin Tsabit', gender: 'L', class_name: 'Kelas 7A', parent_name: 'Heri Irawan', parent_phone: '081234567897', balance: 60000, qr_code_token: 'MH-STD-0081234565' },
    { id: 6, nisn: '0081234566', name: 'Khadijah Al-Kubro', gender: 'P', class_name: 'Kelas 7A', parent_name: 'Bambang Sudiro', parent_phone: '081234567898', balance: 190000, qr_code_token: 'MH-STD-0081234566' },
    { id: 7, nisn: '0081234567', name: 'Umar Al-Faruq', gender: 'L', class_name: 'Kelas 7A', parent_name: 'H. Mansyur', parent_phone: '081234567899', balance: 110000, qr_code_token: 'MH-STD-0081234567' },
    { id: 8, nisn: '0081234568', name: 'Maryam Syafira', gender: 'P', class_name: 'Kelas 7A', parent_name: 'Suryono', parent_phone: '081234567800', balance: 450000, qr_code_token: 'MH-STD-0081234568' }
];

const DEFAULT_ATTENDANCES = [
    { student_id: 1, status: 'Hadir', scan_time: '06:55 WIB', notes: 'Tepat Waktu via QR' },
    { student_id: 2, status: 'Hadir', scan_time: '07:02 WIB', notes: 'Tepat Waktu via QR' },
    { student_id: 3, status: 'Sakit', scan_time: '-', notes: 'Surat dokter terlampir' },
    { student_id: 4, status: 'Hadir', scan_time: '07:05 WIB', notes: 'Tepat Waktu via QR' },
    { student_id: 5, status: 'Izin', scan_time: '-', notes: 'Izin acara keluarga' },
    { student_id: 6, status: 'Hadir', scan_time: '07:11 WIB', notes: 'Tepat Waktu via QR' },
    { student_id: 7, status: 'Alfa', scan_time: '-', notes: 'Belum scan kartu' },
    { student_id: 8, status: 'Hadir', scan_time: '07:14 WIB', notes: 'Tepat Waktu via QR' }
];

const DEFAULT_ANNOUNCEMENTS = [
    {
        id: 1,
        title: 'Pelaksanaan Penilaian Tengah Semester (PTS) Ganjil',
        content: 'Diberitahukan kepada seluruh Bapak/Ibu Dewan Guru bahwa pelaksanaan PTS Ganjil dimulai Senin depan. Mohon rekap absensi kelas dan bank soal segera diselesaikan.',
        target: 'teachers',
        category: 'Akademik',
        author: 'KH. Ahmad Syafei, M.Pd.',
        date: '28 Sep 2026',
        urgent: true
    },
    {
        id: 2,
        title: 'Himbauan Gerakan Menabung & Kartu Name Tag QR',
        content: 'Kepada seluruh Wali Murid Manbaul Hikmah, santri kini dilengkapi Name Tag Digital untuk pencatatan presensi otomatis serta buku tabungan digital di sekolah.',
        target: 'parents',
        category: 'Kegiatan',
        author: 'KH. Ahmad Syafei, M.Pd.',
        date: '27 Sep 2026',
        urgent: false
    },
    {
        id: 3,
        title: 'Peringatan Hari Besar Islam & Pengajian Santri',
        content: 'Kegiatan belajar mengajar diliburkan menyambut peringatan Maulid Nabi SAW. Santri diharapkan mengikuti rangkaian wirid dan shalawat di Masjid Utama.',
        target: 'all',
        category: 'Libur',
        author: 'KH. Ahmad Syafei, M.Pd.',
        date: '29 Sep 2026',
        urgent: false
    }
];

const DEFAULT_TRANSACTIONS = [
    { id: 1, student_id: 1, type: 'setor', amount: 50000, balance_after: 150000, notes: 'Uang saku mingguan', date: '29 Sep 2026 07:15' },
    { id: 2, student_id: 2, type: 'setor', amount: 100000, balance_after: 275000, notes: 'Setoran bulanan santri', date: '28 Sep 2026 09:30' },
    { id: 3, student_id: 3, type: 'tarik', amount: 20000, balance_after: 85000, notes: 'Beli buku tulis & kitab', date: '27 Sep 2026 10:15' },
    { id: 4, student_id: 4, type: 'setor', amount: 50000, balance_after: 320000, notes: 'Tabungan mandiri', date: '29 Sep 2026 07:30' }
];

let state = {
    role: 'wali_kelas',
    activeClass: 'Kelas 7A',
    students: JSON.parse(localStorage.getItem('mh_students')) || DEFAULT_STUDENTS,
    attendances: JSON.parse(localStorage.getItem('mh_attendances')) || DEFAULT_ATTENDANCES,
    announcements: JSON.parse(localStorage.getItem('mh_announcements')) || DEFAULT_ANNOUNCEMENTS,
    transactions: JSON.parse(localStorage.getItem('mh_transactions')) || DEFAULT_TRANSACTIONS,
    isBalanceVisible: true,
    html5QrCode: null,
    isScannerRunning: false,
    currentTransType: 'setor'
};

function saveState() {
    localStorage.setItem('mh_students', JSON.stringify(state.students));
    localStorage.setItem('mh_attendances', JSON.stringify(state.attendances));
    localStorage.setItem('mh_announcements', JSON.stringify(state.announcements));
    localStorage.setItem('mh_transactions', JSON.stringify(state.transactions));
}

/**
 * ============================================================
 * MAONEART GLASSMORPHISM MODAL SYSTEM (Standard)
 * ============================================================
 */
function ensureModalContainer() {
    let modalContainer = document.getElementById('maoneartModalContainer');
    if (!modalContainer) {
        modalContainer = document.createElement('div');
        modalContainer.id = 'maoneartModalContainer';
        modalContainer.className = 'maoneart-modal-backdrop';
        document.body.appendChild(modalContainer);
    }
    return modalContainer;
}

function showConfirmModal(options = {}) {
    const {
        title = 'Konfirmasi Tindakan',
        message = 'Apakah Anda yakin ingin melanjutkan?',
        confirmText = 'Ya, Lanjutkan',
        cancelText = 'Batal',
        isDanger = true,
        icon = 'fa-solid fa-triangle-exclamation',
        onConfirm = null
    } = options;

    const container = ensureModalContainer();
    const iconClass = isDanger ? 'danger' : 'info';
    const confirmBtnClass = isDanger ? 'danger' : 'primary';

    container.innerHTML = `
        <div class="maoneart-modal-card">
            <div class="maoneart-modal-icon-box ${iconClass}">
                <i class="${icon}"></i>
            </div>
            <h3 class="maoneart-modal-title">${title}</h3>
            <p class="maoneart-modal-message">${message}</p>
            <div class="maoneart-modal-actions">
                <button type="button" class="maoneart-modal-btn cancel" id="maoneartModalCancel">
                    ${cancelText}
                </button>
                <button type="button" class="maoneart-modal-btn ${confirmBtnClass}" id="maoneartModalConfirm">
                    ${confirmText}
                </button>
            </div>
        </div>
    `;

    setTimeout(() => container.classList.add('active'), 10);

    const close = () => {
        container.classList.remove('active');
    };

    const cancelBtn = container.querySelector('#maoneartModalCancel');
    const confirmBtn = container.querySelector('#maoneartModalConfirm');

    cancelBtn.onclick = () => close();
    confirmBtn.onclick = () => {
        close();
        if (typeof onConfirm === 'function') onConfirm();
    };
    container.onclick = (e) => {
        if (e.target === container) close();
    };
}

function showAlertModal(options = {}) {
    const {
        title = 'Informasi',
        message = '',
        buttonText = 'Mengerti',
        icon = 'fa-solid fa-circle-info',
        type = 'info'
    } = options;

    const container = ensureModalContainer();
    const btnClass = (type === 'danger') ? 'danger' : 'primary';

    container.innerHTML = `
        <div class="maoneart-modal-card">
            <div class="maoneart-modal-icon-box ${type}">
                <i class="${icon}"></i>
            </div>
            <h3 class="maoneart-modal-title">${title}</h3>
            <p class="maoneart-modal-message">${message}</p>
            <button type="button" class="maoneart-modal-btn ${btnClass}" id="maoneartModalOk" style="width: 100%;">
                ${buttonText}
            </button>
        </div>
    `;

    setTimeout(() => container.classList.add('active'), 10);

    const close = () => {
        container.classList.remove('active');
    };

    const okBtn = container.querySelector('#maoneartModalOk');
    okBtn.onclick = () => close();
    container.onclick = (e) => {
        if (e.target === container) close();
    };
}

function playSuccessBeep() {
    try {
        const audioCtx = new (window.AudioContext || window.webkitAudioContext)();
        const osc = audioCtx.createOscillator();
        const gain = audioCtx.createGain();
        osc.type = 'sine';
        osc.frequency.setValueAtTime(880, audioCtx.currentTime);
        osc.frequency.exponentialRampToValueAtTime(1760, audioCtx.currentTime + 0.15);
        gain.gain.setValueAtTime(0.3, audioCtx.currentTime);
        gain.gain.exponentialRampToValueAtTime(0.01, audioCtx.currentTime + 0.25);
        osc.connect(gain);
        gain.connect(audioCtx.destination);
        osc.start();
        osc.stop(audioCtx.currentTime + 0.25);
    } catch (e) {}
}

function openTab(tabName) {
    const tabs = ['beranda', 'presensi', 'nametag', 'tabungan', 'pengumuman', 'siswa', 'kalender', 'rekap'];
    tabs.forEach(t => {
        const el = document.getElementById('tab-' + t);
        if (el) el.classList.add('hidden');
    });

    const activeEl = document.getElementById('tab-' + tabName);
    if (activeEl) activeEl.classList.remove('hidden');

    document.querySelectorAll('.nav-btn').forEach(btn => {
        if (btn.getAttribute('data-tab') === tabName) {
            btn.classList.add('text-gojek');
            btn.classList.remove('text-gray-400');
        } else {
            btn.classList.remove('text-gojek');
            btn.classList.add('text-gray-400');
        }
    });

    if (tabName === 'nametag') {
        const sel = document.getElementById('nameTagStudentSelect');
        if (sel && sel.value) renderSelectedNameTag(sel.value);
    } else if (tabName === 'kalender') {
        renderCalendar();
    }

    window.scrollTo({ top: 0, behavior: 'smooth' });
}

function openModal(modalId) {
    const m = document.getElementById(modalId);
    if (m) m.classList.remove('hidden');
}

function closeModal(modalId) {
    const m = document.getElementById(modalId);
    if (m) m.classList.add('hidden');
}

function toggleBalanceVisibility() {
    state.isBalanceVisible = !state.isBalanceVisible;
    updateBalanceDisplay();
}

function updateBalanceDisplay() {
    const display = document.getElementById('balanceDisplay');
    const eye = document.getElementById('balanceEyeIcon');
    const total = state.students.reduce((sum, s) => sum + (Number(s.balance) || 0), 0);
    
    if (display) {
        if (state.isBalanceVisible) {
            display.innerText = 'Rp ' + total.toLocaleString('id-ID');
            eye.className = 'fa-regular fa-eye text-xs text-cyan-300';
        } else {
            display.innerText = 'Rp ••••••••';
            eye.className = 'fa-regular fa-eye-slash text-xs text-cyan-300';
        }
    }
}

function switchDemoRole(role) {
    state.role = role;
    const badge = document.getElementById('roleBadge');
    const nameHeader = document.getElementById('userNameHeader');
    const createAnnBtn = document.getElementById('createAnnouncementBtn');

    if (role === 'kepsek') {
        badge.innerText = 'Kepala Sekolah';
        nameHeader.innerText = 'KH. Ahmad Syafei, M.Pd.';
        if (createAnnBtn) createAnnBtn.classList.remove('hidden');
    } else if (role === 'wali_kelas') {
        badge.innerText = 'Wali Kelas 7A';
        nameHeader.innerText = 'Ustadz Budi Santoso, S.Pd.';
        if (createAnnBtn) createAnnBtn.classList.add('hidden');
    } else if (role === 'wali_murid') {
        badge.innerText = 'Wali Murid';
        nameHeader.innerText = 'Bpk. H. Rahmat (Wali Ahmad)';
        if (createAnnBtn) createAnnBtn.classList.add('hidden');
    }

    renderAnnouncements('all');
}
/**
 * Manbaul Hikmah Mobile - Client Application Engine Part 2
 * QR Scanner, Simulation Scan, Manual Status
 */

function startQrScanner() {
    const readerEl = document.getElementById('reader');
    if (!readerEl) return;

    if (!state.html5QrCode) {
        state.html5QrCode = new Html5Qrcode("reader");
    }

    const config = { fps: 10, qrbox: { width: 220, height: 220 } };

    state.html5QrCode.start({ facingMode: "environment" }, config, onScanSuccess)
        .then(() => {
            state.isScannerRunning = true;
            document.getElementById('startCamBtn').classList.add('hidden');
            document.getElementById('stopCamBtn').classList.remove('hidden');
        })
        .catch(err => {
            showAlertModal({
                title: 'Akses Kamera Terkendala',
                message: 'Tidak dapat mengakses kamera: ' + err + '. Silakan gunakan fitur "Tes Simulasi Scan Siswa" di bawah ini!',
                type: 'danger',
                icon: 'fa-solid fa-video-slash'
            });
        });
}

function stopQrScanner() {
    if (state.html5QrCode && state.isScannerRunning) {
        state.html5QrCode.stop().then(() => {
            state.isScannerRunning = false;
            document.getElementById('startCamBtn').classList.remove('hidden');
            document.getElementById('stopCamBtn').classList.add('hidden');
        }).catch(err => console.error(err));
    }
}

function onScanSuccess(decodedText) {
    processScannedQr(decodedText);
}

function simulateScanSelected() {
    const sel = document.getElementById('simulatedStudentSelect');
    if (!sel || !sel.value) return;
    const student = state.students.find(s => s.id == sel.value);
    if (student) {
        processScannedQr(student.qr_code_token);
    }
}

function processScannedQr(qrToken) {
    const student = state.students.find(s => s.qr_code_token === qrToken || s.nisn === qrToken);
    const box = document.getElementById('scanResultBox');

    if (!student) {
        if (box) {
            box.className = 'mt-3 p-3 rounded-xl border border-red-200 bg-red-50 text-red-700 text-xs font-semibold block';
            box.innerHTML = '<i class="fa-solid fa-triangle-exclamation mr-1"></i> QR Code tidak dikenali dalam data siswa!';
        }
        return;
    }

    playSuccessBeep();

    const now = new Date();
    const timeStr = String(now.getHours()).padStart(2, '0') + ':' + String(now.getMinutes()).padStart(2, '0') + ' WIB';
    
    // SOP Sekolah Formal: Batas Masuk 07:00 WIB
    const isLate = (now.getHours() > 7 || (now.getHours() === 7 && now.getMinutes() > 0));
    const calculatedStatus = isLate ? 'Terlambat' : 'Hadir';
    const noteStr = isLate ? `Terlambat (${timeStr})` : 'Tepat Waktu via QR';
    
    let att = state.attendances.find(a => a.student_id == student.id);
    if (!att) {
        att = { student_id: student.id, status: calculatedStatus, scan_time: timeStr, notes: noteStr };
        state.attendances.push(att);
    } else {
        att.status = calculatedStatus;
        att.scan_time = timeStr;
        att.notes = noteStr;
    }

    saveState();
    updateAttendanceUI();

    if (box) {
        if (isLate) {
            box.className = 'mt-3 p-3 rounded-xl border border-amber-200 bg-amber-50 text-amber-900 text-xs block text-left';
            box.innerHTML = `
                <div class="flex items-center space-x-2.5">
                    <div class="w-8 h-8 rounded-full bg-amber-500 text-white flex items-center justify-center font-bold text-sm">
                        <i class="fa-solid fa-clock"></i>
                    </div>
                    <div>
                        <h4 class="font-extrabold text-sm text-amber-900">⚠️ Tercatat TERLAMBAT: ${student.name}</h4>
                        <p class="text-[11px] text-amber-700">NISN: ${student.nisn} • Scan pukul ${timeStr} (Lewat batas 07:00 WIB)</p>
                    </div>
                </div>
            `;
        } else {
            box.className = 'mt-3 p-3 rounded-xl border border-green-200 bg-green-50 text-green-800 text-xs block text-left';
            box.innerHTML = `
                <div class="flex items-center space-x-2.5">
                    <div class="w-8 h-8 rounded-full bg-green-500 text-white flex items-center justify-center font-bold text-sm">
                        ${student.name.charAt(0)}
                    </div>
                    <div>
                        <h4 class="font-extrabold text-sm text-green-900">✅ Hadir Tepat Waktu: ${student.name}</h4>
                        <p class="text-[11px] text-green-700">NISN: ${student.nisn} • Hadir pada ${timeStr}</p>
                    </div>
                </div>
            `;
        }
    }
}

function setAttendanceStatus(studentId, status) {
    let att = state.attendances.find(a => a.student_id == studentId);
    const now = new Date();
    const timeStr = (status === 'Hadir' || status === 'Terlambat') ? String(now.getHours()).padStart(2, '0') + ':' + String(now.getMinutes()).padStart(2, '0') + ' WIB' : '-';
    const noteStr = (status === 'Terlambat') ? `Terlambat (${timeStr})` : (status === 'Hadir' ? 'Hadir manual' : `Manual: ${status}`);

    if (!att) {
        att = { student_id: studentId, status: status, scan_time: timeStr, notes: noteStr };
        state.attendances.push(att);
    } else {
        att.status = status;
        att.scan_time = timeStr;
        att.notes = noteStr;
    }

    saveState();
    updateAttendanceUI();
}

function confirmLockAttendance() {
    showConfirmModal({
        title: 'Kunci Presensi Hari Ini?',
        message: 'Sesuai SOP Sekolah, seluruh siswa yang belum melakukan scan presensi akan otomatis dicatat sebagai ALFA (Presensi Ditutup).',
        confirmText: 'Kunci Presensi',
        cancelText: 'Batal',
        isDanger: true,
        icon: 'fa-solid fa-lock',
        onConfirm: () => {
            lockAttendanceToday();
        }
    });
}

function lockAttendanceToday() {
    fetch('api/attendance.php?action=lock', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
            class: state.activeClass,
            recorded_by: 'SOP Kunci Presensi (Wali Kelas)'
        })
    })
    .then(res => res.json())
    .catch(() => ({}))
    .finally(() => {
        let count = 0;
        state.students.forEach(s => {
            if (state.activeClass === 'Semua' || s.class_name === state.activeClass) {
                let att = state.attendances.find(a => a.student_id == s.id);
                if (!att) {
                    state.attendances.push({
                        student_id: s.id,
                        status: 'Alfa',
                        scan_time: '-',
                        notes: 'Presensi Ditutup (Auto-Alfa SOP)'
                    });
                    count++;
                } else if (att.status === 'Belum Absen') {
                    att.status = 'Alfa';
                    att.notes = 'Presensi Ditutup (Auto-Alfa SOP)';
                    count++;
                }
            }
        });

        saveState();
        updateAttendanceUI();

        showAlertModal({
            title: 'Presensi Berhasil Dikunci',
            message: `SOP berhasil dijalankan. Sebanyak ${count} siswa yang belum scan otomatis dicatat sebagai ALFA.`,
            type: 'success',
            icon: 'fa-solid fa-circle-check',
            buttonText: 'Selesai'
        });
    });
}

function updateAttendanceUI() {
    const tbody = document.getElementById('attendanceTableBody');
    if (!tbody) return;

    let hadirCount = 0, terlambatCount = 0, sakitCount = 0, izinCount = 0, alfaCount = 0;

    tbody.innerHTML = '';
    state.students.forEach(student => {
        const att = state.attendances.find(a => a.student_id == student.id) || { status: 'Belum Absen', scan_time: '-' };
        
        let statusBadge = '<span class="bg-gray-100 text-gray-600 px-2 py-0.5 rounded font-medium">Belum Scan</span>';
        if (att.status === 'Hadir') {
            hadirCount++;
            statusBadge = `<span class="bg-green-100 text-green-700 px-2 py-0.5 rounded font-bold">Hadir (${att.scan_time})</span>`;
        } else if (att.status === 'Terlambat') {
            terlambatCount++;
            statusBadge = `<span class="bg-amber-100 text-amber-800 border border-amber-300 px-2 py-0.5 rounded font-bold">Terlambat (${att.scan_time})</span>`;
        } else if (att.status === 'Sakit') {
            sakitCount++;
            statusBadge = '<span class="bg-blue-100 text-blue-700 px-2 py-0.5 rounded font-bold">Sakit</span>';
        } else if (att.status === 'Izin') {
            izinCount++;
            statusBadge = '<span class="bg-amber-100 text-amber-700 px-2 py-0.5 rounded font-bold">Izin</span>';
        } else if (att.status === 'Alfa') {
            alfaCount++;
            statusBadge = '<span class="bg-rose-100 text-rose-700 px-2 py-0.5 rounded font-bold">Alfa</span>';
        }

        const tr = document.createElement('tr');
        tr.className = 'hover:bg-gray-50';
        tr.innerHTML = `
            <td class="p-2.5">
                <div class="font-bold text-gray-800 text-xs">${student.name}</div>
                <div class="text-[10px] text-gray-400">NISN: ${student.nisn}</div>
            </td>
            <td class="p-2.5">${statusBadge}</td>
            <td class="p-2.5 text-center">
                <div class="inline-flex rounded-lg shadow-sm border border-gray-200 overflow-hidden text-[10px]">
                    <button onclick="setAttendanceStatus(${student.id}, 'Hadir')" title="Hadir Tepat Waktu" class="px-2 py-1 font-bold ${att.status === 'Hadir' ? 'bg-green-600 text-white' : 'bg-white text-gray-700 hover:bg-gray-100'}">H</button>
                    <button onclick="setAttendanceStatus(${student.id}, 'Terlambat')" title="Terlambat" class="px-2 py-1 font-bold ${att.status === 'Terlambat' ? 'bg-amber-500 text-white' : 'bg-white text-gray-700 hover:bg-gray-100'}">T</button>
                    <button onclick="setAttendanceStatus(${student.id}, 'Sakit')" title="Sakit" class="px-2 py-1 font-bold ${att.status === 'Sakit' ? 'bg-blue-600 text-white' : 'bg-white text-gray-700 hover:bg-gray-100'}">S</button>
                    <button onclick="setAttendanceStatus(${student.id}, 'Izin')" title="Izin" class="px-2 py-1 font-bold ${att.status === 'Izin' ? 'bg-amber-600 text-white' : 'bg-white text-gray-700 hover:bg-gray-100'}">I</button>
                    <button onclick="setAttendanceStatus(${student.id}, 'Alfa')" title="Alfa" class="px-2 py-1 font-bold ${att.status === 'Alfa' ? 'bg-rose-600 text-white' : 'bg-white text-gray-700 hover:bg-gray-100'}">A</button>
                </div>
            </td>
        `;
        tbody.appendChild(tr);
    });

    const cHadir = document.getElementById('countHadir');
    const cSakit = document.getElementById('countSakit');
    const cIzin = document.getElementById('countIzin');
    const cAlfa = document.getElementById('countAlfa');
    if (cHadir) cHadir.innerText = (hadirCount + terlambatCount);
    if (cSakit) cSakit.innerText = sakitCount;
    if (cIzin) cIzin.innerText = izinCount;
    if (cAlfa) cAlfa.innerText = alfaCount;

    const ratioText = document.getElementById('hadirRatioText');
    const percentBadge = document.getElementById('hadirPercentBadge');
    if (ratioText) ratioText.innerText = `${hadirCount + terlambatCount}/${state.students.length} Hadir`;
    if (percentBadge) {
        const pct = Math.round(((hadirCount + terlambatCount) / state.students.length) * 100);
        percentBadge.innerText = pct + '%';
    }
}
/**
 * Manbaul Hikmah Mobile - Client Application Engine Part 3
 * Name Tag QR, Savings, Announcements, Student List, Export & Boot
 */

function renderSelectedNameTag(studentId) {
    const student = state.students.find(s => s.id == studentId) || state.students[0];
    if (!student) return;

    document.getElementById('cardStudentName').innerText = student.name;
    document.getElementById('cardStudentClass').innerText = student.class_name;
    document.getElementById('cardStudentNisn').innerText = student.nisn;
    document.getElementById('cardAvatar').innerText = student.name.charAt(0);

    const qrContainer = document.getElementById('cardQrCode');
    qrContainer.innerHTML = '';
    new QRCode(qrContainer, {
        text: student.qr_code_token,
        width: 140,
        height: 140,
        colorDark: "#064E3B",
        colorLight: "#FFFFFF",
        correctLevel: QRCode.CorrectLevel.H
    });
}

function setTransType(type) {
    state.currentTransType = type;
    const title = document.getElementById('transModalTitle');
    const btn = document.getElementById('submitTransBtn');
    if (type === 'setor') {
        title.innerText = 'Setor Tabungan Siswa';
        btn.className = 'w-full bg-gojek text-white text-xs font-bold py-3 rounded-xl hover:bg-gojek-dark shadow transition mt-2';
        btn.innerText = 'Konfirmasi Setoran (+)';
    } else {
        title.innerText = 'Tarik Tabungan Siswa';
        btn.className = 'w-full bg-rose-600 text-white text-xs font-bold py-3 rounded-xl hover:bg-rose-700 shadow transition mt-2';
        btn.innerText = 'Konfirmasi Penarikan (-)';
    }
}

function openTransactionModal(type) {
    setTransType(type);
    openModal('transactionModal');
}

function setTransAmount(val) {
    document.getElementById('transAmountInput').value = val;
}

function submitTransaction() {
    const studentId = document.getElementById('transStudentSelect').value;
    const amount = Number(document.getElementById('transAmountInput').value);
    const notes = document.getElementById('transNotesInput').value.trim() || 'Tabungan siswa';

    if (!amount || amount <= 0) {
        showAlertModal({
            title: 'Nominal Tidak Valid',
            message: 'Masukkan nominal tabungan yang valid (lebih dari 0)!',
            type: 'danger',
            icon: 'fa-solid fa-triangle-exclamation'
        });
        return;
    }

    const student = state.students.find(s => s.id == studentId);
    if (!student) return;

    if (state.currentTransType === 'tarik' && student.balance < amount) {
        showAlertModal({
            title: 'Saldo Tidak Cukup',
            message: 'Saldo tidak mencukupi! Saldo saat ini: Rp ' + student.balance.toLocaleString('id-ID'),
            type: 'danger',
            icon: 'fa-solid fa-wallet'
        });
        return;
    }

    const newBalance = (state.currentTransType === 'setor') ? (student.balance + amount) : (student.balance - amount);
    student.balance = newBalance;

    const now = new Date();
    const dateStr = now.toLocaleDateString('id-ID', { day: 'numeric', month: 'short', year: 'numeric', hour: '2-digit', minute: '2-digit' });
    const receiptNo = 'MH-TAB-' + now.toISOString().slice(0, 10).replace(/-/g, '') + '-' + Math.random().toString(36).substring(2, 6).toUpperCase();

    state.transactions.unshift({
        id: Date.now(),
        receipt_no: receiptNo,
        student_id: student.id,
        type: state.currentTransType,
        amount: amount,
        balance_after: newBalance,
        notes: notes,
        date: dateStr
    });

    saveState();
    updateBalanceDisplay();
    renderSavingsUI();
    renderRecentActivity();
    closeModal('transactionModal');

    showAlertModal({
        title: 'Transaksi Berhasil',
        message: `No. Kuitansi: <b>${receiptNo}</b><br>Berhasil ${state.currentTransType.toUpperCase()} Rp ${amount.toLocaleString('id-ID')} untuk ${student.name}.<br>Saldo baru: Rp ${newBalance.toLocaleString('id-ID')}`,
        type: 'success',
        icon: 'fa-solid fa-receipt',
        buttonText: 'Tutup'
    });
}

function openStudentPassbook(studentId) {
    const student = state.students.find(s => s.id == studentId);
    if (!student) return;

    document.getElementById('passbookStudentName').innerText = student.name;
    document.getElementById('passbookSubtitle').innerText = `NISN: ${student.nisn} • ${student.class_name}`;
    document.getElementById('passbookCurrentBalance').innerText = 'Rp ' + student.balance.toLocaleString('id-ID');

    const historyEl = document.getElementById('passbookHistoryList');
    const studentTrans = state.transactions.filter(t => t.student_id == studentId);

    if (studentTrans.length === 0) {
        historyEl.innerHTML = '<div class="p-6 text-center text-xs text-gray-400">Belum ada riwayat mutasi tabungan</div>';
    } else {
        historyEl.innerHTML = studentTrans.map(t => `
            <div class="py-2.5 flex items-center justify-between">
                <div class="flex items-center space-x-2">
                    <div class="w-8 h-8 rounded-xl flex items-center justify-center text-xs ${t.type === 'setor' ? 'bg-green-100 text-green-700' : 'bg-rose-100 text-rose-700'}">
                        <i class="fa-solid ${t.type === 'setor' ? 'fa-arrow-down' : 'fa-arrow-up'}"></i>
                    </div>
                    <div>
                        <div class="text-xs font-bold text-gray-800">${t.notes}</div>
                        <div class="text-[10px] text-gray-400 font-mono">No: ${t.receipt_no || 'MH-TAB-MANUAL'} • ${t.date}</div>
                    </div>
                </div>
                <div class="text-right">
                    <div class="text-xs font-black ${t.type === 'setor' ? 'text-green-600' : 'text-rose-600'}">
                        ${t.type === 'setor' ? '+' : '-'}Rp ${t.amount.toLocaleString('id-ID')}
                    </div>
                    <div class="text-[10px] text-gray-400">Saldo: Rp ${t.balance_after.toLocaleString('id-ID')}</div>
                </div>
            </div>
        `).join('');
    }

    openModal('passbookModal');
}

function renderSavingsUI() {
    const list = document.getElementById('savingsStudentList');
    if (!list) return;

    list.innerHTML = state.students.map(s => `
        <div class="py-3 flex items-center justify-between">
            <div class="flex items-center space-x-2.5">
                <div class="w-9 h-9 rounded-2xl bg-amber-100 text-amber-800 font-bold flex items-center justify-center text-xs">
                    ${s.name.charAt(0)}
                </div>
                <div>
                    <h4 class="text-xs font-bold text-gray-800">${s.name}</h4>
                    <p class="text-[10px] text-gray-400">NISN: ${s.nisn}</p>
                </div>
            </div>
            <div class="text-right flex items-center space-x-2">
                <div>
                    <span class="block text-xs font-black text-gray-900">Rp ${s.balance.toLocaleString('id-ID')}</span>
                    <button onclick="openStudentPassbook(${s.id})" class="text-[10px] text-amber-600 font-semibold hover:underline">
                        Lihat Mutasi
                    </button>
                </div>
                <button onclick="document.getElementById('transStudentSelect').value = ${s.id}; openTransactionModal('setor');" class="w-7 h-7 bg-green-50 text-green-700 hover:bg-green-100 rounded-lg flex items-center justify-center text-xs">
                    <i class="fa-solid fa-plus"></i>
                </button>
            </div>
        </div>
    `).join('');
}

function filterAnnouncements(filter) {
    document.querySelectorAll('.ann-filter-btn').forEach(btn => {
        if (btn.getAttribute('data-filter') === filter) {
            btn.className = 'ann-filter-btn active text-xs font-semibold px-3 py-1.5 rounded-full bg-gojek text-white';
        } else {
            btn.className = 'ann-filter-btn text-xs font-semibold px-3 py-1.5 rounded-full bg-gray-200 text-gray-700';
        }
    });

    renderAnnouncements(filter);
}

function renderAnnouncements(filter = 'all') {
    const container = document.getElementById('announcementsListContainer');
    const bannerContainer = document.getElementById('announcementCardsContainer');
    if (!container) return;

    let filtered = state.announcements;
    if (filter !== 'all') {
        filtered = state.announcements.filter(a => a.target === filter || a.target === 'all');
    }

    container.innerHTML = filtered.map(a => `
        <div class="bg-white p-4 rounded-2xl border border-gray-100 shadow-sm relative overflow-hidden">
            ${a.urgent ? '<div class="absolute top-0 right-0 bg-rose-500 text-white text-[9px] font-bold px-2 py-0.5 rounded-bl-lg">PENTING</div>' : ''}
            <div class="flex items-center space-x-2 mb-1.5">
                <span class="text-[10px] bg-rose-100 text-rose-700 font-bold px-2 py-0.5 rounded-full">${a.category}</span>
                <span class="text-[10px] text-gray-400">Target: ${a.target === 'teachers' ? 'Dewan Guru' : (a.target === 'parents' ? 'Wali Murid' : 'Semua')}</span>
                <span class="text-[10px] text-gray-400">• ${a.date}</span>
            </div>
            <h3 class="text-xs font-bold text-gray-800 leading-snug">${a.title}</h3>
            <p class="text-[11px] text-gray-600 mt-1 leading-relaxed">${a.content}</p>
            <div class="mt-2 pt-2 border-t border-gray-50 flex items-center justify-between text-[10px] text-gray-500">
                <span>${a.author}</span>
                <span class="text-gojek font-semibold cursor-pointer">Bagikan</span>
            </div>
        </div>
    `).join('');

    if (bannerContainer) {
        bannerContainer.innerHTML = state.announcements.slice(0, 4).map(a => `
            <div class="min-w-[260px] bg-gradient-to-br from-white to-gray-50 p-3.5 rounded-2xl border border-gray-100 shadow-sm flex-shrink-0 cursor-pointer" onclick="openTab('pengumuman')">
                <div class="flex items-center space-x-1.5 mb-1">
                    <span class="text-[9px] bg-rose-100 text-rose-700 font-bold px-1.5 py-0.5 rounded">${a.category}</span>
                    <span class="text-[9px] text-gray-400">${a.date}</span>
                </div>
                <h4 class="text-xs font-bold text-gray-800 line-clamp-1">${a.title}</h4>
                <p class="text-[10px] text-gray-500 line-clamp-2 mt-0.5">${a.content}</p>
            </div>
        `).join('');
    }
}

function submitAnnouncement() {
    const target = document.getElementById('annTargetSelect').value;
    const category = document.getElementById('annCategorySelect').value;
    const title = document.getElementById('annTitleInput').value.trim();
    const content = document.getElementById('annContentInput').value.trim();

    if (!title || !content) {
        showAlertModal({
            title: 'Form Belum Lengkap',
            message: 'Judul dan isi pengumuman wajib diisi!',
            type: 'danger',
            icon: 'fa-solid fa-triangle-exclamation'
        });
        return;
    }

    const now = new Date();
    const dateStr = now.toLocaleDateString('id-ID', { day: 'numeric', month: 'short', year: 'numeric' });

    state.announcements.unshift({
        id: Date.now(),
        title: title,
        content: content,
        target: target,
        category: category,
        author: 'KH. Ahmad Syafei, M.Pd.',
        date: dateStr,
        urgent: false
    });

    saveState();
    renderAnnouncements('all');
    closeModal('createAnnouncementModal');

    showAlertModal({
        title: 'Pengumuman Diterbitkan',
        message: 'Pengumuman resmi Kepala Sekolah berhasil dipublikasikan!',
        type: 'success',
        icon: 'fa-solid fa-bullhorn'
    });
}

function renderStudentList() {
    const list = document.getElementById('fullStudentList');
    if (!list) return;

    list.innerHTML = state.students.map(s => `
        <div class="py-3 flex items-center justify-between">
            <div class="flex items-center space-x-2.5">
                <div class="w-10 h-10 rounded-2xl bg-blue-100 text-blue-700 font-black flex items-center justify-center text-sm">
                    ${s.name.charAt(0)}
                </div>
                <div>
                    <h4 class="text-xs font-bold text-gray-800">${s.name}</h4>
                    <p class="text-[10px] text-gray-500">NISN: ${s.nisn} • ${s.gender === 'L' ? 'Laki-laki' : 'Perempuan'}</p>
                    <p class="text-[10px] text-gray-400">Wali: ${s.parent_name} (${s.parent_phone})</p>
                </div>
            </div>
            <div class="text-right flex items-center space-x-1.5">
                <button onclick="document.getElementById('nameTagStudentSelect').value = ${s.id}; openTab('nametag');" class="bg-purple-50 text-purple-700 px-2 py-1 rounded-lg text-[10px] font-bold hover:bg-purple-100">
                    <i class="fa-solid fa-id-card"></i> Name Tag
                </button>
            </div>
        </div>
    `).join('');
}

function submitNewStudent() {
    const nisn = document.getElementById('newNisnInput').value.trim();
    const name = document.getElementById('newNameInput').value.trim();
    const className = document.getElementById('newClassInput').value;
    const gender = document.getElementById('newGenderInput').value;
    const parentName = document.getElementById('newParentNameInput').value.trim();
    const parentPhone = document.getElementById('newParentPhoneInput').value.trim();

    if (!nisn || !name) {
        showAlertModal({
            title: 'Form Belum Lengkap',
            message: 'NISN dan Nama Siswa wajib diisi!',
            type: 'danger',
            icon: 'fa-solid fa-triangle-exclamation'
        });
        return;
    }

    const newStudent = {
        id: Date.now(),
        nisn: nisn,
        name: name,
        gender: gender,
        class_name: className,
        parent_name: parentName || 'Orang Tua Murid',
        parent_phone: parentPhone || '-',
        balance: 0,
        qr_code_token: 'MH-STD-' + nisn
    };

    state.students.push(newStudent);
    saveState();

    populateStudentDropdowns();
    renderStudentList();
    renderSavingsUI();
    updateAttendanceUI();
    closeModal('addStudentModal');

    showAlertModal({
        title: 'Siswa Berhasil Ditambahkan',
        message: 'Siswa baru <b>' + name + '</b> berhasil ditambahkan dan QR Name Tag telah digenerate!',
        type: 'success',
        icon: 'fa-solid fa-user-check'
    });
}

function populateStudentDropdowns() {
    const dropdowns = ['nameTagStudentSelect', 'transStudentSelect', 'simulatedStudentSelect'];
    dropdowns.forEach(id => {
        const sel = document.getElementById(id);
        if (!sel) return;
        sel.innerHTML = state.students.map(s => `
            <option value="${s.id}">${s.name} (${s.nisn}) - ${s.class_name}</option>
        `).join('');
    });
}

function renderCalendar() {
    const grid = document.getElementById('calendarDaysGrid');
    if (!grid) return;

    let html = '';
    for (let day = 1; day <= 30; day++) {
        const isToday = (day === 29);
        const isSunday = (day % 7 === 6);
        let badge = 'text-gray-700 bg-gray-50';
        if (isToday) badge = 'bg-gojek text-white font-black shadow-md';
        else if (isSunday) badge = 'bg-rose-50 text-rose-600 font-semibold';
        
        html += `
            <div class="h-10 rounded-xl flex flex-col items-center justify-center p-1 border border-gray-100 ${badge} cursor-pointer hover:border-gojek">
                <span class="text-[11px]">${day}</span>
                ${isToday ? '<span class="w-1.5 h-1.5 rounded-full bg-white mt-0.5"></span>' : ''}
            </div>
        `;
    }
    grid.innerHTML = html;
}

function downloadCsvAttendance() {
    let csv = "No,NISN,Nama Siswa,Kelas,Status Kehadiran,Jam Scan,Catatan\n";
    state.students.forEach((s, idx) => {
        const att = state.attendances.find(a => a.student_id == s.id) || { status: 'Alfa', scan_time: '-', notes: 'Tidak hadir' };
        csv += `${idx + 1},"${s.nisn}","${s.name}","${s.class_name}","${att.status}","${att.scan_time}","${att.notes}"\n`;
    });

    const blob = new Blob([csv], { type: 'text/csv;charset=utf-8;' });
    const url = URL.createObjectURL(blob);
    const link = document.createElement("a");
    link.setAttribute("href", url);
    link.setAttribute("download", "Rekap_Presensi_Kelas_7A_September_2026.csv");
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
}

function downloadCsvSavings() {
    let csv = "No,NISN,Nama Siswa,Kelas,Saldo Tabungan,Nama Wali,No HP Wali\n";
    state.students.forEach((s, idx) => {
        csv += `${idx + 1},"${s.nisn}","${s.name}","${s.class_name}",${s.balance},"${s.parent_name}","${s.parent_phone}"\n`;
    });

    const blob = new Blob([csv], { type: 'text/csv;charset=utf-8;' });
    const url = URL.createObjectURL(blob);
    const link = document.createElement("a");
    link.setAttribute("href", url);
    link.setAttribute("download", "Rekap_Tabungan_Siswa_Manbaul_Hikmah.csv");
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
}

function downloadBackupJson() {
    const data = JSON.stringify(state, null, 2);
    const blob = new Blob([data], { type: 'application/json' });
    const url = URL.createObjectURL(blob);
    const link = document.createElement("a");
    link.setAttribute("href", url);
    link.setAttribute("download", "Manbaul_Hikmah_Backup_" + Date.now() + ".json");
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
}

function renderRecentActivity() {
    const list = document.getElementById('recentActivityList');
    if (!list) return;

    list.innerHTML = state.transactions.slice(0, 5).map(t => {
        const student = state.students.find(s => s.id == t.student_id) || { name: 'Siswa' };
        return `
            <div class="py-2.5 px-3 flex items-center justify-between text-xs">
                <div class="flex items-center space-x-2.5">
                    <div class="w-8 h-8 rounded-xl flex items-center justify-center ${t.type === 'setor' ? 'bg-green-100 text-green-700' : 'bg-rose-100 text-rose-700'}">
                        <i class="fa-solid ${t.type === 'setor' ? 'fa-arrow-down' : 'fa-arrow-up'}"></i>
                    </div>
                    <div>
                        <div class="font-bold text-gray-800">${t.type === 'setor' ? 'Setoran Tabungan' : 'Penarikan Tabungan'}</div>
                        <div class="text-[10px] text-gray-400">${student.name} • ${t.notes}</div>
                    </div>
                </div>
                <div class="text-right">
                    <div class="font-bold ${t.type === 'setor' ? 'text-green-600' : 'text-rose-600'}">
                        ${t.type === 'setor' ? '+' : '-'}Rp ${t.amount.toLocaleString('id-ID')}
                    </div>
                    <div class="text-[10px] text-gray-400">${t.date.split(' ')[0]}</div>
                </div>
            </div>
        `;
    }).join('');
}

document.addEventListener('DOMContentLoaded', () => {
    updateBalanceDisplay();
    populateStudentDropdowns();
    updateAttendanceUI();
    renderStudentList();
    renderSavingsUI();
    renderAnnouncements('all');
    renderRecentActivity();
    renderCalendar();

    if (state.students.length > 0) {
        renderSelectedNameTag(state.students[0].id);
    }
});
