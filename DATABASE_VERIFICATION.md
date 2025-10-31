# 🔍 Database Verification Guide

## Kiểm Tra Database đã Setup Đúng

### 1. Kiểm tra Migrations
```bash
cd D:\flutter\App_HenHo\backend_project
python manage.py showmigrations users
```

**Expected Output:**
```
users
 [X] 0001_initial
 [X] 0002_alter_userprofile_options_alter_userprofile_managers_and_more
 [X] 0003_alter_userprofile_bio_alter_userprofile_gender
 [X] 0004_userprofile_age_userprofile_hobbies_and_more
 [X] 0005_like_match
```

✅ Tất cả migrations đã apply (có dấu [X])

---

### 2. Kiểm tra Tables trong MySQL

**Kết nối MySQL:**
```bash
mysql -u root -p
use app_henho;
```

**List all tables:**
```sql
SHOW TABLES;
```

**Expected Tables:**
```
+----------------------------+
| Tables_in_app_henho        |
+----------------------------+
| auth_group                 |
| auth_permission            |
| django_admin_log           |
| django_content_type        |
| django_migrations          |
| django_session             |
| users_like                 |
| users_match                |
| users_userprofile          |
| users_userprofile_groups   |
| users_userprofile_user_... |
+----------------------------+
```

---

### 3. Verify Schema của Main Tables

**Check users_userprofile:**
```sql
DESCRIBE users_userprofile;
```

**Expected Columns:**
```
+-------------+--------------+------+-----+
| Field       | Type         | Null | Key |
+-------------+--------------+------+-----+
| id          | int          | NO   | PRI |
| password    | varchar(128) | NO   |     |
| last_login  | datetime(6)  | YES  |     |
| is_superuser| tinyint(1)   | NO   |     |
| username    | varchar(150) | NO   | UNI |
| email       | varchar(254) | NO   | UNI |
| first_name  | varchar(150) | NO   |     |
| last_name   | varchar(150) | NO   |     |
| is_staff    | tinyint(1)   | NO   |     |
| is_active   | tinyint(1)   | NO   |     |
| date_joined | datetime(6)  | NO   |     |
| avatar      | varchar(100) | YES  |     |
| bio         | longtext     | YES  |     |
| birthday    | date         | YES  |     |
| gender      | varchar(10)  | YES  |     |
| location    | varchar(100) | YES  |     |
| age         | int          | YES  |     |
| hobbies     | longtext     | YES  |     |
+-------------+--------------+------+-----+
```

**Check users_like:**
```sql
DESCRIBE users_like;
```

**Expected Columns:**
```
+--------------+-------------+------+-----+
| Field        | Type        | Null | Key |
+--------------+-------------+------+-----+
| id           | int         | NO   | PRI |
| created_at   | datetime(6) | NO   |     |
| from_user_id | int         | NO   | MUL |
| to_user_id   | int         | NO   | MUL |
+--------------+-------------+------+-----+
```

**Check constraints:**
```sql
SHOW CREATE TABLE users_like;
```

**Should have:**
- UNIQUE constraint on `(from_user_id, to_user_id)`
- Foreign key to `users_userprofile(id)`
- Index on `from_user_id` and `to_user_id`

**Check users_match:**
```sql
DESCRIBE users_match;
```

**Expected Columns:**
```
+------------+-------------+------+-----+
| Field      | Type        | Null | Key |
+------------+-------------+------+-----+
| id         | int         | NO   | PRI |
| created_at | datetime(6) | NO   |     |
| user1_id   | int         | NO   | MUL |
| user2_id   | int         | NO   | MUL |
+------------+-------------+------+-----+
```

---

### 4. Verify Test Data

**Count users:**
```sql
SELECT COUNT(*) as total_users FROM users_userprofile;
```
Expected: `16` users (4 admin/existing + 12 test users)

**Count likes:**
```sql
SELECT COUNT(*) as total_likes FROM users_like;
```
Expected: `34` likes

**Count matches:**
```sql
SELECT COUNT(*) as total_matches FROM users_match;
```
Expected: `5` matches

