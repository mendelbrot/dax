# Dax
### Your personalized information bank

Entry
- id: serial required
- vault: Vault forign key Vault required
- created_at: time now immutable required
- edited_at: time now required on update
- heading: string
- body: text
- attributes: JSONB

Entry GIN indexes
- heading
- body
- attributes

Vault
- id
- name: string required minimum 1 character
- created_at
- settings: JSONB

VaultUsers
- id 
- vault Vault
- user User
- created_at

Users
- id
- created_at
- active_at
- username
- hash
- settings JSONB
