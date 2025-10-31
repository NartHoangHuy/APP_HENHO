# 🔧 Fix: Bad Request 400 - Update Profile

## ✅ Đã Fix

### Backend Changes

1. **EditProfileSerializer** - Tất cả fields optional
2. **ProfileAPIView** - Accept JSON parser + debug logs
3. **Gender validation** - Chỉ accept 'male' hoặc 'female'

### Frontend Changes

1. **AuthService** - Detailed error logging
2. **EditProfileScreen** - Loading + success/error messages
3. **ProfileScreen** - Reload sau khi edit thành công

## 🧪 Test

1. Login: `mailan@test.com` / `password123`
2. Edit profile và save
3. Check logs trong console:
   - Frontend: `📡 Response status: 200`
   - Backend: `✅ Profile updated`

## 🐛 Debug

Nếu vẫn lỗi 400, check logs để xem validation error:
```
❌ Validation errors: {...}
```

Common errors:
- Birthday format phải `YYYY-MM-DD`
- Gender phải `male` hoặc `female`
- Username/email đã tồn tại
