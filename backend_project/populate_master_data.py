"""
Script để populate dữ liệu cho City và Hobby
Chạy: python manage.py shell < populate_master_data.py
Hoặc: python populate_master_data.py
"""
from users.models import City, Hobby
import os
import django

# Setup Django
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'backend_project.settings')
django.setup()


# Danh sách thành phố Việt Nam
cities_data = [
    {'name': 'Hà Nội', 'display_order': 1},
    {'name': 'TP. Hồ Chí Minh', 'display_order': 2},
    {'name': 'Đà Nẵng', 'display_order': 3},
    {'name': 'Hải Phòng', 'display_order': 4},
    {'name': 'Cần Thơ', 'display_order': 5},
    {'name': 'An Giang', 'display_order': 6},
    {'name': 'Bà Rịa - Vũng Tàu', 'display_order': 7},
    {'name': 'Bắc Giang', 'display_order': 8},
    {'name': 'Bắc Kạn', 'display_order': 9},
    {'name': 'Bạc Liêu', 'display_order': 10},
    {'name': 'Bắc Ninh', 'display_order': 11},
    {'name': 'Bến Tre', 'display_order': 12},
    {'name': 'Bình Định', 'display_order': 13},
    {'name': 'Bình Dương', 'display_order': 14},
    {'name': 'Bình Phước', 'display_order': 15},
    {'name': 'Bình Thuận', 'display_order': 16},
    {'name': 'Cà Mau', 'display_order': 17},
    {'name': 'Cao Bằng', 'display_order': 18},
    {'name': 'Đắk Lắk', 'display_order': 19},
    {'name': 'Đắk Nông', 'display_order': 20},
    {'name': 'Điện Biên', 'display_order': 21},
    {'name': 'Đồng Nai', 'display_order': 22},
    {'name': 'Đồng Tháp', 'display_order': 23},
    {'name': 'Gia Lai', 'display_order': 24},
    {'name': 'Hà Giang', 'display_order': 25},
    {'name': 'Hà Nam', 'display_order': 26},
    {'name': 'Hà Tĩnh', 'display_order': 27},
    {'name': 'Hải Dương', 'display_order': 28},
    {'name': 'Hậu Giang', 'display_order': 29},
    {'name': 'Hòa Bình', 'display_order': 30},
    {'name': 'Hưng Yên', 'display_order': 31},
    {'name': 'Khánh Hòa', 'display_order': 32},
    {'name': 'Kiên Giang', 'display_order': 33},
    {'name': 'Kon Tum', 'display_order': 34},
    {'name': 'Lai Châu', 'display_order': 35},
    {'name': 'Lâm Đồng', 'display_order': 36},
    {'name': 'Lạng Sơn', 'display_order': 37},
    {'name': 'Lào Cai', 'display_order': 38},
    {'name': 'Long An', 'display_order': 39},
    {'name': 'Nam Định', 'display_order': 40},
    {'name': 'Nghệ An', 'display_order': 41},
    {'name': 'Ninh Bình', 'display_order': 42},
    {'name': 'Ninh Thuận', 'display_order': 43},
    {'name': 'Phú Thọ', 'display_order': 44},
    {'name': 'Phú Yên', 'display_order': 45},
    {'name': 'Quảng Bình', 'display_order': 46},
    {'name': 'Quảng Nam', 'display_order': 47},
    {'name': 'Quảng Ngãi', 'display_order': 48},
    {'name': 'Quảng Ninh', 'display_order': 49},
    {'name': 'Quảng Trị', 'display_order': 50},
    {'name': 'Sóc Trăng', 'display_order': 51},
    {'name': 'Sơn La', 'display_order': 52},
    {'name': 'Tây Ninh', 'display_order': 53},
    {'name': 'Thái Bình', 'display_order': 54},
    {'name': 'Thái Nguyên', 'display_order': 55},
    {'name': 'Thanh Hóa', 'display_order': 56},
    {'name': 'Thừa Thiên Huế', 'display_order': 57},
    {'name': 'Tiền Giang', 'display_order': 58},
    {'name': 'Trà Vinh', 'display_order': 59},
    {'name': 'Tuyên Quang', 'display_order': 60},
    {'name': 'Vĩnh Long', 'display_order': 61},
    {'name': 'Vĩnh Phúc', 'display_order': 62},
    {'name': 'Yên Bái', 'display_order': 63},
]

# Danh sách sở thích với icon
hobbies_data = [
    {'name': 'Nghệ thuật', 'icon': '🎨', 'display_order': 1},
    {'name': 'Bơi lội', 'icon': '🏊', 'display_order': 2},
    {'name': 'Xem phim', 'icon': '🎬', 'display_order': 3},
    {'name': 'Nhạc cụ', 'icon': '🎸', 'display_order': 4},
    {'name': 'Du lịch', 'icon': '✈️', 'display_order': 5},
    {'name': 'Ẩm thực', 'icon': '🍜', 'display_order': 6},
    {'name': 'Thể thao', 'icon': '⚽', 'display_order': 7},
    {'name': 'Đọc sách', 'icon': '📚', 'display_order': 8},
    {'name': 'Chụp ảnh', 'icon': '📷', 'display_order': 9},
    {'name': 'Công nghệ', 'icon': '💻', 'display_order': 10},
]


def populate_cities():
    print('🏙️  Đang thêm danh sách thành phố...')
    created_count = 0
    for city_data in cities_data:
        city, created = City.objects.get_or_create(
            name=city_data['name'],
            defaults={'display_order': city_data['display_order']}
        )
        if created:
            created_count += 1
            print(f'  ✅ Đã tạo: {city.name}')
        else:
            print(f'  ⏭️  Đã tồn tại: {city.name}')

    print(f'\n📊 Tổng kết: Đã tạo {created_count}/{len(cities_data)} thành phố')
    return created_count


def populate_hobbies():
    print('\n❤️  Đang thêm danh sách sở thích...')
    created_count = 0
    for hobby_data in hobbies_data:
        hobby, created = Hobby.objects.get_or_create(
            name=hobby_data['name'],
            defaults={
                'icon': hobby_data['icon'],
                'display_order': hobby_data['display_order']
            }
        )
        if created:
            created_count += 1
            print(f'  ✅ Đã tạo: {hobby.icon} {hobby.name}')
        else:
            print(f'  ⏭️  Đã tồn tại: {hobby.icon} {hobby.name}')

    print(f'\n📊 Tổng kết: Đã tạo {created_count}/{len(hobbies_data)} sở thích')
    return created_count


if __name__ == '__main__':
    print('='*60)
    print('🚀 BẮT ĐẦU POPULATE DỮ LIỆU MASTER DATA')
    print('='*60)

    cities_created = populate_cities()
    hobbies_created = populate_hobbies()

    print('\n' + '='*60)
    print('✨ HOÀN THÀNH!')
    print(f'   - Cities: {City.objects.count()} tổng cộng')
    print(f'   - Hobbies: {Hobby.objects.count()} tổng cộng')
    print('='*60)
