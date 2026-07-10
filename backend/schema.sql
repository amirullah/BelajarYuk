-- Skema database BelajarYuk! 2.0 (MySQL / Hostinger)
-- Import lewat phpMyAdmin atau jalankan init_db.php sekali.

-- Akun orang tua (login Google atau email/password)
CREATE TABLE IF NOT EXISTS users (
    id            BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    email         VARCHAR(191) NOT NULL UNIQUE,
    google_sub    VARCHAR(191) NULL UNIQUE,      -- ID unik Google (bila login Google)
    password_hash VARCHAR(255) NULL,             -- bila email/password
    display_name  VARCHAR(100) NULL,
    created_at    TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Profil anak (beberapa per akun). Semua mulai Kelas 1.
CREATE TABLE IF NOT EXISTS profiles (
    id             BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id        BIGINT UNSIGNED NOT NULL,
    name           VARCHAR(50) NOT NULL,          -- nama tampil (juga di leaderboard)
    avatar         VARCHAR(16) DEFAULT '🦊',
    unlocked_grade TINYINT UNSIGNED DEFAULT 1,
    total_stars    INT UNSIGNED DEFAULT 0,
    created_at     TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Progres per level per profil (bintang tertinggi).
CREATE TABLE IF NOT EXISTS progress (
    profile_id BIGINT UNSIGNED NOT NULL,
    level_id   VARCHAR(32) NOT NULL,              -- mis. "math-1-07"
    stars      TINYINT UNSIGNED DEFAULT 0,
    best_pct   TINYINT UNSIGNED DEFAULT 0,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (profile_id, level_id),
    FOREIGN KEY (profile_id) REFERENCES profiles(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Skor leaderboard mingguan per profil per kelas.
CREATE TABLE IF NOT EXISTS leaderboard (
    profile_id  BIGINT UNSIGNED NOT NULL,
    grade       TINYINT UNSIGNED NOT NULL,
    week        VARCHAR(8) NOT NULL,              -- mis. "2026-28" (tahun-minggu)
    score       INT UNSIGNED DEFAULT 0,
    updated_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (profile_id, grade, week),
    FOREIGN KEY (profile_id) REFERENCES profiles(id) ON DELETE CASCADE,
    INDEX idx_rank (grade, week, score)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
