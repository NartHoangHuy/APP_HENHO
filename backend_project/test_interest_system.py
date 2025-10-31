"""
Test script for the new interest-based tagging system

Test flow:
1. User logs in
2. User taps "Người yêu" category → adds to interested_in
3. Another user filters by "Người yêu" → sees first user in results
"""
import requests
import json

BASE_URL = 'http://192.168.1.61:8000/api/users/'


def test_interest_system():
    print("🧪 Testing Interest-Based Tagging System\n")

    # Step 1: Login as user
    print("Step 1: Login as test user...")
    login_response = requests.post(
        f'{BASE_URL}login/',
        json={'username': 'user1', 'password': 'password123'}
    )

    if login_response.status_code == 200:
        token = login_response.json().get('access_token')
        user_id = login_response.json().get('user', {}).get('id')
        print(f"✅ Login successful! User ID: {user_id}")
        print(f"🔑 Token: {token[:30]}...")
    else:
        print(f"❌ Login failed: {login_response.status_code}")
        print(login_response.text)
        return

    # Step 2: Add interest "Người yêu"
    print("\nStep 2: Adding interest 'Người yêu'...")
    add_interest_response = requests.post(
        f'{BASE_URL}interests/',
        headers={'Authorization': f'Bearer {token}'},
        json={'interest': 'Người yêu'}
    )

    if add_interest_response.status_code == 200:
        print("✅ Interest added successfully!")
        print(
            f"📋 Interested in: {add_interest_response.json().get('interested_in')}")
    else:
        print(f"❌ Failed to add interest: {add_interest_response.status_code}")
        print(add_interest_response.text)
        return

    # Step 3: Verify profile updated
    print("\nStep 3: Checking profile...")
    profile_response = requests.get(
        f'{BASE_URL}profile/',
        headers={'Authorization': f'Bearer {token}'}
    )

    if profile_response.status_code == 200:
        profile = profile_response.json()
        print(f"✅ Profile retrieved!")
        print(f"📋 Username: {profile.get('username')}")
        print(f"📋 Interested in: {profile.get('interested_in')}")
    else:
        print(f"❌ Failed to get profile: {profile_response.status_code}")

    # Step 4: Test discover filter
    print("\nStep 4: Testing discover filter with 'Người yêu'...")
    discover_response = requests.get(
        f'{BASE_URL}discover/?hobby=Người yêu',
        headers={'Authorization': f'Bearer {token}'}
    )

    if discover_response.status_code == 200:
        results = discover_response.json()
        print(f"✅ Discover query successful!")
        print(f"📊 Found {len(results)} users with interest 'Người yêu'")

        # Show first 3 results
        for user in results[:3]:
            print(
                f"   - {user.get('username')} (age: {user.get('age')}, interested_in: {user.get('interested_in')})")
    else:
        print(f"❌ Discover query failed: {discover_response.status_code}")
        print(discover_response.text)

    # Step 5: Add another interest
    print("\nStep 5: Adding interest 'Bạn trò chuyện'...")
    add_interest2_response = requests.post(
        f'{BASE_URL}interests/',
        headers={'Authorization': f'Bearer {token}'},
        json={'interest': 'Bạn trò chuyện'}
    )

    if add_interest2_response.status_code == 200:
        print("✅ Second interest added!")
        print(
            f"📋 Now interested in: {add_interest2_response.json().get('interested_in')}")
    else:
        print(
            f"❌ Failed to add second interest: {add_interest2_response.status_code}")

    # Step 6: Remove an interest
    print("\nStep 6: Removing interest 'Người yêu'...")
    remove_response = requests.delete(
        f'{BASE_URL}interests/',
        headers={'Authorization': f'Bearer {token}'},
        json={'interest': 'Người yêu'}
    )

    if remove_response.status_code == 200:
        print("✅ Interest removed!")
        print(
            f"📋 Now interested in: {remove_response.json().get('interested_in')}")
    else:
        print(f"❌ Failed to remove interest: {remove_response.status_code}")

    print("\n" + "="*60)
    print("✅ All tests completed!")
    print("="*60)


if __name__ == '__main__':
    test_interest_system()
