from dax.models import Vault, Entry
from rest_framework import serializers

class VaultSerializer(serializers.HyperlinkedModelSerializer):
    class Meta:
        model = Vault
        fields = ["url", "id", "owner", "name", "settings", "created_at"]


class EntrySerializer(serializers.HyperlinkedModelSerializer):
    class Meta:
        model = Entry
        fields = ["url", "id", "vault", "heading", "body", "attributes", "created_at", "updated_at"]
