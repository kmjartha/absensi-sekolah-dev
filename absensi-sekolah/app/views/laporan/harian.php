<?php
$date = $date ?? date('Y-m-d');
?>
<div class="page-head d-flex justify-content-between align-items-center flex-wrap gap-2 mb-3">
  <div>
    <h2 class="mb-1">Laporan Harian</h2>
    <div class="text-muted-soft">Tanggal: <?= e($date) ?></div>
  </div>
  <form method="get" class="d-flex gap-2">
    <input type="date" name="date" class="form-control form-control-sm" value="<?= e($date) ?>">
    <button class="btn btn-primary btn-sm">Tampilkan</button>
  </form>
</div>

<div class="card-soft p-0" style="overflow-x:auto">
  <table class="table table-hover align-middle mb-0">
    <thead style="background:var(--surface-2)">
      <tr>
        <th>NIY</th><th>Nama</th><th>Tanggal</th><th>Masuk</th><th>Menit Telat</th><th>Pulang</th><th class="text-center">Status</th><th class="text-end">Match</th>
      </tr>
    </thead>
    <tbody>
      <?php if (!$rows): ?>
        <tr><td colspan="8" class="text-center text-muted-soft py-4">Tidak ada absensi pada tanggal ini.</td></tr>
      <?php endif; ?>
      <?php foreach ($rows as $r): ?>
        <tr>
          <td class="text-muted-soft"><?= e($r['niy']) ?></td>
          <td class="fw-semibold"><?= e($r['nama']) ?></td>
          <td><?= e($r['tanggal']) ?></td>
          <td><?= e(time_only($r['jam_masuk'])) ?></td>
          <td class="text-center"><?= isset($r['terlambat_menit']) && $r['terlambat_menit']!==null ? (int)$r['terlambat_menit'] : '—' ?></td>
          <td><?= $r['jam_keluar'] ? e(time_only($r['jam_keluar'])) : '—' ?></td>
          <td class="text-center"><?= status_badge($r['status']) ?></td>
          <td class="text-end text-muted-soft"><?= isset($r['face_match_masuk']) && $r['face_match_masuk']!==null ? number_format((float)$r['face_match_masuk'],3) : '—' ?></td>
        </tr>
      <?php endforeach; ?>
    </tbody>
  </table>
</div>
