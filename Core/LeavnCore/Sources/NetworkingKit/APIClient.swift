import Foundation
import LeavnCore

// MARK: - API Client Protocol
public protocol APIClient {
    var networkService: NetworkService { get }
}

// MARK: - Base API Client
open class BaseAPIClient: APIClient {
    public let networkService: NetworkService
    
    public init(networkService: NetworkService) {
        self.networkService = networkService
    }
}

// MARK: - API Response Models
public struct APIResponse<T: Decodable>: Decodable {
    public let data: T
    public let meta: ResponseMeta?
    
    public struct ResponseMeta: Decodable {
        public let page: Int?
        public let totalPages: Int?
        public let totalItems: Int?
        public let itemsPerPage: Int?
    }
}

public struct APIError: Decodable, LocalizedError {
    public let code: String
    public let message: String
    public let details: [String: AnyCodable]?
    
    public var errorDescription: String? {
        message
    }
}


// MARK: - Pagination
public struct PaginationRequest {
    public let page: Int
    public let perPage: Int
    public let sortBy: String?
    public let sortOrder: SortOrder?
    
    public enum SortOrder: String {
        case ascending = "asc"
        case descending = "desc"
    }
    
    public init(
        page: Int = 1,
        perPage: Int = 20,
        sortBy: String? = nil,
        sortOrder: SortOrder? = nil
    ) {
        self.page = page
        self.perPage = perPage
        self.sortBy = sortBy
        self.sortOrder = sortOrder
    }
    
    public var parameters: [String: Any] {
        var params: [String: Any] = [
            "page": page,
            "per_page": perPage
        ]
        
        if let sortBy = sortBy {
            params["sort_by"] = sortBy
        }
        
        if let sortOrder = sortOrder {
            params["sort_order"] = sortOrder.rawValue
        }
        
        return params
    }
}