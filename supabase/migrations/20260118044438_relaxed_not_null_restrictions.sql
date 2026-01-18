alter table "public"."dax_entry" alter column "attributes" drop not null;

alter table "public"."dax_entry" alter column "body" drop not null;

alter table "public"."dax_entry" alter column "heading" drop not null;

alter table "public"."dax_vault" alter column "name" drop not null;

alter table "public"."dax_vault" alter column "settings" drop not null;


