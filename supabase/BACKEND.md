# PetPocket — Backend Documentation

> **Stack:** Supabase (Auth · PostgreSQL · Realtime · Storage · Edge Functions)
> **SDK:** [supabase-swift](https://github.com/supabase/supabase-swift) v2.46.0
> **Branch:** `supabase`

---

## Table of Contents

1. [Architecture](#architecture)
2. [Project Setup](#project-setup)
3. [Database Schema](#database-schema)
4. [Row Level Security](#row-level-security)
5. [Storage Buckets](#storage-buckets)
6. [Realtime](#realtime)
7. [Push Notifications (FCM)](#push-notifications-fcm)
8. [Task Division](#task-division)
9. [Swift Usage Examples](#swift-usage-examples)

---

## Architecture

```
iOS App (Swift)
     │
     ├── Supabase Auth        → Sign up / Sign in / Session management
     ├── PostgREST (REST API) → CRUD for all pet data (auto-generated from schema)
     ├── Supabase Realtime    → Live chat (clarify_messages) + data sync
     ├── Supabase Storage     → Pet photos & feeding media
     └── Edge Functions       → Access code logic · FCM push notifications
```

**Key design decisions:**
- Owners have **full CRUD** on all their pet data
- Sitters have **read-only** access to pets they're linked to via `pet_access`
- All permissions enforced at the **database level** via RLS — not just in the UI
- Chat uses **WebSockets** (Supabase Realtime), not FCM — FCM is only for background push

---

## Project Setup

### Prerequisites

1. Create a project at [supabase.com](https://supabase.com)
2. Go to **Project Settings → API** and copy:
   - **API URL** → `supabaseURL`
   - **Publishable key** → `supabaseAnonKey`

### Configure the iOS app

```bash
# Duplicate the example file
cp PetPocket/Secrets.example.swift PetPocket/Secrets.swift
```

Fill in `Secrets.swift` (this file is gitignored — never commit it):

```swift
enum Secrets {
    static let supabaseURL     = "https://xxxx.supabase.co"
    static let supabaseAnonKey = "eyJh..."
}
```

### Run SQL (in order)

Go to **Supabase Dashboard → SQL Editor** and run each file:

| Order | File | Purpose |
|---|---|---|
| 1 | `supabase/schema.sql` | Creates all tables + triggers |
| 2 | `supabase/rls.sql` | Applies Row Level Security policies |
| 3 | `supabase/storage.sql` | Creates storage buckets + policies |

### Enable Realtime

Dashboard → **Database → Replication** → enable the `clarify_messages` table

---

## Database Schema

### `profiles`
Extends Supabase Auth. Auto-created on sign up via trigger.

| Column | Type | Notes |
|---|---|---|
| `id` | UUID PK | References `auth.users` |
| `name` | TEXT | Display name |
| `photo_url` | TEXT | Avatar URL (from Storage) |
| `created_at` | TIMESTAMPTZ | |
| `updated_at` | TIMESTAMPTZ | Auto-updated via trigger |

---

### `pets`

| Column | Type | Notes |
|---|---|---|
| `id` | UUID PK | |
| `owner_id` | UUID FK → profiles | |
| `name` | TEXT | |
| `gender` | TEXT | `'Male'` or `'Female'` |
| `date_of_birth` | DATE | Calculate age from this, don't store age directly |
| `breed` | TEXT | e.g. `Golden Retriever` |
| `species` | TEXT | e.g. `Dog` |
| `photo_url` | TEXT | From `pet-avatars` storage bucket |

---

### `dietary_restrictions`
One row per item (allergy or restricted food).

| Column | Type | Notes |
|---|---|---|
| `pet_id` | UUID FK → pets | |
| `type` | TEXT | `'allergy'` or `'restricted'` |
| `item` | TEXT | e.g. `'Chicken'`, `'Grapes'` |

---

### `feeding_meals`
Food category content.

| Column | Type | Notes |
|---|---|---|
| `pet_id` | UUID FK → pets | |
| `meal_name` | TEXT | e.g. `Breakfast` |
| `time` | TEXT | e.g. `8:00 AM` |
| `amount` | TEXT | e.g. `1 Cup Dry Kibble` |
| `notes` | TEXT | Preparation instructions |
| `icon_name` | TEXT | SF Symbol name |
| `media_url` | TEXT | From `pet-media` storage bucket |
| `media_type` | TEXT | `'photo'` or `'video'` |
| `sort_order` | INTEGER | Display order |

---

### `care_items`
Covers Waste + Care Notes + Emergency categories.
Each row is a card, section title, or quote item.

| Column | Type | Notes |
|---|---|---|
| `pet_id` | UUID FK → pets | |
| `category` | TEXT | `'waste'` · `'care'` · `'emergency'` |
| `item_type` | TEXT | `'card'` · `'section_title'` · `'quote'` |
| `title` | TEXT | Card title or section heading |
| `content` | TEXT | Body text |
| `icon` | TEXT | SF Symbol name |
| `style` | TEXT | `'normal'` or `'alert'` (alert = orange banner) |
| `sort_order` | INTEGER | Display order |

---

### `emergency_contacts`

| Column | Type | Notes |
|---|---|---|
| `pet_id` | UUID FK → pets | |
| `name` | TEXT | |
| `role` | TEXT | e.g. `Has spare key` |
| `phone` | TEXT | |
| `initial` | CHAR(1) | For avatar circle display |

---

### `vet_clinics`

| Column | Type | Notes |
|---|---|---|
| `pet_id` | UUID FK → pets | |
| `name` | TEXT | |
| `address` | TEXT | |
| `phone` | TEXT | |
| `latitude` | DOUBLE PRECISION | For MapKit |
| `longitude` | DOUBLE PRECISION | For MapKit |
| `is_primary` | BOOLEAN | |

---

### `access_codes`
6-digit codes owners generate to invite sitters.

| Column | Type | Notes |
|---|---|---|
| `pet_id` | UUID FK → pets | |
| `created_by` | UUID FK → profiles | |
| `code` | TEXT UNIQUE | 6-digit string |
| `expires_at` | TIMESTAMPTZ | 48h after creation |
| `used_at` | TIMESTAMPTZ | NULL if not redeemed |
| `used_by` | UUID FK → profiles | NULL if not redeemed |
| `status` | TEXT | `'pending'` · `'used'` · `'expired'` |

---

### `pet_access`
Active sitter ↔ pet relationships. Created when a sitter redeems a code.

| Column | Type | Notes |
|---|---|---|
| `pet_id` | UUID FK → pets | |
| `sitter_id` | UUID FK → profiles | |
| `access_code_id` | UUID FK → access_codes | Which code was used |
| `role` | TEXT | `'sitter'` or `'viewer'` |
| `start_date` | TIMESTAMPTZ | |
| `end_date` | TIMESTAMPTZ | NULL = still active |
| `is_active` | BOOLEAN | |

---

### `clarify_threads`
A chat thread tied to a pet + care category.

| Column | Type | Notes |
|---|---|---|
| `pet_id` | UUID FK → pets | |
| `category` | TEXT | `'food'` · `'waste'` · `'care'` · `'emergency'` |
| `title` | TEXT | Thread subject |
| `created_by` | UUID FK → profiles | |
| `is_resolved` | BOOLEAN | |

---

### `clarify_messages`
Individual messages. **Realtime is enabled on this table.**

| Column | Type | Notes |
|---|---|---|
| `thread_id` | UUID FK → clarify_threads | |
| `sender_id` | UUID FK → profiles | |
| `message` | TEXT | |
| `created_at` | TIMESTAMPTZ | Used as message timestamp |

---

### `device_tokens`
FCM tokens for push notifications. One user can have multiple devices.

| Column | Type | Notes |
|---|---|---|
| `user_id` | UUID FK → profiles | |
| `fcm_token` | TEXT | FCM registration token |
| `platform` | TEXT | `'ios'` or `'android'` |
| `device_name` | TEXT | e.g. `Naufal's iPhone 15` |

Unique constraint on `(user_id, fcm_token)` — upsert on every app launch.

---

### `notification_logs`

| Column | Type | Notes |
|---|---|---|
| `pet_id` | UUID FK → pets | |
| `sender_id` | UUID FK → profiles | NULL = system notification |
| `receiver_id` | UUID FK → profiles | |
| `type` | TEXT | `'new_message'` · `'meal_reminder'` · `'access_granted'` · `'emergency'` |
| `title` | TEXT | |
| `body` | TEXT | |
| `data` | JSONB | Custom payload for deep-linking |
| `sent_at` | TIMESTAMPTZ | |
| `read_at` | TIMESTAMPTZ | NULL = unread |

---

## Row Level Security

Two helper functions power all policies:

```sql
is_pet_owner(pet_id)    -- true if current user owns the pet
is_active_sitter(pet_id) -- true if current user has active access to the pet
```

**Summary of access rules:**

| Table | Owner | Active Sitter | Others |
|---|---|---|---|
| profiles | Full | Read own + collaborators | None |
| pets | Full | Read | None |
| dietary_restrictions | Full | Read | None |
| feeding_meals | Full | Read | None |
| care_items | Full | Read | None |
| emergency_contacts | Full | Read | None |
| vet_clinics | Full | Read | None |
| access_codes | Full | Read pending only | None |
| pet_access | Full | Read own record | None |
| clarify_threads | Full | Read + Insert | None |
| clarify_messages | Full | Read + Insert | None |
| device_tokens | Own only | Own only | None |
| notification_logs | None | None | Own received |

---

## Storage Buckets

### `pet-avatars` (public)
- Pet profile photos
- Path format: `{owner_id}/{pet_id}/avatar`
- Anyone can read, only owner can write

### `pet-media` (private)
- Feeding card photos + videos
- Path format: `{owner_id}/{pet_id}/{filename}`
- Owner can read/write, active sitters can read via signed URL

---

## Realtime

Subscribe to new messages in a thread:

```swift
let channel = supabase.realtime.channel("thread-\(threadId)")

channel.onPostgresChanges(
    AnyAction.self,
    schema: "public",
    table: "clarify_messages",
    filter: "thread_id=eq.\(threadId)"
) { action in
    // handle new message
}

await channel.subscribe()
```

Unsubscribe when leaving the view:
```swift
await supabase.realtime.removeChannel(channel)
```

---

## Push Notifications (FCM)

### Flow
```
App launch → FCM SDK → FCM token
     ↓
Upsert token into device_tokens table
     ↓
Event occurs (new message, meal reminder)
     ↓
Supabase Edge Function reads fcm_token for target user
     ↓
POST to FCM API → APNs → iPhone notification
```

### Save token on app launch (Person 2's task)

```swift
import FirebaseMessaging

let token = try await Messaging.messaging().token()

try await supabase
    .from("device_tokens")
    .upsert([
        "user_id": supabase.auth.currentUser!.id,
        "fcm_token": token,
        "platform": "ios"
    ], onConflict: "user_id, fcm_token")
    .execute()
```

---

## Task Division

### Person 1 — Foundation (you)
- [x] Supabase project setup
- [x] `schema.sql` — all tables
- [x] `rls.sql` — security policies
- [x] `storage.sql` — media buckets
- [x] `Supabase.swift` — shared client
- [x] `supabase-swift` linked to Xcode project
- [ ] Auth flows (sign up / sign in / sign out)
- [ ] Pet CRUD (create, read, update, delete)

### Person 2 — Access Management & Notifications
- [ ] Access code generation (Edge Function)
- [ ] Access code redemption → creates `pet_access` row
- [ ] Manage collaborators (view / revoke)
- [ ] FCM token registration on app launch
- [ ] Edge Function: send push notification
- [ ] Notification log reads

### Person 3 — Clarify Chat & Realtime
- [ ] `clarify_threads` CRUD
- [ ] `clarify_messages` CRUD
- [ ] Realtime subscription on `clarify_messages`
- [ ] Trigger push notification on new message (calls Person 2's function)

---

## Swift Usage Examples

### Auth — Sign up
```swift
try await supabase.auth.signUp(email: email, password: password)
```

### Auth — Sign in
```swift
try await supabase.auth.signIn(email: email, password: password)
```

### Auth — Current user
```swift
let user = try await supabase.auth.user()
```

### Fetch pet with meals
```swift
let pet: Pet = try await supabase
    .from("pets")
    .select("*, feeding_meals(*), dietary_restrictions(*)")
    .eq("id", value: petId)
    .single()
    .execute()
    .value
```

### Insert a feeding meal
```swift
try await supabase
    .from("feeding_meals")
    .insert(newMeal)
    .execute()
```

### Upload pet photo
```swift
let path = "\(ownerId)/\(petId)/avatar"
try await supabase.storage
    .from("pet-avatars")
    .upload(path, data: imageData, options: .init(contentType: "image/jpeg"))
```

### Get public avatar URL
```swift
let url = supabase.storage
    .from("pet-avatars")
    .getPublicURL(path: "\(ownerId)/\(petId)/avatar")
```
