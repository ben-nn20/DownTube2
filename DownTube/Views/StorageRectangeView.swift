//
//  StorageRectangeView.swift
//  StorageRectangeView
//
//  Created by Benjamin Nakiwala on 8/24/21.
//

import SwiftUI

struct StorageRectangeView: View {
    @State var size: Int64
    @State var parentBarWidth: CGFloat
    @State var totalDiskSpace: Int64
    @State var color: Color
    @State var isAnimating = false
    var width: CGFloat {
        (CGFloat(size) * CGFloat(totalDiskSpace)) * parentBarWidth
    }
    var body: some View {
        Rectangle()
            .frame(width: 2, height: 20, alignment: .center)
            .scaleEffect(x: isAnimating ? width / 2 : 1, anchor: .trailing)
            .onAppear {
                withAnimation(Animation.spring(blendDuration: 0.5).delay(0.5)) {
                    isAnimating = true
                }
            }
            .onDisappear {
                withAnimation(Animation.spring(blendDuration: 0.5).delay(0.5)) {
                    isAnimating = false
                }
            }
    }
}
