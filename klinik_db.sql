-- --------------------------------------------------------
-- Host:                         127.0.0.1
-- Server version:               8.0.30 - MySQL Community Server - GPL
-- Server OS:                    Win64
-- HeidiSQL Version:             12.1.0.6537
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

-- Dumping structure for table klinik_uin.apoteker_apoteker
DROP TABLE IF EXISTS `apoteker_apoteker`;
CREATE TABLE IF NOT EXISTS `apoteker_apoteker` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `nama` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `nomor_lisensi` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `telepon` varchar(15) COLLATE utf8mb4_unicode_ci NOT NULL,
  `user_id` int NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `user_id` (`user_id`),
  CONSTRAINT `apoteker_apoteker_user_id_d3073348_fk_auth_user_id` FOREIGN KEY (`user_id`) REFERENCES `auth_user` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table klinik_uin.apoteker_apoteker: ~1 rows (approximately)
REPLACE INTO `apoteker_apoteker` (`id`, `nama`, `nomor_lisensi`, `telepon`, `user_id`) VALUES
	(1, 'Sigit Pratama', '12345', '081234567432', 3);

-- Dumping structure for table klinik_uin.apoteker_detailresep
DROP TABLE IF EXISTS `apoteker_detailresep`;
CREATE TABLE IF NOT EXISTS `apoteker_detailresep` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `jumlah` int NOT NULL,
  `obat_id` bigint NOT NULL,
  `resep_id` bigint NOT NULL,
  PRIMARY KEY (`id`),
  KEY `apoteker_detailresep_obat_id_e353afe3_fk_apoteker_obat_id` (`obat_id`),
  KEY `apoteker_detailresep_resep_id_18369a0c_fk_apoteker_resep_id` (`resep_id`),
  CONSTRAINT `apoteker_detailresep_obat_id_e353afe3_fk_apoteker_obat_id` FOREIGN KEY (`obat_id`) REFERENCES `apoteker_obat` (`id`),
  CONSTRAINT `apoteker_detailresep_resep_id_18369a0c_fk_apoteker_resep_id` FOREIGN KEY (`resep_id`) REFERENCES `apoteker_resep` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table klinik_uin.apoteker_detailresep: ~0 rows (approximately)

-- Dumping structure for table klinik_uin.apoteker_obat
DROP TABLE IF EXISTS `apoteker_obat`;
CREATE TABLE IF NOT EXISTS `apoteker_obat` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `nama` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `stok` int NOT NULL,
  `harga` decimal(10,2) NOT NULL,
  `deskripsi` longtext COLLATE utf8mb4_unicode_ci,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table klinik_uin.apoteker_obat: ~2 rows (approximately)
REPLACE INTO `apoteker_obat` (`id`, `nama`, `stok`, `harga`, `deskripsi`) VALUES
	(1, 'paracetamol', 2, 10000.00, ''),
	(2, 'amoxilin', 7, 20000.00, '');

-- Dumping structure for table klinik_uin.apoteker_pengeluaranobat
DROP TABLE IF EXISTS `apoteker_pengeluaranobat`;
CREATE TABLE IF NOT EXISTS `apoteker_pengeluaranobat` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `tanggal_pengeluaran` datetime(6) NOT NULL,
  `catatan` longtext COLLATE utf8mb4_unicode_ci,
  `apoteker_id` bigint NOT NULL,
  `resep_id` bigint NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `resep_id` (`resep_id`),
  KEY `apoteker_pengeluaran_apoteker_id_86f778eb_fk_apoteker_` (`apoteker_id`),
  CONSTRAINT `apoteker_pengeluaran_apoteker_id_86f778eb_fk_apoteker_` FOREIGN KEY (`apoteker_id`) REFERENCES `apoteker_apoteker` (`id`),
  CONSTRAINT `apoteker_pengeluaranobat_resep_id_97ca28f0_fk_apoteker_resep_id` FOREIGN KEY (`resep_id`) REFERENCES `apoteker_resep` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table klinik_uin.apoteker_pengeluaranobat: ~0 rows (approximately)

-- Dumping structure for table klinik_uin.apoteker_resep
DROP TABLE IF EXISTS `apoteker_resep`;
CREATE TABLE IF NOT EXISTS `apoteker_resep` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `tanggal_dibuat` datetime(6) NOT NULL,
  `status` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL,
  `catatan` longtext COLLATE utf8mb4_unicode_ci,
  `status_pembayaran` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL,
  `midtrans_transaction_id` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `dokter_id` bigint NOT NULL,
  `pasien_id` bigint NOT NULL,
  PRIMARY KEY (`id`),
  KEY `apoteker_resep_dokter_id_3e3f33f6_fk_dokter_dokter_id` (`dokter_id`),
  KEY `apoteker_resep_pasien_id_d725da38_fk_dokter_pasien_id` (`pasien_id`),
  CONSTRAINT `apoteker_resep_dokter_id_3e3f33f6_fk_dokter_dokter_id` FOREIGN KEY (`dokter_id`) REFERENCES `dokter_dokter` (`id`),
  CONSTRAINT `apoteker_resep_pasien_id_d725da38_fk_dokter_pasien_id` FOREIGN KEY (`pasien_id`) REFERENCES `dokter_pasien` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table klinik_uin.apoteker_resep: ~0 rows (approximately)

-- Dumping structure for table klinik_uin.auth_group
DROP TABLE IF EXISTS `auth_group`;
CREATE TABLE IF NOT EXISTS `auth_group` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(150) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table klinik_uin.auth_group: ~0 rows (approximately)

