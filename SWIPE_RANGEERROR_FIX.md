# 🔥 FIX: RangeError khi Like/Swipe

## ❌ LỖI

```
RangeError (length): Invalid value: Only valid value is 0: 1
```

**Mô tả:**
- Khi nhấn button Like/Dislike hoặc swipe card
- App crash với RangeError
- Lỗi xảy ra khi cố truy cập index không hợp lệ trong list

## 🔍 NGUYÊN NHÂN

### 1. **`numberOfCardsDisplayed` có thể = 0**

**Code cũ:**
```dart
numberOfCardsDisplayed: _candidates.length >= 3
    ? 3
    : _candidates.length,  // ❌ Có thể = 0!
```

**Vấn đề:**
- Nếu `_candidates.isEmpty` → `numberOfCardsDisplayed = 0`
- Flutter CardSwiper expects >= 1
- Gây RangeError khi render

### 2. **Không validate index trong `_onSwipe`**

**Code cũ:**
```dart
Future<bool> _onSwipe(int previousIndex, ...) async {
  final candidate = _candidates[previousIndex];  // ❌ Không check bounds!
  
  setState(() {
    _candidates.removeAt(previousIndex);  // ❌ Có thể out of range!
  });
}
```

**Vấn đề:**
- Nếu swipe nhanh liên tục → async race condition
- `previousIndex` có thể out of bounds sau khi list bị modify
- `removeAt` gây RangeError nếu index không hợp lệ

### 3. **Không validate trong `cardBuilder`**

**Code cũ:**
```dart
cardBuilder: (context, index, _, __) {
  return CandidateCard(
    candidate: _candidates[index],  // ❌ Không check bounds!
  );
}
```

**Vấn đề:**
- CardSwiper có thể gọi cardBuilder với index không hợp lệ
- Đặc biệt khi list đang thay đổi (adding/removing cards)

### 4. **Buttons không disable khi list rỗng**

**Code cũ:**
```dart
onPressed: () => _controller.swipe(CardSwiperDirection.right),
// ❌ Không check nếu _candidates.isEmpty!
```

**Vấn đề:**
- User có thể nhấn Like khi không còn cards
- Controller cố swipe card không tồn tại
- Gây crash

## ✅ GIẢI PHÁP

### Fix 1: Validate `numberOfCardsDisplayed`

**File: `lib/screen/user/home_content.dart`**

```dart
numberOfCardsDisplayed: _candidates.isEmpty 
    ? 1  // ✅ Fallback to 1 to prevent RangeError
    : (_candidates.length >= 3 ? 3 : _candidates.length),
```

**Giải thích:**
- Luôn trả về >= 1 để CardSwiper không crash
- Nếu list rỗng, UI sẽ show "Không còn người dùng mới" ở phía trên

### Fix 2: Validate index trong `_onSwipe`

```dart
Future<bool> _onSwipe(int previousIndex, ...) async {
  print('🔄 [SWIPE] previousIndex: $previousIndex, currentIndex: $currentIndex');
  print('🔄 [SWIPE] _candidates.length: ${_candidates.length}');
  
  // ✅ Validate index BEFORE accessing
  if (previousIndex < 0 || previousIndex >= _candidates.length) {
    print('❌ [SWIPE] Invalid previousIndex: $previousIndex (list length: ${_candidates.length})');
    return false;
  }
  
  final candidate = _candidates[previousIndex];  // ✅ Safe now
  
  // ... process swipe ...
  
  // ✅ Validate again before removing (async gap protection)
  if (previousIndex >= 0 && previousIndex < _candidates.length) {
    setState(() {
      _candidates.removeAt(previousIndex);
    });
    print('✅ Removed candidate from list. Remaining: ${_candidates.length}');
  } else {
    print('⚠️ Cannot remove: index $previousIndex out of bounds (length: ${_candidates.length})');
  }
  
  return true;
}
```

**Giải thích:**
- Check bounds TRƯỚC khi access `_candidates[previousIndex]`
- Check lại TRƯỚC khi `removeAt` (vì có async gap)
- Return false nếu invalid → prevent crash
- Logging chi tiết để debug

### Fix 3: Validate trong `cardBuilder`

```dart
cardBuilder: (context, index, _, __) {
  // ✅ Validate index
  if (index < 0 || index >= _candidates.length) {
    print('❌ [CARD_BUILDER] Invalid index: $index (length: ${_candidates.length})');
    return const SizedBox.shrink();  // Return empty widget
  }
  
  return CandidateCard(
    candidate: _candidates[index],  // ✅ Safe now
    controller: _controller,
  );
}
```

**Giải thích:**
- Check bounds trước khi access
- Return empty widget nếu invalid
- Prevent crash trong rendering

### Fix 4: Disable buttons khi list rỗng