**List test users:**
```sql
SELECT id, username, email, gender, age, location 
FROM users_userprofile 
WHERE email LIKE '%@test.com'
ORDER BY id;
```

**Expected Output:**
```
+----+--------------+----------------------+--------+-----+-------------------+
| id | username     | email                | gender | age | location          |
+----+--------------+----------------------+--------+-----+-------------------+
|  5 | Mai Lan      | mailan@test.com      | female |  23 | Hà Nội            |
|  6 | Minh Tuấn    | minhtuan@test.com    | male   |  27 | TP. Hồ Chí Minh   |
|  7 | Lan Anh      | lananh@test.com      | female |  24 | Đà Nẵng           |
|  8 | Hoàng Nam    | hoangnam@test.com    | male   |  28 | Hà Nội            |
|  9 | Thu Hà       | thuha@test.com       | female |  22 | Hải Phòng         |
| 10 | Quang Huy    | quanghuy@test.com    | male   |  26 | Đà Nẵng           |
| 11 | Phương Anh   | phuonganh@test.com   | female |  25 | TP. Hồ Chí Minh   |
| 12 | Đức Anh      | ducanh@test.com      | male   |  29 | Hà Nội            |
| 13 | Ngọc Mai     | ngocmai@test.com     | female |  23 | Cần Thơ           |
| 14 | Bảo Long     | baolong@test.com     | male   |  30 | TP. Hồ Chí Minh   |
| 15 | Khánh Linh   | khanhlinh@test.com   | female |  24 | Hà Nội            |
| 16 | Anh Tuấn     | anhtuan@test.com     | male   |  28 | Đà Nẵng           |
+----+--------------+----------------------+--------+-----+-------------------+
```

---

### 5. Verify Likes Relationships

**View who liked whom:**
```sql
SELECT 
    l.id,
    u1.username as from_user,
    u2.username as to_user,
    l.created_at
FROM users_like l
JOIN users_userprofile u1 ON l.from_user_id = u1.id
JOIN users_userprofile u2 ON l.to_user_id = u2.id
ORDER BY l.created_at DESC
LIMIT 10;
```

**Find mutual likes (should be matches):**
```sql
SELECT 
    u1.username as user1,
    u2.username as user2,
    l1.created_at as user1_liked_at,
    l2.created_at as user2_liked_at
FROM users_like l1
JOIN users_like l2 
    ON l1.from_user_id = l2.to_user_id 
    AND l1.to_user_id = l2.from_user_id
JOIN users_userprofile u1 ON l1.from_user_id = u1.id
JOIN users_userprofile u2 ON l1.to_user_id = u2.id
WHERE l1.from_user_id < l1.to_user_id;
```

---

### 6. Verify Matches

**View all matches:**
```sql
SELECT 
    m.id,
    u1.username as user1,
    u2.username as user2,
    m.created_at
FROM users_match m
JOIN users_userprofile u1 ON m.user1_id = u1.id
JOIN users_userprofile u2 ON m.user2_id = u2.id
ORDER BY m.created_at DESC;
```

**Verify match integrity:**
```sql
-- Mỗi match phải có 2 likes tương ứng
SELECT 
    m.id as match_id,
    m.user1_id,
    m.user2_id,
    (SELECT COUNT(*) FROM users_like WHERE 
        (from_user_id = m.user1_id AND to_user_id = m.user2_id) OR
        (from_user_id = m.user2_id AND to_user_id = m.user1_id)
    ) as like_count
FROM users_match m;
-- like_count phải = 2
```

---

### 7. Test Queries Used by API

**Discover Query (loại trừ đã like/match):**
```sql
-- Giả sử user_id = 5 (Mai Lan)
SELECT DISTINCT u.id, u.username, u.age, u.gender, u.location
FROM users_userprofile u
WHERE u.id != 5
AND u.id NOT IN (
    -- Đã like
    SELECT to_user_id FROM users_like WHERE from_user_id = 5
)
AND u.id NOT IN (
    -- Đã match
    SELECT user2_id FROM users_match WHERE user1_id = 5
    UNION
    SELECT user1_id FROM users_match WHERE user2_id = 5
)
ORDER BY RAND()
LIMIT 20;
```

