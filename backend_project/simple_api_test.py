"""
Simple API test script using urllib (no external dependencies)
Run: python simple_api_test.py
"""
import urllib.request
import json

BASE_URL = 'http://127.0.0.1:8000/api/users'


def test_api(endpoint, name):
    print(f'\n{"="*60}')
    print(f'Testing {name} API: {endpoint}')
    print("="*60)

    try:
        with urllib.request.urlopen(f'{BASE_URL}{endpoint}') as response:
            if response.status == 200:
                data = json.loads(response.read().decode())
                print(f'✅ SUCCESS: Got {len(data)} items')

                if len(data) > 0:
                    print(f'\n📋 First item:')
                    print(json.dumps(data[0], indent=2, ensure_ascii=False))

                    if len(data) > 1:
                        print(f'\n📋 Last item:')
                        print(json.dumps(
                            data[-1], indent=2, ensure_ascii=False))

                return True
            else:
                print(f'❌ FAILED: Status {response.status}')
                return False
    except Exception as e:
        print(f'❌ ERROR: {e}')
        return False


def main():
    print('🚀 TESTING MASTER DATA APIs')
    print('Make sure server is running: python manage.py runserver')

    results = {}
    results['cities'] = test_api('/cities/', 'Cities')
    results['hobbies'] = test_api('/hobbies/', 'Hobbies')

    print(f'\n{"="*60}')
    print('📊 SUMMARY')
    print("="*60)
    for name, passed in results.items():
        print(f'{name.upper()}: {"✅ PASSED" if passed else "❌ FAILED"}')

    passed_count = sum(results.values())
    total_count = len(results)
    print(f'\nResult: {passed_count}/{total_count} tests passed')


if __name__ == '__main__':
    main()
