"""
Script để verify database schema và data
Chạy: python verify_database.py
"""
from django.db.models import F
from django.db import connection
from users.models import UserProfile, Like, Match
import os
import django

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'backend_project.settings')
django.setup()


def print_section(title):
    print("\n" + "="*60)
    print(f"  {title}")
    print("="*60)


def verify_tables():
    """Kiểm tra tất cả tables đã tạo"""
    print_section("📊 KIỂM TRA TABLES")

    with connection.cursor() as cursor:
        cursor.execute("SHOW TABLES")
        tables = cursor.fetchall()
        table_names = [t[0] for t in tables]

        required_tables = [
            'users_userprofile',
            'users_like',
            'users_match',
            'django_migrations',
            'auth_permission'
        ]

        print(f"\n✅ Tổng số tables: {len(table_names)}")
        print("\n📋 Danh sách tables:")
        for table in sorted(table_names):
            marker = "✅" if any(
                req in table for req in required_tables) else "📄"
            print(f"   {marker} {table}")

        missing = [t for t in required_tables if t not in table_names]
        if missing:
            print(f"\n❌ Thiếu tables: {missing}")
            return False
        else:
            print(f"\n✅ Tất cả required tables đã tồn tại!")
            return True


def verify_schema():
    """Kiểm tra schema của main tables"""
    print_section("🔍 KIỂM TRA SCHEMA")

    # Check UserProfile fields
    user_fields = [f.name for f in UserProfile._meta.get_fields()]
    print(f"\n👤 UserProfile fields ({len(user_fields)}):")
    required_user_fields = ['username', 'email', 'avatar', 'bio', 'birthday',
                            'gender', 'location', 'age', 'hobbies']
    for field in required_user_fields:
        if field in user_fields:
            print(f"   ✅ {field}")
        else:
            print(f"   ❌ {field} - MISSING!")

    # Check Like fields
    like_fields = [f.name for f in Like._meta.get_fields()]
    print(f"\n❤️  Like fields ({len(like_fields)}):")
    required_like_fields = ['from_user', 'to_user', 'created_at']
    for field in required_like_fields:
        if field in like_fields:
            print(f"   ✅ {field}")
        else:
            print(f"   ❌ {field} - MISSING!")

    # Check Match fields
    match_fields = [f.name for f in Match._meta.get_fields()]
    print(f"\n💑 Match fields ({len(match_fields)}):")
    required_match_fields = ['user1', 'user2', 'created_at']
    for field in required_match_fields:
        if field in match_fields:
            print(f"   ✅ {field}")
        else:
            print(f"   ❌ {field} - MISSING!")


def verify_indexes():
    """Kiểm tra indexes"""
    print_section("🔗 KIỂM TRA INDEXES")

    with connection.cursor() as cursor:
        # Check Like indexes
        cursor.execute("SHOW INDEX FROM users_like")
        like_indexes = cursor.fetchall()
        print(f"\n❤️  users_like indexes: {len(like_indexes)}")
        for idx in like_indexes:
            print(f"   📌 {idx[2]} on {idx[4]}")

        # Check Match indexes
        cursor.execute("SHOW INDEX FROM users_match")
        match_indexes = cursor.fetchall()
        print(f"\n💑 users_match indexes: {len(match_indexes)}")
        for idx in match_indexes:
            print(f"   📌 {idx[2]} on {idx[4]}")


def verify_data():
    """Kiểm tra data trong database"""
    print_section("📦 KIỂM TRA DATA")

    total_users = UserProfile.objects.count()
    test_users = UserProfile.objects.filter(
        email__contains='@test.com').count()
    total_likes = Like.objects.count()
    total_matches = Match.objects.count()

    print(f"\n👥 Users:")
    print(f"   📊 Total: {total_users}")
    print(f"   🧪 Test users: {test_users}")

    print(f"\n❤️  Likes:")
    print(f"   📊 Total: {total_likes}")

    print(f"\n💑 Matches:")
    print(f"   📊 Total: {total_matches}")

    if total_users == 0:
        print("\n⚠️  WARNING: No users in database!")
        print("   👉 Run: python create_test_users.py")
        return False

    return True


def verify_test_users():
    """Kiểm tra chi tiết test users"""
    print_section("🧪 TEST USERS")

    test_users = UserProfile.objects.filter(
        email__contains='@test.com'
    ).order_by('id')

    if not test_users.exists():
        print("\n❌ Không có test users!")
        print("   👉 Run: python create_test_users.py")
        return

    print(f"\n📋 Danh sách {test_users.count()} test users:\n")
    print(f"{'ID':<5} {'Username':<15} {'Email':<25} {'Gender':<8} {'Age':<5} {'Location':<20}")
    print("-" * 90)

    for user in test_users:
        print(f"{user.id:<5} {user.username:<15} {user.email:<25} {user.gender or 'N/A':<8} {user.age or 'N/A':<5} {user.location or 'N/A':<20}")


