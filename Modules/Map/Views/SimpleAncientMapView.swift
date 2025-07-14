import SwiftUI
import MapKit
import CoreLocation

public struct AncientMapView: View {
    @StateObject private var viewModel = AncientMapViewModel()
    @State private var selectedTimePeriod: TimePeriod = .ministry
    @State private var showingLocationDetail: BiblicalLocation?
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 31.7683, longitude: 35.2137),
        span: MKCoordinateSpan(latitudeDelta: 5.0, longitudeDelta: 5.0)
    )
    
    public init() {}
    
    public var body: some View {
        ZStack {
            // Map
            MapViewRepresentable(
                region: $region,
                locations: viewModel.visibleLocations,
                routes: viewModel.visibleRoutes,
                territories: viewModel.visibleTerritories,
                onLocationTapped: { location in
                    showingLocationDetail = location
                }
            )
            .ignoresSafeArea()
            
            // Controls overlay
            VStack {
                timePeriodSelector
                    .padding(.top, 60)
                
                Spacer()
                
                mapLegend
                    .padding(.bottom, 100)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                VStack(spacing: 2) {
                    Text("Biblical Atlas")
                        .font(.headline)
                    Text(selectedTimePeriod.dateRange)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .sheet(item: $showingLocationDetail) { location in
            LocationDetailSheet(location: location)
        }
        .onAppear {
            Task { await viewModel.filterByTimePeriod(selectedTimePeriod) }
        }
    }
    
    private var timePeriodSelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(TimePeriod.allCases, id: \.self) { period in
                    TimePeriodChip(
                        period: period,
                        isSelected: selectedTimePeriod == period
                    ) {
                        withAnimation(.spring()) {
                            selectedTimePeriod = period
                            Task { await viewModel.filterByTimePeriod(period) }
                            
                            // Update region to fit new locations
                            if let newRegion = viewModel.regionForCurrentLocations() {
                                region = newRegion
                            }
                        }
                    }
                }
            }
            .padding(.horizontal)
        }
    }
    
    private var mapLegend: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "mappin.circle.fill")
                    .foregroundColor(LeavnTheme.Colors.error)
                Text("Biblical Locations")
                    .font(.caption)
            }
            
            HStack {
                Rectangle()
                    .fill(LeavnTheme.Colors.info)
                    .frame(width: 20, height: 2)
                Text("Ancient Routes")
                    .font(.caption)
            }
            
            HStack {
                Rectangle()
                    .fill(LeavnTheme.Colors.accent.opacity(0.3))
                    .frame(width: 20, height: 15)
                    .overlay(
                        Rectangle()
                            .stroke(LeavnTheme.Colors.accent, lineWidth: 1)
                    )
                Text("Territories")
                    .font(.caption)
            }
        }
        .padding(12)
        .background(LeavnTheme.Colors.darkBackground.opacity(0.9))
        .foregroundColor(.primary)
        .cornerRadius(8)
        .padding(.horizontal)
    }
}

// Map UIKit Bridge
struct MapViewRepresentable: UIViewRepresentable {
    @Binding var region: MKCoordinateRegion
    let locations: [BiblicalLocation]
    let routes: [AncientRoute]
    let territories: [AncientTerritory]
    let onLocationTapped: (BiblicalLocation) -> Void
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.mapType = .standard
        return mapView
    }
    
    func updateUIView(_ mapView: MKMapView, context: Context) {
        mapView.setRegion(region, animated: true)
        
        // Remove existing annotations and overlays
        mapView.removeAnnotations(mapView.annotations)
        mapView.removeOverlays(mapView.overlays)
        
        // Add location annotations
        let annotations = locations.map { LocationAnnotation(location: $0) }
        mapView.addAnnotations(annotations)
        
        // Add route overlays
        for route in routes {
            let polyline = MKPolyline(coordinates: route.waypoints, count: route.waypoints.count)
            mapView.addOverlay(polyline)
        }
        
        // Add territory overlays
        for territory in territories {
            let polygon = MKPolygon(coordinates: territory.boundaries, count: territory.boundaries.count)
            mapView.addOverlay(polygon)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapViewRepresentable
        
        init(_ parent: MapViewRepresentable) {
            self.parent = parent
        }
        
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            guard annotation is LocationAnnotation else { return nil }
            
            let identifier = "BiblicalLocation"
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView
            
            if annotationView == nil {
                annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                annotationView?.canShowCallout = true
                annotationView?.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            } else {
                annotationView?.annotation = annotation
            }
            
            annotationView?.markerTintColor = .systemRed
            annotationView?.glyphImage = UIImage(systemName: "mappin.circle.fill")
            
            return annotationView
        }
        
        func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
            guard let locationAnnotation = view.annotation as? LocationAnnotation else { return }
            parent.onLocationTapped(locationAnnotation.location)
        }
        
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let polyline = overlay as? MKPolyline {
                let renderer = MKPolylineRenderer(polyline: polyline)
                renderer.strokeColor = .systemBlue
                renderer.lineWidth = 3
                return renderer
            } else if let polygon = overlay as? MKPolygon {
                let renderer = MKPolygonRenderer(polygon: polygon)
                renderer.fillColor = UIColor.systemPurple.withAlphaComponent(0.2)
                renderer.strokeColor = .systemPurple
                renderer.lineWidth = 2
                return renderer
            }
            return MKOverlayRenderer(overlay: overlay)
        }
    }
}

// Location Annotation
class LocationAnnotation: NSObject, MKAnnotation {
    let location: BiblicalLocation
    let coordinate: CLLocationCoordinate2D
    let title: String?
    let subtitle: String?
    
    init(location: BiblicalLocation) {
        self.location = location
        self.coordinate = location.coordinate
        self.title = location.name
        self.subtitle = location.ancientName ?? location.description
        super.init()
    }
}

// Time Period Chip
struct TimePeriodChip: View {
    let period: TimePeriod
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text(period.rawValue.split(separator: "(").first ?? "")
                    .font(.caption)
                    .fontWeight(.medium)
                Text(period.dateRange)
                    .font(.caption2)
                    .opacity(0.8)
            }
            .foregroundColor(isSelected ? .white : .primary)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(isSelected ? LeavnTheme.Colors.accent : Color(.systemGray5))
            )
        }
    }
}

// Location Detail Sheet
struct LocationDetailSheet: View {
    let location: BiblicalLocation
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        if let ancientName = location.ancientName {
                            Label("Ancient: \(ancientName)", systemImage: "scroll")
                                .font(.subheadline)
                        }
                        if let modernName = location.modernName {
                            Label("Modern: \(modernName)", systemImage: "map")
                                .font(.subheadline)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Description
                    Text(location.description)
                        .font(.body)
                        .padding(.horizontal)
                    
                    if let significance = location.significance {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Significance")
                                .font(.headline)
                            Text(significance)
                                .font(.body)
                        }
                        .padding(.horizontal)
                    }
                    
                    // Biblical References
                    if !location.biblicalReferences.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Biblical References")
                                .font(.headline)
                                .padding(.horizontal)
                            
                            ForEach(location.biblicalReferences, id: \.text) { reference in
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("\(reference.book) \(reference.chapter):\(reference.verse ?? 0)")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                    Text(reference.text)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                .padding(.vertical, 8)
                                .padding(.horizontal, 12)
                                .background(Color(.systemGray6))
                                .cornerRadius(8)
                                .padding(.horizontal)
                            }
                        }
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle(location.name)
            .navigationBarTitleDisplayMode(.large)
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
