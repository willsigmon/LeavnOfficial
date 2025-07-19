// Core
@_exported import struct ComposableArchitecture.Store
@_exported import struct ComposableArchitecture.StoreOf
@_exported import struct ComposableArchitecture.WithViewStore
@_exported import struct ComposableArchitecture.ViewStore
@_exported import protocol ComposableArchitecture.Reducer
@_exported import struct IdentifiedCollections.IdentifiedArrayOf

// App
public typealias AppStore = Store<AppReducer.State, AppReducer.Action>

// Core Types
public typealias LeavnAppView = AppView
public typealias LeavnAppReducer = AppReducer

// Models
public typealias LeavnBook = Book
public typealias LeavnBookmark = Bookmark
public typealias LeavnNote = Note
public typealias LeavnPrayer = Prayer
public typealias LeavnGroup = Group
public typealias LeavnDownload = Download

// Features
public typealias LeavnBibleView = BibleView
public typealias LeavnBibleReducer = BibleReducer
public typealias LeavnCommunityView = CommunityView
public typealias LeavnCommunityReducer = CommunityReducer
public typealias LeavnLibraryView = LibraryView
public typealias LeavnLibraryReducer = LibraryReducer
public typealias LeavnSettingsView = SettingsView
public typealias LeavnSettingsReducer = SettingsReducer
public typealias LeavnOnboardingView = OnboardingView