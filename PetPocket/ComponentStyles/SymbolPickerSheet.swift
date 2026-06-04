//
//  SymbolPickerSheet.swift
//  PetPocket
//
//  Lightweight SF Symbol picker. There is no system-provided symbol picker for
//  apps (it only exists in Xcode), and no public runtime API to enumerate all
//  symbols — so we ship a curated, searchable list. All symbols render in the
//  app tint (primaryG) so the selection always matches the theme.
//

import SwiftUI

struct SymbolPickerSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selection: String

    @State private var query = ""

    private let columns = [GridItem(.adaptive(minimum: 64), spacing: 12)]

    private var filtered: [String] {
        let q = query.trimmingCharacters(in: .whitespaces).lowercased()
        guard !q.isEmpty else { return Self.symbols }
        return Self.symbols.filter { $0.contains(q) }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(filtered, id: \.self) { name in
                        let isSelected = name == selection
                        Button {
                            selection = name
                            dismiss()
                        } label: {
                            Image(systemName: name)
                                .font(.title2)
                                .foregroundColor(isSelected ? .white : .primaryG)
                                .frame(width: 60, height: 60)
                                .background(isSelected ? Color.primaryG : Color.primaryG.opacity(0.1))
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(20)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Choose an Icon")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $query, prompt: "Search symbols")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(.primaryG)
                }
            }
        }
    }

    // Curated list — pet care, food, health, time, general.
    static let symbols: [String] = [
        // Food & drink
        "fork.knife", "cup.and.saucer.fill", "takeoutbag.and.cup.and.straw.fill",
        "carrot.fill", "fish.fill", "birthday.cake.fill", "waterbottle.fill", "drop.fill",
        // Time of day
        "sunrise.fill", "sun.max.fill", "sunset.fill", "moon.fill", "moon.stars.fill",
        "clock.fill", "alarm.fill", "timer", "calendar",
        // Pets & animals
        "pawprint.fill", "dog.fill", "cat.fill", "bird.fill", "tortoise.fill", "hare.fill",
        "teddybear.fill", "leaf.fill", "tree.fill",
        // Health & care
        "heart.fill", "heart.text.square.fill", "cross.fill", "cross.case.fill",
        "pills.fill", "pill.fill", "bandage.fill", "stethoscope", "syringe.fill",
        "thermometer.medium", "lungs.fill", "bolt.heart.fill",
        // Activity & grooming
        "figure.walk", "figure.run", "shower.fill", "bubbles.and.sparkles.fill",
        "scissors", "comb.fill", "shoe.fill", "tennis.racket",
        // Waste & cleaning
        "trash.fill", "toilet.fill", "sparkles", "wind",
        // Alerts & info
        "exclamationmark.triangle.fill", "exclamationmark.shield.fill", "bell.fill",
        "info.circle.fill", "star.fill", "flag.fill", "bookmark.fill",
        // Location & misc
        "location.fill", "house.fill", "mappin.and.ellipse", "phone.fill",
        "camera.fill", "photo.fill", "tag.fill", "key.fill", "shippingbox.fill",
    ]
}

#Preview {
    SymbolPickerSheet(selection: .constant("pawprint.fill"))
}
