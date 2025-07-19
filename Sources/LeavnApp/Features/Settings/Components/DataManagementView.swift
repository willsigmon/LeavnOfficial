import SwiftUI
import ComposableArchitecture

struct DataManagementView: View {
    @Bindable var store: StoreOf<SettingsReducer>
    @State private var showingClearDataConfirmation = false
    @State private var dataToDelete: DataType?
    
    enum DataType: String, CaseIterable {
        case bookmarks = "Bookmarks"
        case notes = "Notes"
        case highlights = "Highlights"
        case downloads = "Downloads"
        case readingHistory = "Reading History"
        case cache = "Cache"
        case all = "All Data"
        
        var icon: String {
            switch self {
            case .bookmarks: return "bookmark.fill"
            case .notes: return "note.text"
            case .highlights: return "highlighter"
            case .downloads: return "arrow.down.circle.fill"
            case .readingHistory: return "clock.fill"
            case .cache: return "memorychip"
            case .all: return "trash.fill"
            }
        }
        
        var description: String {
            switch self {
            case .bookmarks: return "Remove all saved bookmarks"
            case .notes: return "Delete all notes and annotations"
            case .highlights: return "Clear all highlighted verses"
            case .downloads: return "Remove downloaded Bible content"
            case .readingHistory: return "Clear reading history and statistics"
            case .cache: return "Clear temporary files and cache"
            case .all: return "Delete all app data and reset to defaults"
            }
        }
    }
    
    var body: some View {
        Form {
            // Storage Overview
            Section {
                StorageOverviewCard(store: store)
            }
            
            // Data Categories
            Section("Manage Data") {
                ForEach(store.dataCategories) { category in
                    DataCategoryRow(category: category) {
                        if category.isDownload {
                            store.send(.navigateToDownloadManager)
                        }
                    }
                }
            }
            
            // Clear Data Options
            Section("Clear Data") {
                ForEach(DataType.allCases.filter { $0 != .all }, id: \.self) { dataType in
                    Button(action: {
                        dataToDelete = dataType
                        showingClearDataConfirmation = true
                    }) {
                        HStack {
                            Image(systemName: dataType.icon)
                                .foregroundColor(.red)
                                .frame(width: 24)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Clear \(dataType.rawValue)")
                                    .foregroundColor(.primary)
                                Text(dataType.description)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
            }
            
            // Reset Section
            Section {
                Button(action: {
                    dataToDelete = .all
                    showingClearDataConfirmation = true
                }) {
                    HStack {
                        Spacer()
                        Label("Reset All Data", systemImage: "exclamationmark.triangle.fill")
                            .foregroundColor(.red)
                        Spacer()
                    }
                }
            }
        }
        .navigationTitle("Storage")
        .navigationBarTitleDisplayMode(.inline)
        .confirmationDialog(
            "Clear \(dataToDelete?.rawValue ?? "Data")?",
            isPresented: $showingClearDataConfirmation,
            titleVisibility: .visible
        ) {
            Button("Clear", role: .destructive) {
                if let dataType = dataToDelete {
                    store.send(.clearData(dataType.rawValue))
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This action cannot be undone. \(dataToDelete?.description ?? "")")
        }
    }
}

struct StorageOverviewCard: View {
    @Bindable var store: StoreOf<SettingsReducer>
    
    var body: some View {
        VStack(spacing: 16) {
            // Storage Visual
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.3), lineWidth: 20)
                
                Circle()
                    .trim(from: 0, to: store.storageUsedPercentage)
                    .stroke(
                        AngularGradient(
                            colors: [.blue, .purple, .pink],
                            center: .center
                        ),
                        style: StrokeStyle(lineWidth: 20, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                
                VStack(spacing: 4) {
                    Text(store.storageUsed)
                        .font(.title2.bold())
                    Text("of \(store.totalStorage)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .frame(width: 150, height: 150)
            
            // Storage Breakdown
            VStack(spacing: 8) {
                ForEach(store.storageBreakdown) { item in
                    HStack {
                        Circle()
                            .fill(item.color)
                            .frame(width: 8, height: 8)
                        
                        Text(item.category)
                            .font(.caption)
                        
                        Spacer()
                        
                        Text(item.size)
                            .font(.caption.monospacedDigit())
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(8)
        }
        .padding()
    }
}

struct DataCategoryRow: View {
    let category: DataCategory
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: category.icon)
                    .font(.title3)
                    .foregroundColor(category.color)
                    .frame(width: 32)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(category.name)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text("\(category.itemCount) items")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Text(category.size)
                    .font(.callout.monospacedDigit())
                    .foregroundColor(.secondary)
                
                if category.isDownload {
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.tertiaryLabel)
                }
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(.plain)
    }
}

// Mock Data Category
struct DataCategory: Identifiable {
    let id = UUID()
    let name: String
    let icon: String
    let color: Color
    let itemCount: Int
    let size: String
    let isDownload: Bool
}

struct StorageBreakdownItem: Identifiable {
    let id = UUID()
    let category: String
    let size: String
    let color: Color
}