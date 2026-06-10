//
//  PetListsView.swift
//  PetPocket
//
//  Created by Michel Pierce on 03/06/26.
//

import SwiftUI

struct PetListView: View {
    @State private var showAddModal = false
    @State private var navigateToOwnPet = false
    @State private var navigateToSitPet = false
    @State private var navigateToDashboard = false
    @State private var searchPet: String = ""
    @State private var selectedPet: PetRow? = nil
    @State private var store: PetStore

    init(store: PetStore = PetStore()) {
        _store = State(initialValue: store)
    }

    // PetRow (DB) -> PetItem (UI card)
    private func card(for row: PetRow, type: PetCardType) -> PetItem {
        PetItem(
            id: row.id,
            name: row.name,
            gender: row.gender ?? "",
            age: Self.ageText(from: row.dateOfBirth),
            breed: row.breed ?? "",
            image: "",
            photoUrl: row.photoUrl,
            type: type
        )
    }

    private static let dobFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        f.locale = Locale(identifier: "en_US_POSIX")
        return f
    }()

    private static func ageText(from iso: String?) -> String {
        guard let iso, let dob = dobFormatter.date(from: iso) else { return "" }
        let years =
            Calendar.current.dateComponents([.year], from: dob, to: .now).year
            ?? 0
        return years > 0 ? "\(years)" : ""
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.background.ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 30) {

                        // Pet cards
                        VStack(spacing: 16) {
                            ForEach(store.ownedPets) { row in
                                PetListCard(item: card(for: row, type: .owning))
                                    .onTapGesture {
                                        selectedPet = row
                                        navigateToDashboard = true
                                    }
                            }
                            ForEach(store.sittingPets) { row in
                                PetListCard(
                                    item: card(
                                        for: row,
                                        type: .sitting(
                                            sitter: "",
                                            sitterImage: "",
                                            dateRange: ""
                                        )
                                    )
                                )
                                .onTapGesture {
                                    selectedPet = row
                                    navigateToDashboard = true
                                }
                            }
                        }
                    }.padding(20)
                        // header
                        .navigationTitle(Text("Here Are Your Pets"))
                        .navigationSubtitle(
                            Text(
                                "\(store.ownedPets.count + store.sittingPets.count) friends are under your care"
                            )
                        )
                        .navigationBarTitleDisplayMode(.large)
                        // toolbar
                        .searchable(text: $searchPet)
                        //.searchToolbarBehavior(.minimize)
                        .toolbar {

                            // search btn
                            DefaultToolbarItem(
                                kind: .search,
                                placement: .bottomBar
                            )
                            ToolbarSpacer(placement: .bottomBar)

                            // settings
                            ToolbarItem(placement: .navigationBarTrailing) {
                                Menu {

                                    // user settings
                                    Button {
                                        print("profile settings btn pressed")
                                    } label: {
                                        Label(
                                            "User Settings",
                                            systemImage: "person.crop.circle"
                                        )

                                    }

                                    // logout
                                    Button {
                                        Task {
                                            await AuthManager.shared.signOut()
                                        }
                                    } label: {
                                        Label(
                                            "Logout",
                                            systemImage:
                                                "rectangle.portrait.and.arrow.forward"
                                        )
                                        .foregroundStyle(.red)
                                    }

                                } label: {
                                    Image(systemName: "ellipsis")
                                        .imageScale(.large)
                                        .rotationEffect(Angle(degrees: 90))

                                }.tint(.black)

                            }

                            // add btn
                            ToolbarItem(placement: .bottomBar) {

                                Button(action: {
                                    showAddModal.toggle()
                                }) {

                                    Image(systemName: "plus")
                                }.tint(.black)
                            }

                        }
                        .navigationDestination(
                            isPresented: $navigateToDashboard
                        ) {
                            if let pet = selectedPet {
                                PetDashboardView(pet: pet)
                            }
                        }
                        .navigationDestination(isPresented: $navigateToOwnPet) {
                            AddingNewPetForm(store: store)
                        }
                        .navigationDestination(isPresented: $navigateToSitPet) {
                            PetCodeInput(store: store)
                        }
                    // show add pet sheet
                        .sheet(isPresented: $showAddModal) {
                            AddPetModal(
                                isPresented: $showAddModal,
                                onOwnPet: { navigateToOwnPet = true },
                                onSitPet: { navigateToSitPet = true }
                            )
                            .presentationDetents([.height(300)])
                            .presentationDragIndicator(.visible)
                        }
                        .task { await store.load() }
                        .refreshable { await store.load() }
                }
            }
        }
    }

}
//
#Preview {
    PetListView()
}
