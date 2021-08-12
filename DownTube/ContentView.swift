//
//  VideoList.swift
//  DownTube
//
//  Created by Benjamin Nakiwala on 6/28/21.
//

import SwiftUI
import AVKit

struct ContentView: View {
    @StateObject var orientation = Orientation()
    @EnvironmentObject var systemContext: MainViewUpdator
    @State var addButtonIsShowing = false
    @State var errorAlertShowing = false
    @State var deleteAlertShowing = false
    @State var errorViewIsShowing = false
    @State var settingsShowing = false
    @State var contextMenuDeleteTriggered = false
    @State var shouldDelete: Video?
    @State var videoSelection = Set<String>()
    var body: some View {
        NavigationView {
            VStack {
                VideoList(selectionBinding: videoSelection)
                    .environmentObject(videoDatabase)
                    .listStyle(PlainListStyle())
                    .navigationBarTitle(Text("Videos"))
                    .navigationBarItems(leading:
                                            Image(systemName: "gear")
                                            .foregroundColor(.red)
                                            .onTapGesture {
                        settingsShowing = true
                    }
                                            .onLongPressGesture {
                        errorViewIsShowing = true
                    }
                                        
                                        
                                        , trailing: EditButton()
                                            .foregroundColor(.blue))
                    .overlay(VStack {
                        ForEach(1 ..< 8) { _ in
                            Spacer()
                        }
                        HStack {
                            ForEach(1 ..< 9) { _ in
                                Spacer()
                            }
                            Button(action: {
                                addButtonIsShowing.toggle()
                            }, label: {
                                Image(systemName: "plus")
                                    .resizable()
                                    .padding(14)
                                    .foregroundColor(.white)
                                    .frame(width: 50, height: 50, alignment: .center)
                                    .background(Circle())
                            })
                                .shadow(radius: 5)
                                .foregroundColor(.red)
                            Spacer()
                        }
                        Spacer()
                    }
                    )
                HStack {
                    if videoSelection.count > 0 {
                        Button(action: {
                            let videos = videoDatabase.videoFolders.compactMap {
                                $0.video
                            }
                            let filteredVideos = videos.filter {
                                videoSelection.contains($0.id)
                            }
                            let videoFolders = filteredVideos.map {
                                VideoFolder(video: $0, folder: nil)
                            }
                            let folder = Folder(videoFolders: videoFolders, name: "Folder 1")
                            videoDatabase.videoFolders.append(VideoFolder(video: nil, folder: folder))
                        }, label: {
                            Image(systemName: "folder.badge.plus")
                                .padding()
                        })
                        Spacer()
                        Button(action: {
                            if videoSelection.count > 0 {
                                deleteAlertShowing = true
                            }
                        }, label: {
                            Image(systemName: "trash")
                                .padding()
                        })
                    }
                }
            }
            .accentColor(.blue)
            .fullScreenCover(isPresented: $settingsShowing) {
                SettingsView()
                    .environmentObject(Settings.shared)
            }
            .sheet(isPresented: $errorViewIsShowing, content: {
                ErrorList()
            })
            .sheet(isPresented: $addButtonIsShowing) {
                InputView()
            }
        }
    }
}
struct VideoList_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(VideoDatabase.example)
            .environmentObject(MainViewUpdator.shared)
    }
}
