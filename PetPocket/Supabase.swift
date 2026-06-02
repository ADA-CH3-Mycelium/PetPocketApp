//
//  Supabase.swift
//  PetPocket
//
//  Shared Supabase client — import anywhere you need DB / Auth / Storage / Realtime.
//
//  Setup:
//  1. Duplicate Secrets.example.swift → Secrets.swift
//  2. Fill in your Project URL + Anon Key from:
//     Supabase Dashboard → Project Settings → API
//  3. Secrets.swift is gitignored — never commit it
//

import Supabase
import Foundation

// MARK: - Shared client (use this everywhere in the app)
let supabase = SupabaseClient(
    supabaseURL: URL(string: Secrets.supabaseURL)!,
    supabaseKey: Secrets.supabaseAnonKey
)
