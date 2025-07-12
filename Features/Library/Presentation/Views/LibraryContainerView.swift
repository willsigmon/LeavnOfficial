import SwiftUI

/// Example of how to create and inject dependencies for the Library feature
public struct LibraryContainerView: View {
    @StateObject private var dependencyContainer = DependencyContainer()
    @StateObject private var coordinator = LibraryCoordinator()
    
    public init() {}
    
    public var body: some View {
        let viewModel = dependencyContainer.makeLibraryViewModel(coordinator: coordinator)
        
        LibraryView(viewModel: viewModel, coordinator: coordinator)
            .environmentObject(dependencyContainer)
    }
}

// MARK: - Alternative approach using Environment directly

public struct LibraryEnvironmentView: View {
    @Environment(\.getLibraryItemsUseCase) private var getItemsUseCase
    @Environment(\.saveLibraryItemUseCase) private var saveItemUseCase
    @StateObject private var coordinator = LibraryCoordinator()
    
    public var body: some View {
        if let getItemsUseCase = getItemsUseCase,
           let saveItemUseCase = saveItemUseCase {
            let viewModel = LibraryViewModel(
                getItemsUseCase: getItemsUseCase,
                saveItemUseCase: saveItemUseCase,
                coordinator: coordinator
            )
            
            LibraryView(viewModel: viewModel, coordinator: coordinator)
        } else {
            Text("Dependencies not configured")
        }
    }
}