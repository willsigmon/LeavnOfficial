import XCTest
import ComposableArchitecture
@testable import LeavnApp

final class AppReducerTests: XCTestCase {
    @MainActor
    func testTabSelection() async {
        let store = TestStore(initialState: AppReducer.State()) {
            AppReducer()
        }
        
        await store.send(.tabSelected(.community)) {
            $0.selectedTab = .community
        }
        
        await store.send(.tabSelected(.library)) {
            $0.selectedTab = .library
        }
    }
    
    @MainActor
    func testFirstLaunchComplete() async {
        let store = TestStore(initialState: AppReducer.State()) {
            AppReducer()
        } withDependencies: {
            $0.userDefaults.isFirstLaunch = true
        }
        
        await store.send(.onFirstLaunchComplete) {
            $0.isFirstLaunch = false
        }
    }
}