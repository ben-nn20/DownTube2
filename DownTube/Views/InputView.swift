//
//  InputView.swift
//  DownTube
//
//  Created by Benjamin Nakiwala on 7/1/21.
//

import SwiftUI

struct InputView: View {
    @State var inputText = ""
    @State var alertIsShowing = false
    var parentFolderId: String?
    @Environment(\.presentationMode) var presMode
    var body: some View {
        NavigationView {
            TextField("Youtube URL", text: $inputText) { (editing) in
                // pasteboard code
                if UIPasteboard.general.hasStrings && editing {
                    if let str = UIPasteboard.general.strings?.first(where: {
                        $0.contains("youtube.com/watch")
                    }) {
                        inputText = str
                    } else {
                        guard var str = UIPasteboard.general.strings?.first else {
                            alertIsShowing = true
                            return
                        }
                        str.replaceOccurances(of: "youtu.be/", with: "youtube.com/watch?v=")
                        inputText = str
                    }
                }
            } onCommit: {
                // user input code
                var str = inputText
                str.replaceOccurances(of: "watch?v=", with: "Ω")
                guard let ohmIndex = str.firstIndex(of: "Ω") else {
                    alertIsShowing = true
                    return
                }
                str.removeSubrange(str.firstIndex(of: str.first!)! ... ohmIndex)
                
                if !VideoDatabase.shared.videos.contains(where: { $0.videoId == str
                }) {
                    if let parentFolderId = parentFolderId {
                        Video.video(fromVideoId: str, parentFolderId: parentFolderId)
                    } else {
                        Video.video(fromVideoId: str)
                    }
                }
            }
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .padding()
            .alert(isPresented: $alertIsShowing) {
                Alert(title: Text("Invalid Input"))
            }
            .toolbar {
                Button("Done") {
                    var str = inputText
                    str.replaceOccurances(of: "watch?v=", with: "Ω")
                    guard let ohmIndex = str.firstIndex(of: "Ω") else {
                        return
                    }
                    str.removeSubrange(str.firstIndex(of: str.first!)! ... ohmIndex)
                    
                    if !VideoDatabase.shared.videos.contains(where: {  $0.videoId == str
                    }) {
                        Video.video(fromVideoId: str)
                    }
                    presMode.wrappedValue.dismiss()
                }
        }
        }
        
    }
}

struct InputView_Previews: PreviewProvider {
    static var previews: some View {
        InputView()
            .previewLayout(.fixed(width: 300, height: 300))
    }
}
