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
    @State private var vm: PetListViewModel

    init(store: PetStore = PetStore()) {
        _vm = State(initialValue: PetListViewModel(store: store))
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.background.ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 30) {
                        
                        // Pet cards
                        VStack(spacing: 16) {
                            ForEach(vm.ownedPets) { row in
                                PetListCard(item: vm.card(for: row, type: .owning))
                                    .onTapGesture {
                                        selectedPet = row
                                        navigateToDashboard = true
                                    }
                            }
                            ForEach(vm.sittingPets) { row in
                                PetListCard(item: vm.card(for: row, type: .sitting(sitter: "", sitterImage: "", dateRange: "")))
                                    .onTapGesture {
                                        selectedPet = row
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
                        .navigationSubtitle(Text("\(vm.petCount) friends are under your care"))
                        .navigationBarTitleDisplayMode(.large)
                    // toolbar
                        .searchable(text: $searchPet)
                    //.searchToolbarBehavior(.minimize)
                        .toolbar {
                            
                            // search btn
                            DefaultToolbarItem(kind: .search, placement: .bottomBar)
                            ToolbarSpacer(placement: .bottomBar)
                            
                            ToolbarItem(placement: .topBarTrailing){
                                Button {
                                    Task { await vm.signOut() }
                                } label: {
                                    Image(systemName: "rectangle.portrait.and.arrow.right")
                                        .font(.title3)
                                        .foregroundColor(.alertRed)
                                }
                            }
                            
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
                            if let pet = selectedPet {
                                PetDashboardView(pet: pet)
                            }
                        }
                        .navigationDestination(isPresented: $navigateToOwnPet) {
                            AddingNewPetForm(store: vm.store)
                        }
                        .navigationDestination(isPresented: $navigateToSitPet) {
                            PetCodeInput(store: vm.store)
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
                        .task { await vm.load() }
                        .refreshable { await vm.load() }
                }
            }
        }
    }
    
}
//
//#Preview {
//    PetListView()
//}
