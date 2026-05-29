//
//  ContentView.swift
//  Pet Waste and Special Notes Feature
//
//  Layout: Pet Header (scroll-away) + Pet's Informations + content cards.
//  Sticky bar muncul di luar ScrollView saat scroll melewati pet header.
//

import SwiftUI

struct PetWaste: View {
    @State private var selected: PetCategory = .waste
    @State private var itemsByCategory: [PetCategory: [CategoryItem]] = Dictionary(
        uniqueKeysWithValues: PetCategory.allCases.map { ($0, CategoryItem.items(for: $0)) }
    )
    @State private var isEditing = false
    @State private var clarifyTitle: String? = nil
    @State private var isSticky = false
    @State private var petHeaderHeight: CGFloat = 0

    var body: some View {
        VStack(spacing: 0) {
            // Sticky bar (di LUAR ScrollView → tidak ada bleed-through possible)
            if isSticky {
                categoryTabs
                    .background(Color.white.ignoresSafeArea(edges: .top))
                    .transition(.opacity)
            }

            ScrollView {
                VStack(spacing: 0) {
                    PetHeaderView(pet: .cooper)
                        .padding(.horizontal, 20)
                        .padding(.top, 16)
                        .padding(.bottom, 16)
                        .background(
                            GeometryReader { geo in
                                Color.clear.preference(
                                    key: PetHeaderHeightKey.self,
                                    value: geo.size.height
                                )
                            }
                        )

                    // Inline tabs (sesuai hifi). Pakai opacity supaya layout
                    // tetap stabil saat toggle sticky.
                    categoryTabs.opacity(isSticky ? 0 : 1)

                    categoryContent.padding(.bottom, 40)
                }
            }
            .scrollIndicators(.hidden)
            .scrollDismissesKeyboard(.interactively)
            .onScrollGeometryChange(for: CGFloat.self) { $0.contentOffset.y } action: { _, offset in
                guard petHeaderHeight > 0 else { return }
                let shouldStick = offset > petHeaderHeight - 30
                if shouldStick != isSticky {
                    withAnimation(.easeInOut(duration: 0.2)) { isSticky = shouldStick }
                }
            }
        }
        .background(Color.white.ignoresSafeArea())
        .onPreferenceChange(PetHeaderHeightKey.self) { petHeaderHeight = $0 }
        .sheet(item: Binding(
            get: { clarifyTitle.map(IdentifiedString.init) },
            set: { clarifyTitle = $0?.value }
        )) { wrapper in
            ClarifyChatSheet(title: wrapper.value)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
    }

    private var categoryTabs: some View {
        CategoryTabsView(
            selected: $selected,
            isEditing: isEditing,
            onEditTap: { withAnimation { isEditing = true } },
            onDoneTap: { withAnimation { isEditing = false } }
        )
    }

    @ViewBuilder
    private var categoryContent: some View {
        let items = itemsByCategory[selected] ?? []
        VStack(spacing: 12) {
            if items.isEmpty {
                EmptyCategoryView(category: selected)
            } else {
                ForEach(Array(items.enumerated()), id: \.element.id) { idx, item in
                    itemRow(item: item, index: idx)
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
    }

    @ViewBuilder
    private func itemRow(item: CategoryItem, index: Int) -> some View {
        switch item {
        case .card(let card):
            SwipeableCard(onClarify: { clarifyTitle = card.title }) {
                InfoCardView(card: cardBinding(at: index), isEditing: isEditing)
            }
        case .sectionTitle:
            SectionTitleView(text: sectionTitleBinding(at: index), isEditing: isEditing)
        case .quote:
            SwipeableCard(onClarify: { clarifyTitle = "Note" }) {
                QuoteCardView(quote: quoteBinding(at: index), isEditing: isEditing)
            }
        }
    }

    // MARK: - Bindings ke nested dictionary[selected][index]

    private func cardBinding(at index: Int) -> Binding<InfoCard> {
        Binding(
            get: {
                if case .card(let c) = itemsByCategory[selected]?[index] ?? .sectionTitle("") {
                    return c
                }
                return InfoCard(title: "", content: "", icon: "", style: .normal)
            },
            set: { itemsByCategory[selected]?[index] = .card($0) }
        )
    }

    private func quoteBinding(at index: Int) -> Binding<QuoteItem> {
        Binding(
            get: {
                if case .quote(let q) = itemsByCategory[selected]?[index] ?? .sectionTitle("") {
                    return q
                }
                return QuoteItem(text: "")
            },
            set: { itemsByCategory[selected]?[index] = .quote($0) }
        )
    }

    private func sectionTitleBinding(at index: Int) -> Binding<String> {
        Binding(
            get: {
                if case .sectionTitle(let t) = itemsByCategory[selected]?[index] ?? .sectionTitle("") {
                    return t
                }
                return ""
            },
            set: { itemsByCategory[selected]?[index] = .sectionTitle($0) }
        )
    }
}

struct PetHeaderHeightKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

private struct IdentifiedString: Identifiable {
    let value: String
    var id: String { value }
}

#Preview {
    PetWaste()
}
