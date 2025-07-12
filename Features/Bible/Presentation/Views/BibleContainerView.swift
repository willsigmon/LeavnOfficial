import SwiftUI

/// Container view that creates and injects dependencies for the Bible feature
public struct BibleContainerView: View {
    @EnvironmentObject private var dependencyContainer: DependencyContainer
    @StateObject private var coordinator = BibleCoordinator()
    
    public init() {}
    
    public var body: some View {
        // Create view model with dependencies
        let viewModel = dependencyContainer.makeBibleViewModel(coordinator: coordinator)
        
        BibleReaderView(viewModel: viewModel, coordinator: coordinator)
    }
}