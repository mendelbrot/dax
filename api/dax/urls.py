from django.urls import include, path
from rest_framework import routers

from dax import views

router = routers.DefaultRouter()
router.register(r"vaults", views.VaultViewSet)
router.register(r"entries", views.EntryViewSet)

urlpatterns = [
    path("", include(router.urls)),
]
