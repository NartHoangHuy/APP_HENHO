"""
Script để test Master Data APIs
Chạy: python test_master_data_api.py
"""
import requests
import json

BASE_URL = 'http://localhost:8000/api/users'


def test_cities_api():
    print('='*60)
    print('🏙️  Testing Cities API')
    print('='*60)

    try:
        response = requests.get(f'{BASE_URL}/cities/')
        print(f'Status Code: {response.status_code}')

        if response.status_code == 200:
            cities = response.json()
            print(f'✅ SUCCESS: Got {len(cities)} cities')
            print('\n📋 First 5 cities:')
            for city in cities[:5]:
                print(
                    f"  - ID: {city['id']}, Name: {city['name']}, Order: {city['display_order']}")
            print('\n📋 Last 3 cities:')
            for city in cities[-3:]:
                print(
                    f"  - ID: {city['id']}, Name: {city['name']}, Order: {city['display_order']}")
            return True
        else:
            print(f'❌ FAILED: {response.text}')
            return False
    except Exception as e:
        print(f'❌ ERROR: {e}')
        return False


def test_hobbies_api():
    print('\n' + '='*60)
    print('❤️  Testing Hobbies API')
    print('='*60)

    try:
        response = requests.get(f'{BASE_URL}/hobbies/')
        print(f'Status Code: {response.status_code}')

        if response.status_code == 200:
            hobbies = response.json()
            print(f'✅ SUCCESS: Got {len(hobbies)} hobbies')
            print('\n📋 All hobbies:')
            for hobby in hobbies:
                icon = hobby.get('icon', '')
                print(
                    f"  - ID: {hobby['id']}, Name: {hobby['name']}, Icon: {icon}, Order: {hobby['display_order']}")
            return True
        else:
            print(f'❌ FAILED: {response.text}')
            return False
    except Exception as e:
        print(f'❌ ERROR: {e}')
        return False


def test_register_api():
    print('\n' + '='*60)
    print('👤 Testing Register API')
    print('='*60)

    test_user = {
        'username': 'testuser_' + str(int(requests.get('http://worldtimeapi.org/api/timezone/Asia/Ho_Chi_Minh').json()['unixtime'])),
        'email': f'test{int(requests.get("http://worldtimeapi.org/api/timezone/Asia/Ho_Chi_Minh").json()["unixtime"])}@example.com',
        'password': 'testpass123',
        'password_confirm': 'testpass123'
    }

    try:
        response = requests.post(
            f'{BASE_URL}/register/',
            json=test_user,
            headers={'Content-Type': 'application/json'}
        )
        print(f'Status Code: {response.status_code}')

        if response.status_code == 201:
            print(f'✅ SUCCESS: User registered')
            print(f'Response: {response.json()}')
            return True
        else:
            print(f'❌ FAILED: {response.text}')
            return False
    except Exception as e:
        print(f'❌ ERROR: {e}')
        return False


def main():
    print('🚀 STARTING API TESTS')
    print('Make sure Django server is running on http://localhost:8000\n')

    results = {
        'cities': test_cities_api(),
        'hobbies': test_hobbies_api(),
        'register': test_register_api()
    }

    print('\n' + '='*60)
    print('📊 TEST RESULTS')
    print('='*60)
    for test_name, passed in results.items():
        status = '✅ PASSED' if passed else '❌ FAILED'
        print(f'{test_name.upper()}: {status}')

    total = len(results)
    passed = sum(results.values())
    print(f'\nTotal: {passed}/{total} tests passed')
    print('='*60)


if __name__ == '__main__':
    main()
