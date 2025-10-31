"""
Script để tạo dummy users với đầy đủ thông tin cho Dating App
Chạy: python create_test_users.py
"""
from datetime import date, timedelta
import random
from django.utils import timezone
from users.models import UserProfile, Like, Match
import os
import django

# Setup Django
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'backend_project.settings')
django.setup()


# Xóa data cũ
print("🗑️  Xóa data cũ...")
Like.objects.all().delete()
Match.objects.all().delete()
# Giữ lại user hiện tại, chỉ xóa test users
UserProfile.objects.filter(email__contains='test').delete()

print("\n👥 Tạo test users với đầy đủ thông tin...")

users_data = [
    {
        'username': 'Mai Lan',
        'email': 'mailan@test.com',
        'age': 23,
        'gender': 'female',
        'location': 'Hà Nội',
        'bio': 'Thích nghệ thuật, du lịch khắp nơi. Yêu những điều đơn giản trong cuộc sống. Tìm kiếm một người đồng hành chân thành.',
        'hobbies': 'Nghệ thuật, Du lịch, Ẩm thực',
        'birthday': date(2001, 5, 15),
    },
    {
        'username': 'Minh Tuấn',
        'email': 'minhtuan@test.com',
        'age': 27,
        'gender': 'male',
        'location': 'TP. Hồ Chí Minh',
        'bio': 'Developer, thích công nghệ và thể thao. Tìm kiếm người đồng hành để chia sẻ niềm vui và khó khăn.',
        'hobbies': 'Công nghệ, Thể thao, Xem phim',
        'birthday': date(1997, 8, 20),
    },
    {
        'username': 'Lan Anh',
        'email': 'lananh@test.com',
        'age': 24,
        'gender': 'female',
        'location': 'Đà Nẵng',
        'bio': 'Yêu thích du lịch và khám phá những điều mới mẻ. Photographer nghiệp dư, thích bắt trọn khoảnh khắc đẹp.',
        'hobbies': 'Du lịch, Chụp ảnh, Bơi lội',
        'birthday': date(2000, 3, 10),
    },
    {
        'username': 'Hoàng Nam',
        'email': 'hoangnam@test.com',
        'age': 28,
        'gender': 'male',
        'location': 'Hà Nội',
        'bio': 'Kỹ sư phần mềm, thích đọc sách và tập gym. Yêu thích sự tĩnh lặng và không gian riêng tư.',
        'hobbies': 'Đọc sách, Thể thao, Công nghệ',
        'birthday': date(1996, 11, 25),
    },
    {
        'username': 'Thu Hà',
        'email': 'thuha@test.com',
        'age': 22,
        'gender': 'female',
        'location': 'Hải Phòng',
        'bio': 'Yêu âm nhạc và nghệ thuật. Chơi piano và guitar. Tìm kiếm người cùng đam mê âm nhạc.',
        'hobbies': 'Nhạc cụ, Nghệ thuật, Xem phim',
        'birthday': date(2002, 7, 8),
    },
    {
        'username': 'Quang Huy',
        'email': 'quanghuy@test.com',
        'age': 26,
        'gender': 'male',
        'location': 'Đà Nẵng',
        'bio': 'Photographer chuyên nghiệp, yêu thích bắt trọn những khoảnh khắc đẹp. Thích khám phá và trải nghiệm.',
        'hobbies': 'Chụp ảnh, Du lịch, Ẩm thực',
        'birthday': date(1998, 4, 18),
    },
    {
        'username': 'Phương Anh',
        'email': 'phuonganh@test.com',
        'age': 25,
        'gender': 'female',
        'location': 'TP. Hồ Chí Minh',
        'bio': 'Food blogger, yêu ẩm thực Việt Nam và thế giới. Thích nấu ăn và khám phá món mới.',
        'hobbies': 'Ẩm thực, Du lịch, Xem phim',
        'birthday': date(1999, 12, 30),
    },
    {
        'username': 'Đức Anh',
        'email': 'ducanh@test.com',
        'age': 29,
        'gender': 'male',
        'location': 'Hà Nội',
        'bio': 'Startup founder, yêu thích thử thách và học hỏi. Tìm kiếm người đồng hành có tư duy tích cực.',
        'hobbies': 'Công nghệ, Đọc sách, Thể thao',
        'birthday': date(1995, 9, 5),
    },
    {
        'username': 'Ngọc Mai',
        'email': 'ngocmai@test.com',
        'age': 23,
        'gender': 'female',
        'location': 'Cần Thơ',
        'bio': 'Giáo viên, yêu trẻ con và những điều tích cực. Thích đọc sách và du lịch cuối tuần.',
        'hobbies': 'Đọc sách, Du lịch, Nghệ thuật',
        'birthday': date(2001, 6, 22),
    },
    {
        'username': 'Bảo Long',
        'email': 'baolong@test.com',
        'age': 30,
        'gender': 'male',
        'location': 'TP. Hồ Chí Minh',
        'bio': 'Doanh nhân, thích thể thao và du lịch. Yêu thích cuộc sống năng động và đầy thử thách.',
        'hobbies': 'Thể thao, Du lịch, Ẩm thực',
        'birthday': date(1994, 2, 14),
    },
    {
        'username': 'Khánh Linh',
        'email': 'khanhlinh@test.com',
        'age': 24,
        'gender': 'female',
        'location': 'Hà Nội',
        'bio': 'Marketing Manager, yêu thích sáng tạo và giao tiếp. Thích cafe và trò chuyện cùng bạn bè.',
        'hobbies': 'Xem phim, Ẩm thực, Du lịch',
        'birthday': date(2000, 10, 3),
    },
    {
        'username': 'Anh Tuấn',
        'email': 'anhtuan@test.com',
        'age': 28,
        'gender': 'male',
        'location': 'Đà Nẵng',
        'bio': 'Kiến trúc sư, đam mê thiết kế và nghệ thuật. Tìm kiếm người cùng tần số để chia sẻ đam mê.',
        'hobbies': 'Nghệ thuật, Chụp ảnh, Du lịch',
        'birthday': date(1996, 1, 28),
    },
]

