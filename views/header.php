<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
    <title>Manbaul Hikmah Mobile - Smart School & Presensi QR</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <script>
        tailwind.config = {
            theme: {
                extend: {
                    colors: {
                        gojek: {
                            DEFAULT: '#00AA13',
                            dark: '#00880C',
                            light: '#E6F8E8',
                            surface: '#F6FBF7',
                            badge: '#10B981'
                        },
                        gopay: {
                            blue: '#0081A0',
                            card: '#005D74',
                            badge: '#38BDF8'
                        }
                    },
                    fontFamily: {
                        sans: ['Inter', 'system-ui', 'sans-serif']
                    }
                }
            }
        }
    </script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <script src="https://cdnjs.cloudflare.com/ajax/libs/qrcodejs/1.0.0/qrcode.min.js"></script>
    <script src="https://unpkg.com/html5-qrcode" type="text/javascript"></script>
    <style>
        body { font-family: 'Inter', sans-serif; background-color: #F3F4F6; -webkit-tap-highlight-color: transparent; }
        .hide-scrollbar::-webkit-scrollbar { display: none; }
        .hide-scrollbar { -ms-overflow-style: none; scrollbar-width: none; }
        @media print {
            body * { visibility: hidden; }
            #printable-name-tag, #printable-name-tag * { visibility: visible; }
            #printable-name-tag { position: absolute; left: 0; top: 0; width: 100%; }
        }

        /* MAONEART GLASSMORPHISM MODAL SYSTEM */
        .maoneart-modal-backdrop {
            position: fixed;
            inset: 0;
            background: rgba(15, 23, 42, 0.7);
            backdrop-filter: blur(12px);
            -webkit-backdrop-filter: blur(12px);
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 20px;
            z-index: 99999;
            opacity: 0;
            visibility: hidden;
            transition: opacity 0.25s ease, visibility 0.25s ease;
        }
        .maoneart-modal-backdrop.active {
            opacity: 1;
            visibility: visible;
        }
        .maoneart-modal-card {
            background: rgba(255, 255, 255, 0.98);
            border: 1px solid rgba(255, 255, 255, 0.8);
            box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.35);
            border-radius: 28px;
            width: 100%;
            max-width: 380px;
            padding: 26px 22px;
            text-align: center;
            transform: scale(0.92) translateY(12px);
            transition: transform 0.25s cubic-bezier(0.34, 1.56, 0.64, 1);
        }
        .maoneart-modal-backdrop.active .maoneart-modal-card {
            transform: scale(1) translateY(0);
        }
        .maoneart-modal-icon-box {
            width: 60px;
            height: 60px;
            border-radius: 50%;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            font-size: 1.75rem;
            margin-bottom: 16px;
        }
        .maoneart-modal-icon-box.danger {
            background: #fee2e2;
            color: #dc2626;
        }
        .maoneart-modal-icon-box.info {
            background: #e6f8e8;
            color: #00aa13;
        }
        .maoneart-modal-icon-box.success {
            background: #d1fae5;
            color: #059669;
        }
        .maoneart-modal-title {
            font-size: 1.15rem;
            font-weight: 800;
            color: #0f172a;
            margin-bottom: 8px;
            line-height: 1.35;
        }
        .maoneart-modal-message {
            font-size: 0.85rem;
            color: #64748b;
            line-height: 1.5;
            margin-bottom: 24px;
        }
        .maoneart-modal-actions {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 12px;
            width: 100%;
        }
        .maoneart-modal-btn {
            width: 100%;
            height: 46px;
            border-radius: 14px;
            font-size: 0.88rem;
            font-weight: 800;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            cursor: pointer;
            border: none;
            transition: transform 0.15s ease;
        }
        .maoneart-modal-btn:active {
            transform: scale(0.96);
        }
        .maoneart-modal-btn.cancel {
            background: #f1f5f9;
            color: #475569;
            border: 1px solid #e2e8f0;
        }
        .maoneart-modal-btn.danger {
            background: #dc2626;
            color: #ffffff;
        }
        .maoneart-modal-btn.primary {
            background: #00aa13;
            color: #ffffff;
        }
    </style>
