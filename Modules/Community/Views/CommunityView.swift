import SwiftUI

public struct CommunityView: View {
    @StateObject private var viewModel: CommunityViewModel
    
    public init(viewModel: CommunityViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }
    
    public var body: some View {
        NavigationView {
            VStack {
                Text("Community")
                    .font(.largeTitle)
                    .padding()
                
                Spacer()
                
                Text("Connect with fellow believers")
                    .foregroundColor(.secondary)
                
                Spacer()
            }
            .navigationTitle("Community")
        }
    }
}

#Preview {
    CommunityView(viewModel: CommunityViewModel(
        communityService: DIContainer.shared.communityService
    ))
}
