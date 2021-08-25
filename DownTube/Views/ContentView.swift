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
    }
}
