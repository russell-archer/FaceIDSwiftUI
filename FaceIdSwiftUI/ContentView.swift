//
//  ContentView.swift
//  FaceIdSwiftUI
//
//  Created by Russell Archer on 03/08/2022.
//

import SwiftUI

struct ContentView: View {
    @State var isSupported = false
    @State var authenticated : Bool?
    var bioSec = BioSecurity()
    
    var body: some View {
        VStack {
            Button(action: {
                bioSec.authenticate() { result in
                    switch result {
                        case .failure(_): authenticated = false
                        case .success(_): authenticated = true
                    }
                }
            }, label: {
                Label("Authenticate", systemImage: "person.badge.key.fill")
            })
            .padding()
            .disabled(!isSupported)
            
            Text("Biometric authentication \(isSupported ? "" : "not") supported")
                .padding()
                .font(.footnote)
            
            if let auth = authenticated {
                Text(auth ? "Authenticated 😁" : "Authentication failed ☹️")
                    .padding()
                    .font(.largeTitle)
                    .foregroundColor(auth ? .green : .red)
            }
            
            Spacer()
        }
        .task {
            isSupported = bioSec.isSupported()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
