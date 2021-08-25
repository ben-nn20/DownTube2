//
//  LaunchScreen.swift
//  LaunchScreen
//
//  Created by Benjamin Nakiwala on 8/23/21.
//

import SwiftUI

struct LaunchScreen: View {
    @State var scale = false
    var body: some View {
        ZStack {
            Rectangle()
                .frame(width: nil, height: nil, alignment: .center)
                .foregroundColor(.white)
            if let image = UIImage(named: "DowntubeSVG") {
                if scale {
                    Image(uiImage: image)
                        .transition(.scale)
                        .shadow(radius: 5)
                        .animation(Animation.linear(duration: 2).speed(1.5), value: scale)
                } else {
                    Image(uiImage: image)
                        .shadow(radius: 5)
                }
            }
        }
        .onDisappear {
            withAnimation {
                scale = true
            }
        }
    }
}

struct LaunchScreen_Previews: PreviewProvider {
    static var previews: some View {
        LaunchScreen()
    }
}
