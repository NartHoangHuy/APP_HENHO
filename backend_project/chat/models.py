from django.db import models
from users.models import UserProfile


class Message(models.Model):
    sender = models.ForeignKey(
        UserProfile, related_name='sent_messages', on_delete=models.CASCADE)
    receiver = models.ForeignKey(
        UserProfile, related_name='received_messages', on_delete=models.CASCADE)
    content = models.TextField()
    timestamp = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.sender.username} -> {self.receiver.username}: {self.content[:20]}"
