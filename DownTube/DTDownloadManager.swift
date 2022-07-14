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
            let thumbReq = URLRequest(url: thumbnailURL)
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
            let videoDownloadTask = urlSession.downloadTask(with: videoURL)
            videoDownloadTask.resume()
            video.downloadProgress = videoDownloadTask.progress
            DispatchQueue.main.async {
                video.downloadStatus = .downloading
            }
            downloadingVideos.append((videoDownloadTask, video))
            Logs.addError(NSError(domain: "Downloading \(video.title)", code: 0, userInfo: nil))
        } else {
            downloadQueue.append((videoURL, video))
            Logs.addError(NSError(domain: "Scheduled Download of \(video.title)", code: 0, userInfo: nil))
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
            videoAndInfo.videoTask.cancel { data in
                videoAndInfo.video.downloadResumeData = data
            }
            downloadingVideos.removeAll {
                $0 == videoAndInfo
            }
            Logs.addError(NSError(domain: "Cancelled \(video.title)", code: 0, userInfo: nil))
        }
    }
    func pauseDownloads() {
        downloadingVideos.forEach {
            $0.videoTask.suspend()
        }
    }
    func pauseDownload(for video: Video) {
        let videoAndInfo = downloadingVideos.first {
            $0.video === video
        }
        if let videoAndInfo = videoAndInfo {
            videoAndInfo.videoTask.suspend()
            video.downloadStatus = .paused
        }
    }
    func resumeDownload(for video: Video) {
        let videoAndInfo = downloadingVideos.first {
            $0.video === video
        }
        if let videoAndInfo = videoAndInfo {
            videoAndInfo.videoTask.resume()
            video.downloadStatus = .downloading
        }
    }
    func resumeWtih(resumeData: Data, video: Video) {
        let task = urlSession.downloadTask(withResumeData: resumeData)
        downloadingVideos.append((task, video))
        task.resume()
        video.downloadProgress = task.progress
        video.downloadResumeData = nil
        video.downloadStatus = .downloading
        video.isDownloaded = false
    }
    private func getVideoFrom(task: URLSessionTask) -> Video? {
        guard let set = downloadingVideos.first(where: { $0.videoTask === task }) else { return nil }
        return set.video
    }
    func handleDownloadingVideos() {
        // Pause all downloading videos
        downloadingVideos.forEach { task in
            task.videoTask.cancel { data in
                task.video.downloadResumeData = data
                print(data as Any)
            }
        }
    }
}
//MARK: Extension
extension DTDownloadManager: URLSessionDownloadDelegate, URLSessionDelegate {
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        guard let video = getVideoFrom(task: downloadTask) else { downloadTask.cancel(); return }
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
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        guard let video = getVideoFrom(task: downloadTask) else { downloadTask.cancel(); return }
        DispatchQueue.main.async {
           let size = Int64((downloadTask.response as? HTTPURLResponse)?.value(forHTTPHeaderField: "Content-Length") ?? "0") ?? 0
            video.downloadedVideoSize = totalBytesWritten
            video.totalVideoSize = size
            video.downloadFractionCompleted = video.downloadProgress.fractionCompleted
            let timeDiff = CFAbsoluteTimeGetCurrent() - video.downloadSpeedTimeStamp
            let speed = Double(bytesWritten) / timeDiff
            video.downloadSpeed = "\(ByteCountFormatter.string(fromByteCount: Int64(speed), countStyle: .binary))/s"
            video.downloadSpeedTimeStamp = CFAbsoluteTimeGetCurrent()
        }
    }
    // Handle Resume Data
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        guard let video = getVideoFrom(task: task), let error = error else { return }
        video.downloadDidFailWith(error: error)
        Logs.addError(error)
    }
    func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        DispatchQueue.main.async { [weak self] in
            self?.urlSessionCallback?()
        }
    }
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didResumeAtOffset fileOffset: Int64, expectedTotalBytes: Int64) {
        guard let video = getVideoFrom(task: downloadTask) else { return }
        DispatchQueue.main.sync {
            var size: Int64?
            if let httpHeader = downloadTask.response as? HTTPURLResponse {
                if let rangeStr = httpHeader.value(forHTTPHeaderField: "content-range") {
                    let index = rangeStr.firstIndex(of: "/")!
                    size = Int64(rangeStr[rangeStr.index(after: index) ... rangeStr.index(before: rangeStr.endIndex)])!
                } else {
                    size = Int64((downloadTask.response as? HTTPURLResponse)?.value(forHTTPHeaderField: "Content-Length") ?? "0") ?? 0
                }
            }
             video.downloadedVideoSize = fileOffset
             video.totalVideoSize = size ?? 0
             video.downloadFractionCompleted = video.downloadProgress.fractionCompleted
        }
    }
}
