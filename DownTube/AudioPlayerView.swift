//
//  AudioPlayerView.swift
//  AudioPlayerView
//
//  Created by Benjamin Nakiwala on 8/5/21.
//

import SwiftUI

struct AudioPlayerView: View {
    @StateObject var audioPlayer = AudioPlayer.shared
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

struct AudioPlayerView_Previews: PreviewProvider {
    static var previews: some View {
        AudioPlayerView()
    }
}
