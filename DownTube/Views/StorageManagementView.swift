//
//  StorageManagementView.swift
//  StorageManagementView
//
//  Created by Benjamin Nakiwala on 8/24/21.
//

import SwiftUI

struct StorageManagementView: View {
    @StateObject var videoDatabase = VideoDatabase.shared
    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

struct StorageManagementView_Previews: PreviewProvider {
    static var previews: some View {
        StorageManagementView()
    }
}
