# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

PetPocket — a SwiftUI (iOS 26 / Xcode 26) pet-care app. Pet owners store care info (feeding, waste, care notes, emergency contacts/clinics) and share a pet with a sitter via a time-limited code. Backend is **Supabase** (Postgres + Storage + Auth), accessed with the `supabase-swift` SDK. ~56 Swift files, no test target.

- Bundle id: `com.ccaapp.PetPocket`. Scheme: `PetPocket`.
- Supabase project ref: `zuycprszpmkjdusznpgd` (region ap-northeast-2, Postgres 17). An MCP server for this project is usually connected — prefer its tools (`list_tables`, `execute_sql`, `apply_migration`, `get_advisors`, `get_logs`) over guessing schema.

## Build / run

Open `PetPocket.xcodeproj` in Xcode and Run (⌘R). There is no test target and no SPM/CLI build script.

`xcrun`/`xcodebuild`/`simctl` on this machine point at **CommandLineTools, not Xcode**, so CLI builds fail with "xcodebuild requires Xcode". Either `sudo xcode-select -s /Applications/Xcode.app` first, or use Xcode's full path directly, e.g. `/Applications/Xcode.app/Contents/Developer/usr/bin/simctl`. Practically: **changes are usually verified by the user rebuilding in Xcode**, not by an automated build here.

Simulator "Application failed preflight checks / Busy" (not a code error) is fixed with:
```
xcrun simctl shutdown all      # use Xcode's simctl path if xcrun fails
killall Simulator
killall -9 com.apple.CoreSimulator.CoreSimulatorService
```

## Secrets

`PetPocket/Secrets.swift` reads `Secrets.plist` (gitignored) from the bundle and builds the global `supabase` client. `Secrets.example.plist` is the tracked template — copy it to `Secrets.plist` on a fresh checkout. The key is the **anon** (public) key. `Secrets.plist` lives in the synced folder so Xcode auto-includes it as a bundle resource.

## Architecture — the layered data flow

This is the part worth understanding before editing. Data flows in one direction:

```
Supabase ──PostgREST/Storage/Auth──▶ PetRepository ──*Row structs──▶ PetStore / PetDetailStore (@Observable) ──UI item structs──▶ SwiftUI Views
```

