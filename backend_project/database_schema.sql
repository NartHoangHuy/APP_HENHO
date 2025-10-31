-- =====================================================
-- SQL Script để tạo database schema cho Dating App
-- Database: app_henho
-- =====================================================
-- Tạo database (nếu chưa có)
CREATE DATABASE IF NOT EXISTS app_henho CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE app_henho;
-- =====================================================
-- 1. Bảng users_userprofile (kế thừa từ Django AbstractUser)
-- =====================================================
CREATE TABLE IF NOT EXISTS users_userprofile (
    id INT PRIMARY KEY AUTO_INCREMENT,
    password VARCHAR(128) NOT NULL,
    last_login DATETIME(6) NULL,
    is_superuser TINYINT(1) NOT NULL DEFAULT 0,
    username VARCHAR(150) NOT NULL UNIQUE,
    email VARCHAR(254) NOT NULL UNIQUE,
    first_name VARCHAR(150) NOT NULL DEFAULT '',
    last_name VARCHAR(150) NOT NULL DEFAULT '',
    is_staff TINYINT(1) NOT NULL DEFAULT 0,
    is_active TINYINT(1) NOT NULL DEFAULT 1,
    date_joined DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    -- Custom fields cho Dating App
    avatar VARCHAR(100) NULL,
    bio TEXT NULL,
    birthday DATE NULL,
    gender VARCHAR(10) NULL,
    location VARCHAR(100) NULL,
    age INT NULL,
    hobbies TEXT NULL,
    INDEX idx_email (email),
    INDEX idx_username (username),
    INDEX idx_gender (gender),
    INDEX idx_age (age)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;
-- =====================================================
-- 2. Bảng users_like (Lượt thích)
-- =====================================================
CREATE TABLE IF NOT EXISTS users_like (
    id INT PRIMARY KEY AUTO_INCREMENT,
    created_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    from_user_id INT NOT NULL,
    to_user_id INT NOT NULL,
    -- Indexes để tăng performance
    INDEX idx_from_user (from_user_id),
    INDEX idx_to_user (to_user_id),
    INDEX idx_created (created_at),
    -- Unique constraint: Mỗi user chỉ like người khác 1 lần
    UNIQUE KEY unique_like (from_user_id, to_user_id),
    -- Foreign keys
    CONSTRAINT fk_like_from_user FOREIGN KEY (from_user_id) REFERENCES users_userprofile(id) ON DELETE CASCADE,
    CONSTRAINT fk_like_to_user FOREIGN KEY (to_user_id) REFERENCES users_userprofile(id) ON DELETE CASCADE
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;
-- =====================================================
-- 3. Bảng users_match (Cặp đôi match)
-- =====================================================
CREATE TABLE IF NOT EXISTS users_match (
    id INT PRIMARY KEY AUTO_INCREMENT,
    created_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    user1_id INT NOT NULL,
    user2_id INT NOT NULL,
    -- Indexes
    INDEX idx_user1 (user1_id),
    INDEX idx_user2 (user2_id),
    INDEX idx_created (created_at),
    -- Unique constraint: Mỗi cặp chỉ match 1 lần
    -- user1_id phải < user2_id để tránh duplicate
    UNIQUE KEY unique_match (user1_id, user2_id),
    -- Foreign keys
    CONSTRAINT fk_match_user1 FOREIGN KEY (user1_id) REFERENCES users_userprofile(id) ON DELETE CASCADE,
    CONSTRAINT fk_match_user2 FOREIGN KEY (user2_id) REFERENCES users_userprofile(id) ON DELETE CASCADE,
    -- Check constraint: user1_id phải < user2_id
    CONSTRAINT chk_user_order CHECK (user1_id < user2_id)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;
-- =====================================================
-- 4. Bảng django_migrations (Django internal)
-- =====================================================
CREATE TABLE IF NOT EXISTS django_migrations (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    app VARCHAR(255) NOT NULL,
    name VARCHAR(255) NOT NULL,
    applied DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;
-- =====================================================
-- 5. Bảng django_content_type (Django internal)
-- =====================================================
CREATE TABLE IF NOT EXISTS django_content_type (
    id INT PRIMARY KEY AUTO_INCREMENT,
    app_label VARCHAR(100) NOT NULL,
    model VARCHAR(100) NOT NULL,
    UNIQUE KEY django_content_type_app_label_model (app_label, model)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;
-- =====================================================
-- 6. Bảng auth_permission (Django permissions)
-- =====================================================
CREATE TABLE IF NOT EXISTS auth_permission (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL,
    content_type_id INT NOT NULL,
    codename VARCHAR(100) NOT NULL,
    UNIQUE KEY auth_permission_content_type_id_codename (content_type_id, codename),
    CONSTRAINT auth_permission_content_type_id_fk FOREIGN KEY (content_type_id) REFERENCES django_content_type(id)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;
-- =====================================================
-- 7. Bảng users_userprofile_groups (Many-to-Many)
-- =====================================================
CREATE TABLE IF NOT EXISTS users_userprofile_groups (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    userprofile_id INT NOT NULL,
    group_id INT NOT NULL,
    UNIQUE KEY users_userprofile_groups_userprofile_id_group_id (userprofile_id, group_id),
    INDEX users_userprofile_groups_group_id (group_id),
    INDEX users_userprofile_groups_userprofile_id (userprofile_id)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;
-- =====================================================
-- 8. Bảng users_userprofile_user_permissions (Many-to-Many)
-- =====================================================
CREATE TABLE IF NOT EXISTS users_userprofile_user_permissions (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    userprofile_id INT NOT NULL,
    permission_id INT NOT NULL,
    UNIQUE KEY users_userprofile_user_perm_userprofile_id_permission_id (userprofile_id, permission_id),
    INDEX users_userprofile_user_permissions_permission_id (permission_id),
    INDEX users_userprofile_user_permissions_userprofile_id (userprofile_id)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;
-- =====================================================
-- 9. Bảng django_session (Django sessions)
-- =====================================================
CREATE TABLE IF NOT EXISTS django_session (
    session_key VARCHAR(40) PRIMARY KEY,
    session_data LONGTEXT NOT NULL,
    expire_date DATETIME(6) NOT NULL,
    INDEX django_session_expire_date (expire_date)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;
-- =====================================================
-- 10. Bảng django_admin_log (Admin activity log)
-- =====================================================
CREATE TABLE IF NOT EXISTS django_admin_log (
    id INT PRIMARY KEY AUTO_INCREMENT,
    action_time DATETIME(6) NOT NULL,
    object_id LONGTEXT NULL,
    object_repr VARCHAR(200) NOT NULL,
    action_flag SMALLINT UNSIGNED NOT NULL,
    change_message LONGTEXT NOT NULL,
    content_type_id INT NULL,
    user_id INT NOT NULL,
    INDEX django_admin_log_content_type_id (content_type_id),
    INDEX django_admin_log_user_id (user_id)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;
-- =====================================================
-- Insert sample data (Optional)
-- =====================================================
-- Lưu ý: Password phải hash bằng Django's make_password()
-- Password "password123" đã hash:
-- pbkdf2_sha256$870000$<random_salt>$<hash>
-- Insert test users (sử dụng Python script create_test_users.py thay thế)
-- Vì password cần hash bằng Django
-- =====================================================
-- Useful Queries
-- =====================================================
-- Xem tất cả users:
-- SELECT id, username, email, gender, age, location FROM users_userprofile;
-- Xem likes của một user:
-- SELECT u.username, l.created_at 
-- FROM users_like l 
-- JOIN users_userprofile u ON l.from_user_id = u.id 
-- WHERE l.to_user_id = ?;
-- Xem matches của một user:
-- SELECT 
--     CASE 
--         WHEN m.user1_id = ? THEN u2.username 
--         ELSE u1.username 
--     END as match_username,
--     m.created_at
-- FROM users_match m
-- JOIN users_userprofile u1 ON m.user1_id = u1.id
-- JOIN users_userprofile u2 ON m.user2_id = u2.id
-- WHERE m.user1_id = ? OR m.user2_id = ?;
-- Kiểm tra mutual likes (chưa match):
-- SELECT 
--     l1.from_user_id as user1,
--     l1.to_user_id as user2,
--     u1.username as user1_name,
--     u2.username as user2_name
-- FROM users_like l1
-- JOIN users_like l2 
--     ON l1.from_user_id = l2.to_user_id 
--     AND l1.to_user_id = l2.from_user_id
-- LEFT JOIN users_match m 
--     ON (m.user1_id = LEAST(l1.from_user_id, l1.to_user_id) 
--         AND m.user2_id = GREATEST(l1.from_user_id, l1.to_user_id))
-- JOIN users_userprofile u1 ON l1.from_user_id = u1.id
-- JOIN users_userprofile u2 ON l1.to_user_id = u2.id
-- WHERE m.id IS NULL;
-- =====================================================
-- Indexes for Performance
-- =====================================================
-- Additional composite indexes nếu cần
-- CREATE INDEX idx_like_from_to ON users_like(from_user_id, to_user_id);
-- CREATE INDEX idx_match_users ON users_match(user1_id, user2_id);
-- =====================================================
-- DONE!
-- =====================================================
-- Sau khi chạy script này, sử dụng Django migrations:
-- python manage.py makemigrations
-- python manage.py migrate
-- python create_test_users.py