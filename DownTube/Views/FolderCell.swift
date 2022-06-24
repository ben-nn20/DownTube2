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
            .onDrop(of: [UTType.plainText.identifier], isTargeted: $isTargeted) { providers in
                guard let provider = providers.first(where: {
                    $0.hasItemConformingToTypeIdentifier(UTType.plainText.identifier)
                }) else { return false }
                    _ = provider.loadObject(ofClass: String.self, completionHandler: { vidID, error in
                        let video = VideoDatabase.shared.allVideos.first {
                            $0.videoId == vidID
                        }
                        VideoDatabase.shared.remove(video)
                        folder.add(video)
                    })
                return true
            }
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
                        Text("Remane")
                        Image(systemName: "pencil")
                    }
                }
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