- **`PetPocket/Supabase/DBModels.swift`** — `Decodable` `*Row` types (reads) + `Encodable` `*Insert` / `*Update` types (writes). The SDK does **not** auto-convert case, so every property maps to its snake_case column via explicit `CodingKeys`. When adding a DB field you touch the Row, Insert, and Update structs here.
- **`PetPocket/Supabase/PetRepository.swift`** — every network call lives here, one `async throws` func per query. Queries are scoped by `owner_id` / `pet_id` / `auth.uid()`. **UUIDs are passed to filters as `.uuidString`** (Postgres `uuid` columns normalize case; but storage paths do not — see below).
- **`PetPocket/Supabase/PetStore.swift`** — two `@Observable` classes:
  - `PetStore` (home): profile name + owned/sitting pets; `addPet`, `redeem`.
  - `PetDetailStore` (one pet's categories): loads meals/dietary/care/emergency in parallel, and owns all the add/update/delete methods. **It maps DB rows into the existing UI item structs** (`RoutineCardItem`, `ContactCardItem`, `VetClinicCardItem`, allergy/restricted `[String]`). care_items are routed by category → keypath (`waste`→`wasteItems`, `care`→`careItems`, `emergency`→`firstAid`). Static `*Item(_ row:)` helpers build items and **must carry `id: row.id`** so edit/delete target the right DB row.
- These stores are NOT in a DI container. `PetStore` is created in `PetListView`; `PetDetailStore(pet:)` is created in `PetDashboardView.init` and injected to the category views via `.environment(detail)` — category views read it with `@Environment(PetDetailStore.self)`.

### Navigation & auth gate
- Root: `PetPocketApp` gates on `AuthManager.shared.isAuthenticated` → `PetListView()` else `LoginView()`. **Do not push `PetListView` from inside `LoginView`** — that creates nested `NavigationStack`s and tapping a pet pops the whole stack back to login. Login/register just call `AuthManager.signIn/signUp`; the root swaps automatically when `isAuthenticated` flips.
- `AuthManager` (`Features/Auth/AuthManager.swift`) is the singleton `@Observable` auth wrapper; restores the session on launch.
- Pet → dashboard nav uses `NavigationLink(value: PetRow)` + `.navigationDestination(for: PetRow.self)`. Category nav inside the dashboard uses `.navigationDestination(item: $selectedScreen)` driven by `TwCoColGrid`'s callback (not value-based links).

### Category screens
`Views/InformationCategoryViews/` — `FoodView`, `WasteView`, `CareView`, `EmergencyView` plus the edit sheets (`AddMealSheet`, `CareItemSheet`, `ContactSheet`, `ClinicSheet`, `DietaryEditSheet`, `SymbolPickerSheet`). `CategoryViewComponents.swift` holds shared primitives (`TappableRoutineCard`, `GhostRoutineCard`, `AddCardButton`, `EditMenuButton`, `EditHintBanner`). Edit mode is a local `@State isEditing` toggled by `EditMenuButton`; cards are tapped to open an edit sheet. In `EmergencyView`, cards contain their own buttons/Map, so the edit tap is a transparent `Color.clear.contentShape(Rectangle()).onTapGesture` overlay shown only while editing (a wrapping `Button` would be blocked by the inner controls).

## Supabase specifics / gotchas

- **Storage paths must be lowercased.** Buckets `pet-avatars` and `pet-media` enforce RLS `auth.uid()::text = (storage.foldername(name))[1]`. `UUID.uuidString` is uppercase; an un-lowercased path → HTTP **400** (RLS deny), which the client surfaces as a "request timed out". Always `uid.uuidString.lowercased()` in storage paths.
- **`media_type`** on `feeding_meals` is `'photo' | 'video'`; meal media maps to `MediaAttachment.photoURL(URL)` / `.video(URL)`. `MediaAttachment.photo(String)` is an asset name only (not a URL).
- `dietary_restrictions` is **one row per pet** with comma-separated `allergies` / `restricted` text columns (not type/item rows). `replaceDietary` does delete-then-insert.
- Sitter code redeem goes through the `redeem_access_code(p_code text)` SECURITY DEFINER RPC, because RLS blocks a sitter from writing `pet_access` directly. Owner code generation writes `access_codes` directly.
- **RLS is currently DISABLED on all public tables (dev convenience)** — re-enable before real users. Storage `objects` RLS is still on, so storage policies matter.
- After DDL, run `get_advisors` (security). Note: `list_tables` has reported `rls_enabled: true` incorrectly here — trust `pg_class.relrowsecurity` via `execute_sql` for RLS state.
- Applying migrations to this live shared DB is gated by the harness; get explicit user approval before `apply_migration`.

## Conventions

- New DB-backed feature = add columns to all three structs in `DBModels.swift` → add repo funcs in `PetRepository.swift` → add `@MainActor` store methods that mutate the local arrays optimistically → wire the view/sheet. Store write methods return `Bool` and set `errorMessage` on failure.
- Brand colors live in asset catalog color sets surfaced as `Color.primaryG`, `.secondaryG`, `.alertRed`, `.background`, plus `Color.brandSecondary` (#F4A261 orange, defined in `Features/PetWaste&SpecialNotes/Models.swift`). The clarify button uses `brandSecondary`.
- iOS 26 glass APIs (`.glassEffect`, `.searchToolbarBehavior`) and `Map { Marker }` content closures are used freely — this targets the latest SDK.

## Known mock / unfinished areas

`Features/Clarify/ClarifySheetView` (chat) and `Views/ManageAccess/ManageAccessView` (collaborator list) are still mock UI, not wired to `clarify_*` / `pet_access`. Push notifications (`device_tokens`, `notification_logs`) are unimplemented. Sitter pet-card owner name/date are placeholders. `DATA_FLOW.md` at the repo root documents the full DB↔UI field mapping and a verification checklist.
