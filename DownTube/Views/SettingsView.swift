//
//  SettingsView.swift
//  DownTube
//
//  Created by Benjamin Nakiwala on 7/5/21.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.presentationMode) var presentationState
    @EnvironmentObject var settings: Settings
    @State var preferredQualitySelection: String?
    @State var manageStorageIsShowing = false
    var body: some View {
        NavigationView {
            List {
                // Beginning of preferred video quality
                Section(header: Text("Preferred Video Quality")) {
                    ForEach(settings.preferredVideoQuality.allCases) {
                        str in
                        Button() {
                            preferredQualitySelection = str
                            settings.preferredVideoQuality = VideoQuality.allCases.first {
                                $0.rawValue == str
                            }!
                    } label: {
                            HStack {
                                Text(str)
                                Spacer()
                                if settings.preferredVideoQuality.rawValue == str {
                                        Image(systemName: "checkmark")
                                            .foregroundColor(.blue)
                                    }
                            }
                        }
                    }
                }
                // end of preferred video quality
                // playback section
                Section(header: Text("Playback"), footer: Text(
                """
                Autoplay automatically plays videos on selection.
                """
                )) {
                    Toggle("Autoplay", isOn: $settings.shouldAutoplay)
                }
                Section {
                    Toggle("Play the next file in folder", isOn: $settings.usePlaybackQueue)
                    Toggle("Save Playback Position", isOn: $settings.savePlaybackPosition)
                }
                // folders
                Section(header: Text("Folders")) {
                    Toggle("Group channels into folders", isOn: $settings.groupChannelsIntoFolders)
                }
                // Network
                Section {
                    Toggle("Use Cellular Data", isOn: $settings.useCellularData)
                } header: {
                    Text("Network")
                }
                // download settings
                Section {
                    HStack {
                        Stepper("Number Of Concurrent Downloads", value: $settings.numberOfConcurrentDownloads, in: 1 ... 10, step: 1)
                        Text(String(settings.numberOfConcurrentDownloads))
                    }
                } header: {
                    Text("Downloads")
                } footer: {
                    Text("""
                    Youtube streams are throttled thus a video is inherently limited by how fast it can download. To make use of unused networks resources, videos can be downloaded concurrently. For faster networks, increase the number of concurrent downloads. For slower networks, decrease it. The default is three.
                    """)
                }

                // storage management
                Section(header: Text("Storage")) {
                    Button("Manage Storage...") {
                        // show storage managment
                        
                        manageStorageIsShowing = true
                    }
                    .foregroundColor(.blue)
                }
            }
            .sheet(isPresented: $manageStorageIsShowing, onDismiss: nil, content: {
                StorageBarView()
            })
            .listStyle(InsetGroupedListStyle())
            .navigationTitle(Text("Settings"))
            .toolbar {
                Button("Done") {
                    Settings.saveSettings()
                    presentationState.wrappedValue.dismiss()
                }
            }
            
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .environmentObject(Settings.shared)
    }
}
