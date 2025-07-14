import Foundation
import SwiftUI

// MARK: - AI Provider
public enum AIProvider: String, CaseIterable, Identifiable {
    case openAI = "OpenAI"
    case anthropic = "Anthropic"
    case google = "Google Gemini"
    case xAI = "Grok (xAI)"
    
    public var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .openAI: return "brain"
        case .anthropic: return "a.circle.fill"
        case .google: return "sparkles"
        case .xAI: return "bolt.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .openAI: return Color(red: 0.063, green: 0.639, blue: 0.498)
        case .anthropic: return Color(red: 0.831, green: 0.647, blue: 0.455)
        case .google: return Color(red: 0.259, green: 0.522, blue: 0.957)
        case .xAI: return Color(red: 0.114, green: 0.631, blue: 0.949)
        }
    }
    
    var description: String {
        switch self {
        case .openAI:
            return "GPT-4 and GPT-3.5 models for Bible study insights"
        case .anthropic:
            return "Claude models for thoughtful theological analysis"
        case .google:
            return "Gemini models for comprehensive scripture understanding"
        case .xAI:
            return "Grok models for unique perspectives and insights"
        }
    }
    
    var keyPlaceholder: String {
        switch self {
        case .openAI: return "sk-proj-..."
        case .anthropic: return "sk-ant-api03-..."
        case .google: return "AIzaSy..."
        case .xAI: return "xai-..."
        }
    }
    
    var documentationURL: String {
        switch self {
        case .openAI: return "https://platform.openai.com/api-keys"
        case .anthropic: return "https://console.anthropic.com/account/keys"
        case .google: return "https://makersuite.google.com/app/apikey"
        case .xAI: return "https://x.ai/api"
        }
    }
    
    var models: [AIModel] {
        switch self {
        case .openAI:
            // Check if user is using demo key - restrict to GPT-4.1 models only
            let isUsingDemoKey = UserDefaults.standard.bool(forKey: "use_demo_openai_key")
            
            if isUsingDemoKey {
                // Demo key users only get GPT-4.1 family models
                return [
                    AIModel(id: "gpt-4.1", name: "GPT-4.1", description: "Latest and most advanced model with enhanced reasoning"),
                    AIModel(id: "gpt-4.1-mini", name: "GPT-4.1 Mini", description: "Efficient version of GPT-4.1 for faster responses"),
                    AIModel(id: "gpt-4.1-nano", name: "GPT-4.1 Nano", description: "Ultra-fast, lightweight version for quick tasks")
                ]
            } else {
                // Users with their own API keys get full model access
                return [
                    AIModel(id: "gpt-4.1", name: "GPT-4.1", description: "Latest and most advanced model with enhanced reasoning"),
                    AIModel(id: "gpt-4.1-mini", name: "GPT-4.1 Mini", description: "Efficient version of GPT-4.1 for faster responses"),
                    AIModel(id: "gpt-4.1-nano", name: "GPT-4.1 Nano", description: "Ultra-fast, lightweight version for quick tasks"),
                    AIModel(id: "gpt-4o", name: "GPT-4o", description: "Latest multimodal model with vision capabilities"),
                    AIModel(id: "gpt-4-turbo", name: "GPT-4 Turbo", description: "Most capable for complex theological questions"),
                    AIModel(id: "gpt-4", name: "GPT-4", description: "Advanced reasoning and analysis"),
                    AIModel(id: "gpt-3.5-turbo", name: "GPT-3.5 Turbo", description: "Fast and efficient for basic queries")
                ]
            }
        case .anthropic:
            return [
                AIModel(id: "claude-3-5-sonnet-20241022", name: "Claude 3.5 Sonnet", description: "Latest and most capable model"),
                AIModel(id: "claude-3-opus-20240229", name: "Claude 3 Opus", description: "Powerful for deep analysis"),
                AIModel(id: "claude-3-haiku-20240307", name: "Claude 3 Haiku", description: "Fast responses for simple tasks")
            ]
        case .google:
            return [
                AIModel(id: "gemini-1.5-pro", name: "Gemini 1.5 Pro", description: "Latest with 1M token context window"),
                AIModel(id: "gemini-1.5-flash", name: "Gemini 1.5 Flash", description: "Fast and efficient model"),
                AIModel(id: "gemini-pro", name: "Gemini Pro", description: "Balanced performance")
            ]
        case .xAI:
            return [
                AIModel(id: "grok-2-1212", name: "Grok-2", description: "Latest model with enhanced capabilities"),
                AIModel(id: "grok-2-vision-1212", name: "Grok-2 Vision", description: "Multimodal understanding")
            ]
        }
    }
}

// MARK: - AI Model
public struct AIModel: Identifiable {
    public let id: String
    public let name: String
    public let description: String
}

// MARK: - API Key Configuration
public struct APIKeyConfiguration: Codable {
    public var provider: String
    public var apiKey: String
    public var selectedModel: String?
    public var isEnabled: Bool
    
    public init(provider: AIProvider, apiKey: String = "", selectedModel: String? = nil, isEnabled: Bool = false) {
        self.provider = provider.rawValue
        self.apiKey = apiKey
        self.selectedModel = selectedModel ?? provider.models.first?.id
        self.isEnabled = isEnabled
    }
}

// MARK: - AI Settings
public struct AISettings: Codable {
    public var configurations: [APIKeyConfiguration]
    public var preferredProvider: String?
    public var autoSelectBestModel: Bool
    public var streamResponses: Bool
    public var cacheResponses: Bool
    public var responseLength: ResponseLength
    
    public init() {
        self.configurations = AIProvider.allCases.map { APIKeyConfiguration(provider: $0) }
        self.preferredProvider = nil
        self.autoSelectBestModel = true
        self.streamResponses = true
        self.cacheResponses = true
        self.responseLength = .balanced
    }
    
    public enum ResponseLength: String, CaseIterable, Codable {
        case concise = "Concise"
        case balanced = "Balanced"
        case detailed = "Detailed"
        
        var description: String {
            switch self {
            case .concise: return "Brief, to-the-point answers"
            case .balanced: return "Moderate detail and context"
            case .detailed: return "Comprehensive explanations"
            }
        }
    }
}