import SwiftUI

@MainActor
public final class SearchCoordinator: ObservableObject {
    @Published public var path = NavigationPath()
    @Published public var selectedResult: SearchResult?
    @Published public var isShowingBibleReader = false
    
    // Dependencies that might be needed for navigation
    private weak var appCoordinator: NavigationCoordinator?
    
    public init(appCoordinator: NavigationCoordinator? = nil) {
        self.appCoordinator = appCoordinator
    }
    
    public func navigateToSearchResult(_ result: SearchResult) {
        selectedResult = result
        isShowingBibleReader = true
    }
    
    public func navigateToBibleVerse(bookId: String, chapter: Int, verse: Int) {
        // If we have access to app coordinator, use it for global navigation
        if let appCoordinator = appCoordinator {
            appCoordinator.push(.bibleVerse(
                bookId: bookId,
                chapter: chapter,
                verse: verse
            ))
        } else {
            // Otherwise handle locally
            let result = SearchResult(
                bookId: bookId,
                bookName: bookId, // This would be mapped properly
                chapter: chapter,
                verse: verse,
                text: "",
                translation: "NIV"
            )
            navigateToSearchResult(result)
        }
    }
    
    public func dismissBibleReader() {
        isShowingBibleReader = false
        selectedResult = nil
    }
    
    public func popToRoot() {
        path.removeLast(path.count)
    }
}