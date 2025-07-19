import Dependencies
import Foundation

struct DownloadClient {
    var loadDownloads: @Sendable () async throws -> [Download]
    var downloadBook: @Sendable (Book) -> AsyncStream<Double>
    var deleteDownload: @Sendable (Download.ID) async throws -> Void
    var isBookDownloaded: @Sendable (Book) async -> Bool
    var getDownloadedContent: @Sendable (Book, Int) async throws -> String?
}

extension DownloadClient: DependencyKey {
    static let liveValue = Self(
        loadDownloads: {
            // Load downloads from local storage
            let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let downloadsPath = documentsPath.appendingPathComponent("Downloads")
            
            guard FileManager.default.fileExists(atPath: downloadsPath.path) else {
                return []
            }
            
            let metadataURL = downloadsPath.appendingPathComponent("metadata.json")
            
            guard let data = try? Data(contentsOf: metadataURL) else {
                return []
            }
            
            return try JSONDecoder().decode([Download].self, from: data)
        },
        downloadBook: { book in
            AsyncStream { continuation in
                Task {
                    do {
                        // Create downloads directory if needed
                        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                        let downloadsPath = documentsPath.appendingPathComponent("Downloads")
                        try FileManager.default.createDirectory(at: downloadsPath, withIntermediateDirectories: true)
                        
                        let bookPath = downloadsPath.appendingPathComponent("\(book.rawValue)")
                        try FileManager.default.createDirectory(at: bookPath, withIntermediateDirectories: true)
                        
                        // Download all chapters for the book
                        @Dependency(\.esvClient) var esvClient
                        
                        for chapter in 1...book.chapterCount {
                            let progress = Double(chapter - 1) / Double(book.chapterCount)
                            continuation.yield(progress)
                            
                            let response = try await esvClient.getPassage(book, chapter, nil)
                            
                            let chapterPath = bookPath.appendingPathComponent("chapter_\(chapter).json")
                            let chapterData = try JSONEncoder().encode(response)
                            try chapterData.write(to: chapterPath)
                            
                            // Small delay to show progress
                            try await Task.sleep(for: .milliseconds(100))
                        }
                        
                        continuation.yield(1.0)
                        continuation.finish()
                        
                        // Update metadata
                        await updateDownloadMetadata(book: book, status: .completed)
                        
                    } catch {
                        continuation.finish()
                        await updateDownloadMetadata(book: book, status: .failed, error: error.localizedDescription)
                    }
                }
            }
        },
        deleteDownload: { downloadId in
            // Remove from metadata and delete files
            let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let downloadsPath = documentsPath.appendingPathComponent("Downloads")
            let metadataURL = downloadsPath.appendingPathComponent("metadata.json")
            
            if let data = try? Data(contentsOf: metadataURL),
               var downloads = try? JSONDecoder().decode([Download].self, from: data) {
                
                if let index = downloads.firstIndex(where: { $0.id == downloadId }) {
                    let download = downloads[index]
                    downloads.remove(at: index)
                    
                    // Save updated metadata
                    let updatedData = try JSONEncoder().encode(downloads)
                    try updatedData.write(to: metadataURL)
                    
                    // Delete book files
                    let bookPath = downloadsPath.appendingPathComponent("\(download.book.rawValue)")
                    try? FileManager.default.removeItem(at: bookPath)
                }
            }
        },
        isBookDownloaded: { book in
            let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let downloadsPath = documentsPath.appendingPathComponent("Downloads")
            let bookPath = downloadsPath.appendingPathComponent("\(book.rawValue)")
            
            return FileManager.default.fileExists(atPath: bookPath.path)
        },
        getDownloadedContent: { book, chapter in
            let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let downloadsPath = documentsPath.appendingPathComponent("Downloads")
            let chapterPath = downloadsPath.appendingPathComponent("\(book.rawValue)/chapter_\(chapter).json")
            
            guard let data = try? Data(contentsOf: chapterPath),
                  let response = try? JSONDecoder().decode(PassageResponse.self, from: data) else {
                return nil
            }
            
            return response.text
        }
    )
}

extension DependencyValues {
    var downloadClient: DownloadClient {
        get { self[DownloadClient.self] }
        set { self[DownloadClient.self] = newValue }
    }
}

@Sendable private func updateDownloadMetadata(book: Book, status: DownloadStatus, error: String? = nil) async {
    let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    let downloadsPath = documentsPath.appendingPathComponent("Downloads")
    let metadataURL = downloadsPath.appendingPathComponent("metadata.json")
    
    var downloads: [Download] = []
    
    if let data = try? Data(contentsOf: metadataURL) {
        downloads = (try? JSONDecoder().decode([Download].self, from: data)) ?? []
    }
    
    if let index = downloads.firstIndex(where: { $0.book == book }) {
        downloads[index].status = status
        downloads[index].error = error
        if status == .completed {
            downloads[index].completedAt = Date()
        }
    } else {
        let download = Download(
            book: book,
            progress: status == .completed ? 1.0 : 0.0,
            status: status,
            completedAt: status == .completed ? Date() : nil,
            error: error
        )
        downloads.append(download)
    }
    
    if let data = try? JSONEncoder().encode(downloads) {
        try? data.write(to: metadataURL)
    }
}