import SwiftUI

struct SettingsView: View {
    var body: some View {
        NavigationView {
            ZStack {
                Image("Drowsii Sounds & Chat Background")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .ignoresSafeArea()
                
            Form {
                Section(header: Text("Account")) {
                    HStack {
                        Image(systemName: "person.crop.circle")
                        Text("Profile")
                    }
                    HStack {
                        Image(systemName: "lock.circle")
                        Text("Privacy")
                    }
                }
                Section(header: Text("App")) {
                    HStack {
                        Image(systemName: "moon.stars")
                        Text("Theme")
                    }
                    HStack {
                        Image(systemName: "bell")
                        Text("Notifications")
                    }
                }
                Section(header: Text("About")) {
                    HStack {
                        Image(systemName: "info.circle")
                        Text("Version 1.0")
                        }
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }
} 