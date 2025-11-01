#!/usr/bin/env python
"""
Test Match API để xem response trả về có đúng không
"""
import requests
import json

BASE_URL = "http://192.168.1.61:8000"

# Test với user trie2 (ID=23)
print("\n" + "="*60)
print("🧪 TEST MATCH API - User: trie2")
print("="*60)

# Login để lấy token
login_data = {
    "email": "trie2@gmail.com",
    "password": "matkhau123"
}

print("\n1️⃣ LOGIN...")
response = requests.post(f"{BASE_URL}/api/users/login/", json=login_data)
print(f"   Status: {response.status_code}")

if response.status_code == 200:
    login_result = response.json()
    token = login_result.get('access')
    print(f"   ✅ Token: {token[:50]}...")
    
    # Get Profile
    print("\n2️⃣ GET PROFILE...")
    headers = {"Authorization": f"Bearer {token}"}
    profile_response = requests.get(f"{BASE_URL}/api/users/profile/", headers=headers)
    print(f"   Status: {profile_response.status_code}")
    
    if profile_response.status_code == 200:
        profile = profile_response.json()
        print(f"   ✅ User ID: {profile['id']}")
        print(f"   ✅ Username: {profile['username']}")
        print(f"   ✅ Email: {profile['email']}")
        
        # Get Matches
        print("\n3️⃣ GET MATCHES LIST...")
        matches_response = requests.get(f"{BASE_URL}/api/users/matches/", headers=headers)
        print(f"   Status: {matches_response.status_code}")
        
        if matches_response.status_code == 200:
            matches_data = matches_response.json()
            matches = matches_data.get('results', [])
            print(f"   ✅ Total matches: {len(matches)}")
            
            print("\n📋 MATCHES DETAILS:")
            for i, match in enumerate(matches, 1):
                print(f"\n   Match #{i}:")
                print(f"      match_id: {match.get('id')}")
                print(f"      other_user: {match.get('other_user')} ⚠️ ĐÂY LÀ ID NGƯỜI KIA")
                print(f"      other_user_name: {match.get('other_user_name')}")
                print(f"      other_user_age: {match.get('other_user_age')}")
                print(f"      other_user_avatar: {match.get('other_user_avatar', '')[:50]}")
                
                # Kiểm tra có trùng với current user không
                current_user_id = profile['id']
                other_user_id = match.get('other_user')
                
                if current_user_id == other_user_id:
                    print(f"      ❌❌❌ ERROR: other_user == current_user ({current_user_id})!")
                else:
                    print(f"      ✅ Correct: current_user={current_user_id}, other_user={other_user_id}")
            
            print("\n" + "="*60)
            print("✅ API TEST COMPLETE")
            print("="*60)
        else:
            print(f"   ❌ Error: {matches_response.text}")
    else:
        print(f"   ❌ Error: {profile_response.text}")
else:
    print(f"   ❌ Error: {response.text}")
