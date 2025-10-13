from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import UserProfileViewSet
from rest_framework_simplejwt.views import (
    TokenObtainPairView,
    TokenRefreshView,
)

router = DefaultRouter()
router.register(r'', UserProfileViewSet)

urlpatterns = [
    path('', include(router.urls)),
    path('register/',
         UserProfileViewSet.as_view({'post': 'create'}), name='register'),
    path('login/', TokenObtainPairView.as_view(), name='login'),
    path('token/refresh/', TokenRefreshView.as_view(), name='token_refresh'),
]
