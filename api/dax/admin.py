from django.contrib import admin
from .models import Vault, Entry

admin.site.site_header = "Dax Admin Console"


class VaultAdmin(admin.ModelAdmin):
    list_display = ("name", "owner", "created_at")
    list_filter = ("owner",)
    search_fields = ("name",)


admin.site.register(Vault, VaultAdmin)


class EntryAdmin(admin.ModelAdmin):
    list_display = ("heading", "vault", "created_at", "updated_at")
    list_filter = ("vault",)
    search_fields = ("heading", "body")


admin.site.register(Entry, EntryAdmin)
