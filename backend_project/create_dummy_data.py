"""
Script để tạo dummy data cho Dating App
Chạy: python manage.py shell < create_dummy_data.py
"""

from users.models import UserProfile, Like, Match
from django.utils import timezone
import random

# Xóa data cũ (nếu muốn reset)
print("🗑️  Xóa data cũ...")
Like.objects.all().delete()
Match.objects.all().delete()

# Tạo users
print("👥 Tạo users...")

users_data = [
    {
        'username': 'Mai Lan',
        'email': 'mailan@example.com',
        'age': 23,
        'gender': 'female',
        'location': 'Hà Nội',
        'bio': 'Thích nghệ thuật, du lịch khắp nơi. Yêu những điều đơn giản trong cuộc sống.',
        'hobbies': 'Nghệ thuật, Du lịch, Ẩm thực'
    },
    {
        'username': 'Minh Tuấn',
        'email': 'minhtuan@example.com',
        'age': 27,
        'gender': 'male',
        'location': 'TP. Hồ Chí Minh',
        'bio': 'Developer, thích công nghệ và thể thao. Tìm kiếm người đồng hành.',
        'hobbies': 'Công nghệ, Thể thao, Xem phim'
    },
    {
        'username': 'Lan Anh',
        'email': 'lananh@example.com',
        'age': 24,
        'gender': 'female',
        'location': 'Đà Nẵng',
        'bio': 'Yêu thích du lịch và khám phá những điều mới mẻ.',
        'hobbies': 'Du lịch, Chụp ảnh, Bơi lội'
    },
    {
        'username': 'Hoàng Nam',
        'email': 'hoangnam@example.com',
        'age': 28,
        'gender': 'male',
        'location': 'Hà Nội',
        'bio': 'Kỹ sư phần mềm, thích đọc sách và tập gym.',
        'hobbies': 'Đọc sách, Thể thao, Công nghệ'
    },
    {
        'username': 'Thu Hà',
        'email': 'thuha@example.com',
        'age': 22,
        'gender': 'female',
        'location': 'Hải Phòng',
        'bio': 'Yêu âm nhạc và nghệ thuật. Chơi piano và guitar.',
        'hobbies': 'Nhạc cụ, Nghệ thuật, Xem phim'
    },
    {
        'username': 'Quang Huy',
        'email': 'quanghuy@example.com',
        'age': 26,
        'gender': 'male',
        'location': 'Đà Nẵng',
        'bio': 'Photographer, yêu thích bắt trọn những khoảnh khắc đẹp.',
        'hobbies': 'Chụp ảnh, Du lịch, Ẩm thực'
    },
    {
        'username': 'Phương Anh',
        'email': 'phuonganh@example.com',
        'age': 25,
        'gender': 'female',
        'location': 'TP. Hồ Chí Minh',
        'bio': 'Food blogger, yêu ẩm thực Việt Nam và thế giới.',
        'hobbies': 'Ẩm thực, Du lịch, Xem phim'
    },
    {
        'username': 'Đức Anh',
        'email': 'ducanh@example.com',
        'age': 29,
        'gender': 'male',
        'location': 'Hà Nội',
        'bio': 'Startup founder, yêu thích thử thách và học hỏi.',
        'hobbies': 'Công nghệ, Đọc sách, Thể thao'
    },
    {
        'username': 'Ngọc Mai',
        'email': 'ngocmai@example.com',
        'age': 23,
        'gender': 'female',
        'location': 'Cần Thơ',
        'bio': 'Giáo viên, yêu trẻ con và những điều tích cực.',
        'hobbies': 'Đọc sách, Du lịch, Nghệ thuật'
    },
    {
        'username': 'Bảo Long',
        'email': 'baolong@example.com',
        'age': 30,
        'gender': 'male',
        'location': 'TP. Hồ Chí Minh',
        'bio': 'Doanh nhân, thích thể thao và du lịch.',
        'hobbies': 'Thể thao, Du lịch, Ẩm thực'
    }
]

created_users = []
for user_data in users_data:
    user, created = UserProfile.objects.get_or_create(
        email=user_data['email'],
        defaults={
            'username': user_data['username'],
            'age': user_data['age'],
            'gender': user_data['gender'],
            'location': user_data['location'],
            'bio': user_data['bio'],
            'hobbies': user_data['hobbies'],
        }
    )
    if created:
        user.set_password('password123')
        user.save()
        print(f"   ✅ Created: {user.username}")
    else:
        print(f"   ℹ️  Already exists: {user.username}")
    created_users.append(user)

# Tạo likes ngẫu nhiên
print("\n❤️  Tạo likes...")
like_count = 0
for i, from_user in enumerate(created_users):
    # Mỗi user like 2-4 người khác ngẫu nhiên
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
            print(f"   ❤️  {from_user.username} → {to_user.username}")

print(f"\n✅ Đã tạo {like_count} likes")

# Tạo matches từ likes có đi có lại
print("\n💑 Tạo matches...")
match_count = 0
all_likes = Like.objects.all()

for like in all_likes:
    # Kiểm tra xem có like ngược lại không
    reverse_like = Like.objects.filter(
        from_user=like.to_user,
        to_user=like.from_user
    ).first()

    if reverse_like:
        # Tạo match
        user1, user2 = sorted(
            [like.from_user, like.to_user], key=lambda u: u.id)
        match, created = Match.objects.get_or_create(
            user1=user1,
            user2=user2
        )
        if created:
            match_count += 1
            print(f"   💑 Match: {user1.username} ↔ {user2.username}")

print(f"\n✅ Đã tạo {match_count} matches")

# Tổng kết
print("\n" + "="*50)
print("📊 TỔNG KẾT:")
print(f"   👥 Users: {UserProfile.objects.count()}")
print(f"   ❤️  Likes: {Like.objects.count()}")
print(f"   💑 Matches: {Match.objects.count()}")
print("="*50)

print("\n🎉 Hoàn thành! Bạn có thể test API với:")
print("   📧 Email: mailan@example.com")
print("   🔑 Password: password123")
print("\n   Hoặc bất kỳ user nào khác với password: password123")
