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
    var body: some View {
        List {
            
            if logs.count > 0 {
                ForEach(Range<Int>(0 ... logs.count - 1)) { i in
                    let error = logs[i] as NSError
                    Text(error.domain + " " +  (error.localizedFailureReason ?? ""))
                        .onTapGesture {
                            self.error = error
                            errorAlertShowing = true
                        }
                }
            } else {
                EmptyView()
            }
        }
        .alert(isPresented: $errorAlertShowing, content: {
            Alert(title: Text("Error"), message: Text(error!.description + "\n" + (error!.localizedFailureReason ?? "") ), dismissButton: nil)
        })
    }
}

struct ErrorList_Previews: PreviewProvider {
    static var previews: some View {
        ErrorList()
    }
}
