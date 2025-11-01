#!/usr/bin/env python
"""
Script kiểm tra User IDs và Match data trong database
"""
import os
import sys
import django

# Setup Django
sys.path.insert(0, os.path.dirname(__file__))
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'backend_project.settings')
django.setup()

from django.contrib.auth import get_user_model
from users.models import Match

User = get_user_model()

print("\n" + "="*60)
print("🔍 KIỂM TRA USER IDs VÀ MATCHES")
print("="*60)

# Kiểm tra Users
print("\n📋 ALL USERS:")
users = User.objects.all()[:10]
for u in users:
    print(f"   ID: {u.id:3d} | Username: {u.username:20s} | Email: {u.email}")

# Kiểm tra có User IDs bị trùng không
user_ids = list(User.objects.values_list('id', flat=True))
if len(user_ids) != len(set(user_ids)):
    print("\n❌ WARNING: CÓ USER IDs BỊ TRÙNG!")
else:
    print("\n✅ Tất cả User IDs đều UNIQUE")

# Kiểm tra Matches
print("\n📋 ALL MATCHES:")
matches = Match.objects.select_related('user1', 'user2').all()[:10]
for m in matches:
    print(f"   Match #{m.id:3d}:")
    print(f"      User1: ID={m.user1_id:3d} ({m.user1.username})")
    print(f"      User2: ID={m.user2_id:3d} ({m.user2.username})")
    print(f"      Created: {m.created_at.strftime('%Y-%m-%d %H:%M')}")
    print()

# Kiểm tra có Match nào có user1_id == user2_id không (self-match)
self_matches = Match.objects.filter(user1_id=django.db.models.F('user2_id'))
if self_matches.exists():
    print("❌ WARNING: CÓ MATCHES VỚI CHÍNH MÌNH!")
    for m in self_matches:
        print(f"   Match #{m.id}: user1={m.user1_id}, user2={m.user2_id}")
else:
    print("✅ Không có matches với chính mình")

print("\n" + "="*60)
print("✅ KIỂM TRA HOÀN TẤT")
print("="*60 + "\n")
