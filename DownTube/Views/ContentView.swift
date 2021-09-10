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
    @StateObject var systemContext = MainViewUpdator.shared
    @State var addButtonIsShowing = false
    @State var errorAlertShowing = false
    @State var deleteAlertShowing = false
    @State var errorViewIsShowing = false
    @State var settingsShowing = false
    var body: some View {
        NavigationView {
            VStack {
                VideoList()
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
                    }, trailing: EditButton()
                                            .foregroundColor(.blue))
                    .overlay(AddButton(hasBeenTapped: $addButtonIsShowing))
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
            .sheet(item: $systemContext.showVideo, onDismiss: nil) { video in
                VideoView(isSheet: true)
                    .environmentObject(video)
            }
        }
    }
}
struct VideoList_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
