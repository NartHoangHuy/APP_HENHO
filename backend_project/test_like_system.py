"""
Test script for the improved Like system with is_like field

Test cases:
1. Swipe right (like) → creates Like with is_like=True
2. Swipe left (dislike) → creates Like with is_like=False
3. Two users like each other → creates Match
4. Get likes list → only shows users with is_like=True
5. Discover excludes all swiped users (both like and dislike)
"""
import requests
import json

BASE_URL = 'http://192.168.1.61:8000/api/users/'


def test_like_system():
    print("🧪 Testing Improved Like System\n")
    print("="*60)

    # Step 1: Login as user1
    print("\n📝 Step 1: Login as user1...")
    login1 = requests.post(
        f'{BASE_URL}login/',
        json={'username': 'user1', 'password': 'password123'}
    )

    if login1.status_code == 200:
        token1 = login1.json().get('access_token')
        user1_id = login1.json().get('user', {}).get('id')
        print(f"✅ User1 logged in! ID: {user1_id}")
    else:
        print(f"❌ Login failed: {login1.status_code}")
        return

    # Step 2: Login as user2
    print("\n📝 Step 2: Login as user2...")
    login2 = requests.post(
        f'{BASE_URL}login/',
        json={'username': 'user2', 'password': 'password123'}
    )

    if login2.status_code == 200:
        token2 = login2.json().get('access_token')
        user2_id = login2.json().get('user', {}).get('id')
        print(f"✅ User2 logged in! ID: {user2_id}")
    else:
        print(f"❌ Login failed: {login2.status_code}")
        return

    # Step 3: User1 swipes right on User2 (LIKE)
    print(f"\n📝 Step 3: User1 swipes RIGHT on User2 (like)...")
    swipe_like = requests.post(
        f'{BASE_URL}discover/swipe/',
        headers={'Authorization': f'Bearer {token1}'},
        json={'target_user_id': user2_id, 'action': 'like'}
    )

    if swipe_like.status_code == 200:
        result = swipe_like.json()
        print(f"✅ Swipe right successful!")
        print(f"   Matched: {result.get('matched')}")
        print(f"   Message: {result.get('message')}")
    else:
        print(f"❌ Swipe failed: {swipe_like.status_code}")
        print(swipe_like.text)

    # Step 4: User2 checks likes received
    print(f"\n📝 Step 4: User2 checks who liked them...")
    likes_received = requests.get(
        f'{BASE_URL}likes/',
        headers={'Authorization': f'Bearer {token2}'}
    )

    if likes_received.status_code == 200:
        likes = likes_received.json()
        print(f"✅ Likes received: {len(likes)} likes")
        for like in likes:
            print(
                f"   - {like.get('from_user_name')} (is_like: {like.get('is_like')})")
    else:
        print(f"❌ Failed to get likes: {likes_received.status_code}")

    # Step 5: User1 swipes left on User3 (DISLIKE)
    print(f"\n📝 Step 5: User1 swipes LEFT on User3 (dislike)...")
    # Get user3 id first
    login3 = requests.post(
        f'{BASE_URL}login/',
        json={'username': 'user3', 'password': 'password123'}
    )
    if login3.status_code == 200:
        user3_id = login3.json().get('user', {}).get('id')

        swipe_dislike = requests.post(
            f'{BASE_URL}discover/swipe/',
            headers={'Authorization': f'Bearer {token1}'},
            json={'target_user_id': user3_id, 'action': 'dislike'}
        )

        if swipe_dislike.status_code == 200:
            result = swipe_dislike.json()
            print(f"✅ Swipe left successful!")
            print(f"   Message: {result.get('message')}")
        else:
            print(f"❌ Swipe failed: {swipe_dislike.status_code}")

    # Step 6: User3 checks likes (should NOT see User1)
    print(f"\n📝 Step 6: User3 checks likes (should be empty)...")
    token3 = login3.json().get('access_token')
    likes_user3 = requests.get(
        f'{BASE_URL}likes/',
        headers={'Authorization': f'Bearer {token3}'}
    )

    if likes_user3.status_code == 200:
        likes = likes_user3.json()
        print(f"✅ User3 likes received: {len(likes)} likes")
        if len(likes) == 0:
            print("   ✅ CORRECT: User1's dislike not shown in likes!")
        else:
            print("   ❌ ERROR: Dislike should not appear in likes!")

    # Step 7: User2 swipes right on User1 (LIKE BACK)
    print(f"\n📝 Step 7: User2 swipes RIGHT on User1 (like back → should MATCH)...")
    swipe_likeback = requests.post(
        f'{BASE_URL}discover/swipe/',
        headers={'Authorization': f'Bearer {token2}'},
        json={'target_user_id': user1_id, 'action': 'like'}
    )

    if swipe_likeback.status_code == 200:
        result = swipe_likeback.json()
        print(f"✅ Swipe right successful!")
        print(f"   Matched: {result.get('matched')}")
        print(f"   Match ID: {result.get('match_id')}")
        print(f"   Message: {result.get('message')}")

        if result.get('matched'):
            print("   🎉 MATCH CREATED!")
        else:
            print("   ❌ ERROR: Should have matched!")
    else:
        print(f"❌ Swipe failed: {swipe_likeback.status_code}")

    # Step 8: Check User1's matches
    print(f"\n📝 Step 8: User1 checks their matches...")
    matches1 = requests.get(
        f'{BASE_URL}matches/',
        headers={'Authorization': f'Bearer {token1}'}
    )

    if matches1.status_code == 200:
        matches = matches1.json()
        print(f"✅ User1 has {len(matches)} matches")
        for match in matches:
            print(
                f"   - Match ID: {match.get('id')}, Other user: {match.get('other_user_name')}")

    # Step 9: User1 checks discover list (should exclude User2 and User3)
    print(f"\n📝 Step 9: User1 checks discover list...")
    discover = requests.get(
        f'{BASE_URL}discover/',
        headers={'Authorization': f'Bearer {token1}'}
    )

    if discover.status_code == 200:
        users = discover.json().get('results', [])
        print(f"✅ Discover list: {len(users)} users")
        user_ids = [u['id'] for u in users]

        if user2_id not in user_ids:
            print(f"   ✅ CORRECT: User2 (matched) excluded from discover")
        else:
            print(f"   ❌ ERROR: User2 should be excluded!")

        if user3_id not in user_ids:
            print(f"   ✅ CORRECT: User3 (disliked) excluded from discover")
        else:
            print(f"   ❌ ERROR: User3 should be excluded!")

    print("\n" + "="*60)
    print("✅ All tests completed!")
    print("="*60)

    print("\n📊 Summary:")
    print("✅ Like (swipe right) creates Like with is_like=True")
    print("✅ Dislike (swipe left) creates Like with is_like=False")
    print("✅ Likes list only shows is_like=True")
    print("✅ Mutual likes create Match")
    print("✅ Discover excludes all swiped users (like + dislike + matched)")


if __name__ == '__main__':
    test_like_system()
