//
//  File.swift
//  DownTube
//
//  Created by Benjamin Nakiwala on 7/4/21.
//

import Foundation

class DTDownloadManager: NSObject {
    static var shared = DTDownloadManager()
    private override init() {}
    typealias DownloadTaskInfo = (videoTask: URLSessionDownloadTask, video: Video)
    typealias DownloadURLInfo = (videoURL: URL, video: Video)
    var urlSessionCallback: (() -> Void)?
    lazy private var urlSession: URLSession = {
        let configuration = URLSessionConfiguration.background(withIdentifier: "VideoDownloaderConfiguaration")
        configuration.isDiscretionary = false
        configuration.sessionSendsLaunchEvents = true
        return URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
    }()
    var hasDownloads: Bool {
        if !downloadQueue.isEmpty || !downloadingVideos.isEmpty {
            return true
        } else {
            return false
        }
    }
    var numberOfConcurrentDownloads: Int {
        Settings.shared.numberOfConcurrentDownloads
    }
    private var downloadingVideos = [DownloadTaskInfo]()
    private var downloadQueue = [DownloadURLInfo]()
    // MARK: Functions
    func download(videoURL: URL, thumbnailURL: URL? = nil, video: Video) {
        // thumbnail urlSessiontask
        if let thumbnailURL = thumbnailURL {
            var thumbReq = URLRequest(url: thumbnailURL)
            thumbReq.allowsCellularAccess = Settings.shared.useCellularData
            URLSession.shared.dataTask(with: thumbReq) { (data, response, error) in
                guard error == nil else { return }
                try! data!.write(to: video.thumbnailUrl)
                DispatchQueue.main.async {
                    video.thumbnailIsDownloaded = true
                }
            }.resume()
        }
        if downloadingVideos.count < numberOfConcurrentDownloads {
            // video urlSessionTask
            var req = URLRequest(url: videoURL)
            req.addValue("", forHTTPHeaderField: "Range")
            req.allowsCellularAccess = Settings.shared.useCellularData
            let videoDownloadTask = urlSession.downloadTask(with: videoURL)
            videoDownloadTask.resume()
            video.downloadProgress = videoDownloadTask.progress
            DispatchQueue.main.async {
                video.downloadStatus = .downloading
            }
            downloadingVideos.append((videoDownloadTask, video))
            logs.insert(NSError(domain: "Downloading \(video.title)", code: 0, userInfo: nil), at:  0)
        } else {
            downloadQueue.append((videoURL, video))
            logs.insert(NSError(domain: "Scheduled Download of \(video.title)", code: 0, userInfo: nil), at: 0)
            video.downloadStatus = .waiting
        }
    }
    func isVideoDownloading(_ video: Video) -> Bool {
        downloadingVideos.contains { videoAndInfo in
            videoAndInfo.video === video
        } || downloadQueue.contains(where: { videoAndInfo in
            videoAndInfo.video === video
        })
    }
    /// Cancel downloads for video if any exist.
    func cancelDownloads(for video: Video) {
        let videoAndInfo = downloadingVideos.first {
            $0.video === video
        }
        if let videoAndInfo = videoAndInfo {
            videoAndInfo.videoTask.cancel()
            logs.insert(NSError(domain: "Cancelled \(video.title)", code: 0, userInfo: nil), at: 0)
        }
    }
    private func getVideoFrom(task: URLSessionTask) -> Video? {
        guard let set = downloadingVideos.first(where: { $0.videoTask === task }) else { return nil }
        return set.video
    }
}
extension DTDownloadManager: URLSessionDownloadDelegate {
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        guard let video = getVideoFrom(task: downloadTask) else { return }
        DispatchQueue.main.sync {
            video.videoFinishedDownloading(location)
        }
        downloadingVideos.removeAll {
            $0.video === video
        }
        
        guard let nextVideo = downloadQueue.first, downloadingVideos.count < numberOfConcurrentDownloads else { return }
        download(videoURL: nextVideo.videoURL, video: nextVideo.video)
        downloadQueue.removeAll {
            $0 == nextVideo
        }
    }
    // Handle Resume Data
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        guard let video = getVideoFrom(task: task), let error = error else { return }
        video.downloadDidFailWith(error: error)
        logs.insert(error, at: 0)
    }
    func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        DispatchQueue.main.async { [weak self] in
            self?.urlSessionCallback?()
        }
    }
}