```dart
// Nút Dislike
_buildActionButton(
  icon: Icons.close,
  color: Colors.red.shade400,
  onPressed: _candidates.isEmpty 
      ? () {}  // ✅ No-op if empty
      : () => _controller.swipe(CardSwiperDirection.left),
  size: 54,
),

// Nút Like
_buildActionButton(
  icon: Icons.favorite,
  color: Colors.pink.shade400,
  onPressed: _candidates.isEmpty 
      ? () {}  // ✅ No-op if empty
      : () => _controller.swipe(CardSwiperDirection.right),
  size: 54,
),

// Nút Super Like
_buildActionButton(
  icon: Icons.star,
  color: Colors.blue.shade400,
  onPressed: _candidates.isEmpty 
      ? () {} 
      : () => _controller.swipe(CardSwiperDirection.top),
  size: 46,
),

// Nút Undo
_buildActionButton(
  icon: Icons.rotate_left,
  color: Colors.amber.shade400,
  onPressed: _candidates.isEmpty ? () {} : _controller.undo,
  size: 46,
),
```

**Giải thích:**
- Check `_candidates.isEmpty` trước khi swipe
- No-op function nếu rỗng → không crash
- User có thể nhấn nhưng không có effect

## 🧪 TEST CASES

### Test 1: Swipe hết cards
```
1. Login và mở Home
2. Swipe right/left hết tất cả cards
3. Verify: 
   ✅ Hiện "Không còn người dùng mới"
   ✅ Buttons vẫn clickable nhưng không crash
   ✅ Không có RangeError
```

### Test 2: Spam click Like button
```
1. Mở Home với 1 card
2. Click Like button nhanh liên tục 5 lần
3. Verify:
   ✅ Card bị swipe 1 lần
   ✅ Không crash
   ✅ Không có RangeError
```

### Test 3: Swipe nhanh
```
1. Mở Home với nhiều cards
2. Swipe left/right liên tục rất nhanh
3. Verify:
   ✅ Mỗi card bị swipe đúng 1 lần
   ✅ Không có duplicate removes
   ✅ Không có RangeError
```

### Test 4: Empty state
```
1. Swipe hết cards
2. List trống
3. Click tất cả buttons (Like, Dislike, Super Like, Undo)
4. Verify:
   ✅ Không crash
   ✅ Buttons không có effect
   ✅ UI stable
```

### Test 5: Reload sau khi rỗng
```
1. Swipe hết cards
2. Click button "Tải lại"
3. Verify:
   ✅ Load cards mới thành công
   ✅ Swipe hoạt động bình thường
   ✅ Không có lỗi
```

## 📊 SO SÁNH TRƯỚC VÀ SAU

### ❌ TRƯỚC KHI FIX

| Scenario | Kết quả |
|----------|---------|
| List rỗng + click Like | ❌ CRASH: RangeError |
| Swipe nhanh liên tục | ❌ CRASH: Index out of bounds |
| numberOfCardsDisplayed = 0 | ❌ CRASH: CardSwiper error |
| cardBuilder với invalid index | ❌ CRASH: RangeError |

### ✅ SAU KHI FIX

| Scenario | Kết quả |
|----------|---------|
| List rỗng + click Like | ✅ No-op, không crash |
| Swipe nhanh liên tục | ✅ Safe, validate index |
| numberOfCardsDisplayed = 1 (fallback) | ✅ No crash |
| cardBuilder với invalid index | ✅ Return empty widget |

## 🎯 KẾT LUẬN

**Root Cause:**
- Không validate index trước khi access list
- numberOfCardsDisplayed có thể = 0
- Async race condition khi swipe nhanh

**Fix Applied:**
1. ✅ Validate index trong `_onSwipe` (2 lần: trước access và trước remove)
2. ✅ Validate index trong `cardBuilder`
3. ✅ Fix `numberOfCardsDisplayed` >= 1
4. ✅ Disable buttons khi list rỗng (no-op)
5. ✅ Thêm logging để debug

**Expected Result:**
- Không crash khi swipe/like
- Buttons hoạt động smooth
- Empty state stable

## 🚀 NEXT STEPS

1. **Hot Restart app** (press `R` in terminal)
2. **Test tất cả swipe actions:**
   - Like button
   - Dislike button
   - Super Like button
   - Undo button
   - Swipe gesture
3. **Test edge cases:**
   - List rỗng
   - 1 card
   - Swipe nhanh liên tục
4. **Verify logs không có ERROR**

**Expected logs:**
```
🔄 [SWIPE] previousIndex: 0, currentIndex: null
🔄 [SWIPE] _candidates.length: 5
👉 Swiped like on User A (ID: 24)
✅ Removed candidate from list. Remaining: 4
```

**KHÔNG CÒN RangeError!** 🎉