created_users = []
for i, user_data in enumerate(users_data):
    user, created = UserProfile.objects.get_or_create(
        email=user_data['email'],
        defaults={
            'username': user_data['username'],
            'age': user_data['age'],
            'gender': user_data['gender'],
            'location': user_data['location'],
            'bio': user_data['bio'],
            'hobbies': user_data['hobbies'],
            'birthday': user_data['birthday'],
        }
    )
    if created:
        user.set_password('password123')
        user.save()
        print(f"   ✅ Created: {user.username} ({user.email})")
    else:
        # Update nếu đã tồn tại
        user.username = user_data['username']
        user.age = user_data['age']
        user.gender = user_data['gender']
        user.location = user_data['location']
        user.bio = user_data['bio']
        user.hobbies = user_data['hobbies']
        user.birthday = user_data['birthday']
        user.save()
        print(f"   🔄 Updated: {user.username} ({user.email})")
    created_users.append(user)

# Tạo likes ngẫu nhiên
print("\n❤️  Tạo likes giữa các users...")
like_count = 0
for i, from_user in enumerate(created_users):
    # Mỗi user like 2-4 người khác
    num_likes = random.randint(2, 4)
    potential_targets = [u for u in created_users if u != from_user]
    targets = random.sample(potential_targets, min(
        num_likes, len(potential_targets)))

    for to_user in targets:
        like, created = Like.objects.get_or_create(
            from_user=from_user,
            to_user=to_user
        )
        if created:
            like_count += 1

print(f"   ✅ Đã tạo {like_count} likes")

# Tạo matches từ likes có đi có lại
print("\n💑 Tạo matches...")
match_count = 0
all_likes = Like.objects.all()

for like in all_likes:
    reverse_like = Like.objects.filter(
        from_user=like.to_user,
        to_user=like.from_user
    ).first()

    if reverse_like:
        user1, user2 = sorted(
            [like.from_user, like.to_user], key=lambda u: u.id)
        match, created = Match.objects.get_or_create(
            user1=user1,
            user2=user2
        )
        if created:
            match_count += 1

print(f"   ✅ Đã tạo {match_count} matches")

# Tổng kết
print("\n" + "="*60)
print("📊 TỔNG KẾT:")
print(f"   👥 Total Users: {UserProfile.objects.count()}")
print(f"   🧪 Test Users: {len(created_users)}")
print(f"   ❤️  Likes: {Like.objects.count()}")
print(f"   💑 Matches: {Match.objects.count()}")
print("="*60)

print("\n🎉 Hoàn thành!")
print("\n📝 Thông tin đăng nhập:")
print("   📧 Email: mailan@test.com")
print("   🔑 Password: password123")
print("\n   Hoặc bất kỳ user nào khác với password: password123")
print("\n🚀 Bạn có thể login vào app và test API ngay!")
