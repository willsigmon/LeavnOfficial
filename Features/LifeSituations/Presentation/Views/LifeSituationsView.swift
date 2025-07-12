import SwiftUI
import LeavnCore

public struct LifeSituationsView: View {
    @StateObject private var viewModel = LifeSituationsViewModel()

    public init() {}
    
    public var body: some View {
        NavigationView {
            ScrollView {
                LifeSituationsWidget(viewModel: viewModel)
                    .padding()
            }
            .navigationTitle("Life Situations")
        }
    }
} 