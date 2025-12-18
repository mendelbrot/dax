from dax.models import Vault, Entry
from rest_framework import permissions, viewsets

from dax.serializers import VaultSerializer, EntrySerializer


class EntryViewSet(viewsets.ModelViewSet):
    """
    API endpoint that allows vaults to be viewed or edited.
    """

    queryset = Vault.objects.all().order_by("-created_at")
    serializer_class = VaultSerializer
    permission_classes = [permissions.IsAuthenticated]


class VaultViewSet(viewsets.ModelViewSet):
    """
    API endpoint that allows vault entries to be viewed or edited.
    """

    queryset = Entry.objects.all().order_by("-updated_at")
    serializer_class = EntrySerializer
    permission_classes = [permissions.IsAuthenticated]