-- Dumping structure for table klinik_uin.auth_group_permissions
DROP TABLE IF EXISTS `auth_group_permissions`;
CREATE TABLE IF NOT EXISTS `auth_group_permissions` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `group_id` int NOT NULL,
  `permission_id` int NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `auth_group_permissions_group_id_permission_id_0cd325b0_uniq` (`group_id`,`permission_id`),
  KEY `auth_group_permissio_permission_id_84c5c92e_fk_auth_perm` (`permission_id`),
  CONSTRAINT `auth_group_permissio_permission_id_84c5c92e_fk_auth_perm` FOREIGN KEY (`permission_id`) REFERENCES `auth_permission` (`id`),
  CONSTRAINT `auth_group_permissions_group_id_b120cbf9_fk_auth_group_id` FOREIGN KEY (`group_id`) REFERENCES `auth_group` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table klinik_uin.auth_group_permissions: ~0 rows (approximately)

-- Dumping structure for table klinik_uin.auth_permission
DROP TABLE IF EXISTS `auth_permission`;
CREATE TABLE IF NOT EXISTS `auth_permission` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `content_type_id` int NOT NULL,
  `codename` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `auth_permission_content_type_id_codename_01ab375a_uniq` (`content_type_id`,`codename`),
  CONSTRAINT `auth_permission_content_type_id_2f476e4b_fk_django_co` FOREIGN KEY (`content_type_id`) REFERENCES `django_content_type` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=105 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table klinik_uin.auth_permission: ~96 rows (approximately)
REPLACE INTO `auth_permission` (`id`, `name`, `content_type_id`, `codename`) VALUES
	(1, 'Can add log entry', 1, 'add_logentry'),
	(2, 'Can change log entry', 1, 'change_logentry'),
	(3, 'Can delete log entry', 1, 'delete_logentry'),
	(4, 'Can view log entry', 1, 'view_logentry'),
	(5, 'Can add permission', 2, 'add_permission'),
	(6, 'Can change permission', 2, 'change_permission'),
	(7, 'Can delete permission', 2, 'delete_permission'),
	(8, 'Can view permission', 2, 'view_permission'),
	(9, 'Can add group', 3, 'add_group'),
	(10, 'Can change group', 3, 'change_group'),
	(11, 'Can delete group', 3, 'delete_group'),
	(12, 'Can view group', 3, 'view_group'),
	(13, 'Can add user', 4, 'add_user'),
	(14, 'Can change user', 4, 'change_user'),
	(15, 'Can delete user', 4, 'delete_user'),
	(16, 'Can view user', 4, 'view_user'),
	(17, 'Can add content type', 5, 'add_contenttype'),
	(18, 'Can change content type', 5, 'change_contenttype'),
	(19, 'Can delete content type', 5, 'delete_contenttype'),
	(20, 'Can view content type', 5, 'view_contenttype'),
	(21, 'Can add session', 6, 'add_session'),
	(22, 'Can change session', 6, 'change_session'),
	(23, 'Can delete session', 6, 'delete_session'),
	(24, 'Can view session', 6, 'view_session'),
	(25, 'Can add poli', 7, 'add_poli'),
	(26, 'Can change poli', 7, 'change_poli'),
	(27, 'Can delete poli', 7, 'delete_poli'),
	(28, 'Can view poli', 7, 'view_poli'),
	(29, 'Can add dokter', 8, 'add_dokter'),
	(30, 'Can change dokter', 8, 'change_dokter'),
	(31, 'Can delete dokter', 8, 'delete_dokter'),
	(32, 'Can view dokter', 8, 'view_dokter'),
	(33, 'Can add pasien', 9, 'add_pasien'),
	(34, 'Can change pasien', 9, 'change_pasien'),
	(35, 'Can delete pasien', 9, 'delete_pasien'),
	(36, 'Can view pasien', 9, 'view_pasien'),
	(37, 'Can add konsultasi', 10, 'add_konsultasi'),
	(38, 'Can change konsultasi', 10, 'change_konsultasi'),
	(39, 'Can delete konsultasi', 10, 'delete_konsultasi'),
	(40, 'Can view konsultasi', 10, 'view_konsultasi'),
	(41, 'Can add janji temu', 11, 'add_janjitemu'),
	(42, 'Can change janji temu', 11, 'change_janjitemu'),
	(43, 'Can delete janji temu', 11, 'delete_janjitemu'),
	(44, 'Can view janji temu', 11, 'view_janjitemu'),
	(45, 'Can add pesan konsultasi', 12, 'add_pesankonsultasi'),
	(46, 'Can change pesan konsultasi', 12, 'change_pesankonsultasi'),
	(47, 'Can delete pesan konsultasi', 12, 'delete_pesankonsultasi'),
	(48, 'Can view pesan konsultasi', 12, 'view_pesankonsultasi'),
	(49, 'Can add rekam medis', 13, 'add_rekammedis'),
	(50, 'Can change rekam medis', 13, 'change_rekammedis'),
	(51, 'Can delete rekam medis', 13, 'delete_rekammedis'),
	(52, 'Can view rekam medis', 13, 'view_rekammedis'),
	(53, 'Can add crontab', 14, 'add_crontabschedule'),
	(54, 'Can change crontab', 14, 'change_crontabschedule'),
	(55, 'Can delete crontab', 14, 'delete_crontabschedule'),
	(56, 'Can view crontab', 14, 'view_crontabschedule'),
	(57, 'Can add interval', 15, 'add_intervalschedule'),
	(58, 'Can change interval', 15, 'change_intervalschedule'),
	(59, 'Can delete interval', 15, 'delete_intervalschedule'),
	(60, 'Can view interval', 15, 'view_intervalschedule'),
	(61, 'Can add periodic task', 16, 'add_periodictask'),
	(62, 'Can change periodic task', 16, 'change_periodictask'),
	(63, 'Can delete periodic task', 16, 'delete_periodictask'),
	(64, 'Can view periodic task', 16, 'view_periodictask'),
	(65, 'Can add periodic task track', 17, 'add_periodictasks'),
	(66, 'Can change periodic task track', 17, 'change_periodictasks'),
	(67, 'Can delete periodic task track', 17, 'delete_periodictasks'),
	(68, 'Can view periodic task track', 17, 'view_periodictasks'),
	(69, 'Can add solar event', 18, 'add_solarschedule'),
	(70, 'Can change solar event', 18, 'change_solarschedule'),
	(71, 'Can delete solar event', 18, 'delete_solarschedule'),
	(72, 'Can view solar event', 18, 'view_solarschedule'),
	(73, 'Can add clocked', 19, 'add_clockedschedule'),
	(74, 'Can change clocked', 19, 'change_clockedschedule'),
	(75, 'Can delete clocked', 19, 'delete_clockedschedule'),
	(76, 'Can view clocked', 19, 'view_clockedschedule'),
	(77, 'Can add obat', 20, 'add_obat'),
	(78, 'Can change obat', 20, 'change_obat'),
	(79, 'Can delete obat', 20, 'delete_obat'),
	(80, 'Can view obat', 20, 'view_obat'),
	(81, 'Can add resep', 21, 'add_resep'),
	(82, 'Can change resep', 21, 'change_resep'),
	(83, 'Can delete resep', 21, 'delete_resep'),
	(84, 'Can view resep', 21, 'view_resep'),
	(85, 'Can add apoteker', 22, 'add_apoteker'),
	(86, 'Can change apoteker', 22, 'change_apoteker'),
	(87, 'Can delete apoteker', 22, 'delete_apoteker'),
	(88, 'Can view apoteker', 22, 'view_apoteker'),
	(89, 'Can add detail resep', 23, 'add_detailresep'),
	(90, 'Can change detail resep', 23, 'change_detailresep'),
	(91, 'Can delete detail resep', 23, 'delete_detailresep'),
	(92, 'Can view detail resep', 23, 'view_detailresep'),
	(93, 'Can add pengeluaran obat', 24, 'add_pengeluaranobat'),
	(94, 'Can change pengeluaran obat', 24, 'change_pengeluaranobat'),
	(95, 'Can delete pengeluaran obat', 24, 'delete_pengeluaranobat'),
	(96, 'Can view pengeluaran obat', 24, 'view_pengeluaranobat'),
	(97, 'Can add pemeriksaan awal', 26, 'add_pemeriksaanawal'),
	(98, 'Can change pemeriksaan awal', 26, 'change_pemeriksaanawal'),
	(99, 'Can delete pemeriksaan awal', 26, 'delete_pemeriksaanawal'),
	(100, 'Can view pemeriksaan awal', 26, 'view_pemeriksaanawal'),
	(101, 'Can add perawat', 25, 'add_perawat'),
	(102, 'Can change perawat', 25, 'change_perawat'),
	(103, 'Can delete perawat', 25, 'delete_perawat'),
	(104, 'Can view perawat', 25, 'view_perawat');

