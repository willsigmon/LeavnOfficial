import SwiftUI
import ComposableArchitecture

struct DownloadsView: View {
    @Bindable var store: StoreOf<LibraryReducer>
    
    var body: some View {
        VStack(spacing: 16) {
            // Download Stats
            DownloadStatsBar(store: store)
            
            // Active Downloads
            if !store.activeDownloads.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Downloading")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    ForEach(store.activeDownloads) { download in
                        ActiveDownloadCard(download: download) {
                            store.send(.pauseDownload(download.id))
                        } onCancel: {
                            store.send(.cancelDownload(download.id))
                        }
                    }
                }
            }
            
            // Completed Downloads
            if !store.completedDownloads.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Downloaded")
                            .font(.headline)
                        
                        Spacer()
                        
                        Button("Manage") {
                            store.send(.navigateToDownloadManager)
                        }
                        .font(.callout)
                    }
                    .padding(.horizontal)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(store.completedDownloads.prefix(5)) { download in
                                CompletedDownloadCard(download: download) {
                                    store.send(.openDownload(download))
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
        }
    }
}

struct DownloadStatsBar: View {
    @Bindable var store: StoreOf<LibraryReducer>
    
    var body: some View {
        HStack(spacing: 20) {
            VStack(spacing: 4) {
                Text("\(store.totalDownloadSize)")
                    .font(.headline)
                Text("Total Size")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Divider()
                .frame(height: 30)
            
            VStack(spacing: 4) {
                Text("\(store.availableOfflineBooks.count)")
                    .font(.headline)
                Text("Books")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Divider()
                .frame(height: 30)
            
            VStack(spacing: 4) {
                Text("\(store.availableSpace)")
                    .font(.headline)
                Text("Available")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
        .padding(.horizontal)
    }
}

struct ActiveDownloadCard: View {
    let download: Download
    let onPause: () -> Void
    let onCancel: () -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "arrow.down.circle.fill")
                    .font(.title2)
                    .foregroundColor(.leavnPrimary)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(download.book.name)
                        .font(.headline)
                    
                    HStack {
                        Text("\(Int(download.progress * 100))%")
                            .font(.caption)
                            .monospacedDigit()
                        
                        Text("•")
                            .foregroundColor(.secondary)
                        
                        Text(download.remainingTime ?? "Calculating...")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text("•")
                            .foregroundColor(.secondary)
                        
                        Text(download.downloadSpeed ?? "0 KB/s")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                HStack(spacing: 16) {
                    Button(action: onPause) {
                        Image(systemName: download.isPaused ? "play.circle" : "pause.circle")
                            .font(.title2)
                            .foregroundColor(.leavnPrimary)
                    }
                    
                    Button(action: onCancel) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            ProgressView(value: download.progress)
                .progressViewStyle(.linear)
                .tint(.leavnPrimary)
        }
        .padding()
        .background(Color.leavnSecondaryBackground)
        .cornerRadius(12)
        .padding(.horizontal)
    }
}

struct CompletedDownloadCard: View {
    let download: Download
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.largeTitle)
                    .foregroundColor(.green)
                
                Text(download.book.name)
                    .font(.headline)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                
                Text(download.fileSize ?? "")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .frame(width: 120, height: 120)
            .background(Color.leavnSecondaryBackground)
            .cornerRadius(12)
        }
        .buttonStyle(.plain)
    }
}

struct DownloadManagerView: View {
    @Bindable var store: StoreOf<LibraryReducer>
    @State private var selectedSort: SortOption = .name
    @State private var showingDeleteConfirmation = false
    @State private var itemsToDelete: Set<Download.ID> = []
    
    enum SortOption: String, CaseIterable {
        case name = "Name"
        case size = "Size"
        case date = "Date"
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Storage Header
            StorageHeaderView(
                usedSpace: store.usedDownloadSpace,
                totalSpace: store.totalAvailableSpace
            )
            
            // Sort Options
            HStack {
                Text("Sort by:")
                    .font(.callout)
                    .foregroundColor(.secondary)
                
                Picker("Sort", selection: $selectedSort) {
                    ForEach(SortOption.allCases, id: \.self) { option in
                        Text(option.rawValue).tag(option)
                    }
                }
                .pickerStyle(.segmented)
                
                Spacer()
                
                if !itemsToDelete.isEmpty {
                    Button(action: { showingDeleteConfirmation = true }) {
                        Text("Delete (\(itemsToDelete.count))")
                            .font(.callout.bold())
                            .foregroundColor(.red)
                    }
                }
            }
            .padding()
            
            // Downloads List
            List(selection: $itemsToDelete) {
                ForEach(sortedDownloads) { download in
                    DownloadManagerRow(download: download)
                        .tag(download.id)
                }
            }
            .listStyle(.plain)
            .environment(\.editMode, .constant(.active))
        }
        .navigationTitle("Download Manager")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Select All") {
                    if itemsToDelete.count == store.completedDownloads.count {
                        itemsToDelete.removeAll()
                    } else {
                        itemsToDelete = Set(store.completedDownloads.map { $0.id })
                    }
                }
            }
        }
        .confirmationDialog(
            "Delete Downloads",
            isPresented: $showingDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("Delete \(itemsToDelete.count) items", role: .destructive) {
                store.send(.deleteDownloads(Array(itemsToDelete)))
                itemsToDelete.removeAll()
            }
            
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This will remove the selected downloads from your device. You can download them again later.")
        }
    }
    
    private var sortedDownloads: [Download] {
        switch selectedSort {
        case .name:
            return store.completedDownloads.sorted { $0.book.name < $1.book.name }
        case .size:
            return store.completedDownloads.sorted { ($0.fileSizeBytes ?? 0) > ($1.fileSizeBytes ?? 0) }
        case .date:
            return store.completedDownloads.sorted { $0.completedAt ?? Date() > $1.completedAt ?? Date() }
        }
    }
}

struct StorageHeaderView: View {
    let usedSpace: String
    let totalSpace: String
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Storage Used")
                        .font(.headline)
                    Text("\(usedSpace) of \(totalSpace)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "internaldrive")
                    .font(.largeTitle)
                    .foregroundColor(.leavnPrimary)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 8)
                    
                    Capsule()
                        .fill(Color.leavnPrimary)
                        .frame(width: geometry.size.width * 0.3, height: 8) // Example: 30% used
                }
            }
            .frame(height: 8)
        }
        .padding()
        .background(Color.leavnSecondaryBackground)
        .cornerRadius(12)
        .padding()
    }
}

struct DownloadManagerRow: View {
    let download: Download
    
    var body: some View {
        HStack {
            Image(systemName: "book.fill")
                .font(.title2)
                .foregroundColor(.leavnPrimary)
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(download.book.name)
                    .font(.headline)
                
                HStack {
                    Text(download.fileSize ?? "")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    if let date = download.completedAt {
                        Text("•")
                            .foregroundColor(.secondary)
                        
                        Text(date, style: .date)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
}