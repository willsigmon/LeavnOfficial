import SwiftUI
import ComposableArchitecture

public struct AppView: View {
    @Bindable var store: StoreOf<AppReducer>
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    
    public init(store: StoreOf<AppReducer>) {
        self.store = store
    }
    
    private var isIPad: Bool {
        horizontalSizeClass == .regular && verticalSizeClass == .regular
    }
    
    public var body: some View {
        TabView(selection: $store.selectedTab.sending(\.tabSelected)) {
            ForEach(AppReducer.Tab.allCases) { tab in
                Group {
                    switch tab {
                    case .bible:
                        BibleView(store: store.scope(state: \.bible, action: \.bible))
                    case .community:
                        CommunityView(store: store.scope(state: \.community, action: \.community))
                    case .library:
                        LibraryView(store: store.scope(state: \.library, action: \.library))
                    case .settings:
                        SettingsView(store: store.scope(state: \.settings, action: \.settings))
                    }
                }
                .tabItem {
                    Label(tab.rawValue, systemImage: tab.icon)
                        .accessibilityLabel(tab.accessibilityLabel)
                }
                .tag(tab)
            }
        }
        .onAppear {
            store.send(.onAppear)
        }
        .sheet(isPresented: $store.isFirstLaunch) {
            OnboardingView {
                store.send(.onFirstLaunchComplete)
            }
        }
    }
}