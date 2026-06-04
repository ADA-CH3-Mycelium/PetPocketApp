# PetPocket — Data Flow & API Integration

Reference for verifying that Supabase backend data renders correctly in the SwiftUI frontend.

- **Backend**: Supabase project `zuycprszpmkjdusznpgd` (Postgres 17, region ap-northeast-2).
- **Client SDK**: `supabase-swift` 2.46.
- **Config**: `Secrets.plist` (gitignored) → `Secrets.swift` builds the global `supabase` client.

---

## 1. Architecture layers

```
Supabase (Postgres + Storage + Auth)
        │  PostgREST / Storage / GoTrue
        ▼
PetRepository.swift      ← thin async API wrapper (one func per query)
        │  returns Decodable *Row structs (DBModels.swift)
        ▼
PetStore / PetDetailStore (@Observable)  ← maps DB rows → UI item structs
        │  publishes arrays the views read
        ▼
SwiftUI Views            ← render; write back via store methods
```

- **DBModels.swift** — `Decodable` row types (read) + `Encodable` insert/update types (write). Keys are snake_case via `CodingKeys` (the SDK does NOT auto-convert).
- **PetRepository.swift** — every network call. Filters scoped by `pet_id` / `owner_id` / `auth.uid()`.
- **PetStore** — home screen (profile + pet list).
- **PetDetailStore** — one pet's categories (meals, dietary, care, emergency).

---

## 2. Auth flow

| Step | Code | Notes |
|------|------|-------|
| Launch | `AuthManager.shared.restoreSession()` | Restores persisted session. |
| Root routing | `PetPocketApp` → `auth.isAuthenticated ? PetListView() : LoginView()` | Single root stack. |
| Login | `LoginView.login()` → `AuthManager.signIn(email:password:)` | On success `isAuthenticated` flips → root swaps. |
| Register | `RegisterView.register()` → `AuthManager.signUp(email:password:name:)` | Trigger `handle_new_user` auto-creates `profiles` row. |
| Identity for queries | `PetRepository.currentUserId()` = `supabase.auth.session.user.id` | Required by every owner-scoped call. |

**Verify:** sign in → no crash, lands on PetListView. Relaunch → skips login (session restored).

> ⚠️ RLS is currently **disabled on all tables** (dev). Re-enable before real users.

---

## 3. Home screen — `PetListView`

**Store:** `PetStore.load()` runs three calls in parallel:

| UI element | Store property | Repo call | Table | Field mapping |
|------------|----------------|-----------|-------|---------------|
| Greeting "Good morning, X" | `profileName` | `fetchProfile()` | `profiles` | `name` |
| Owned pet cards | `ownedPets` | `fetchOwnedPets()` | `pets` (`owner_id = uid`) | `PetRow → PetItem` |
| Sitting pet cards | `sittingPets` | `fetchSittingPets()` | `pet_access` → `pets` | sitter's `pet_id`s |

**`PetRow → PetItem` (card render):**
| PetItem field | Source |
|---------------|--------|
| `name` | `pets.name` |
| `gender` | `pets.gender` |
| `age` | `pets.date_of_birth` → `ageDescription` (computed years) |
| `breed` | `pets.breed` |
| `photoUrl` | `pets.photo_url` (AsyncImage; placeholder if nil) |

**Add pet:** `AddingNewPetForm.save()` → `PetStore.addPet()` → (optional `uploadPetAvatar`) → `PetRepository.createPet()` INSERT `pets`, then `load()` refresh.

**Verify:**
- Pets you own in DB appear as cards; name/age/breed match the row.
- Uploaded photo shows (else paw placeholder).
- Add a pet → row appears in Supabase `pets` and immediately in the list.

---

## 4. Pet dashboard — `PetDashboardView(pet:)`

Creates `PetDetailStore(pet:)`, injected to category views via `.environment(detail)`. `detail.loadIfNeeded()` loads everything for that pet in parallel.

| Header element | Source |
|----------------|--------|
| Name | `pets.name` |
| Subtitle | `ageDescription • gender • breed` |
| Photo | `pets.photo_url` (AsyncImage) |
| Generate code | `GenerateCodeView(petId:)` → `generateAccessCode()` INSERT `access_codes` |

---

## 5. Categories (per pet)

All loaded by `PetDetailStore.load()`.

### 5a. Food — `FoodView`

| UI | Store | Repo | Table | Mapping |
|----|-------|------|-------|---------|
| Dietary alert | `allergies`, `restricted` | `fetchDietary()` | `dietary_restrictions` (1 row/pet) | `allergies`/`restricted` text → split on `,` |
| Meal cards | `meals` | `fetchMeals()` | `feeding_meals` | see below |

**`FeedingMealRow → RoutineCardItem`:** `id`←`id`, title←`meal_name`, time←`time`, description←`notes`, icon←`icon_name`.

Writes: `addMeal` / `updateMeal` / `deleteMeal` (AddMealSheet). Dietary: `updateDietary()` → `replaceDietary()` (delete-then-insert one row).

