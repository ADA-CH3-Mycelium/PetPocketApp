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
        let years = Calendar.current.dateComponents([.year], from: dob, to: .now).year ?? 0
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
                        ForEach(mockData) { pet in
                            PetListCard(
                                item: PetItem(
                                    id: pet.id,
                                    name: pet.name,
                                    gender: pet.gender,
                                    age: pet.age,
                                    breed: pet.breed,
                                    image: pet.image,
                                    type: pet.type,
                                )
                            )
                            .onTapGesture {
                                navigateToDashboard = true
                            }
                        }

//                        // add new pet
//                        Button(action: { showAddModal = true }) {
//                            Image(systemName: "plus")
//                                .fontWeight(.bold)
//                                .frame(width: 36, height: 36)
//                                .glassEffect()
//                        }
                    }
                }.padding(20)
                    // header
                    .navigationTitle(Text("Here Are Your Pets 🐾"))
                    .navigationSubtitle(Text("2 friends are under your care"))
                    .navigationBarTitleDisplayMode(.large)
                // toolbar
                    .searchable(text: $searchPet)
                    //.searchToolbarBehavior(.minimize)
                    .toolbar {
                        
                        // search btn
                        DefaultToolbarItem(kind: .search, placement: .bottomBar)
                        ToolbarSpacer(placement: .bottomBar)
                        
                        // add btn
                        ToolbarItem(placement: .bottomBar) {
                            
                            Button(action: {
                                showAddModal.toggle()
                            }) {
                                
                                Image(systemName: "plus")
                            }
                        }
                        

                    }
                    .navigationDestination(isPresented: $navigateToDashboard) {
                        PetDashboardView()
                    }
                    .navigationDestination(isPresented: $navigateToOwnPet) {
                        AddingNewPetForm()
                    }
                    .navigationDestination(isPresented: $navigateToSitPet) {
                        PetCodeInput()
                    }
                    .sheet(isPresented: $showAddModal) {
                        AddPetModal(
                            isPresented: $showAddModal,
                            onOwnPet: { navigateToOwnPet = true },
                            onSitPet: { navigateToSitPet = true }
                        )
                        .presentationDetents([.height(400)])
                        .presentationCornerRadius(24)
                    }
            }
        }
        }
    }
    
}
//
//#Preview {
//    PetListView()
//}
