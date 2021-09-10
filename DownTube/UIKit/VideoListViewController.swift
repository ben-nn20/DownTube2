//
//  VideoListViewController.swift
//  VideoListViewController
//
//  Created by Benjamin Nakiwala on 8/9/21.
//

import UIKit

class VideoListViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.rightBarButtonItem = self.editButtonItem
        tableView.register(VideoFolderTableViewCell.self, forCellReuseIdentifier: "videoCell")
        tableView.separatorColor = .clear
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        VideoDatabase.shared.videoFolders.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "videoCell", for: indexPath) as! VideoFolderTableViewCell
        let row = indexPath.row
        let vF = VideoDatabase.shared.videoFolders(.dateAdded)[row]
        cell.configureWith(videoFolder: vF)
        return cell
    }

    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let vF = VideoDatabase.shared.videoFolders[indexPath.row]
        if let video = vF.video {
            return UISwipeActionsConfiguration(actions: [UIContextualAction(style: .normal, title: "Play Audio", handler: { action, view, completion in
                AudioPlayer.shared.play(video)
            })])
        }
        return nil
    }
}