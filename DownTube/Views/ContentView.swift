//
//  VideoList.swift
//  DownTube
//
//  Created by Benjamin Nakiwala on 6/28/21.
//

import SwiftUI
import AVKit

struct ContentView: View {
    @StateObject var systemContext = MainViewUpdator.shared
    @StateObject var orientation = Orientation()
    @State var addButtonIsShowing = false
    @State var errorAlertShowing = false
    @State var deleteAlertShowing = false
    @State var errorViewIsShowing = false
    @State var settingsShowing = false
    enum OS {
        case macCatalyst
        case iOS
        case iPadOS
    }
    var os: OS {
        let idiom = UIDevice.current.userInterfaceIdiom
        switch idiom {
        case .pad:
               return .iPadOS
        case .mac:
            return .macCatalyst
        case .phone:
            return .iOS
        default:
            fatalError()
        }
    }
    var body: some View {
        #if targetEnvironment(macCatalyst)
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
                VideoView(video: video, isSheet: true)
            }
        }
        .navigationViewStyle(.stack)
        #elseif os(iOS)
        if orientation.direction == .portriat && os == .iPadOS {
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
                    VideoView(video: video, isSheet: true)
                }
            }
            .navigationViewStyle(.stack)
        } else {
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
                    VideoView(video: video, isSheet: true)
                }
            }
            .navigationViewStyle(.stack)
        }
        #endif
    }
}
struct VideoList_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
