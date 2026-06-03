//
//  EmergencyView.swift
//  PetPocket
//
//  Created by Samantha Lugay on 02/06/26.
//

import MapKit
import SwiftUI

struct EmergencyView: View {
    private var mockFirstAidData: [RoutineCardItem] = [
        RoutineCardItem(
            title: "Choking",
            time: "",
            description:
                "Signs: Pawing at mouth, pale gums, inability to breathe.",
            icon: "lungs.fill"
        ),
        RoutineCardItem(
            title: "Poisoning",
            time: "",
            description: "Signs: Vomiting, drooling, unusual behavior.",
            icon: "pills.fill"
        ),
    ]

    var body: some View {
        ZStack {
            Color.background.ignoresSafeArea()
            ScrollView {
                VStack(spacing: 30) {

                    // First Aid Guide
                    VStack(alignment: .leading, spacing: 10) {
                        HStack(spacing: 2) {
                            Image(systemName: "cross.case.fill")
                            Text("First Aid Guides")
                                .font(.headline)
                                .fontWeight(.bold)
                            Spacer()
                        }

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 15) {
                                RoutineCard(item: mockFirstAidData[0])
                                    .frame(width: 240)

                                RoutineCard(item: mockFirstAidData[1])
                                    .frame(width: 240)

                            }

                        }.scrollClipDisabled()
                    }

                    VStack(alignment: .leading, spacing: 10){
                        HStack(spacing: 8) {
                            Image(systemName: "person.circle")
                                .foregroundStyle(.black)
                            Text("Trusted Contacts")
                                .font(.headline)
                                .fontWeight(.semibold)
                            Spacer()
                        }
                        
                        .padding(.top)
                        
                        VStack(spacing: 12) {
                            ForEach(mockContact, id: \.self) { contact in
                                ContactCard(contact: contact)
                            }
                        }
                    }

                    VetClinicCard()

                        .padding(.top)
                }.padding(20)
            }
        }
        .navigationTitle("Emergency Guidelines")
        .navigationBarTitleDisplayMode(.inline)
        .tint(Color.primaryG)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button(action: {}) {
                        Label("Edit information", systemImage: "pencil")
                    }
                    
                } label: {
                    Image(systemName: "ellipsis")
                        .imageScale(.large)
                        .rotationEffect(Angle(degrees: 90))
                        .foregroundColor(Color.primaryG)
                }
                
            }
        }
    }
}

#Preview {
    EmergencyView()
}


struct VetClinicCard: View {
    var body: some View {
        HStack(spacing: 0) {
            Rectangle()
                .fill(Color.green)
                .frame(width: 6)

            VStack(alignment: .leading, spacing: 8) {
                Text("Oakwood Veterinary Clinic")
                    .font(.headline)
                    .fontWeight(.semibold)

                Text("1240 Oakwood Ave, Brookside, NY 10012")
                    .font(.subheadline)
                    .foregroundStyle(.gray)

                Text("(555) 012-3456 • 24/7 Emergency Line")
                    .font(.subheadline)
                    .foregroundStyle(.gray)

                HStack(spacing: 12) {
                    Button(action: {}) {
                        HStack(spacing: 6) {
                            Image(systemName: "map.fill")
                            Text("Map")
                        }
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.black)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(Color.gray.opacity(0.15))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }

                    Button(action: {}) {
                        HStack(spacing: 6) {
                            Image(systemName: "phone.fill")
                            Text("Call Vet")
                        }
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(Color.red)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
                .padding(.top, 8)

                Map(
                    initialPosition: .region(
                        MKCoordinateRegion(
                            center: CLLocationCoordinate2D(
                                latitude: 40.7128,
                                longitude: -74.0060
                            ),
                            span: MKCoordinateSpan(
                                latitudeDelta: 0.05,
                                longitudeDelta: 0.05
                            )
                        )
                    )
                )
                .frame(height: 150)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(.top, 8)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}
