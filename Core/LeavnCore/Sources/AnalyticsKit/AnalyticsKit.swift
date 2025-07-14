import Foundation
import os.log

// MARK: - Analytics Event Protocol
public protocol AnalyticsEvent {
    var name: String { get }
    var parameters: [String: Any]? { get }
}

// MARK: - Analytics Provider Protocol
public protocol AnalyticsProvider {
    func track(event: AnalyticsEvent)
    func setUserProperty(key: String, value: String?)
    func setUserId(_ userId: String?)
    func resetUser()
}

// MARK: - Analytics Service
public final class AnalyticsService {
    private var providers: [AnalyticsProvider] = []
    private let configuration: LeavnConfiguration
    
    public init(configuration: LeavnConfiguration) {
        self.configuration = configuration
    }
    
    public func addProvider(_ provider: AnalyticsProvider) {
        providers.append(provider)
    }
    
    public func track(event: AnalyticsEvent) {
        guard configuration.analyticsEnabled else { return }
        
        providers.forEach { provider in
            provider.track(event: event)
        }
    }
    
    public func setUserProperty(key: String, value: String?) {
        guard configuration.analyticsEnabled else { return }
        
        providers.forEach { provider in
            provider.setUserProperty(key: key, value: value)
        }
    }
    
    public func setUserId(_ userId: String?) {
        guard configuration.analyticsEnabled else { return }
        
        providers.forEach { provider in
            provider.setUserId(userId)
        }
    }
    
    public func resetUser() {
        guard configuration.analyticsEnabled else { return }
        
        providers.forEach { provider in
            provider.resetUser()
        }
    }
    
    public func trackError(_ error: Error, additionalInfo: [String: Any]? = nil) {
        guard configuration.analyticsEnabled else { return }
        
        var errorInfo: [String: Any] = [
            "error_type": String(describing: type(of: error)),
            "error_description": error.localizedDescription
        ]
        
        if let additionalInfo = additionalInfo {
            errorInfo.merge(additionalInfo) { _, new in new }
        }
        
        let event = CommonAnalyticsEvent.error(
            domain: String(describing: type(of: error)),
            code: (error as NSError).code,
            description: error.localizedDescription
        )
        
        track(event: event)
    }
}

// MARK: - Common Analytics Events
public enum CommonAnalyticsEvent: AnalyticsEvent {
    case screenView(screenName: String, screenClass: String?)
    case userSignUp(method: String)
    case userLogin(method: String)
    case userLogout
    case error(domain: String, code: Int, description: String?)
    case purchase(productId: String, price: Double, currency: String)
    case share(contentType: String, itemId: String, method: String)
    case search(query: String, category: String?)
    
    public var name: String {
        switch self {
        case .screenView: return "screen_view"
        case .userSignUp: return "sign_up"
        case .userLogin: return "login"
        case .userLogout: return "logout"
        case .error: return "error"
        case .purchase: return "purchase"
        case .share: return "share"
        case .search: return "search"
        }
    }
    
    public var parameters: [String: Any]? {
        switch self {
        case .screenView(let screenName, let screenClass):
            var params: [String: Any] = ["screen_name": screenName]
            if let screenClass = screenClass {
                params["screen_class"] = screenClass
            }
            return params
            
        case .userSignUp(let method):
            return ["method": method]
            
        case .userLogin(let method):
            return ["method": method]
            
        case .userLogout:
            return nil
            
        case .error(let domain, let code, let description):
            var params: [String: Any] = [
                "error_domain": domain,
                "error_code": code
            ]
            if let description = description {
                params["error_description"] = description
            }
            return params
            
        case .purchase(let productId, let price, let currency):
            return [
                "product_id": productId,
                "price": price,
                "currency": currency
            ]
            
        case .share(let contentType, let itemId, let method):
            return [
                "content_type": contentType,
                "item_id": itemId,
                "method": method
            ]
            
        case .search(let query, let category):
            var params: [String: Any] = ["search_term": query]
            if let category = category {
                params["search_category"] = category
            }
            return params
        }
    }
}

// MARK: - Console Analytics Provider (for debugging)
public final class ConsoleAnalyticsProvider: AnalyticsProvider {
    private let logger = Logger(subsystem: "com.leavn.analytics", category: "console")
    
    public init() {}
    
    public func track(event: AnalyticsEvent) {
        logger.info("📊 Analytics Event: \(event.name)")
        if let parameters = event.parameters {
            logger.debug("   Parameters: \(String(describing: parameters))")
        }
    }
    
    public func setUserProperty(key: String, value: String?) {
        logger.info("📊 User Property: \(key) = \(value ?? "nil")")
    }
    
    public func setUserId(_ userId: String?) {
        logger.info("📊 User ID: \(userId ?? "nil")")
    }
    
    public func resetUser() {
        logger.info("📊 User Reset")
    }
}