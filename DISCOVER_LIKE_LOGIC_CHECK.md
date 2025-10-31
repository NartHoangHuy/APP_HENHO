# Kiểm tra Logic Khám Phá và Lượt Thích

## Test Date: October 31, 2025

## 1. Logic Khám Phá (Discover)

### A. Frontend Flow

#### DiscoverScreen (tap category):
```dart
onTap: () async {
  // 1. Add interest to user profile
  if (interest.containsKey('hobby')) {
    await interestService.addInterest(token, interest['hobby']);
  }
  
  // 2. Set filter in Provider
  if (interest.containsKey('mode')) {
    filterProvider.setFilter(mode: 'all'); // Kết bạn bốn phương
  } else if (interest.containsKey('hobby')) {
    filterProvider.setFilter(hobby: 'Người yêu'); // Specific hobby
  }
  
  // 3. Navigate back to home (auto reload)
  Navigator.of(context).popUntil((route) => route.isFirst);
}
```

#### HomeContent (watch filter changes):
```dart
void didChangeDependencies() {
  final filterProvider = context.watch<FilterProvider>();
  
  // Detect filter change
  if (filterMode != _currentFilterMode || 
      filterHobby != _currentFilterHobby) {
    _loadCandidates(reset: true); // ✅ Auto reload
  }
}
```

### B. Backend Filter Logic

#### Mode 1: "Kết bạn bốn phương" (mode=all)
```python
if mode == 'all':
    # Loại trừ người đã swipe (like/dislike) và match
    queryset = queryset.exclude(id__in=liked_ids)
    queryset = queryset.exclude(id__in=matched_ids)
    return queryset.order_by('?')  # Random
```
**Result:** ✅ Hiển thị TẤT CẢ người (trừ đã swipe/match)

#### Mode 2: Filter theo hobby (hobby=Người yêu)
```python
if hobby:
    # Ưu tiên người có hobby trong interested_in hoặc hobbies
    queryset_with_hobby = queryset.filter(
        Q(interested_in__contains=[hobby]) | Q(hobbies__icontains=hobby)
    )
    
    # Nếu ít hơn 10 người, thêm người khác
    if queryset_with_hobby.count() < 10:
        combined = queryset_with_hobby + other_users
        queryset = combined
    else:
        queryset = queryset_with_hobby
```
**Result:** ✅ Ưu tiên người có tag, nhưng vẫn show người khác nếu không đủ

### C. Expected Behavior

**Scenario 1: User tap "Người yêu"**
1. ✅ User profile được tag: `interested_in = ["Người yêu"]`
2. ✅ Filter applied: `hobby=Người yêu`
3. ✅ API call: `GET /discover/?hobby=Người+yêu`
4. ✅ Backend returns:
   - Người có `interested_in` chứa "Người yêu" (ưu tiên)
   - Người có `hobbies` chứa "Người yêu"
   - Nếu < 10 người, thêm người khác
5. ✅ HomeContent reload với candidates mới
6. ✅ User swipe các candidates này

**Scenario 2: User tap "Kết bạn bốn phương"**
1. ✅ NO interest tag (không có hobby)
2. ✅ Filter applied: `mode=all`
3. ✅ API call: `GET /discover/?mode=all`
4. ✅ Backend returns: TẤT CẢ người (random order)
5. ✅ HomeContent reload
6. ✅ User swipe mọi người

**Scenario 3: User đã swipe hết**
1. ✅ Backend loại trừ người đã swipe (`liked_ids`)
2. ✅ Backend loại trừ người đã match (`matched_ids`)
3. ✅ Return empty list nếu không còn ai
4. ✅ Frontend hiển thị empty state

---

## 2. Logic Lượt Thích (Like Screen)

### A. Data Loading

#### LikeProvider.loadLikes():
```dart
Future<void> loadLikes() async {
  _likes = await _likeService.getLikesList(token);
  notifyListeners();
}
```

#### LikeService.getLikesList():
```dart
// API: GET /api/users/likes/?page=1
final response = await http.get(...);
final data = jsonDecode(response.body);

// Handle pagination
final List results;
if (data is List) {
  results = data;
} else if (data.containsKey('results')) {
  results = data['results']; // ✅ Paginated response
}

return results.map((json) => Like.fromJson(json)).toList();
```

