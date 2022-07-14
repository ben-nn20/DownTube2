//
//  ErrorList.swift
//  DownTube
//
//  Created by Benjamin Nakiwala on 7/5/21.
//

import SwiftUI

struct ErrorList: View {
    @State var errorAlertShowing = false
    @State var error: NSError?
    @StateObject var logs = Logs.shared
    @Environment(\.dismiss) var dismiss
    var body: some View {
        NavigationView {
            List($logs.logs, id: \.id) { log in
                let error = log.wrappedValue
                Text(error.domain)
                    .onTapGesture {
                        self.error = error
                        errorAlertShowing = true
                    }
            }
            .toolbar {
                Button("Done") {
                    dismiss()
                }
            }
            .alert(isPresented: $errorAlertShowing, content: {
                Alert(title: Text("Error"), message: Text(error!.description + "\n" + (error!.localizedFailureReason ?? "") ), dismissButton: nil)
        })
        }
    }
}

struct ErrorList_Previews: PreviewProvider {
    static var previews: some View {
        ErrorList()
    }
}