**Get Likes Received:**
```sql
SELECT 
    l.id,
    u.id as from_user_id,
    u.username,
    u.age,
    u.gender,
    u.avatar,
    l.created_at
FROM users_like l
JOIN users_userprofile u ON l.from_user_id = u.id
WHERE l.to_user_id = 5  -- Mai Lan
ORDER BY l.created_at DESC;
```

**Get Matches:**
```sql
SELECT 
    m.id,
    CASE 
        WHEN m.user1_id = 5 THEN m.user2_id
        ELSE m.user1_id
    END as other_user_id,
    CASE 
        WHEN m.user1_id = 5 THEN u2.username
        ELSE u1.username
    END as other_username,
    m.created_at
FROM users_match m
JOIN users_userprofile u1 ON m.user1_id = u1.id
JOIN users_userprofile u2 ON m.user2_id = u2.id
WHERE m.user1_id = 5 OR m.user2_id = 5
ORDER BY m.created_at DESC;
```

---

### 8. Common Issues & Solutions

#### Issue 1: No tables found
```bash
# Re-run migrations
python manage.py migrate users
```

#### Issue 2: Test users not created
```bash
# Run create script
python create_test_users.py
```

#### Issue 3: Foreign key constraints fail
```sql
-- Check for orphaned records
SELECT l.* FROM users_like l
LEFT JOIN users_userprofile u1 ON l.from_user_id = u1.id
LEFT JOIN users_userprofile u2 ON l.to_user_id = u2.id
WHERE u1.id IS NULL OR u2.id IS NULL;
```

#### Issue 4: Match without likes
```sql
-- Find matches without corresponding likes
SELECT m.* FROM users_match m
WHERE NOT EXISTS (
    SELECT 1 FROM users_like 
    WHERE (from_user_id = m.user1_id AND to_user_id = m.user2_id)
    OR (from_user_id = m.user2_id AND to_user_id = m.user1_id)
);
```

---

### 9. Performance Check

**Check indexes:**
```sql
SHOW INDEX FROM users_like;
SHOW INDEX FROM users_match;
SHOW INDEX FROM users_userprofile;
```

**Explain query performance:**
```sql
EXPLAIN SELECT * FROM users_userprofile 
WHERE gender = 'female' AND age BETWEEN 20 AND 30;
```

---

### 10. Cleanup Commands (if needed)

**Delete test data only:**
```sql
-- Delete matches involving test users
DELETE FROM users_match WHERE user1_id >= 5 OR user2_id >= 5;

-- Delete likes involving test users
DELETE FROM users_like WHERE from_user_id >= 5 OR to_user_id >= 5;

-- Delete test users
DELETE FROM users_userprofile WHERE email LIKE '%@test.com';
```

**Reset auto increment:**
```sql
ALTER TABLE users_userprofile AUTO_INCREMENT = 1;
ALTER TABLE users_like AUTO_INCREMENT = 1;
ALTER TABLE users_match AUTO_INCREMENT = 1;
```

---

## ✅ Checklist

- [ ] All migrations applied ([X] in showmigrations)
- [ ] All tables exist (11 tables)
- [ ] users_userprofile has 17 columns
- [ ] users_like has unique constraint
- [ ] users_match has user1_id < user2_id logic
- [ ] 12+ users in database
- [ ] 30+ likes in database
- [ ] 5+ matches in database
- [ ] Foreign keys working
- [ ] Indexes created
- [ ] Test queries run successfully

---

## 🎯 Next: Test API Endpoints

Once database is verified, test with curl:

```bash
# Login
curl -X POST http://192.168.1.111:8000/api/users/login/ \
  -H "Content-Type: application/json" \
  -d '{"email":"mailan@test.com","password":"password123"}'

# Get discover list (replace TOKEN)
curl -X GET "http://192.168.1.111:8000/api/users/discover/" \
  -H "Authorization: Bearer TOKEN"
```

Xem thêm trong file: `FIX_403_GUIDE.md`
