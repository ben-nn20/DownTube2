//
//  SwiftUITableViewCell.swift
//  VideoFolderTableViewCell
//
//  Created by Benjamin Nakiwala on 8/9/21.
//

import SwiftUI

class VideoFolderTableViewCell: UITableViewCell {
    func configureWith(videoFolder: VideoFolder) {
        if let video = videoFolder.video {
            let hostingVC = UIHostingController(rootView: VideoCell().environmentObject(video))
            let view = hostingVC.view!
            self.contentView.addSubview(view)
        } else if let folder = videoFolder.folder {
            let hostingVC = UIHostingController(rootView: FolderCell().environmentObject(folder))
            let view = hostingVC.view!
            self.contentView.addSubview(view)
            self.accessoryType = .disclosureIndicator
        }
       
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
}
