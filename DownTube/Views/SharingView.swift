//
//  SharingVIew.swift
//  DownTube
//
//  Created by Benjamin Nakiwala on 7/11/22.
//

import SwiftUI
import Combine

struct SharingView: View {
    @EnvironmentObject var video: Video
    @StateObject var sharingManager = SharingManager.shared
    @State var progress = Progress() {
        didSet {
            cancellable = progress.publisher(for: \.fractionCompleted).sink { fractionCompleted in
                withAnimation {
                    self.fractionCompleted = fractionCompleted
                }
            }
        }
    }
    @State var fractionCompleted = 0.0
    @Environment(\.dismiss) var dismiss
    @State var cancellable: AnyCancellable!
    var body: some View {
        NavigationView {
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack {
                    ForEach(sharingManager.peers) { peer in
                        VStack(spacing: 10) {
                            Spacer()
                            Circle()
                                .foregroundColor(sharingManager.peerConnectionStatus(peer: peer) ? .green : .gray.opacity(0.5))
                                .frame(width: 100)
                                .overlay {
                                    ZStack {
                                        Image(systemName: "person.fill")
                                        Circle()
                                            .trim(from: 0.0, to: fractionCompleted)
                                            .stroke(LinearGradient(gradient: Gradient(colors: [.red.opacity(0.75), .red.opacity(0.8)]), startPoint: UnitPoint(x: 0, y: 0), endPoint: UnitPoint(x: 1, y: 1)), style: StrokeStyle(lineWidth: 5, lineCap: .round, lineJoin: .round))
                                            .rotationEffect(.degrees(-90))
                                            .frame(width: 100)
                                    }
                                }
                            Text(peer.displayName)
                            Spacer()
                        }
                        .onTapGesture {
                            sharingManager.connectToPeer(peer: peer) { connected in
                                if connected {
                                    progress = sharingManager.sendVideo(video) ?? Progress()
                                    print(progress.totalUnitCount)
                                }
                            }
                           // dismiss()
                        }
                    }
                    .padding()
                }
                .onAppear {
                    sharingManager.startSearchingForAvailablePeers()
                }
                .onDisappear {
                    sharingManager.stopSearchingForAvailablePeers()
                }
            }
            .toolbar {
                Button {
                    dismiss()
                } label: {
                    Text("Done")
                }
            }
        }
    }
}
