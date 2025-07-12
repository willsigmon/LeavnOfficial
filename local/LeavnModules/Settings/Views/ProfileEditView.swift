import SwiftUI
import LeavnCore
import LeavnServices

@MainActor
class ProfileEditViewModel: ObservableObject {
    @Published var displayName = ""
    @Published var bio = ""
    @Published var favoriteVerse = ""
    @Published var user: User?
    @Published var isLoading = false
    @Published var error: Error?

    private let userService: UserServiceProtocol
    private let analyticsService: AnalyticsServiceProtocol

    init() {
        guard let userService = DIContainer.shared.userService,
              let analyticsService = DIContainer.shared.analyticsService else {
            fatalError("Services not initialized")
        }
        self.userService = userService
        self.analyticsService = analyticsService
        loadInitialData()
    }

    func loadInitialData() {
        Task {
            self.user = try? await userService.getCurrentUser()
            self.displayName = user?.name ?? ""
            let defaults = UserDefaults.standard
            self.bio = defaults.string(forKey: "userBio") ?? ""
            self.favoriteVerse = defaults.string(forKey: "userFavoriteVerse") ?? ""
        }
    }

    func saveProfile(image: UIImage?) async {
        isLoading = true
        error = nil

        guard let currentUser = user else {
            isLoading = false
            return
        }

        do {
            let photoURLString = await uploadImage(image)

            let updatedUser = User(
                id: currentUser.id,
                name: displayName,
                email: currentUser.email,
                preferences: currentUser.preferences,
                createdAt: currentUser.createdAt,
                updatedAt: Date()
            )
            try await userService.updateUser(updatedUser)

            let defaults = UserDefaults.standard
            defaults.set(bio, forKey: "userBio")
            defaults.set(favoriteVerse, forKey: "userFavoriteVerse")

            await analyticsService.track(event: AnalyticsEvent(name: "profile_edited", parameters: [
                "user_id": String(currentUser.id),
                "has_photo": String(photoURLString != nil),
                "has_bio": String(!bio.isEmpty),
                "has_favorite_verse": String(!favoriteVerse.isEmpty)
            ]))
        } catch {
            self.error = error
            logError("Failed to save profile", error: error, category: .general)
        }

        isLoading = false
    }

    func deleteAccount() async {
        isLoading = true
        error = nil

        do {
            await analyticsService.track(event: AnalyticsEvent(name: "account_deleted"))
            try await userService.deleteUser()
        } catch {
            self.error = error
            logError("Failed to delete account", error: error, category: .general)
        }

        isLoading = false
    }

    private func uploadImage(_ image: UIImage?) async -> String? {
        guard let image = image, let data = image.jpegData(compressionQuality: 0.8) else { return nil }
        let base64String = data.base64EncodedString()
        let photoURLString = "data:image/jpeg;base64,\(base64String)"
        UserDefaults.standard.set(photoURLString, forKey: "userProfileImage")
        return photoURLString
    }
}

public struct ProfileEditView: View {
    @StateObject private var viewModel = ProfileEditViewModel()
    @Environment(\.dismiss) private var dismiss
    @State private var showImagePicker = false
    @State private var selectedImage: UIImage?

    public init() {}

    public var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Profile Picture")) {
                    HStack {
                        Spacer()
                        VStack {
                            if let image = selectedImage {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 120, height: 120)
                                    .clipShape(Circle())
                            } else if let photoURLString = UserDefaults.standard.string(forKey: "userProfileImage"),
                                      let url = URL(string: photoURLString) {
                                AsyncImage(url: url) {
                                    $0.resizable()
                                        .scaledToFill()
                                } placeholder: {
                                    ProgressView()
                                }
                                .frame(width: 120, height: 120)
                                .clipShape(Circle())
                            } else {
                                Image(systemName: "person.circle.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 120, height: 120)
                                    .foregroundColor(.gray.opacity(0.5))
                            }
                            Button("Change Photo") { showImagePicker = true }
                        }
                        Spacer()
                    }
                }

                Section(header: Text("Public Profile")) {
                    TextField("Display Name", text: $viewModel.displayName)
                    TextField("Bio", text: $viewModel.bio)
                    TextField("Favorite Verse (e.g., John 3:16)", text: $viewModel.favoriteVerse)
                }

                Section {
                    Button("Save Profile") {
                        Task {
                            await viewModel.saveProfile(image: selectedImage)
                            dismiss()
                        }
                    }
                    .disabled(viewModel.isLoading)
                }

                Section(header: Text("Account Actions")) {
                    Button("Delete Account", role: .destructive) {
                        Task { await viewModel.deleteAccount() }
                    }
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
            }
            .sheet(isPresented: $showImagePicker) {
                // Replace with a proper image picker implementation
                // For now, we just dismiss it.
            }
            .overlay {
                if viewModel.isLoading {
                    ProgressView("Saving...")
                }
            }
            .alert("Error", isPresented: .constant(viewModel.error != nil), actions: {
                Button("OK") { viewModel.error = nil }
            }, message: {
                Text(viewModel.error?.localizedDescription ?? "An unknown error occurred.")
            })
        }
    }
}