def verify_relationships():
    """Kiểm tra relationships giữa tables"""
    print_section("🔗 KIỂM TRA RELATIONSHIPS")

    # Check mutual likes
    print("\n💕 Mutual likes (should create matches):")
    all_likes = Like.objects.select_related('from_user', 'to_user').all()
    mutual_count = 0

    for like in all_likes:
        reverse_exists = Like.objects.filter(
            from_user=like.to_user,
            to_user=like.from_user
        ).exists()

        if reverse_exists:
            user1, user2 = sorted(
                [like.from_user, like.to_user], key=lambda u: u.id)
            match_exists = Match.objects.filter(
                user1=user1,
                user2=user2
            ).exists()

            if match_exists:
                print(
                    f"   ✅ {like.from_user.username} ↔️ {like.to_user.username} (matched)")
            else:
                print(
                    f"   ⚠️  {like.from_user.username} ↔️ {like.to_user.username} (NOT matched!)")
                mutual_count += 1

    if mutual_count > 0:
        print(f"\n⚠️  Found {mutual_count} mutual likes without matches!")

    # Verify match integrity
    print("\n💑 Verifying matches integrity:")
    matches = Match.objects.select_related('user1', 'user2').all()

    for match in matches:
        like1 = Like.objects.filter(
            from_user=match.user1,
            to_user=match.user2
        ).exists()

        like2 = Like.objects.filter(
            from_user=match.user2,
            to_user=match.user1
        ).exists()

        if like1 and like2:
            print(f"   ✅ {match.user1.username} ↔️ {match.user2.username}")
        else:
            print(
                f"   ❌ {match.user1.username} ↔️ {match.user2.username} - MISSING LIKES!")


def verify_constraints():
    """Kiểm tra unique constraints"""
    print_section("🔒 KIỂM TRA CONSTRAINTS")

    # Check duplicate likes
    print("\n❤️  Checking duplicate likes:")
    with connection.cursor() as cursor:
        cursor.execute("""
            SELECT from_user_id, to_user_id, COUNT(*) as cnt
            FROM users_like
            GROUP BY from_user_id, to_user_id
            HAVING cnt > 1
        """)
        duplicates = cursor.fetchall()

        if duplicates:
            print(f"   ❌ Found {len(duplicates)} duplicate likes!")
            for dup in duplicates:
                print(
                    f"      From user {dup[0]} to user {dup[1]}: {dup[2]} times")
        else:
            print("   ✅ No duplicate likes")

    # Check duplicate matches
    print("\n💑 Checking duplicate matches:")
    with connection.cursor() as cursor:
        cursor.execute("""
            SELECT user1_id, user2_id, COUNT(*) as cnt
            FROM users_match
            GROUP BY user1_id, user2_id
            HAVING cnt > 1
        """)
        duplicates = cursor.fetchall()

        if duplicates:
            print(f"   ❌ Found {len(duplicates)} duplicate matches!")
            for dup in duplicates:
                print(f"      User {dup[0]} and {dup[1]}: {dup[2]} times")
        else:
            print("   ✅ No duplicate matches")

    # Check match user order
    print("\n💑 Checking match user1_id < user2_id constraint:")
    invalid_matches = Match.objects.filter(user1_id__gte=F('user2_id'))
    if invalid_matches.exists():
        print(
            f"   ❌ Found {invalid_matches.count()} matches with invalid user order!")
    else:
        print("   ✅ All matches have user1_id < user2_id")


def main():
    print("\n" + "🚀" * 30)
    print("  DATABASE VERIFICATION SCRIPT")
    print("🚀" * 30)

    # Run all checks
    tables_ok = verify_tables()
    verify_schema()
    verify_indexes()
    data_ok = verify_data()

    if data_ok:
        verify_test_users()
        verify_relationships()
        verify_constraints()

    # Final summary
    print_section("📊 SUMMARY")

    if tables_ok and data_ok:
        print("\n✅ ✅ ✅ DATABASE VERIFICATION PASSED! ✅ ✅ ✅")
        print("\n🎉 Database is ready for API testing!")
        print("\n📝 Next steps:")
        print("   1. Start server: python manage.py runserver 192.168.1.111:8000")
        print("   2. Test login: curl -X POST http://192.168.1.111:8000/api/users/login/")
        print("   3. Run Flutter app: flutter run")
    else:
        print("\n❌ ❌ ❌ DATABASE VERIFICATION FAILED! ❌ ❌ ❌")
        print("\n🔧 Fix issues and run again:")
        if not tables_ok:
            print("   👉 python manage.py migrate")
        if not data_ok:
            print("   👉 python create_test_users.py")

    print("\n" + "="*60 + "\n")


if __name__ == '__main__':
    main()
