import ComposableArchitecture
import Foundation

@Reducer
public struct CommunityReducer {
    @ObservableState
    public struct State: Equatable {
        public var prayerWall: PrayerWallReducer.State
        public var groups: GroupsReducer.State
        public var selectedTab: Tab = .prayerWall
        
        public init() {
            self.prayerWall = PrayerWallReducer.State()
            self.groups = GroupsReducer.State()
        }
        
        public enum Tab: String, CaseIterable {
            case prayerWall = "Prayer Wall"
            case groups = "Groups"
        }
    }
    
    public enum Action {
        case prayerWall(PrayerWallReducer.Action)
        case groups(GroupsReducer.Action)
        case tabSelected(State.Tab)
    }
    
    public init() {}
    
    public var body: some ReducerOf<Self> {
        Scope(state: \.prayerWall, action: \.prayerWall) {
            PrayerWallReducer()
        }
        
        Scope(state: \.groups, action: \.groups) {
            GroupsReducer()
        }
        
        Reduce { state, action in
            switch action {
            case .tabSelected(let tab):
                state.selectedTab = tab
                return .none
                
            case .prayerWall, .groups:
                return .none
            }
        }
    }
}

// MARK: - Prayer Wall

@Reducer
public struct PrayerWallReducer {
    @ObservableState
    public struct State: Equatable {
        public var prayers: IdentifiedArrayOf<Prayer> = []
        public var isLoading: Bool = false
        public var error: String? = nil
        public var newPrayerText: String = ""
        public var isAnonymous: Bool = false
        public var currentUserId: String? = nil
        
        public init() {}
    }
    
    public enum Action {
        case onAppear
        case loadPrayers
        case prayersResponse(Result<[Prayer], Error>)
        case newPrayerTextChanged(String)
        case anonymousToggled
        case submitPrayer
        case prayerSubmitted(Result<Prayer, Error>)
        case prayForRequest(Prayer.ID)
        case prayerResponse(Prayer.ID, Result<Prayer, Error>)
        case deletePrayer(Prayer.ID)
        case deleteResponse(Prayer.ID, Result<Bool, Error>)
        case currentUserIdLoaded(String)
    }
    
    @Dependency(\.communityClient) var communityClient
    @Dependency(\.authClient) var authClient
    @Dependency(\.date) var date
    @Dependency(\.uuid) var uuid
    
    public init() {}
    
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .merge(
                    .send(.loadPrayers),
                    .run { send in
                        if let userId = try? await authClient.getCurrentUserId() {
                            await send(.currentUserIdLoaded(userId))
                        }
                    }
                )
                
            case .loadPrayers:
                state.isLoading = true
                state.error = nil
                
                return .run { send in
                    await send(
                        .prayersResponse(
                            Result { try await communityClient.loadPrayers() }
                        )
                    )
                }
                
            case let .prayersResponse(.success(prayers)):
                state.isLoading = false
                state.prayers = IdentifiedArray(uniqueElements: prayers)
                return .none
                
            case let .prayersResponse(.failure(error)):
                state.isLoading = false
                state.error = error.localizedDescription
                return .none
                
            case let .newPrayerTextChanged(text):
                state.newPrayerText = text
                return .none
                
            case .anonymousToggled:
                state.isAnonymous.toggle()
                return .none
                