### 5b. Waste — `WasteView` & 5c. Care — `CareView`

| UI | Store | Repo | Table | Filter |
|----|-------|------|-------|--------|
| Cards | `wasteItems` / `careItems` | `fetchCareItems(category:)` | `care_items` | `category = "waste"` / `"care"` |

**`CareItemRow → RoutineCardItem`:** `id`←`id`, title←`title`, description←`content`, icon←`icon`.

Writes: `addCareItem` / `updateCareItem` / `deleteCareItem` (CareItemSheet), routed by `category` keypath (`waste`→`wasteItems`, `care`→`careItems`, `emergency`→`firstAid`).

### 5d. Emergency — `EmergencyView`

| Section | Store | Repo | Table | Mapping |
|---------|-------|------|-------|---------|
| First-aid cards | `firstAid` | `fetchCareItems(category:"emergency")` | `care_items` | as 5b |
| Contacts | `contacts` | `fetchContacts()` | `emergency_contacts` | name, role→relationship, phone |
| Vet clinics | `clinics` | `fetchClinics()` | `vet_clinics` | name, address, phone, `is_primary`→note, `latitude`/`longitude`→Map pin |

Writes: Contact = `addContact`/`updateContact`/`deleteContact` (ContactSheet). Clinic = `addClinic`/`updateClinic`/`deleteClinic` (ClinicSheet); lat/long drive the MapKit `Marker` + "Open in Maps".

**Note:** clarify button shows on Food/Waste/Care cards (`isEmergency: false`), hidden on Emergency.

---

## 6. Storage (images)

| Asset | Bucket | Path rule | Used by |
|-------|--------|-----------|---------|
| Pet avatar | `pet-avatars` | `<uid>/<uuid>.jpg` (lowercased — RLS compares `auth.uid()::text`) | `uploadPetAvatar()` → `pets.photo_url` |
| Meal photo | `pet-media` | `<uid>/meals/<uuid>.jpg` | `uploadMealPhoto()` → `feeding_meals.media_url` |

> Path **must** be lowercase. `UUID.uuidString` is uppercase; un-lowercased → Storage 400 (RLS deny).

---

## 7. Write payload ↔ schema check

All verified to match (NOT NULL satisfied, CHECK constraints OK):

| Table | Required sent | CHECK |
|-------|---------------|-------|
| `feeding_meals` | pet_id, meal_name, time | media_type photo/video (left null) |
| `care_items` | pet_id, category, item_type="card" | category waste/care/emergency; style defaults `normal` |
| `dietary_restrictions` | pet_id, allergies, restricted | (old `type_check` dropped) |
| `emergency_contacts` | pet_id, name | — |
| `vet_clinics` | pet_id, name | — |
| `access_codes` | pet_id, created_by, code | status defaults `pending`, 48h expiry |

`redeem_access_code(p_code)` RPC (SECURITY DEFINER) handles sitter join (RLS blocks direct `pet_access` insert).

---

## 8. Frontend verification checklist

For each screen, confirm DB ↔ UI:

- [ ] **Login** → authenticated, lands on pet list; relaunch skips login.
- [ ] **Pet list** — every `pets` row I own shows; name/age/breed/photo correct.
- [ ] **Add pet** — new `pets` row in Supabase + appears in list; photo uploaded to `pet-avatars`.
- [ ] **Dashboard** — header name/age/breed/photo match the pet row.
- [ ] **Food** — meals match `feeding_meals` (order by `sort_order`); dietary alert shows `allergies`/`restricted`.
- [ ] **Waste/Care** — cards match `care_items` of that category.
- [ ] **Emergency** — first-aid (care_items emergency), contacts (`emergency_contacts`), clinics (`vet_clinics`) with map pin at lat/long.
- [ ] **Add/Edit/Delete** in any category — row created/updated/removed in Supabase, UI reflects immediately (no full reload needed).
- [ ] **Generate code** (owner) → `access_codes` row; **Join code** (sitter) → `pet_access` row + pet appears under "caring for".
- [ ] **Empty states** — no rows → ghost/empty UI, no crash.

### Quick DB cross-check (Supabase SQL editor)
```sql
select id, name, owner_id, photo_url from pets;
select pet_id, meal_name, time, notes from feeding_meals order by sort_order;
select pet_id, category, title, content from care_items;
select pet_id, allergies, restricted from dietary_restrictions;
select pet_id, name, role, phone from emergency_contacts;
select pet_id, name, latitude, longitude, is_primary from vet_clinics;
```
Compare each row's values against what the matching screen renders.

---

## 9. Known gaps
- `ClarifySheetView` (chat) and `ManageAccessView` (collaborator list) still use mock data — not wired to `clarify_*` / `pet_access`.
- Push notifications (`device_tokens`, `notification_logs`) not implemented.
- Sitter pet card owner name/date are placeholders.
- RLS disabled (dev) — re-enable before production.
