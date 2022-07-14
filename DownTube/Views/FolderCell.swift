//
//  FolderCell.swift
//  FolderCell
//
//  Created by Benjamin Nakiwala on 8/20/21.
//

import UniformTypeIdentifiers
import SwiftUI

struct FolderCell: View {
    @EnvironmentObject var folder: Folder
    @State var shouldDelete = false
    @State var shouldRemove = false
    @State var isRenaming = false
    @State var newName = ""
    @State var shouldShowFileSize = false
    @State var isTargeted = false
    var body: some View {
        if isRenaming {
            HStack {
                Image(systemName: "folder")
                TextField("\(folder.name)", text: $newName, prompt: nil)
                    .onSubmit {
                        folder.name = newName
                        isRenaming = false
                }
            }
        } else {
            HStack {
                Image(systemName: "folder")
                VStack {
                    Text(folder.name)
                    if shouldShowFileSize {
                        Text(ByteCountFormatter.string(fromByteCount: folder.fileSize, countStyle: .file))
                    }
                }
            }
            .foregroundColor(isTargeted ? .gray.opacity(0.5) : .primary)
            .contextMenu {
                Button {
                    shouldDelete = true
                } label: {
                    HStack {
                        Text("Delete")
                        Image(systemName: "trash")
                    }
                }
                Button {
                    shouldRemove = true
                } label: {
                    HStack {
                        Text("Remove")
                        Image(systemName: "minus.circle.fill")
                    }
                }
                Button {
                    isRenaming = true
                } label: {
                    HStack {
                        Text("Rename")
                        Image(systemName: "pencil")
                    }
                }
            }
            .onDrop(of: ["public.video"], isTargeted: $isTargeted) { providers in
                providers[0].loadObject(ofClass: Video.self) { video, error in
                    guard let video = video as? Video else {
                        return
                    }
                    DispatchQueue.main.async {
                        print(video.parentFolderId)
                        if let parentFolderId = video.parentFolderId, let folder = Folder.folderFrom(parentFolderId) {
                            folder.videoFolderStore.removeAll {
                                $0.video === video
                            }
                        } else {
                            video.parentFolderId = nil
                            VideoDatabase.shared.videoFolderStore.removeAll {
                                $0.video === video
                            }
                        }
                        folder.add(video, folder)
                    }
                }
                return providers[0].canLoadObject(ofClass: Video.self)
            }
            .foregroundColor(isTargeted ? .secondary : .none)
            .alert(Text("Delete Folder?"), isPresented: $shouldDelete) {
                Button("Delete", role: .destructive) {
                    folder.delete()
                }
                Button("Cancel", role: .cancel) {}
            }
            .alert("Remove Folder?", isPresented: $shouldRemove) {
                Button("Remove", role: .destructive) {
                    folder.removeFolder()
                }
                Button("Cancel", role: .cancel) {}
            }
        }
    }
}

struct FolderCell_Previews: PreviewProvider {
    static var previews: some View {
        FolderCell()
    }
}
