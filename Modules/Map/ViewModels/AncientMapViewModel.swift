import SwiftUI
import MapKit
import Combine

public class AncientMapViewModel: ObservableObject {
    @Published public var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 31.7683, longitude: 35.2137), // Jerusalem
        span: MKCoordinateSpan(latitudeDelta: 5.0, longitudeDelta: 5.0)
    )
    
    @Published public var visibleLocations: [BiblicalLocation] = []
    @Published public var visibleRoutes: [AncientRoute] = []
    @Published public var visibleTerritories: [AncientTerritory] = []
    
    private let mapData: BiblicalMapData
    private var cancellables = Set<AnyCancellable>()
    
    @MainActor public init() {
        self.mapData = BiblicalMapData.shared
        Task {
            await filterByTimePeriod(.ministry)
        }
    }
    
    @MainActor public func filterByTimePeriod(_ period: TimePeriod) async {
        visibleLocations = mapData.locations.filter { location in
            location.timePeriods.contains(period)
        }
        
        visibleRoutes = mapData.routes.filter { route in
            route.timePeriod == period
        }
        
        visibleTerritories = mapData.territories.filter { territory in
            territory.timePeriod == period
        }
        
        // Adjust map region to show relevant locations
        adjustRegionToFitLocations()
    }
    
    private func adjustRegionToFitLocations() {
        guard !visibleLocations.isEmpty else { return }
        
        let coordinates = visibleLocations.map { $0.coordinate }
        
        let minLat = coordinates.map { $0.latitude }.min() ?? 0
        let maxLat = coordinates.map { $0.latitude }.max() ?? 0
        let minLon = coordinates.map { $0.longitude }.min() ?? 0
        let maxLon = coordinates.map { $0.longitude }.max() ?? 0
        
        let center = CLLocationCoordinate2D(
            latitude: (minLat + maxLat) / 2,
            longitude: (minLon + maxLon) / 2
        )
        
        let span = MKCoordinateSpan(
            latitudeDelta: (maxLat - minLat) * 1.5,
            longitudeDelta: (maxLon - minLon) * 1.5
        )
        
        withAnimation {
            region = MKCoordinateRegion(center: center, span: span)
        }
    }
    
    public func focusOnLocation(_ location: BiblicalLocation) {
        withAnimation {
            region = MKCoordinateRegion(
                center: location.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
            )
        }
    }
    
    public func searchLocations(query: String) -> [BiblicalLocation] {
        guard !query.isEmpty else { return visibleLocations }
        
        return visibleLocations.filter { location in
            location.name.localizedCaseInsensitiveContains(query) ||
            location.ancientName?.localizedCaseInsensitiveContains(query) ?? false ||
            location.modernName?.localizedCaseInsensitiveContains(query) ?? false ||
            location.biblicalReferences.contains { ref in
                ref.book.localizedCaseInsensitiveContains(query)
            }
        }
    }
    
    public func regionForCurrentLocations() -> MKCoordinateRegion? {
        guard !visibleLocations.isEmpty else { return nil }
        
        let coordinates = visibleLocations.map { $0.coordinate }
        
        let minLat = coordinates.map { $0.latitude }.min() ?? 0
        let maxLat = coordinates.map { $0.latitude }.max() ?? 0
        let minLon = coordinates.map { $0.longitude }.min() ?? 0
        let maxLon = coordinates.map { $0.longitude }.max() ?? 0
        
        let center = CLLocationCoordinate2D(
            latitude: (minLat + maxLat) / 2,
            longitude: (minLon + maxLon) / 2
        )
        
        let span = MKCoordinateSpan(
            latitudeDelta: (maxLat - minLat) * 1.5,
            longitudeDelta: (maxLon - minLon) * 1.5
        )
        
        return MKCoordinateRegion(center: center, span: span)
    }
}