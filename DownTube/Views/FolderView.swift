//
//  FolderView.swift
//  DownTube
//
//  Created by Benjamin Nakiwala on 7/13/21.
//

import SwiftUI

struct FolderView: View {
    @EnvironmentObject var folder: Folder
    @StateObject var settings = Settings.shared
    @Environment(\.editMode) var editMode
    @State var videoSelection = Set<ObjectIdentifier>()
    @State var shouldDeleteItems = Set<ObjectIdentifier>()
    @State var searchText = ""
    @State var filterText = Settings.shared.filterMode.rawValue
    @State var shouldDelete = false
    @State var attemptingToDeleteFolders = false
    //MARK: Computed Properties
    var searchedVideos: [Video] {
        folder.videoFolders
            .compactMap { $0.video }
            .filter { $0.title.lowercased().contains(searchText.lowercased()) || $0.channelName.lowercased().contains(searchText.lowercased()) || $0.description.lowercased().contains(searchText.lowercased()) || $0.videoId.lowercased().contains(searchText.lowercased()) }
    }
    var searchedFolders: [Folder] {
        folder.folders.filter { $0.name.lowercased().contains(searchText.lowercased())}
    }
    var filteredFolders: [Folder] {
        var folders = folder.folders
        switch settings.filterMode {
        case .dateAdded:
            folders.sort {
                $0.dateCreated > $1.dateCreated
            }
        case .datePublished:
            folders.sort {
                $0.dateCreated > $1.dateCreated
            }
        case .off:
            break
        case .lastOpened:
            folders.sort {
                $0.lastOpened > $1.lastOpened
            }
        case .name:
            folders.sort {
                $0.name > $1.name
            }
        }
        return folders
    }
    var filteredVideos: [Video] {
        var videos = folder.videos
        switch settings.filterMode {
        case .dateAdded:
            videos.sort {
                $0.downloadDate > $1.downloadDate
            }
        case .datePublished:
            videos.sort {
                $0.uploadDate > $1.uploadDate
            }
        case .off:
            break
        case .lastOpened:
            videos.sort {
                $0.lastOpened > $1.lastOpened
            }
        case .name:
            videos.sort {
                $0.title > $1.title
            }
        }
        return videos
    }
    var body: some View {
        //MARK: Editing List
        if editMode != nil, let isEditing = editMode?.wrappedValue.isEditing, isEditing {
            VStack {
                List(folder.videoFolders, selection: $videoSelection) { videoFolder in
                    if let video = videoFolder.video {
                        VideoCell()
                            .environmentObject(video)
                    } else {
                        FolderCell()
                            .environmentObject(videoFolder.folder!)
                    }
                }
                HStack {
                    Spacer()
                    Button {
                        let videoFolders = folder.videoFolders.filter {
                            videoSelection.contains($0.id)
                        }
                        folder.videoFolders.removeAll { vF in
                            videoFolders.contains {
                                $0 === vF
                            }
                        }
                        folder.videoFolders.append(VideoFolder(video: nil, folder: Folder(videoFolders: videoFolders, name: "Untitled")))
                    } label: {
                        Image(systemName: "folder.badge.plus")
                            .padding()
                    }
                    Spacer()
                    Button {
                        if !videoSelection.isEmpty {
                            shouldDeleteItems = videoSelection
                        }
                    } label: {
                        Image(systemName: "trash")
                            .padding()
                    }
                    Spacer()
                }
                .animation(Animation.interactiveSpring(), value: isEditing)
            }
            .navigationBarItems(leading: Button("Select All") {
                videoSelection = Set(folder.videoFolders.map {
                    $0.id
                })
            })
            .alert(isPresented: $shouldDelete) {
                let videoFolders = folder.videoFolders.filter {
                    shouldDeleteItems.contains($0.id)
                }
                return Alert(title: Text("Delete \(videoFolders.count) items?"), message: nil, primaryButton: Alert.Button.destructive(Text("Delete"), action: {
                    if videoFolders.contains(where: {
                        $0.folder != nil
                    }) {
                        attemptingToDeleteFolders = true
                    } else {
                        videoFolders.forEach {
                            if let video = $0.video {
                                video.delete()
                            }
                        }
                    }
                }), secondaryButton: Alert.Button.cancel())
            }
            .confirmationDialog(Text("Delete Folders?"), isPresented: $attemptingToDeleteFolders) {
                VStack {
                    Button("Delete Every Folder and its Contents", role: .destructive) {
                        let videoFolders = folder.videoFolders.filter {
                            shouldDeleteItems.contains($0.id)
                        }
                        // Delete Videos
                        videoFolders.forEach { videoFolder in
                            if let video = videoFolder.video {
                                video.delete()
                            }
                        }
                        let folders = videoFolders.compactMap {
                            $0.folder
                        }
                        // Delete folders and subfolders
                        folders.forEach {
                            $0.delete()
                        }
                    }
                    Button("Delete Only the Folder") {
                        let videoFolders = folder.videoFolders.filter {
                            shouldDeleteItems.contains($0.id)
                        }
                        let folders = videoFolders.filter {
                            $0.folder != nil
                        }.compactMap {
                            $0.folder
                        }
                        // Delete folders and subfolders
                        folders.forEach {
                            $0.removeFolder()
                        }
                    }
                    Button("Cancel", role: .cancel) {}
                }
            }
            
        } else {
            //MARK: Main List
            List {
                //MARK: VideoList
                if searchText == "" {
                    // Show folder or video respectively
                    ForEach(filteredFolders) { folder in
                        NavigationLink(
                            destination: FolderView()
                                .environmentObject(folder),
                            label: {
                                FolderCell()
                                    .environmentObject(folder)
                            })
                    }
                    ForEach(filteredVideos) { video in
                        NavigationLink(
                            destination: VideoView()
                                .environmentObject(video),
                            label: {
                                VideoCell()
                                    .environmentObject(video)
                            })
                    }
                    
                    
                } else {
                    //MARK: Searching List
                    ForEach(searchedFolders) { folder in
                        NavigationLink(
                            destination: FolderView()
                                .environmentObject(folder),
                            label: {
                                FolderCell()
                                    .environmentObject(folder)
                            })
                    }
                    ForEach(searchedVideos) { video in
                        NavigationLink(
                            destination: VideoView()
                                .environmentObject(video),
                            label: {
                                VideoCell()
                                    .environmentObject(video)
                            })
                    }
                }
            }
            .searchable(text: $searchText)
            .navigationTitle(folder.name)
            .toolbar {
                ToolbarItemGroup {
                    Button {
                        // handle filtering modes
                        let allCases = FilterModes.allCases
                        let index = allCases.firstIndex(of: settings.filterMode)!
                        if index == allCases.count - 1 {
                            settings.filterMode = allCases[0]
                        } else {
                            settings.filterMode = allCases[index + 1]
                        }
                        filterText = settings.filterMode.rawValue
                    } label: {
                        HStack {
                            Text(filterText)
                            if settings.filterMode == .off {
                                Image(systemName: "line.horizontal.3.decrease.circle")
                                    .foregroundColor(.blue)
                            } else {
                                Image(systemName: "line.horizontal.3.decrease.circle.fill")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                    .toolbar {
                        EditButton()
                    }
                }
            }
            .listStyle(PlainListStyle())
        }
    }
}
    struct FolderView_Previews: PreviewProvider {
        static var previews: some View {
            FolderView()
        }
    }
