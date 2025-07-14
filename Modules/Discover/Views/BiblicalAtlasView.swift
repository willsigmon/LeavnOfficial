import SwiftUI
import MapKit

// import LeavnMap - Removed external dependency

public struct BiblicalAtlasView: View {
    @State private var selectedPeriod: TimePeriod? = nil
    @State private var selectedLocation: BiblicalLocation?
    @State private var showingLocationDetail = false
    @State private var mapRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 31.7683, longitude: 35.2137), // Jerusalem
        span: MKCoordinateSpan(latitudeDelta: 10, longitudeDelta: 10)
    )
    @State private var selectedRoute: AncientRoute?
    
    public init() {}
    
    public var body: some View {
        NavigationStack {
            ZStack {
                // Map View
                // Map placeholder - SimpleAncientMapView not available
                Color.gray.opacity(0.2)
                    .overlay(
                        Text("Map View")
                            .foregroundColor(.secondary)
                    )
                    .ignoresSafeArea(edges: .top)
                
                // Controls Overlay
                VStack {
                    // Period Selector
                    periodSelector
                        .padding(.top, 100)
                    
                    Spacer()
                    
                    // Route Selector
                    if !getRoutesForPeriod().isEmpty {
                        routeSelector
                    }
                    
                    // Location Info Card
                    if let location = selectedLocation {
                        locationInfoCard(location)
                            .transition(.move(edge: .bottom))
                    }
                }
            }
            .navigationTitle("Biblical Atlas")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button(action: { selectedPeriod = nil }) {
                            Label("Show All Periods", systemImage: "clock")
                        }
                        
                        Button(action: resetMap) {
                            Label("Reset View", systemImage: "arrow.counterclockwise")
                        }
                        
                        Divider()
                        
                        Button(action: {}) {
                            Label("Map Legend", systemImage: "info.circle")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
        }
        .sheet(isPresented: $showingLocationDetail) {
            if let location = selectedLocation {
                LocationDetailView(location: location)
            }
        }
    }
    
    private var periodSelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                Button(action: {
                    withAnimation {
                        selectedPeriod = nil
                        selectedRoute = nil
                    }
                }) {
                    Text("All")
                        .font(LeavnTheme.Typography.caption)
                        .fontWeight(selectedPeriod == nil ? .semibold : .medium)
                        .foregroundColor(selectedPeriod == nil ? .white : .primary)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            Capsule()
                                .fill(selectedPeriod == nil ? LeavnTheme.Colors.accent : Color(.secondarySystemBackground))
                        )
                }
                
                ForEach(TimePeriod.allCases, id: \.self) { period in
                    PeriodChip(
                        period: period,
                        isSelected: selectedPeriod == period,
                        action: {
                            withAnimation {
                                selectedPeriod = period
                                selectedRoute = nil
                            }
                        }
                    )
                }
            }
            .padding(.horizontal, 20)
        }
        .background(
            Capsule()
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.1), radius: 10, y: 5)
                .padding(.horizontal, 10)
        )
    }
    
    private var routeSelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(getRoutesForPeriod(), id: \.name) { route in
                    RouteChip(
                        route: route,
                        isSelected: selectedRoute?.name == route.name,
                        action: {
                            withAnimation {
                                selectedRoute = route
                            }
                        }
                    )
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
    }
    
    private func locationInfoCard(_ location: BiblicalLocation) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(location.name)
                        .font(LeavnTheme.Typography.headline)
                        .foregroundColor(.primary)
                    
                    if let modernName = location.modernName {
                        Text(modernName)
                            .font(LeavnTheme.Typography.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                Button(action: { showingLocationDetail = true }) {
                    Image(systemName: "info.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(LeavnTheme.Colors.accent)
                }
            }
            
            Text(location.significance ?? "Historical location")
                .font(LeavnTheme.Typography.body)
                .foregroundColor(.primary)
                .lineLimit(3)
            
            // Bible References
            if !location.biblicalReferences.isEmpty {
                HStack {
                    Image(systemName: "book.fill")
                        .font(.caption)
                        .foregroundColor(LeavnTheme.Colors.accent)
                    
                    Text(location.biblicalReferences.prefix(3).map { "\($0.book) \($0.chapter):\($0.verse ?? 0)" }.joined(separator: ", "))
                        .font(LeavnTheme.Typography.caption)
                        .foregroundColor(LeavnTheme.Colors.accent)
                    
                    if location.biblicalReferences.count > 3 {
                        Text("+\(location.biblicalReferences.count - 3) more")
                            .font(LeavnTheme.Typography.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.1), radius: 10, y: 5)
        )
        .padding(.horizontal, 20)
        .padding(.bottom, 100)
    }
    
    private func getRoutesForPeriod() -> [AncientRoute] {
        switch selectedPeriod {
        case .exodus:
            return [] // Routes not accessible
        case .earlyChurch:
            return [] // Routes not accessible
        case .ministry:
            return [] // Routes not accessible
        default:
            return []
        }
    }
    
    private func resetMap() {
        withAnimation {
            selectedPeriod = nil
            selectedLocation = nil
            selectedRoute = nil
            mapRegion = MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: 31.7683, longitude: 35.2137),
                span: MKCoordinateSpan(latitudeDelta: 10, longitudeDelta: 10)
            )
        }
    }
}

