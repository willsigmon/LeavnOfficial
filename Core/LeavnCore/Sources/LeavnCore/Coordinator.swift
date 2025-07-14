import Foundation
import SwiftUI

// MARK: - Coordinator Protocol
public protocol Coordinator: AnyObject {
    associatedtype Route: Hashable
    
    var navigationPath: NavigationPath { get set }
    var childCoordinators: [any Coordinator] { get set }
    var parentCoordinator: (any Coordinator)? { get set }
    
    func start()
    func navigate(to route: Route)
    func pop()
    func popToRoot()
}

// MARK: - Base Coordinator Implementation
@MainActor
open class BaseCoordinator<Route: Hashable>: ObservableObject, @MainActor Coordinator {
    @Published public var navigationPath = NavigationPath()
    public var childCoordinators: [any Coordinator] = []
    public weak var parentCoordinator: (any Coordinator)?
    
    public init() {}
    
    open func start() {
        // Override in subclasses
    }
    
    open func navigate(to route: Route) {
        navigationPath.append(route)
    }
    
    public func pop() {
        if !navigationPath.isEmpty {
            navigationPath.removeLast()
        }
    }
    
    public func popToRoot() {
        navigationPath.removeLast(navigationPath.count)
    }
    
    public func addChild(_ coordinator: any Coordinator) {
        childCoordinators.append(coordinator)
        coordinator.parentCoordinator = self
    }
    
    public func removeChild(_ coordinator: any Coordinator) {
        childCoordinators.removeAll { $0 === coordinator }
    }
}

// MARK: - App Coordinator Protocol
public protocol AppCoordinator: Coordinator {
    func showAuth()
    func showMain()
    func showOnboarding()
}

// MARK: - Module Coordinator Protocol
public protocol ModuleCoordinator: Coordinator {
    associatedtype ModuleRoute: Hashable
    func handle(deepLink: URL) -> Bool
}

// MARK: - Navigation Helpers
public struct NavigationLinkButton<Label: View>: View {
    let action: () -> Void
    let label: () -> Label
    
    public init(action: @escaping () -> Void, @ViewBuilder label: @escaping () -> Label) {
        self.action = action
        self.label = label
    }
    
    public var body: some View {
        Button(action: action) {
            label()
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Deep Link Handler
public struct DeepLink {
    public let url: URL
    public let components: URLComponents
    
    public init?(url: URL) {
        self.url = url
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            return nil
        }
        self.components = components
    }
    
    public var host: String? {
        components.host
    }
    
    public var path: String {
        components.path
    }
    
    public var queryItems: [URLQueryItem]? {
        components.queryItems
    }
    
    public func queryValue(for name: String) -> String? {
        queryItems?.first(where: { $0.name == name })?.value
    }
}