-- Dumping structure for table klinik_uin.auth_user
DROP TABLE IF EXISTS `auth_user`;
CREATE TABLE IF NOT EXISTS `auth_user` (
  `id` int NOT NULL AUTO_INCREMENT,
  `password` varchar(128) COLLATE utf8mb4_unicode_ci NOT NULL,
  `last_login` datetime(6) DEFAULT NULL,
  `is_superuser` tinyint(1) NOT NULL,
  `username` varchar(150) COLLATE utf8mb4_unicode_ci NOT NULL,
  `first_name` varchar(150) COLLATE utf8mb4_unicode_ci NOT NULL,
  `last_name` varchar(150) COLLATE utf8mb4_unicode_ci NOT NULL,
  `email` varchar(254) COLLATE utf8mb4_unicode_ci NOT NULL,
  `is_staff` tinyint(1) NOT NULL,
  `is_active` tinyint(1) NOT NULL,
  `date_joined` datetime(6) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table klinik_uin.auth_user: ~3 rows (approximately)
REPLACE INTO `auth_user` (`id`, `password`, `last_login`, `is_superuser`, `username`, `first_name`, `last_name`, `email`, `is_staff`, `is_active`, `date_joined`) VALUES
	(1, 'pbkdf2_sha256$870000$HfG7VAJTkX2cifUvY8XeEL$aurqDXNw3EnyaTqHHimF6R8VOX7sX2oB8/5d+ibUqjU=', '2025-05-16 09:44:47.482421', 1, 'admin', '', '', 'admin@klinik.com', 1, 1, '2025-05-04 04:38:57.819868'),
	(2, 'pbkdf2_sha256$870000$ECS4hK1htJ0ULwfI16lgOR$B/kbDOOmeVOULUR61cWwSl8iCRUAg7XsZ2vKu5wR33Q=', '2025-05-17 06:29:57.049129', 0, 'dokter_nadila', '', '', '', 0, 1, '2025-05-04 07:51:04.931293'),
	(3, 'pbkdf2_sha256$870000$0278VmeSqxQsGBOoQJXmcG$fk33HbeXo04RwnKjwkw8XWiygqn8Hnd6PzVbCSqw+PQ=', '2025-05-17 05:56:33.134003', 0, 'apoteker_sigit', '', '', '', 0, 1, '2025-05-04 07:55:05.151737'),
	(4, 'pbkdf2_sha256$870000$M5oincpcEuMhWIOf8e5bLH$ZL+Ezlrg72tLTPBSKiJsveL/8V4dq3YOEOrC+WJ7Pb4=', '2025-05-17 06:30:33.111127', 0, 'Farhan', '', '', 'farhan@gmail.com', 0, 1, '2025-05-04 07:57:26.057807'),
	(5, 'pbkdf2_sha256$870000$j5x8S4P2Kd9HPIU4J41ssp$qupQsZbnQ/QEZfzcXXIw/5bIpx6kSFkv+jzrFeQG1Rs=', '2025-05-17 05:53:55.453149', 0, 'perawat1', '', '', '', 0, 1, '2025-05-16 09:45:33.333333');

-- Dumping structure for table klinik_uin.auth_user_groups
DROP TABLE IF EXISTS `auth_user_groups`;
CREATE TABLE IF NOT EXISTS `auth_user_groups` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `group_id` int NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `auth_user_groups_user_id_group_id_94350c0c_uniq` (`user_id`,`group_id`),
  KEY `auth_user_groups_group_id_97559544_fk_auth_group_id` (`group_id`),
  CONSTRAINT `auth_user_groups_group_id_97559544_fk_auth_group_id` FOREIGN KEY (`group_id`) REFERENCES `auth_group` (`id`),
  CONSTRAINT `auth_user_groups_user_id_6a12ed8b_fk_auth_user_id` FOREIGN KEY (`user_id`) REFERENCES `auth_user` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table klinik_uin.auth_user_groups: ~0 rows (approximately)

-- Dumping structure for table klinik_uin.auth_user_user_permissions
DROP TABLE IF EXISTS `auth_user_user_permissions`;
CREATE TABLE IF NOT EXISTS `auth_user_user_permissions` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `permission_id` int NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `auth_user_user_permissions_user_id_permission_id_14a6b632_uniq` (`user_id`,`permission_id`),
  KEY `auth_user_user_permi_permission_id_1fbb5f2c_fk_auth_perm` (`permission_id`),
  CONSTRAINT `auth_user_user_permi_permission_id_1fbb5f2c_fk_auth_perm` FOREIGN KEY (`permission_id`) REFERENCES `auth_permission` (`id`),
  CONSTRAINT `auth_user_user_permissions_user_id_a95ead1b_fk_auth_user_id` FOREIGN KEY (`user_id`) REFERENCES `auth_user` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table klinik_uin.auth_user_user_permissions: ~0 rows (approximately)

-- Dumping structure for table klinik_uin.django_admin_log
DROP TABLE IF EXISTS `django_admin_log`;
CREATE TABLE IF NOT EXISTS `django_admin_log` (
  `id` int NOT NULL AUTO_INCREMENT,
  `action_time` datetime(6) NOT NULL,
  `object_id` longtext COLLATE utf8mb4_unicode_ci,
  `object_repr` varchar(200) COLLATE utf8mb4_unicode_ci NOT NULL,
  `action_flag` smallint unsigned NOT NULL,
  `change_message` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `content_type_id` int DEFAULT NULL,
  `user_id` int NOT NULL,
  PRIMARY KEY (`id`),
  KEY `django_admin_log_content_type_id_c4bce8eb_fk_django_co` (`content_type_id`),
  KEY `django_admin_log_user_id_c564eba6_fk_auth_user_id` (`user_id`),
  CONSTRAINT `django_admin_log_content_type_id_c4bce8eb_fk_django_co` FOREIGN KEY (`content_type_id`) REFERENCES `django_content_type` (`id`),
  CONSTRAINT `django_admin_log_user_id_c564eba6_fk_auth_user_id` FOREIGN KEY (`user_id`) REFERENCES `auth_user` (`id`),
  CONSTRAINT `django_admin_log_chk_1` CHECK ((`action_flag` >= 0))
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table klinik_uin.django_admin_log: ~8 rows (approximately)
REPLACE INTO `django_admin_log` (`id`, `action_time`, `object_id`, `object_repr`, `action_flag`, `change_message`, `content_type_id`, `user_id`) VALUES
	(1, '2025-05-04 07:51:05.578428', '2', 'dokter_nadila', 1, '[{"added": {}}]', 4, 1),
	(2, '2025-05-04 07:51:35.710516', '1', 'Gigi', 1, '[{"added": {}}]', 7, 1),
	(3, '2025-05-04 07:51:43.700542', '2', 'Umum', 1, '[{"added": {}}]', 7, 1),
	(4, '2025-05-04 07:52:57.116956', '1', 'Dewi Nadika', 1, '[{"added": {}}]', 8, 1),
	(5, '2025-05-04 07:53:30.282409', '1', 'Dewi Nadila', 2, '[{"changed": {"fields": ["Nama"]}}]', 8, 1),
	(6, '2025-05-04 07:55:05.780388', '3', 'apoteker_sigit', 1, '[{"added": {}}]', 4, 1),
	(7, '2025-05-04 07:55:48.337576', '1', 'Sigit Pratama', 1, '[{"added": {}}]', 22, 1),
	(8, '2025-05-04 08:00:50.480929', '3', 'apoteker_sigit', 2, '[{"changed": {"fields": ["password"]}}]', 4, 1),
	(9, '2025-05-16 09:45:33.983371', '5', 'perawat1', 1, '[{"added": {}}]', 4, 1),
	(10, '2025-05-16 09:58:33.027127', '1', 'Perawat', 1, '[{"added": {}}]', 25, 1);

-- Dumping structure for table klinik_uin.django_celery_beat_clockedschedule
DROP TABLE IF EXISTS `django_celery_beat_clockedschedule`;
CREATE TABLE IF NOT EXISTS `django_celery_beat_clockedschedule` (
  `id` int NOT NULL AUTO_INCREMENT,
  `clocked_time` datetime(6) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table klinik_uin.django_celery_beat_clockedschedule: ~0 rows (approximately)

-- Dumping structure for table klinik_uin.django_celery_beat_crontabschedule
DROP TABLE IF EXISTS `django_celery_beat_crontabschedule`;
CREATE TABLE IF NOT EXISTS `django_celery_beat_crontabschedule` (
  `id` int NOT NULL AUTO_INCREMENT,
  `minute` varchar(240) COLLATE utf8mb4_unicode_ci NOT NULL,
  `hour` varchar(96) COLLATE utf8mb4_unicode_ci NOT NULL,
  `day_of_week` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `day_of_month` varchar(124) COLLATE utf8mb4_unicode_ci NOT NULL,
  `month_of_year` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `timezone` varchar(63) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table klinik_uin.django_celery_beat_crontabschedule: ~0 rows (approximately)

-- Dumping structure for table klinik_uin.django_celery_beat_intervalschedule
DROP TABLE IF EXISTS `django_celery_beat_intervalschedule`;
CREATE TABLE IF NOT EXISTS `django_celery_beat_intervalschedule` (
  `id` int NOT NULL AUTO_INCREMENT,
  `every` int NOT NULL,
  `period` varchar(24) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table klinik_uin.django_celery_beat_intervalschedule: ~0 rows (approximately)

-- Dumping structure for table klinik_uin.django_celery_beat_periodictask
DROP TABLE IF EXISTS `django_celery_beat_periodictask`;
CREATE TABLE IF NOT EXISTS `django_celery_beat_periodictask` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(200) COLLATE utf8mb4_unicode_ci NOT NULL,
  `task` varchar(200) COLLATE utf8mb4_unicode_ci NOT NULL,
  `args` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `kwargs` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `queue` varchar(200) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `exchange` varchar(200) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `routing_key` varchar(200) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `expires` datetime(6) DEFAULT NULL,
  `enabled` tinyint(1) NOT NULL,
  `last_run_at` datetime(6) DEFAULT NULL,
  `total_run_count` int unsigned NOT NULL,
  `date_changed` datetime(6) NOT NULL,
  `description` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `crontab_id` int DEFAULT NULL,
  `interval_id` int DEFAULT NULL,
  `solar_id` int DEFAULT NULL,
  `one_off` tinyint(1) NOT NULL,
  `start_time` datetime(6) DEFAULT NULL,
  `priority` int unsigned DEFAULT NULL,
  `headers` longtext COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT (_utf8mb3'{}'),
  `clocked_id` int DEFAULT NULL,
  `expire_seconds` int unsigned DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`),
  KEY `django_celery_beat_p_crontab_id_d3cba168_fk_django_ce` (`crontab_id`),
  KEY `django_celery_beat_p_interval_id_a8ca27da_fk_django_ce` (`interval_id`),
  KEY `django_celery_beat_p_solar_id_a87ce72c_fk_django_ce` (`solar_id`),
  KEY `django_celery_beat_p_clocked_id_47a69f82_fk_django_ce` (`clocked_id`),
  CONSTRAINT `django_celery_beat_p_clocked_id_47a69f82_fk_django_ce` FOREIGN KEY (`clocked_id`) REFERENCES `django_celery_beat_clockedschedule` (`id`),
  CONSTRAINT `django_celery_beat_p_crontab_id_d3cba168_fk_django_ce` FOREIGN KEY (`crontab_id`) REFERENCES `django_celery_beat_crontabschedule` (`id`),
  CONSTRAINT `django_celery_beat_p_interval_id_a8ca27da_fk_django_ce` FOREIGN KEY (`interval_id`) REFERENCES `django_celery_beat_intervalschedule` (`id`),
  CONSTRAINT `django_celery_beat_p_solar_id_a87ce72c_fk_django_ce` FOREIGN KEY (`solar_id`) REFERENCES `django_celery_beat_solarschedule` (`id`),
  CONSTRAINT `django_celery_beat_periodictask_chk_1` CHECK ((`total_run_count` >= 0)),
  CONSTRAINT `django_celery_beat_periodictask_chk_2` CHECK ((`priority` >= 0)),
  CONSTRAINT `django_celery_beat_periodictask_chk_3` CHECK ((`expire_seconds` >= 0))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table klinik_uin.django_celery_beat_periodictask: ~0 rows (approximately)

-- Dumping structure for table klinik_uin.django_celery_beat_periodictasks
DROP TABLE IF EXISTS `django_celery_beat_periodictasks`;
CREATE TABLE IF NOT EXISTS `django_celery_beat_periodictasks` (
  `ident` smallint NOT NULL,
  `last_update` datetime(6) NOT NULL,
  PRIMARY KEY (`ident`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table klinik_uin.django_celery_beat_periodictasks: ~0 rows (approximately)

-- Dumping structure for table klinik_uin.django_celery_beat_solarschedule
DROP TABLE IF EXISTS `django_celery_beat_solarschedule`;
CREATE TABLE IF NOT EXISTS `django_celery_beat_solarschedule` (
  `id` int NOT NULL AUTO_INCREMENT,
  `event` varchar(24) COLLATE utf8mb4_unicode_ci NOT NULL,
  `latitude` decimal(9,6) NOT NULL,
  `longitude` decimal(9,6) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `django_celery_beat_solar_event_latitude_longitude_ba64999a_uniq` (`event`,`latitude`,`longitude`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table klinik_uin.django_celery_beat_solarschedule: ~0 rows (approximately)

-- Dumping structure for table klinik_uin.django_content_type
DROP TABLE IF EXISTS `django_content_type`;
CREATE TABLE IF NOT EXISTS `django_content_type` (
  `id` int NOT NULL AUTO_INCREMENT,
  `app_label` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `model` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `django_content_type_app_label_model_76bd3d3b_uniq` (`app_label`,`model`)
) ENGINE=InnoDB AUTO_INCREMENT=27 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table klinik_uin.django_content_type: ~26 rows (approximately)
REPLACE INTO `django_content_type` (`id`, `app_label`, `model`) VALUES
	(1, 'admin', 'logentry'),
	(22, 'apoteker', 'apoteker'),
	(23, 'apoteker', 'detailresep'),
	(20, 'apoteker', 'obat'),
	(24, 'apoteker', 'pengeluaranobat'),
	(21, 'apoteker', 'resep'),
	(3, 'auth', 'group'),
	(2, 'auth', 'permission'),
	(4, 'auth', 'user'),
	(5, 'contenttypes', 'contenttype'),
	(19, 'django_celery_beat', 'clockedschedule'),
	(14, 'django_celery_beat', 'crontabschedule'),
	(15, 'django_celery_beat', 'intervalschedule'),
	(16, 'django_celery_beat', 'periodictask'),
	(17, 'django_celery_beat', 'periodictasks'),
	(18, 'django_celery_beat', 'solarschedule'),
	(8, 'dokter', 'dokter'),
	(11, 'dokter', 'janjitemu'),
	(10, 'dokter', 'konsultasi'),
	(9, 'dokter', 'pasien'),
	(12, 'dokter', 'pesankonsultasi'),
	(7, 'dokter', 'poli'),
	(13, 'dokter', 'rekammedis'),
	(26, 'perawat', 'pemeriksaanawal'),
	(25, 'perawat', 'perawat'),
	(6, 'sessions', 'session');

-- Dumping structure for table klinik_uin.django_migrations
DROP TABLE IF EXISTS `django_migrations`;
CREATE TABLE IF NOT EXISTS `django_migrations` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `app` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `applied` datetime(6) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=45 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table klinik_uin.django_migrations: ~44 rows (approximately)
REPLACE INTO `django_migrations` (`id`, `app`, `name`, `applied`) VALUES
	(1, 'contenttypes', '0001_initial', '2025-05-04 04:37:39.013642'),
	(2, 'auth', '0001_initial', '2025-05-04 04:37:39.739389'),
	(3, 'admin', '0001_initial', '2025-05-04 04:37:39.942884'),
	(4, 'admin', '0002_logentry_remove_auto_add', '2025-05-04 04:37:39.959770'),
	(5, 'admin', '0003_logentry_add_action_flag_choices', '2025-05-04 04:37:39.979450'),
	(6, 'apoteker', '0001_initial', '2025-05-04 04:37:40.310473'),
	(7, 'dokter', '0001_initial', '2025-05-04 04:37:41.229476'),
	(8, 'apoteker', '0002_initial', '2025-05-04 04:37:41.555722'),
	(9, 'contenttypes', '0002_remove_content_type_name', '2025-05-04 04:37:41.666798'),
	(10, 'auth', '0002_alter_permission_name_max_length', '2025-05-04 04:37:41.759927'),
	(11, 'auth', '0003_alter_user_email_max_length', '2025-05-04 04:37:41.795448'),
	(12, 'auth', '0004_alter_user_username_opts', '2025-05-04 04:37:41.824026'),
	(13, 'auth', '0005_alter_user_last_login_null', '2025-05-04 04:37:41.930638'),
	(14, 'auth', '0006_require_contenttypes_0002', '2025-05-04 04:37:41.934653'),
	(15, 'auth', '0007_alter_validators_add_error_messages', '2025-05-04 04:37:41.946697'),
	(16, 'auth', '0008_alter_user_username_max_length', '2025-05-04 04:37:42.055719'),
	(17, 'auth', '0009_alter_user_last_name_max_length', '2025-05-04 04:37:42.142509'),
	(18, 'auth', '0010_alter_group_name_max_length', '2025-05-04 04:37:42.178926'),
	(19, 'auth', '0011_update_proxy_permissions', '2025-05-04 04:37:42.197359'),
	(20, 'auth', '0012_alter_user_first_name_max_length', '2025-05-04 04:37:42.292114'),
	(21, 'django_celery_beat', '0001_initial', '2025-05-04 04:37:42.531295'),
	(22, 'django_celery_beat', '0002_auto_20161118_0346', '2025-05-04 04:37:42.635078'),
	(23, 'django_celery_beat', '0003_auto_20161209_0049', '2025-05-04 04:37:42.666406'),
	(24, 'django_celery_beat', '0004_auto_20170221_0000', '2025-05-04 04:37:42.682056'),
	(25, 'django_celery_beat', '0005_add_solarschedule_events_choices', '2025-05-04 04:37:42.696003'),
	(26, 'django_celery_beat', '0006_auto_20180322_0932', '2025-05-04 04:37:42.818407'),
	(27, 'django_celery_beat', '0007_auto_20180521_0826', '2025-05-04 04:37:42.895147'),
	(28, 'django_celery_beat', '0008_auto_20180914_1922', '2025-05-04 04:37:42.940916'),
	(29, 'django_celery_beat', '0006_auto_20180210_1226', '2025-05-04 04:37:42.976873'),
	(30, 'django_celery_beat', '0006_periodictask_priority', '2025-05-04 04:37:43.077924'),
	(31, 'django_celery_beat', '0009_periodictask_headers', '2025-05-04 04:37:43.169292'),
	(32, 'django_celery_beat', '0010_auto_20190429_0326', '2025-05-04 04:37:43.374362'),
	(33, 'django_celery_beat', '0011_auto_20190508_0153', '2025-05-04 04:37:43.495009'),
	(34, 'django_celery_beat', '0012_periodictask_expire_seconds', '2025-05-04 04:37:43.590481'),
	(35, 'django_celery_beat', '0013_auto_20200609_0727', '2025-05-04 04:37:43.605536'),
	(36, 'django_celery_beat', '0014_remove_clockedschedule_enabled', '2025-05-04 04:37:43.637059'),
	(37, 'django_celery_beat', '0015_edit_solarschedule_events_choices', '2025-05-04 04:37:43.646702'),
	(38, 'django_celery_beat', '0016_alter_crontabschedule_timezone', '2025-05-04 04:37:43.658480'),
	(39, 'django_celery_beat', '0017_alter_crontabschedule_month_of_year', '2025-05-04 04:37:43.678336'),
	(40, 'django_celery_beat', '0018_improve_crontab_helptext', '2025-05-04 04:37:43.691414'),
	(41, 'django_celery_beat', '0019_alter_periodictasks_options', '2025-05-04 04:37:43.696898'),
	(42, 'sessions', '0001_initial', '2025-05-04 04:37:43.754044'),
	(43, 'dokter', '0002_janjitemu_diperiksa_perawat_and_more', '2025-05-16 09:37:46.227094'),
	(44, 'perawat', '0001_initial', '2025-05-16 09:57:48.938587');

-- Dumping structure for table klinik_uin.django_session
DROP TABLE IF EXISTS `django_session`;
CREATE TABLE IF NOT EXISTS `django_session` (
  `session_key` varchar(40) COLLATE utf8mb4_unicode_ci NOT NULL,
  `session_data` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `expire_date` datetime(6) NOT NULL,
  PRIMARY KEY (`session_key`),
  KEY `django_session_expire_date_a5c62663` (`expire_date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table klinik_uin.django_session: ~0 rows (approximately)

-- Dumping structure for table klinik_uin.dokter_dokter
DROP TABLE IF EXISTS `dokter_dokter`;
CREATE TABLE IF NOT EXISTS `dokter_dokter` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `nama` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `spesialisasi` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `jadwal_praktik` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `foto` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `user_id` int NOT NULL,
  `poli_id` bigint DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `user_id` (`user_id`),
  KEY `dokter_dokter_poli_id_309d1426_fk_dokter_poli_id` (`poli_id`),
  CONSTRAINT `dokter_dokter_poli_id_309d1426_fk_dokter_poli_id` FOREIGN KEY (`poli_id`) REFERENCES `dokter_poli` (`id`),
  CONSTRAINT `dokter_dokter_user_id_4104cacc_fk_auth_user_id` FOREIGN KEY (`user_id`) REFERENCES `auth_user` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table klinik_uin.dokter_dokter: ~1 rows (approximately)
REPLACE INTO `dokter_dokter` (`id`, `nama`, `spesialisasi`, `jadwal_praktik`, `foto`, `user_id`, `poli_id`) VALUES
	(1, 'Dewi Nadila', 'Umum', 'Senin,Selasa,Rabu', 'dokter/foto/pendaftaran_chibi.png', 2, 2);

-- Dumping structure for table klinik_uin.dokter_janjitemu
DROP TABLE IF EXISTS `dokter_janjitemu`;
CREATE TABLE IF NOT EXISTS `dokter_janjitemu` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `tanggal` datetime(6) NOT NULL,
  `status` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL,
  `keluhan_utama` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `kode_antrian` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL,
  `biaya_konsultasi` decimal(10,2) NOT NULL,
  `status_pembayaran` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `transaction_id` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `dokter_id` bigint NOT NULL,
  `pasien_id` bigint NOT NULL,
  `diperiksa_perawat` tinyint(1) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `kode_antrian` (`kode_antrian`),
  KEY `dokter_janjitemu_dokter_id_f0ebd0c9_fk_dokter_dokter_id` (`dokter_id`),
  KEY `dokter_janjitemu_pasien_id_80ecdded_fk_dokter_pasien_id` (`pasien_id`),
  CONSTRAINT `dokter_janjitemu_dokter_id_f0ebd0c9_fk_dokter_dokter_id` FOREIGN KEY (`dokter_id`) REFERENCES `dokter_dokter` (`id`),
  CONSTRAINT `dokter_janjitemu_pasien_id_80ecdded_fk_dokter_pasien_id` FOREIGN KEY (`pasien_id`) REFERENCES `dokter_pasien` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=67 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table klinik_uin.dokter_janjitemu: ~0 rows (approximately)

-- Dumping structure for table klinik_uin.dokter_konsultasi
DROP TABLE IF EXISTS `dokter_konsultasi`;
CREATE TABLE IF NOT EXISTS `dokter_konsultasi` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `tanggal_konsultasi` datetime(6) NOT NULL,
  `status` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL,
  `waktu_aktivitas_terakhir` datetime(6) DEFAULT NULL,
  `dokter_id` bigint NOT NULL,
  `pasien_id` bigint NOT NULL,
  PRIMARY KEY (`id`),
  KEY `dokter_konsultasi_dokter_id_e969fff4_fk_dokter_dokter_id` (`dokter_id`),
  KEY `dokter_konsultasi_pasien_id_655c3de7_fk_dokter_pasien_id` (`pasien_id`),
  CONSTRAINT `dokter_konsultasi_dokter_id_e969fff4_fk_dokter_dokter_id` FOREIGN KEY (`dokter_id`) REFERENCES `dokter_dokter` (`id`),
  CONSTRAINT `dokter_konsultasi_pasien_id_655c3de7_fk_dokter_pasien_id` FOREIGN KEY (`pasien_id`) REFERENCES `dokter_pasien` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table klinik_uin.dokter_konsultasi: ~1 rows (approximately)
REPLACE INTO `dokter_konsultasi` (`id`, `tanggal_konsultasi`, `status`, `waktu_aktivitas_terakhir`, `dokter_id`, `pasien_id`) VALUES
	(2, '2025-05-17 06:29:44.013314', 'Direspons', '2025-05-17 06:30:07.920783', 1, 1);

-- Dumping structure for table klinik_uin.dokter_pasien
DROP TABLE IF EXISTS `dokter_pasien`;
CREATE TABLE IF NOT EXISTS `dokter_pasien` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `nik` varchar(16) COLLATE utf8mb4_unicode_ci NOT NULL,
  `nama` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `telepon` varchar(15) COLLATE utf8mb4_unicode_ci NOT NULL,
  `email` varchar(254) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `alamat` longtext COLLATE utf8mb4_unicode_ci,
  `jenis_kelamin` varchar(10) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `metode_pembayaran` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `nama_asuransi` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `nomor_asuransi` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `tanggal_lahir` date DEFAULT NULL,
  `golongan_darah` varchar(2) COLLATE utf8mb4_unicode_ci NOT NULL,
  `berat_badan` decimal(5,1) DEFAULT NULL,
  `tinggi_badan` decimal(5,1) DEFAULT NULL,
  `riwayat_penyakit` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `riwayat_alergi` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `riwayat_pengobatan` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `obat_saat_ini` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `user_id` int NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `nik` (`nik`),
  UNIQUE KEY `user_id` (`user_id`),
  CONSTRAINT `dokter_pasien_user_id_2706a628_fk_auth_user_id` FOREIGN KEY (`user_id`) REFERENCES `auth_user` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table klinik_uin.dokter_pasien: ~1 rows (approximately)
REPLACE INTO `dokter_pasien` (`id`, `nik`, `nama`, `telepon`, `email`, `alamat`, `jenis_kelamin`, `metode_pembayaran`, `nama_asuransi`, `nomor_asuransi`, `tanggal_lahir`, `golongan_darah`, `berat_badan`, `tinggi_badan`, `riwayat_penyakit`, `riwayat_alergi`, `riwayat_pengobatan`, `obat_saat_ini`, `user_id`) VALUES
	(1, '1234132135312456', 'Farhan Fadlurahman', '081234567890', 'farhan@gmail.com', 'Jl. Bawean 3, Sukarame, Kec. Sukarame, Kota Bandar Lampung, Lampung 35131', 'L', 'Kartu Kredit', '', '', '1998-12-12', '', NULL, NULL, '', '', '', '', 4);

-- Dumping structure for table klinik_uin.dokter_pesankonsultasi
DROP TABLE IF EXISTS `dokter_pesankonsultasi`;
CREATE TABLE IF NOT EXISTS `dokter_pesankonsultasi` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `pengirim` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL,
  `isi` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `tanggal_kirim` datetime(6) NOT NULL,
  `konsultasi_id` bigint NOT NULL,
  PRIMARY KEY (`id`),
  KEY `dokter_pesankonsulta_konsultasi_id_0adfd3be_fk_dokter_ko` (`konsultasi_id`),
  CONSTRAINT `dokter_pesankonsulta_konsultasi_id_0adfd3be_fk_dokter_ko` FOREIGN KEY (`konsultasi_id`) REFERENCES `dokter_konsultasi` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table klinik_uin.dokter_pesankonsultasi: ~2 rows (approximately)
REPLACE INTO `dokter_pesankonsultasi` (`id`, `pengirim`, `isi`, `tanggal_kirim`, `konsultasi_id`) VALUES
	(3, 'Pasien', 'test\r\n', '2025-05-17 06:29:44.024909', 2),
	(4, 'Dokter', 'test\r\n', '2025-05-17 06:30:07.920783', 2);

-- Dumping structure for table klinik_uin.dokter_poli
DROP TABLE IF EXISTS `dokter_poli`;
CREATE TABLE IF NOT EXISTS `dokter_poli` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `nama` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `nama` (`nama`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table klinik_uin.dokter_poli: ~2 rows (approximately)
REPLACE INTO `dokter_poli` (`id`, `nama`) VALUES
	(1, 'Gigi'),
	(2, 'Umum');

-- Dumping structure for table klinik_uin.dokter_rekammedis
DROP TABLE IF EXISTS `dokter_rekammedis`;
CREATE TABLE IF NOT EXISTS `dokter_rekammedis` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `tanggal` datetime(6) NOT NULL,
  `diagnosa` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `catatan` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `dokter_id` bigint NOT NULL,
  `pasien_id` bigint NOT NULL,
  `resep_id` bigint DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `resep_id` (`resep_id`),
  KEY `dokter_rekammedis_dokter_id_e1292927_fk_dokter_dokter_id` (`dokter_id`),
  KEY `dokter_rekammedis_pasien_id_1030d213_fk_dokter_pasien_id` (`pasien_id`),
  CONSTRAINT `dokter_rekammedis_dokter_id_e1292927_fk_dokter_dokter_id` FOREIGN KEY (`dokter_id`) REFERENCES `dokter_dokter` (`id`),
  CONSTRAINT `dokter_rekammedis_pasien_id_1030d213_fk_dokter_pasien_id` FOREIGN KEY (`pasien_id`) REFERENCES `dokter_pasien` (`id`),
  CONSTRAINT `dokter_rekammedis_resep_id_6507e0bb_fk_apoteker_resep_id` FOREIGN KEY (`resep_id`) REFERENCES `apoteker_resep` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table klinik_uin.dokter_rekammedis: ~0 rows (approximately)

-- Dumping structure for table klinik_uin.perawat_pemeriksaanawal
DROP TABLE IF EXISTS `perawat_pemeriksaanawal`;
CREATE TABLE IF NOT EXISTS `perawat_pemeriksaanawal` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `tanggal_pemeriksaan` datetime(6) NOT NULL,
  `tekanan_darah` varchar(10) COLLATE utf8mb4_unicode_ci NOT NULL,
  `suhu_badan` decimal(4,1) DEFAULT NULL,
  `berat_badan` decimal(5,1) DEFAULT NULL,
  `tinggi_badan` decimal(5,1) DEFAULT NULL,
  `catatan` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `janji_temu_id` bigint NOT NULL,
  `perawat_id` bigint DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `janji_temu_id` (`janji_temu_id`),
  KEY `perawat_pemeriksaana_perawat_id_1a206d47_fk_perawat_p` (`perawat_id`),
  CONSTRAINT `perawat_pemeriksaana_janji_temu_id_8147ed33_fk_dokter_ja` FOREIGN KEY (`janji_temu_id`) REFERENCES `dokter_janjitemu` (`id`),
  CONSTRAINT `perawat_pemeriksaana_perawat_id_1a206d47_fk_perawat_p` FOREIGN KEY (`perawat_id`) REFERENCES `perawat_perawat` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table klinik_uin.perawat_pemeriksaanawal: ~0 rows (approximately)

-- Dumping structure for table klinik_uin.perawat_perawat
DROP TABLE IF EXISTS `perawat_perawat`;
CREATE TABLE IF NOT EXISTS `perawat_perawat` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `nama` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `telepon` varchar(15) COLLATE utf8mb4_unicode_ci NOT NULL,
  `email` varchar(254) COLLATE utf8mb4_unicode_ci NOT NULL,
  `poli_id` bigint DEFAULT NULL,
  `user_id` int NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `user_id` (`user_id`),
  KEY `perawat_perawat_poli_id_94eda255_fk_dokter_poli_id` (`poli_id`),
  CONSTRAINT `perawat_perawat_poli_id_94eda255_fk_dokter_poli_id` FOREIGN KEY (`poli_id`) REFERENCES `dokter_poli` (`id`),
  CONSTRAINT `perawat_perawat_user_id_87d0ac15_fk_auth_user_id` FOREIGN KEY (`user_id`) REFERENCES `auth_user` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table klinik_uin.perawat_perawat: ~1 rows (approximately)
REPLACE INTO `perawat_perawat` (`id`, `nama`, `telepon`, `email`, `poli_id`, `user_id`) VALUES
	(1, 'Perawat', '08123456789', 'perawat1@gmail.com', 2, 5);

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
