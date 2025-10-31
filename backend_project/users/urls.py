from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import (
    RegisterAPIView, LoginAPIView, ProfileAPIView, GoogleSignInAPIView,
    DiscoverViewSet, LikeViewSet, MatchViewSet,
    CityListAPIView, HobbyListAPIView
)

# Router cho ViewSets
router = DefaultRouter()
router.register(r'discover', DiscoverViewSet, basename='discover')
router.register(r'likes', LikeViewSet, basename='likes')
router.register(r'matches', MatchViewSet, basename='matches')

urlpatterns = [
    # Authentication endpoints
    path('register/', RegisterAPIView.as_view(), name='register'),
    path('login/', LoginAPIView.as_view(), name='login'),
    path('google-signin/', GoogleSignInAPIView.as_view(), name='google_signin'),
    path('profile/', ProfileAPIView.as_view(), name='profile'),

    # Master data endpoints
    path('cities/', CityListAPIView.as_view(), name='cities'),
    path('hobbies/', HobbyListAPIView.as_view(), name='hobbies'),

    # ViewSet endpoints (discover, likes, matches)
    path('', include(router.urls)),
]
