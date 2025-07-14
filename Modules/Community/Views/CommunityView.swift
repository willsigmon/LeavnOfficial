import SwiftUI

struct CommunityView: View {
    @StateObject private var viewModel = CommunityViewModel()
    @State private var showCreatePost = false
    @State private var newPostContent = ""
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Create Post Button
                    Button(action: { showCreatePost = true }) {
                        HStack {
                            Image(systemName: "square.and.pencil")
                            Text("Share your thoughts...")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)
                    }
                    .padding(.horizontal)
                    
                    // Groups Section
                    VStack(alignment: .leading) {
                        Text("Your Groups")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 15) {
                                ForEach(viewModel.groups) { group in
                                    GroupCardView(group: group)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    
                    // Posts Feed
                    VStack(alignment: .leading) {
                        Text("Community Feed")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        ForEach(viewModel.posts) { post in
                            PostCardView(post: post)
                                .padding(.horizontal)
                        }
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Community")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: NotificationCenterView()) {
                        Image(systemName: "bell")
                    }
                }
            }
            .sheet(isPresented: $showCreatePost) {
                CreatePostView(content: $newPostContent) {
                    viewModel.createPost(content: newPostContent)
                    newPostContent = ""
                    showCreatePost = false
                }
            }
        }
    }
}

struct GroupCardView: View {
    let group: CommunityGroup
    
    var body: some View {
        VStack {
            Image(systemName: "person.3.fill")
                .font(.title)
                .foregroundColor(.blue)
            
            Text(group.name)
                .font(.caption)
                .lineLimit(1)
            
            Text("\(group.memberCount) members")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(width: 100, height: 100)
        .background(Color.blue.opacity(0.1))
        .cornerRadius(10)
    }
}

struct PostCardView: View {
    let post: CommunityPost
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "person.circle.fill")
                    .font(.title2)
                    .foregroundColor(.gray)
                
                VStack(alignment: .leading) {
                    Text(post.author)
                        .font(.headline)
                    Text(post.timestamp, style: .relative)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            
            Text(post.content)
                .font(.body)
            
            HStack {
                Button(action: {}) {
                    Label("Like", systemImage: "heart")
                }
                
                Button(action: {}) {
                    Label("Comment", systemImage: "bubble.right")
                }
                
                Spacer()
                
                Button(action: {}) {
                    Image(systemName: "square.and.arrow.up")
                }
            }
            .font(.caption)
            .foregroundColor(.secondary)
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(10)
    }
}

struct CreatePostView: View {
    @Binding var content: String
    let onPost: () -> Void
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                TextEditor(text: $content)
                    .padding()
                
                Spacer()
            }
            .navigationTitle("Create Post")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Post") {
                        onPost()
                    }
                    .disabled(content.isEmpty)
                }
            }
        }
    }
}

#Preview {
    CommunityView()
}