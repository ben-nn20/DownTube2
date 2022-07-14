//
//  DTSpeedDownloadManager.swift
//  DownTube
//
//  Created by Benjamin Nakiwala on 6/24/22.
//

import Foundation

class DTSpeedDownloadManager: NSObject {
    static let shared = DTSpeedDownloadManager()
    lazy var urlSession: URLSession = {
        let config = URLSessionConfiguration.background(withIdentifier: "DTSpeedDownloadManager")
        config.sessionSendsLaunchEvents = true
        config.shouldUseExtendedBackgroundIdleMode = true
        config.isDiscretionary = false
        config.waitsForConnectivity = false
        return URLSession(configuration: config, delegate: self, delegateQueue: nil)
    }()
    var urlSessionCallback: (() -> Void)?
    private var currentlyDownloadingVideo: (video: Video, videoURL: URL)?
    private var downloadQueue = [(video: Video, videoURL: URL)]()
    private var downloadTasks = [(task: URLSessionDownloadTask, startRange: Int64, endRange: Int64)]()
    let downloadRange: Int64 = 10_000_000
    var rangeAccountedFor: Int64 = 0
    var downloadedRange: Int64 = 0
    var videoSize: Int64 = 10_000_010 {
        didSet {
            if videoSize > 10_000_010 {
                beginAllDownloads()
            }
        }
    }
    var directoryForURLS: URL? {
        guard let currentlyDownloadingVideo = currentlyDownloadingVideo else {
            return nil
        }
        try? FileManager.default.createDirectory(at: FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("\(currentlyDownloadingVideo.video.title) files"), withIntermediateDirectories: true)
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("\(currentlyDownloadingVideo.video.title) files")
    }
    var timeForSpeed = CFAbsoluteTimeGetCurrent()
    private override init() {
        super.init()
    }
    func download(video: Video, videoURL: URL, thumbnailURL: URL? = nil) {
        // Task for thumbnail
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
        if currentlyDownloadingVideo == nil {
            currentlyDownloadingVideo = (video, videoURL)
            beginDownloads()
        } else {
            downloadQueue.append((video, videoURL))
        }
    }
    func request() -> (req: URLRequest, startRange: Int64, endRange: Int64) {
        guard let currentlyDownloadingVideo = currentlyDownloadingVideo else {
            fatalError()
        }
        let endRange = (rangeAccountedFor + downloadRange) < videoSize ? (rangeAccountedFor + downloadRange) : videoSize
        let startRange = rangeAccountedFor
        var req = URLRequest(url: currentlyDownloadingVideo.videoURL)
        req.setValue("bytes=\(rangeAccountedFor)-\(endRange)", forHTTPHeaderField: "Range")
        rangeAccountedFor += downloadRange
        return (req, startRange, endRange)
    }
    func beginDownloads() {
        let reqAndRanges = request()
        let task = urlSession.downloadTask(with: reqAndRanges.req)
        downloadTasks.append((task, reqAndRanges.startRange, reqAndRanges.endRange))
        task.resume()
        DispatchQueue.main.async {
            self.currentlyDownloadingVideo?.video.downloadStatus = .downloading
        }
    }
    func beginAllDownloads() {
        while rangeAccountedFor < videoSize {
            beginDownloads()
        }
    }
    func finishTask(_ task: URLSessionDownloadTask, location: URL) {
        let taskAndRanges = downloadTasks.first {
            $0.task === task
        }!
        guard let url = url(startRange: taskAndRanges.startRange, endRange: taskAndRanges.endRange) else { return }
        
        try? FileManager.default.moveItem(at: location, to: url)
    }
    func finishAllDownloads() {
        guard let currentlyDownloadingVideo = currentlyDownloadingVideo else {
            return
        }
        downloadTasks.sorted {
            $0.endRange < $1.endRange
        }.forEach {
            guard let url = url(startRange: $0.startRange, endRange: $0.endRange) else { return }
            currentlyDownloadingVideo.video.videoPartiallyDownloaded(url)
        }
    }
    func url(startRange: Int64, endRange: Int64) -> URL? {
        guard let directoryForURLS = directoryForURLS else {
            return nil
        }
        return directoryForURLS.appendingPathComponent("\(currentlyDownloadingVideo!.video.videoId) \(startRange) - \(endRange)")
    }
    func cancelDownloads(for video: Video) {
        if currentlyDownloadingVideo?.video === video {
            currentlyDownloadingVideo = nil
            downloadTasks.forEach { taskAndRanges in
                taskAndRanges.task.cancel()
                guard let directoryForURLS = directoryForURLS else {
                    return
                }
                try? FileManager.default.removeItem(at: directoryForURLS)
            }
            downloadTasks.removeAll()
            rangeAccountedFor = 0
            videoSize = 10_000_010
            downloadedRange = 0
        }
    }
    
}
extension DTSpeedDownloadManager: URLSessionDownloadDelegate {
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        if !downloadTasks.contains(where: {
            $0.task === downloadTask
        }) {
            downloadTask.cancel()
            return
        }
        finishTask(downloadTask, location: location)
        if downloadedRange == videoSize {
            finishAllDownloads()
        }
    }
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        if !downloadTasks.contains(where: {
            $0.task === downloadTask
        }) {
            downloadTask.cancel()
        }
        // Set video Size {
        if let httpHeader = downloadTask.response as? HTTPURLResponse, videoSize == 10_000_010 {
            let rangeStr = httpHeader.value(forHTTPHeaderField: "Content-Range")!
            let index = rangeStr.firstIndex(of: "/")!
            let size = rangeStr[rangeStr.index(after: index) ... rangeStr.index(before: rangeStr.endIndex)]
            videoSize = Int64(size)!
        }
        guard let video = currentlyDownloadingVideo else { return }
        let speed = Double(bytesWritten) / timeForSpeed - CFAbsoluteTimeGetCurrent()
        DispatchQueue.main.async {
            video.video.downloadSpeed = ByteCountFormatter.string(fromByteCount: Int64(speed), countStyle: .file) + "/s"
        }
        downloadedRange += bytesWritten
        print(videoSize / downloadedRange)
        DispatchQueue.main.sync {
            video.video.downloadFractionCompleted = Double(videoSize / downloadedRange)
        }
        timeForSpeed = CFAbsoluteTimeGetCurrent()
    }
    func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        urlSessionCallback?()
    }
}
