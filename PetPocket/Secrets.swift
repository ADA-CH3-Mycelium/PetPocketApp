//
//  Secrets.swift
//  PetPocket
//
//  Created by Naufal Muafa on 03/06/26.
//
//  Loads Supabase config from Secrets.plist (gitignored). Copy
//  Secrets.example.plist -> Secrets.plist and fill in your values.
//
//  The anon key is a PUBLIC client key (ships in the app binary). Real
//  security is RLS on the database, not hiding this key.
//

import Supabase
import Foundation

enum Secrets {
    static let supabaseURL: URL = {
        guard let value = info("SUPABASE_URL"), let url = URL(string: value) else {
            fatalError("Missing/invalid SUPABASE_URL in Secrets.plist. Copy Secrets.example.plist to Secrets.plist.")
        }
        return url
    }()

    static let supabaseAnonKey: String = {
        guard let value = info("SUPABASE_ANON_KEY"), !value.isEmpty else {
            fatalError("Missing SUPABASE_ANON_KEY in Secrets.plist. Copy Secrets.example.plist to Secrets.plist.")
        }
        return value
    }()

    private static func info(_ key: String) -> String? {
        guard let url = Bundle.main.url(forResource: "Secrets", withExtension: "plist"),
              let dict = NSDictionary(contentsOf: url) else {
            fatalError("Secrets.plist not found in bundle. Copy Secrets.example.plist to Secrets.plist.")
        }
        return dict[key] as? String
    }
}

let supabase = SupabaseClient(
    supabaseURL: Secrets.supabaseURL,
    supabaseKey: Secrets.supabaseAnonKey
)
