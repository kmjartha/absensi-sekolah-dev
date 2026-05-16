<?php
  $u = user();
  $unreadNav = 0;
  try {
      $unreadNav = (new \App\Models\NotificationRead())->unreadCountFor((int)$u['id']);
  } catch (\Throwable $e) {}
?>
<nav class="mobile-bottom-nav">
  <a href="<?= url('/dashboard') ?>" class="<?= is_active('/dashboard') ?>">
    <i class="bi bi-house-door-fill"></i><span>Beranda</span>
  </a>
  <a href="<?= url('/absensi/riwayat') ?>" class="<?= is_active('/absensi/riwayat') ?>">
    <i class="bi bi-clock-history"></i><span>Riwayat</span>
  </a>
  <a href="<?= url('/absensi') ?>" class="center">
    <i class="bi bi-camera-fill"></i><span>Absen</span>
  </a>
  <a href="<?= url('/cuti') ?>" class="<?= is_active('/cuti') ?>">
    <i class="bi bi-calendar-event"></i><span>Cuti</span>
  </a>
  <a href="<?= url('/notifikasi') ?>" class="<?= is_active('/notifikasi') ?> nav-with-dot">
    <i class="bi bi-bell-fill"></i><span>Akun</span>
    <?php if ($unreadNav > 0): ?><span class="dot-badge"><?= $unreadNav > 9 ? '9+' : $unreadNav ?></span><?php endif; ?>
  </a>
</nav>
