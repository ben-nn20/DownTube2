//
//  AudioPlayerView.swift
//  AudioPlayerView
//
//  Created by Benjamin Nakiwala on 8/5/21.
//

import SwiftUI

struct AudioPlayerView: View {
    @StateObject var audioPlayer = AudioPlayer.shared
    @State var isFullScreen = false
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .frame(width: nil, height: 50, alignment: .center)
                
        }
            
    }
}

struct AudioPlayerView_Previews: PreviewProvider {
    static var previews: some View {
        AudioPlayerView()
    }
}
