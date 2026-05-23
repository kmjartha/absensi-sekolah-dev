-- =====================================================================
-- Sistem Absensi Karyawan Sekolah — Schema + Seed
-- Import file ini di phpMyAdmin (database: absensi_sekolah)
-- atau via CLI:  mysql -u root absensi_sekolah < absensi_sekolah.sql
-- =====================================================================

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- Buat database jika belum ada
CREATE DATABASE IF NOT EXISTS `absensi_sekolah`
  DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `absensi_sekolah`;

-- ================== Drop existing ==================
DROP TABLE IF EXISTS `notification_reads`;
DROP TABLE IF EXISTS `sessions`;
DROP TABLE IF EXISTS `announcements`;
DROP TABLE IF EXISTS `leave_requests`;
DROP TABLE IF EXISTS `attendances`;
DROP TABLE IF EXISTS `user_shifts`;
DROP TABLE IF EXISTS `shifts`;
DROP TABLE IF EXISTS `users`;
DROP TABLE IF EXISTS `roles`;

-- ================== roles ==================
CREATE TABLE `roles` (
  `id`    INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  `name`  VARCHAR(32) NOT NULL UNIQUE,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO `roles` (`id`,`name`) VALUES
  (1,'HRD'), (2,'Kepsek'), (3,'Guru'), (4,'Staff'), (5,'Security'), (6,'Supervisor');

-- ================== users ==================
CREATE TABLE `users` (
  `id`                  INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  `niy`                 VARCHAR(32) NOT NULL UNIQUE,
  `nama`                VARCHAR(120) NOT NULL,
  `jabatan`             VARCHAR(120) NULL,
  `role_id`             INT UNSIGNED NOT NULL,
  `email`               VARCHAR(120) NULL,
  `phone`               VARCHAR(32)  NULL,
  `foto_profile`        VARCHAR(255) NULL,            -- relatif: profile/xxx.jpg
  `face_descriptor`     TEXT NULL,                    -- JSON [128 floats]
  `jumlah_cuti`         INT NOT NULL DEFAULT 12,
  `latitude_kantor`     DECIMAL(10,7) NOT NULL DEFAULT -6.2000000,
  `longitude_kantor`    DECIMAL(10,7) NOT NULL DEFAULT 106.8166700,
  `radius_meter`        INT NOT NULL DEFAULT 100,
  `password`            VARCHAR(255) NOT NULL,
  `is_active`           TINYINT(1) NOT NULL DEFAULT 1,
  `created_at`          TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at`          TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT `fk_users_role` FOREIGN KEY (`role_id`) REFERENCES `roles`(`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Dummy users — semua password: password123 (lihat README)
-- Hash bcrypt $2y$ kompatibel dengan PHP password_verify()
INSERT INTO `users`
(`niy`,`nama`,`jabatan`,`role_id`,`email`,`phone`,`foto_profile`,`face_descriptor`,`jumlah_cuti`,`latitude_kantor`,`longitude_kantor`,`radius_meter`,`password`,`is_active`) VALUES
('HRD001','Rina Oktaviani, S.E.','Kepala HRD',1,'rina.hrd@sekolah.id','081234567001',NULL,NULL,12,-6.2000000,106.8166700,150,'$2y$10$lcA2slSt0pvPe2gGheiT9.0856D0OfMk/24nIsD9RR3O.g94iYUq2',1),
('SUP001','Agus Supervisor','Supervisor',6,'agus.supervisor@sekolah.id','081234567011',NULL,NULL,18,-6.2000000,106.8166700,150,'$2y$10$lcA2slSt0pvPe2gGheiT9.0856D0OfMk/24nIsD9RR3O.g94iYUq2',1),
('KEP001','Drs. Budi Santoso, M.Pd','Kepala Sekolah',2,'budi.kep@sekolah.id','081234567002',NULL,NULL,18,-6.2000000,106.8166700,150,'$2y$10$lcA2slSt0pvPe2gGheiT9.0856D0OfMk/24nIsD9RR3O.g94iYUq2',1),
('GUR001','Siti Aminah, S.Pd','Guru Matematika',3,'siti@sekolah.id','081234567003',NULL,NULL,12,-6.2000000,106.8166700,150,'$2y$10$lcA2slSt0pvPe2gGheiT9.0856D0OfMk/24nIsD9RR3O.g94iYUq2',1),
('GUR002','Ahmad Fauzi, S.Pd','Guru Bahasa Indonesia',3,'ahmad@sekolah.id','081234567004',NULL,NULL,12,-6.2000000,106.8166700,150,'$2y$10$lcA2slSt0pvPe2gGheiT9.0856D0OfMk/24nIsD9RR3O.g94iYUq2',1),
('GUR003','Dewi Lestari, S.Pd','Guru IPA',3,'dewi@sekolah.id','081234567005',NULL,NULL,12,-6.2000000,106.8166700,150,'$2y$10$lcA2slSt0pvPe2gGheiT9.0856D0OfMk/24nIsD9RR3O.g94iYUq2',1),
('GUR004','Eko Prasetyo, S.Pd','Guru Penjaskes',3,'eko@sekolah.id','081234567006',NULL,NULL,12,-6.2000000,106.8166700,150,'$2y$10$lcA2slSt0pvPe2gGheiT9.0856D0OfMk/24nIsD9RR3O.g94iYUq2',1),
('STF001','Linda Permata','Staff Tata Usaha',4,'linda@sekolah.id','081234567007',NULL,NULL,12,-6.2000000,106.8166700,150,'$2y$10$lcA2slSt0pvPe2gGheiT9.0856D0OfMk/24nIsD9RR3O.g94iYUq2',1),
('STF002','Rudi Hartono','Staff Perpustakaan',4,'rudi@sekolah.id','081234567008',NULL,NULL,12,-6.2000000,106.8166700,150,'$2y$10$lcA2slSt0pvPe2gGheiT9.0856D0OfMk/24nIsD9RR3O.g94iYUq2',1),
('SEC001','Joko Susilo','Security Pagi',5,'joko@sekolah.id','081234567009',NULL,NULL,12,-6.2000000,106.8166700,150,'$2y$10$lcA2slSt0pvPe2gGheiT9.0856D0OfMk/24nIsD9RR3O.g94iYUq2',1),
('SEC002','Bambang Wijaya','Security Malam',5,'bambang@sekolah.id','081234567010',NULL,NULL,12,-6.2000000,106.8166700,150,'$2y$10$lcA2slSt0pvPe2gGheiT9.0856D0OfMk/24nIsD9RR3O.g94iYUq2',1);

-- ================== shifts ==================
CREATE TABLE `shifts` (
  `id`                INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  `nama`              VARCHAR(64) NOT NULL,
  `jam_masuk`         TIME NOT NULL,
  `jam_keluar`        TIME NOT NULL,
  `toleransi_menit`   INT  NOT NULL DEFAULT 15,
  `cut_off_tanggal`   TINYINT NOT NULL DEFAULT 25,
  `is_active`         TINYINT(1) NOT NULL DEFAULT 1,
  `created_at`        TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO `shifts` (`id`,`nama`,`jam_masuk`,`jam_keluar`,`toleransi_menit`,`cut_off_tanggal`) VALUES
  (1,'Shift Pagi','07:00:00','15:00:00',15,25),
  (2,'Shift Siang','13:00:00','21:00:00',15,25),
  (3,'Shift Malam','21:00:00','06:00:00',20,25);

-- ================== user_shifts ==================
CREATE TABLE `user_shifts` (
  `id`         INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  `user_id`    INT UNSIGNED NOT NULL,
  `shift_id`   INT UNSIGNED NOT NULL,
  `hari_aktif` VARCHAR(64) DEFAULT 'Senin,Selasa,Rabu,Kamis,Jumat',
  `is_default` TINYINT(1) NOT NULL DEFAULT 1,
  CONSTRAINT `fk_us_user`  FOREIGN KEY (`user_id`)  REFERENCES `users`(`id`)  ON DELETE CASCADE,
  CONSTRAINT `fk_us_shift` FOREIGN KEY (`shift_id`) REFERENCES `shifts`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Default: semua user shift pagi; security 1 pagi, security 2 malam
INSERT INTO `user_shifts` (`user_id`,`shift_id`,`is_default`) VALUES
  (1,1,1),(2,1,1),(3,1,1),(4,1,1),(5,1,1),(6,1,1),(7,1,1),(8,1,1),(9,1,1),(10,3,1);

-- ================== attendances ==================
CREATE TABLE `attendances` (
  `id`                INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  `user_id`           INT UNSIGNED NOT NULL,
  `shift_id`          INT UNSIGNED NULL,
  `tanggal`           DATE NOT NULL,
  `jam_masuk`         DATETIME NULL,
  `jam_keluar`        DATETIME NULL,
  `foto_masuk`        VARCHAR(255) NULL,
  `foto_keluar`       VARCHAR(255) NULL,
  `lat_masuk`         DECIMAL(10,7) NULL,
  `lng_masuk`         DECIMAL(10,7) NULL,
  `lat_keluar`        DECIMAL(10,7) NULL,
  `lng_keluar`        DECIMAL(10,7) NULL,
  `face_match_masuk`  DECIMAL(5,2) NULL,
  `face_match_keluar` DECIMAL(5,2) NULL,
  `status`            ENUM('hadir','telat','izin','sakit','alpha') NOT NULL DEFAULT 'hadir',
  `keterangan`        VARCHAR(255) NULL,
  `created_at`        TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY `uniq_user_date` (`user_id`,`tanggal`),
  CONSTRAINT `fk_att_user`  FOREIGN KEY (`user_id`)  REFERENCES `users`(`id`)  ON DELETE CASCADE,
  CONSTRAINT `fk_att_shift` FOREIGN KEY (`shift_id`) REFERENCES `shifts`(`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Dummy attendance: 5 hari kebelakang untuk beberapa user
INSERT INTO `attendances` (`user_id`,`shift_id`,`tanggal`,`jam_masuk`,`jam_keluar`,`status`) VALUES
  (3,1,DATE_SUB(CURDATE(),INTERVAL 4 DAY), CONCAT(DATE_SUB(CURDATE(),INTERVAL 4 DAY),' 06:55:00'), CONCAT(DATE_SUB(CURDATE(),INTERVAL 4 DAY),' 15:05:00'),'hadir'),
  (3,1,DATE_SUB(CURDATE(),INTERVAL 3 DAY), CONCAT(DATE_SUB(CURDATE(),INTERVAL 3 DAY),' 07:20:00'), CONCAT(DATE_SUB(CURDATE(),INTERVAL 3 DAY),' 15:02:00'),'telat'),
  (3,1,DATE_SUB(CURDATE(),INTERVAL 2 DAY), CONCAT(DATE_SUB(CURDATE(),INTERVAL 2 DAY),' 06:50:00'), CONCAT(DATE_SUB(CURDATE(),INTERVAL 2 DAY),' 15:10:00'),'hadir'),
  (4,1,DATE_SUB(CURDATE(),INTERVAL 4 DAY), CONCAT(DATE_SUB(CURDATE(),INTERVAL 4 DAY),' 07:05:00'), CONCAT(DATE_SUB(CURDATE(),INTERVAL 4 DAY),' 15:00:00'),'hadir'),
  (4,1,DATE_SUB(CURDATE(),INTERVAL 3 DAY), CONCAT(DATE_SUB(CURDATE(),INTERVAL 3 DAY),' 06:58:00'), CONCAT(DATE_SUB(CURDATE(),INTERVAL 3 DAY),' 15:00:00'),'hadir'),
  (5,1,DATE_SUB(CURDATE(),INTERVAL 4 DAY), CONCAT(DATE_SUB(CURDATE(),INTERVAL 4 DAY),' 07:00:00'), CONCAT(DATE_SUB(CURDATE(),INTERVAL 4 DAY),' 15:00:00'),'hadir'),
  (7,1,DATE_SUB(CURDATE(),INTERVAL 4 DAY), CONCAT(DATE_SUB(CURDATE(),INTERVAL 4 DAY),' 06:50:00'), CONCAT(DATE_SUB(CURDATE(),INTERVAL 4 DAY),' 15:00:00'),'hadir'),
  (9,1,DATE_SUB(CURDATE(),INTERVAL 4 DAY), CONCAT(DATE_SUB(CURDATE(),INTERVAL 4 DAY),' 05:55:00'), CONCAT(DATE_SUB(CURDATE(),INTERVAL 4 DAY),' 14:00:00'),'hadir');

-- ================== leave_requests ==================
CREATE TABLE `leave_requests` (
  `id`              INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  `user_id`         INT UNSIGNED NOT NULL,
  `jenis`           ENUM('sakit','tahunan','melahirkan','menikah') NOT NULL,
  `tanggal_mulai`   DATE NOT NULL,
  `tanggal_selesai` DATE NOT NULL,
  `alasan`          TEXT NOT NULL,
  `file_surat`      VARCHAR(255) NULL,
  `status`          ENUM('pending','approved','rejected') NOT NULL DEFAULT 'pending',
  `verified_by`     INT UNSIGNED NULL,
  `catatan`         VARCHAR(500) NULL,
  `created_at`      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at`      TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT `fk_leave_user`     FOREIGN KEY (`user_id`)     REFERENCES `users`(`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_leave_verifier` FOREIGN KEY (`verified_by`) REFERENCES `users`(`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO `leave_requests` (`user_id`,`jenis`,`tanggal_mulai`,`tanggal_selesai`,`alasan`,`status`) VALUES
  (3,'sakit',  DATE_SUB(CURDATE(),INTERVAL 10 DAY), DATE_SUB(CURDATE(),INTERVAL 9 DAY), 'Demam tinggi, ada surat dokter terlampir.','approved'),
  (4,'tahunan',DATE_ADD(CURDATE(),INTERVAL 7 DAY),  DATE_ADD(CURDATE(),INTERVAL 9 DAY), 'Acara keluarga di luar kota.','pending'),
  (7,'menikah',DATE_ADD(CURDATE(),INTERVAL 14 DAY), DATE_ADD(CURDATE(),INTERVAL 16 DAY),'Pernikahan saudara kandung.','pending');

-- ================== announcements ==================
CREATE TABLE `announcements` (
  `id`            INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  `judul`         VARCHAR(180) NOT NULL,
  `isi`           TEXT NOT NULL,
  `image`         VARCHAR(255) NULL,
  `is_published`  TINYINT(1) NOT NULL DEFAULT 1,
  `created_by`    INT UNSIGNED NULL,
  `created_at`    TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at`    TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT `fk_ann_creator` FOREIGN KEY (`created_by`) REFERENCES `users`(`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO `announcements` (`judul`,`isi`,`is_published`,`created_by`) VALUES
  ('Selamat Datang di SiAbsen 🎉','Sistem absensi sekolah berbasis selfie + GPS + face recognition resmi diluncurkan. Silakan login untuk mencoba.',1,1),
  ('Aturan Toleransi Telat','Mulai bulan ini, batas toleransi keterlambatan adalah 15 menit. Lebih dari itu akan tercatat sebagai TELAT.',1,1);

-- ================== sessions (Remember Me / log) ==================
CREATE TABLE `sessions` (
  `id`         BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  `user_id`    INT UNSIGNED NOT NULL,
  `token`      VARCHAR(128) NOT NULL UNIQUE,
  `ip`         VARCHAR(64) NULL,
  `user_agent` VARCHAR(255) NULL,
  `expires_at` DATETIME NOT NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT `fk_sess_user` FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ================== notification_reads ==================
-- Tracking notifikasi yang sudah dibaca per user.
-- type: 'announcement' | 'leave_status'
-- ref_id: id record terkait (announcements.id atau leave_requests.id)
CREATE TABLE `notification_reads` (
  `id`        BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  `user_id`   INT UNSIGNED NOT NULL,
  `type`      VARCHAR(32)  NOT NULL,
  `ref_id`    INT UNSIGNED NOT NULL,
  `read_at`   TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY `uniq_user_type_ref` (`user_id`,`type`,`ref_id`),
  CONSTRAINT `fk_notif_user` FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

SET FOREIGN_KEY_CHECKS = 1;

-- =====================================================================
-- Selesai. Database siap digunakan.
-- Login pakai NIY mana pun di atas, password: password123
-- =====================================================================
