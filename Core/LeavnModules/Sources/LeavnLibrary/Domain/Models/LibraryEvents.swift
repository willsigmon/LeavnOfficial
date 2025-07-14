import Foundation

// MARK: - Library Events
public enum LibraryEvent {
    case itemAdded(LibraryItem)
    case itemUpdated(LibraryItem)
    case itemRemoved(String) // Item ID
    case downloadStarted(LibraryDownload)
    case downloadProgress(LibraryDownload)
    case downloadCompleted(LibraryDownload)
    case downloadFailed(LibraryDownload, Error)
    case syncStarted
    case syncCompleted(LibrarySyncStatus)
    case syncFailed(Error)
    case collectionCreated(LibraryCollection)
    case collectionUpdated(LibraryCollection)
    case collectionRemoved(String) // Collection ID
}