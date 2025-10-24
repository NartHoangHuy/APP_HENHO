from django.urls import path
from .views import RegisterAPIView, LoginAPIView, ProfileAPIView, GoogleSignInAPIView

urlpatterns = [
    path('register/', RegisterAPIView.as_view(), name='register'),
    path('login/', LoginAPIView.as_view(), name='login'),
    path('google-signin/', GoogleSignInAPIView.as_view(), name='google_signin'),
    path('profile/', ProfileAPIView.as_view(), name='profile'),
]
