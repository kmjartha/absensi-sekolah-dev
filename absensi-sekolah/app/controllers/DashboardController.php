<?php

namespace App\Controllers;

use App\Core\Controller;
use App\Models\Announcement;
use App\Models\Attendance;
use App\Models\User;
use App\Models\LeaveRequest;

class DashboardController extends Controller
{
    public function index(): string
    {
        $role = user_role();
        $announcements = (new Announcement())->published(5);

        if (in_array($role, ['HRD','Supervisor'], true)) return $this->renderHrd($announcements);
        if ($role === 'Kepsek') return $this->renderKepsek($announcements);
        return $this->renderPegawai($announcements);
    }

    private function renderHrd(array $announcements): string
    {
        $userModel  = new User();
        $attendance = new Attendance();
        $leave      = new LeaveRequest();

        return $this->render('dashboard.hrd', [
            'title' => 'Dashboard HRD',
            'stats' => [
                'total_karyawan' => $userModel->count('is_active = 1'),
                'today'          => $attendance->statsToday(),
                'pending_cuti'   => $leave->pendingCount(),
            ],
            'trend7'        => $attendance->last7DaysCounts(7),
            'today'         => $attendance->todayFor((int)user()['id']),
            'announcements' => $announcements,
        ]);
    }

    private function renderKepsek(array $announcements): string
    {
        $attendance = new Attendance();
        $today      = $attendance->todayFor(user()['id']);
        return $this->render('dashboard.kepsek', [
            'title'         => 'Dashboard Kepala Sekolah',
            'today'         => $today,
            'today_stats'   => $attendance->statsToday(),
            'trend7'        => $attendance->last7DaysCounts(7),
            'announcements' => $announcements,
        ]);
    }

    private function renderPegawai(array $announcements): string
    {
        $attendance = new Attendance();
        $u          = user();
        $me         = (new User())->find((int)$u['id']);
        $today      = $attendance->todayFor((int)$u['id']);
        return $this->render('dashboard.pegawai', [
            'title'         => 'Beranda',
            'today'         => $today,
            'announcements' => $announcements,
            'me'            => $me,
            'streak'        => $attendance->streakFor((int)$u['id']),
            'jam_minggu'    => $attendance->workHoursThisWeek((int)$u['id']),
        ], 'mobile');
    }
}