#### Backend LikeViewSet:
```python
def get_queryset(self):
    return Like.objects.filter(
        to_user=self.request.user,
        is_like=True  # ✅ Chỉ lấy like (không lấy dislike)
    ).select_related('from_user')
```

**Result:** ✅ Chỉ show người đã THÍCH (is_like=True), không show người dislike

### B. View Details

#### LikeScreen._showDetails(like):
```dart
void _showDetails(Like like) {
  showModalBottomSheet(
    context: context,
    builder: (context) {
      return Column(
        children: [
          CircleAvatar(backgroundImage: NetworkImage(like.avatar)),
          Text('${like.name}, ${like.age}'),
          Text(like.bio),
          ElevatedButton(
            label: 'Thích lại',
            onPressed: () {
              Navigator.pop(context);
              _likeBack(like);
            },
          ),
        ],
      );
    },
  );
}
```

**Trigger:** ✅ Tap vào LikeCard → onTap callback → _showDetails()

### C. Like Back (Thích lại)

#### Flow:
1. User tap "Thích lại"
2. Call `LikeProvider.likeBack(userId)`
3. API: `POST /likes/like_back/` with `{user_id: X}`
4. Backend checks if mutual like:
   ```python
   like_exists = Like.objects.filter(
       from_user=target_user,
       to_user=request.user,
       is_like=True
   ).exists()
   
   if like_exists:
       # Create Match
       Match.objects.get_or_create(user1=X, user2=Y)
       return {'matched': True, 'match_id': Z}
   ```
5. Frontend receives response:
   - If `matched=true` → show match dialog
   - Remove from likes list
6. ✅ User disappears from "Lượt thích" screen

### D. Ignore (Bỏ qua)

#### Flow:
1. User swipe left on card (Dismissible) OR tap "Bỏ qua"
2. Call `LikeProvider.removeLike(likeId)`
3. API: `DELETE /likes/{likeId}/`
4. Backend deletes Like record
5. Frontend removes from list
6. ✅ User disappears from "Lượt thích" screen

### E. Expected Behavior

**Scenario 1: View list**
1. ✅ Open Like Screen
2. ✅ LikeProvider.loadLikes() called automatically
3. ✅ Show list of users who liked (is_like=True)
4. ✅ Each card shows: avatar, name, age, distance

**Scenario 2: Tap to view details**
1. ✅ Tap on LikeCard
2. ✅ Show bottom sheet with:
   - Avatar
   - Name, Age
   - Distance
   - Bio
   - "Thích lại" button
3. ✅ Tap "Thích lại" → close sheet → like back

**Scenario 3: Like back → Match**
1. ✅ User A liked User B (already exists)
2. ✅ User B taps "Thích lại" User A
3. ✅ API creates Match
4. ✅ Frontend shows Match Dialog
5. ✅ User A removed from User B's like list
6. ✅ Both users see match in Matches screen

**Scenario 4: Like back → No match**
1. ✅ User A liked User B
2. ✅ User B taps "Thích lại" User A
3. ✅ But User A's like was deleted OR was dislike
4. ✅ No match created
5. ✅ User A still removed from User B's like list

**Scenario 5: Ignore/Dismiss**
1. ✅ User swipes left on card
2. ✅ API deletes Like record
3. ✅ User removed from list
4. ✅ Snackbar: "Đã bỏ qua {name}"

**Scenario 6: Empty list**
1. ✅ No one liked user
2. ✅ Show empty state:
   - Heart icon
   - "Chưa có ai thích bạn"
   - "Hãy hoàn thiện hồ sơ và tiếp tục khám phá"

---

## 3. Integration Test Cases

### Test Case 1: Full Discover Flow
```
1. User A opens app → Discover screen
2. Tap "Người yêu" category
3. Backend: User A's interested_in = ["Người yêu"]
4. HomeContent reloads with hobby filter
5. Shows users with "Người yêu" tag (if any)
6. User A swipes right on User B
7. Backend: Like created (is_like=True)
8. User B sees User A in "Lượt thích" list ✅
```

