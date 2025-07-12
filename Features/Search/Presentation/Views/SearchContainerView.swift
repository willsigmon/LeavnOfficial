import SwiftUI

/// Container view that creates and injects dependencies for the Search feature
public struct SearchContainerView: View {
    @EnvironmentObject private var dependencyContainer: DependencyContainer
    @EnvironmentObject private var appCoordinator: NavigationCoordinator
    @StateObject private var searchCoordinator: SearchCoordinator
    
    public init() {
        // Initialize with app coordinator if available
        self._searchCoordinator = StateObject(wrappedValue: SearchCoordinator())
    }
    
    public var body: some View {
        let viewModel = dependencyContainer.makeSearchViewModel(coordinator: searchCoordinator)
        
        SearchView(viewModel: viewModel, coordinator: searchCoordinator)
            .onAppear {
                // Connect to app coordinator if available
                if searchCoordinator.appCoordinator == nil {
                    searchCoordinator.appCoordinator = appCoordinator
                }
            }
    }
}