            case .submitPrayer:
                guard !state.newPrayerText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                    return .none
                }
                
                let prayer = Prayer(
                    id: uuid(),
                    text: state.newPrayerText,
                    authorName: state.isAnonymous ? "Anonymous" : nil,
                    authorId: state.isAnonymous ? nil : state.currentUserId,
                    createdAt: date(),
                    prayerCount: 0,
                    hasPrayed: false
                )
                
                state.newPrayerText = ""
                state.isAnonymous = false
                
                return .run { send in
                    await send(
                        .prayerSubmitted(
                            Result { try await communityClient.submitPrayer(prayer) }
                        )
                    )
                }
                
            case let .prayerSubmitted(.success(prayer)):
                state.prayers.insert(prayer, at: 0)
                return .none
                
            case let .prayerSubmitted(.failure(error)):
                state.error = error.localizedDescription
                return .none
                
            case let .prayForRequest(id):
                guard let prayer = state.prayers[id: id] else { return .none }
                
                // Optimistic update
                state.prayers[id: id]?.prayerCount += 1
                state.prayers[id: id]?.hasPrayed = true
                
                return .run { send in
                    await send(
                        .prayerResponse(
                            id,
                            Result { try await communityClient.prayFor(id) }
                        )
                    )
                }
                
            case let .prayerResponse(id, .failure(error)):
                // Revert optimistic update
                state.prayers[id: id]?.prayerCount -= 1
                state.prayers[id: id]?.hasPrayed = false
                state.error = error.localizedDescription
                return .none
                
            case .prayerResponse(_, .success(_)):
                return .none
                
            case let .deletePrayer(id):
                state.prayers.remove(id: id)
                
                return .run { send in
                    await send(
                        .deleteResponse(
                            id,
                            Result { try await communityClient.deletePrayer(id) }
                        )
                    )
                }
                
            case let .deleteResponse(_, .failure(error)):
                state.error = error.localizedDescription
                return .send(.loadPrayers) // Reload to restore state
                
            case .deleteResponse(_, .success(_)):
                return .none
                
            case let .currentUserIdLoaded(userId):
                state.currentUserId = userId
                return .none
            }
        }
    }
}

// MARK: - Groups

@Reducer
public struct GroupsReducer {
    @ObservableState
    public struct State: Equatable {
        public var myGroups: IdentifiedArrayOf<Group> = []
        public var discoverGroups: IdentifiedArrayOf<Group> = []
        public var isLoading: Bool = false
        public var error: String? = nil
        public var searchQuery: String = ""
        
        public init() {}
    }
    
    public enum Action {
        case onAppear
        case loadGroups
        case groupsResponse(Result<(my: [Group], discover: [Group]), Error>)
        case searchQueryChanged(String)
        case joinGroup(Group.ID)
        case joinResponse(Group.ID, Result<Bool, Error>)
        case leaveGroup(Group.ID)
        case leaveResponse(Group.ID, Result<Bool, Error>)
    }
    
    @Dependency(\.communityClient) var communityClient
    
    public init() {}
    
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .send(.loadGroups)
                
            case .loadGroups:
                state.isLoading = true
                state.error = nil
                
                return .run { send in
                    await send(
                        .groupsResponse(
                            Result {
                                async let myGroups = communityClient.loadMyGroups()
                                async let discoverGroups = communityClient.loadDiscoverGroups()
                                return try await (my: myGroups, discover: discoverGroups)
                            }
                        )
                    )
                }
                
            case let .groupsResponse(.success(groups)):
                state.isLoading = false
                state.myGroups = IdentifiedArray(uniqueElements: groups.my)
                state.discoverGroups = IdentifiedArray(uniqueElements: groups.discover)
                return .none
                
            case let .groupsResponse(.failure(error)):
                state.isLoading = false
                state.error = error.localizedDescription
                return .none
                
            case let .searchQueryChanged(query):
                state.searchQuery = query
                return .none
                
            case let .joinGroup(id):
                guard let group = state.discoverGroups[id: id] else { return .none }
                
                // Optimistic update
                state.discoverGroups.remove(id: id)
                state.myGroups.append(group)
                
                return .run { send in
                    await send(
                        .joinResponse(
                            id,
                            Result { try await communityClient.joinGroup(id) }
                        )
                    )
                }
                
            case let .joinResponse(id, .failure(error)):
                state.error = error.localizedDescription
                return .send(.loadGroups) // Reload to restore state
                
            case .joinResponse(_, .success(_)):
                return .none
                
            case let .leaveGroup(id):
                guard let group = state.myGroups[id: id] else { return .none }
                
                // Optimistic update
                state.myGroups.remove(id: id)
                state.discoverGroups.insert(group, at: 0)
                
                return .run { send in
                    await send(
                        .leaveResponse(
                            id,
                            Result { try await communityClient.leaveGroup(id) }
                        )
                    )
                }
                
            case let .leaveResponse(id, .failure(error)):
                state.error = error.localizedDescription
                return .send(.loadGroups) // Reload to restore state
                
            case .leaveResponse(_, .success(_)):
                return .none
            }
        }
    }
}