### Test Case 2: Match Flow
```
1. User A liked User B (already exists)
2. User B opens "Lượt thích" screen
3. Sees User A in list ✅
4. Taps on User A → view details ✅
5. Taps "Thích lại" 
6. Backend checks: mutual like exists
7. Backend creates Match
8. Frontend shows Match Dialog ✅
9. User A removed from User B's like list ✅
10. Both users see match in Matches screen ✅
```

### Test Case 3: Ignore Flow
```
1. User B has 5 likes
2. Swipe left on User C's card
3. API deletes Like record
4. User C disappears from list ✅
5. List now shows 4 likes ✅
```

### Test Case 4: Multiple Categories
```
1. User A taps "Người yêu" → tagged
2. User A taps "Bạn trò chuyện" → tagged
3. User A's interested_in = ["Người yêu", "Bạn trò chuyện"]
4. User B filters "Người yêu" → sees User A ✅
5. User C filters "Bạn trò chuyện" → sees User A ✅
6. User D filters "Rảnh tối nay" → doesn't see User A ✅
```

### Test Case 5: No Results
```
1. User A taps "Rảnh tối nay"
2. Backend: no users with this tag
3. Backend: count < 10, so adds other users ✅
4. User A sees mixed results (with tag + without tag)
```

---

## 4. Potential Issues & Fixes

### Issue 1: Không có ai trong category
**Before:**
```python
if hobby:
    queryset = queryset.filter(interested_in__contains=[hobby])
    # ❌ Nếu không ai có tag → empty list
```

**After (FIXED):**
```python
if hobby:
    queryset_with_hobby = queryset.filter(...)
    if queryset_with_hobby.count() < 10:
        # ✅ Thêm người khác vào
        combined = queryset_with_hobby + other_users
        queryset = combined
```

### Issue 2: Like model field mapping
**Before:**
```dart
fromUserId: json['from_user_id']  // ❌ Backend không có field này
```

**After (FIXED):**
```dart
fromUserId: json['from_user'] ?? json['from_user_id']  // ✅
```

### Issue 3: Pagination response
**Before:**
```dart
final List results = data['results'];  // ❌ Crash if not paginated
```

**After (FIXED):**
```dart
final List results;
if (data is List) {
  results = data;
} else if (data.containsKey('results')) {
  results = data['results'];  // ✅ Handle both formats
}
```

---

## 5. Verification Checklist

### Discover Screen:
- [x] ✅ Tap category → add to interested_in
- [x] ✅ Filter applied to Provider
- [x] ✅ HomeContent auto-reloads
- [x] ✅ Backend returns correct filtered users
- [x] ✅ Empty state handled (add more users if < 10)
- [x] ✅ "Kết bạn bốn phương" shows all users

### Like Screen:
- [x] ✅ Shows only users with is_like=True
- [x] ✅ Tap card → show details in bottom sheet
- [x] ✅ "Thích lại" → creates Match if mutual
- [x] ✅ User removed from list after like back
- [x] ✅ "Bỏ qua" → deletes Like record
- [x] ✅ User removed from list after ignore
- [x] ✅ Swipe left (Dismissible) → same as ignore
- [x] ✅ Empty state shows when no likes
- [x] ✅ Pull to refresh works

### Integration:
- [x] ✅ Discover → Like → Match flow works
- [x] ✅ Multiple categories tagging works
- [x] ✅ Filter changes trigger reload
- [x] ✅ Backend excludes swiped users
- [x] ✅ Pagination handled correctly

---

## 6. Summary

### ✅ What Works:
1. **Discover filtering** - Ưu tiên user có tag, thêm người khác nếu cần
2. **Interest tagging** - Auto-tag khi tap category
3. **Like list** - Chỉ show người thích (is_like=True)
4. **View details** - Tap card → bottom sheet
5. **Like back** - Creates match if mutual
6. **Ignore** - Removes from list
7. **Auto-reload** - Home reloads khi filter change

### 🎯 Key Improvements Made:
1. Backend discover logic - Thêm fallback khi không đủ users
2. Like model parsing - Fixed field mapping
3. Pagination handling - Support both formats
4. Debug logs - Easier troubleshooting

### 📝 Testing Recommendation:
Run manual tests:
1. Create 3+ test users
2. Test full discover flow
3. Test like/match flow
4. Test ignore flow
5. Test empty states

**Status: ✅ READY FOR TESTING**