// MARK: - Supporting Views

struct PeriodChip: View {
    let period: TimePeriod
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(period.rawValue)
                .font(LeavnTheme.Typography.caption)
                .fontWeight(isSelected ? .semibold : .medium)
                .foregroundColor(isSelected ? .white : .primary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(isSelected ? LeavnTheme.Colors.accent : Color(.secondarySystemBackground))
                )
        }
    }
}

struct RouteChip: View {
    let route: AncientRoute
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: "map")
                    .font(.caption)
                Text(route.name)
                    .font(LeavnTheme.Typography.caption)
            }
            .fontWeight(isSelected ? .semibold : .medium)
            .foregroundColor(isSelected ? .white : .primary)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(isSelected ? LeavnTheme.Colors.info : Color(.secondarySystemBackground))
            )
        }
    }
}

struct LocationDetailView: View {
    let location: BiblicalLocation
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text(location.name)
                            .font(LeavnTheme.Typography.displayMedium)
                            .foregroundColor(.primary)
                        
                        if let modernName = location.modernName {
                            Text("Modern: \(modernName)")
                                .font(LeavnTheme.Typography.body)
                                .foregroundColor(.secondary)
                        }
                        
                        HStack {
                            ForEach(location.timePeriods, id: \.self) { period in
                                Text(period.rawValue)
                                    .font(LeavnTheme.Typography.caption)
                                    .foregroundColor(LeavnTheme.Colors.accent)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(
                                        Capsule()
                                            .fill(LeavnTheme.Colors.accent.opacity(0.1))
                                    )
                            }
                        }
                    }
                    
                    // Significance
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Historical Significance")
                            .font(LeavnTheme.Typography.headline)
                            .foregroundColor(.secondary)
                        
                        Text(location.significance ?? "Historical location")
                            .font(LeavnTheme.Typography.body)
                            .foregroundColor(.primary)
                    }
                    
                    // Bible References
                    if !location.biblicalReferences.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Biblical References")
                                .font(LeavnTheme.Typography.headline)
                                .foregroundColor(.secondary)
                            
                            ForEach(location.biblicalReferences, id: \.text) { reference in
                                HStack {
                                    Image(systemName: "book.fill")
                                        .font(.caption)
                                        .foregroundColor(LeavnTheme.Colors.accent)
                                    
                                    Text("\(reference.book) \(reference.chapter):\(reference.verse ?? 0)")
                                        .font(LeavnTheme.Typography.body)
                                        .foregroundColor(LeavnTheme.Colors.accent)
                                    
                                    Spacer()
                                    
                                    Button(action: {}) {
                                        Image(systemName: "arrow.right.circle")
                                            .foregroundColor(LeavnTheme.Colors.accent)
                                    }
                                }
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color(.secondarySystemBackground))
                                )
                            }
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Location Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    BiblicalAtlasView()
}