</head>
<body class="bg-gray-100 flex justify-center min-h-screen">
    <div class="w-full max-w-md md:max-w-3xl lg:max-w-4xl bg-white min-h-screen shadow-2xl flex flex-col relative pb-24">

        <!-- TOP HEADER (ALA GOJEK) -->
        <header class="bg-gradient-to-r from-gojek-dark to-gojek text-white p-5 rounded-b-3xl shadow-lg sticky top-0 z-30">
            <div class="flex items-center justify-between">
                <div class="flex items-center space-x-3">
                    <div class="w-12 h-12 bg-white rounded-2xl flex items-center justify-center shadow-md text-gojek font-black text-xl border-2 border-white/30">
                        <i class="fa-solid fa-graduation-cap"></i>
                    </div>
                    <div>
                        <div class="flex items-center space-x-2">
                            <span class="text-xs uppercase tracking-wider bg-white/20 text-white font-semibold px-2 py-0.5 rounded-full" id="roleBadge">Wali Kelas</span>
                            <span class="text-xs text-green-100">TP 2026/2027</span>
                        </div>
                        <h1 class="text-base font-bold leading-tight mt-0.5" id="userNameHeader">Ustadz Budi Santoso, S.Pd.</h1>
                        <p class="text-xs text-green-100 font-medium" id="schoolSubtitle">SMP & Pesantren Manbaul Hikmah</p>
                    </div>
                </div>

                <div class="relative">
                    <select id="roleSwitcher" onchange="switchDemoRole(this.value)" class="bg-white/20 text-white text-xs font-semibold px-2.5 py-1.5 rounded-xl border border-white/30 focus:outline-none focus:ring-2 focus:ring-white cursor-pointer">
                        <option value="wali_kelas" class="text-gray-800">🧑‍🏫 Wali Kelas 7A</option>
                        <option value="kepsek" class="text-gray-800">👑 Kepala Sekolah</option>
                        <option value="wali_murid" class="text-gray-800">👨‍👩‍👧 Wali Murid</option>
                    </select>
                </div>
            </div>

            <!-- GoPay Style Card: EduPay & Quick Attendance -->
            <div class="mt-4 bg-gradient-to-br from-gopay-card to-gopay-blue rounded-2xl p-4 text-white shadow-xl border border-white/20">
                <div class="flex items-center justify-between pb-3 border-b border-white/15">
                    <div class="flex items-center space-x-2">
                        <div class="w-7 h-7 bg-white/20 rounded-lg flex items-center justify-center text-xs">
                            <i class="fa-solid fa-wallet"></i>
                        </div>
                        <span class="text-xs font-semibold tracking-wide uppercase">EduPay Tabungan</span>
                    </div>
                    <div class="flex items-center space-x-1.5 text-xs text-cyan-200">
                        <span id="activeClassLabel">Kelas 7A</span>
                        <i class="fa-solid fa-circle-check text-green-400"></i>
                    </div>
                </div>

                <div class="grid grid-cols-2 gap-3 pt-3 items-center">
                    <div>
                        <div class="text-[11px] text-cyan-100 flex items-center space-x-1">
                            <span>Total Tabungan</span>
                            <button onclick="toggleBalanceVisibility()" class="focus:outline-none">
                                <i id="balanceEyeIcon" class="fa-regular fa-eye text-xs text-cyan-300"></i>
                            </button>
                        </div>
                        <div class="text-lg font-extrabold tracking-tight" id="balanceDisplay">Rp 1.640.000</div>
                    </div>
                    <div class="border-l border-white/15 pl-3">
                        <div class="text-[11px] text-cyan-100">Presensi Hari Ini</div>
                        <div class="text-sm font-bold text-green-300 flex items-center space-x-1">
                            <span id="hadirRatioText">6/8 Hadir</span>
                            <span class="text-xs bg-green-500/30 text-green-200 px-1.5 py-0.5 rounded font-medium" id="hadirPercentBadge">75%</span>
                        </div>
                    </div>
                </div>

                <!-- 4 Quick Actions (Ala GoPay Bar) -->
                <div class="grid grid-cols-4 gap-2 mt-4 pt-3 border-t border-white/15 text-center">
                    <button onclick="openTab('presensi')" class="flex flex-col items-center group">
                        <div class="w-10 h-10 bg-white text-gopay-blue rounded-xl flex items-center justify-center shadow-md group-hover:scale-105 transition">
                            <i class="fa-solid fa-qrcode text-base text-gojek-dark"></i>
                        </div>
                        <span class="text-[11px] font-semibold mt-1">Scan QR</span>
                    </button>
                    <button onclick="openModal('transactionModal'); setTransType('setor');" class="flex flex-col items-center group">
                        <div class="w-10 h-10 bg-white text-gopay-blue rounded-xl flex items-center justify-center shadow-md group-hover:scale-105 transition">
                            <i class="fa-solid fa-arrow-down-to-bracket text-base text-blue-600"></i>
                        </div>
                        <span class="text-[11px] font-semibold mt-1">Setor</span>
                    </button>
                    <button onclick="openTab('nametag')" class="flex flex-col items-center group">
                        <div class="w-10 h-10 bg-white text-gopay-blue rounded-xl flex items-center justify-center shadow-md group-hover:scale-105 transition">
                            <i class="fa-solid fa-id-badge text-base text-purple-600"></i>
                        </div>
                        <span class="text-[11px] font-semibold mt-1">Name Tag</span>
                    </button>
                    <button onclick="downloadCsvAttendance()" class="flex flex-col items-center group">
                        <div class="w-10 h-10 bg-white text-gopay-blue rounded-xl flex items-center justify-center shadow-md group-hover:scale-105 transition">
                            <i class="fa-solid fa-file-excel text-base text-emerald-600"></i>
                        </div>
                        <span class="text-[11px] font-semibold mt-1">Export</span>
                    </button>
                </div>
            </div>
        </header>

        <!-- MAIN CONTENT CONTAINER -->
        <main class="flex-1 p-4 overflow-y-auto">
