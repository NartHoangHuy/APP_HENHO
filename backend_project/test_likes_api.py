"""
Quick test to check likes API response format
"""
import requests
import json

BASE_URL = 'http://192.168.1.61:8000/api/users/'

# Login first
login = requests.post(
    f'{BASE_URL}login/',
    json={'username': 'trie2', 'password': 'password123'}
)

if login.status_code == 200:
    token = login.json().get('access_token')
    print(f"✅ Logged in as trie2")
    print(f"Token: {token[:30]}...")

    # Get likes list
    print("\n📋 Getting likes list...")
    likes_response = requests.get(
        f'{BASE_URL}likes/',
        headers={'Authorization': f'Bearer {token}'}
    )

    print(f"\n📊 Response Status: {likes_response.status_code}")
    print(f"\n📦 Response Body:")
    print(json.dumps(likes_response.json(), indent=2))
else:
    print(f"❌ Login failed: {login.status_code}")
