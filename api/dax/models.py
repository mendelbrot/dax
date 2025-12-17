from django.db import models
from django.conf import settings as django_settings
from django.db.models import JSONField


class Vault(models.Model):
    owner = models.ForeignKey(
        django_settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        verbose_name="vault owner",
        related_name="owned_vaults",
    )
    name = models.CharField("vault name", max_length=255)
    settings = JSONField("vault settings", default=dict, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)

    contributors = models.ManyToManyField(
        to=django_settings.AUTH_USER_MODEL,
        through="VaultUser",
        related_name="contributed_vaults",
    )

    class Meta:
        constraints = [
            models.UniqueConstraint(
                fields=["owner", "name"], name="unique_vault_name_per_owner"
            )
        ]

    def __str__(self):
        return self.name


class VaultUser(models.Model):
    vault = models.ForeignKey(Vault, on_delete=models.CASCADE)
    user = models.ForeignKey(
        django_settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        verbose_name="vault contributor",
    )

    class Meta:
        db_table = "dax_vault_user"
        constraints = [
            models.UniqueConstraint(fields=["vault", "user"], name="unique_vault_user")
        ]


class Entry(models.Model):
    vault = models.ForeignKey(
        Vault,
        on_delete=models.CASCADE,
        related_name="entries",
    )
    heading = models.CharField("entry heading", max_length=255, blank=True)
    body = models.TextField("entry body", blank=True)
    attributes = JSONField("entry attributes", default=dict, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return self.heading
