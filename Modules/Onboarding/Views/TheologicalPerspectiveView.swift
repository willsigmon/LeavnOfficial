import SwiftUI

struct TheologicalPerspectiveView: View {
    @Binding var selectedPerspectives: Set<TheologicalPerspective>
    @State private var showInfo = false
    @State private var infoForPerspective: TheologicalPerspective?
    
    var body: some View {
        VStack(spacing: 24) {
            // Header
            VStack(spacing: 16) {
                Image(systemName: "books.vertical.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(LeavnTheme.Colors.primaryGradient)
                    .symbolRenderingMode(.hierarchical)
                
                Text("Your Theological Perspective")
                    .font(LeavnTheme.Typography.displayMedium)
                    .multilineTextAlignment(.center)
                
                Text("Select perspectives that resonate with your faith journey")
                    .font(LeavnTheme.Typography.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                
                Text("You can select multiple perspectives")
                    .font(LeavnTheme.Typography.caption)
                    .foregroundColor(LeavnTheme.Colors.accent)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(LeavnTheme.Colors.accent.opacity(0.1))
                    )
            }
            
            // Perspectives Grid
            ScrollView {
                LazyVGrid(columns: [
                    GridItem(.flexible(), spacing: 16),
                    GridItem(.flexible(), spacing: 16)
                ], spacing: 16) {
                    ForEach(TheologicalPerspective.allCases) { perspective in
                        PerspectiveCard(
                            perspective: perspective,
                            isSelected: selectedPerspectives.contains(perspective),
                            onTap: {
                                togglePerspective(perspective)
                            },
                            onInfo: {
                                infoForPerspective = perspective
                                showInfo = true
                            }
                        )
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 100)
            }
        }
        .sheet(isPresented: $showInfo) {
            if let perspective = infoForPerspective {
                PerspectiveInfoSheet(perspective: perspective)
            }
        }
    }
    
    private func togglePerspective(_ perspective: TheologicalPerspective) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            if selectedPerspectives.contains(perspective) {
                selectedPerspectives.remove(perspective)
            } else {
                selectedPerspectives.insert(perspective)
            }
        }
    }
}

// MARK: - Perspective Card
struct PerspectiveCard: View {
    let perspective: TheologicalPerspective
    let isSelected: Bool
    let onTap: () -> Void
    let onInfo: () -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            // Icon
            ZStack {
                Circle()
                    .fill(isSelected ? perspective.color : Color.gray.opacity(0.1))
                    .frame(width: 60, height: 60)
                
                Image(systemName: perspective.icon)
                    .font(.system(size: 28))
                    .foregroundColor(isSelected ? .white : perspective.color)
            }
            .scaleEffect(isSelected ? 1.1 : 1.0)
            
            // Title
            Text(perspective.rawValue)
                .font(LeavnTheme.Typography.headline)
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
            
            // Description
            Text(perspective.description)
                .font(LeavnTheme.Typography.micro)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .lineLimit(3)
                .frame(height: 45)
            
            // Info button
            Button(action: onInfo) {
                HStack(spacing: 4) {
                    Image(systemName: "info.circle")
                    Text("Learn More")
                }
                .font(LeavnTheme.Typography.caption)
                .foregroundColor(LeavnTheme.Colors.accent)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(isSelected ? perspective.color : Color.clear, lineWidth: 2)
                )
        )
        .onTapGesture(perform: onTap)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
}

// MARK: - Info Sheet
struct PerspectiveInfoSheet: View {
    let perspective: TheologicalPerspective
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Header
                    HStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(perspective.color)
                                .frame(width: 80, height: 80)
                            
                            Image(systemName: perspective.icon)
                                .font(.system(size: 40))
                                .foregroundColor(.white)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text(perspective.rawValue)
                                .font(LeavnTheme.Typography.titleLarge)
                            
                            Text(perspective.description)
                                .font(LeavnTheme.Typography.body)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Detailed information would go here
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Key Beliefs")
                            .font(LeavnTheme.Typography.headline)
                        
                        Text(detailedDescription(for: perspective))
                            .font(LeavnTheme.Typography.body)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .navigationTitle("About \(perspective.rawValue)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func detailedDescription(for perspective: TheologicalPerspective) -> String {
        // In a real app, this would contain much more detailed information
        switch perspective {
        case .reformed:
            return "Reformed theology emphasizes the sovereignty of God, the authority of Scripture, and salvation by grace alone through faith alone. Key concepts include the Five Solas and TULIP."
        case .catholic:
            return "Catholic tradition values apostolic succession, the sacraments, and the teaching authority of the Church. Mary and the saints play important intercessory roles."
        case .orthodox:
            return "Eastern Orthodoxy emphasizes theosis (deification), liturgical worship, and mystical theology. Icons and ancient traditions are central to spiritual practice."
        case .evangelical:
            return "Evangelicalism focuses on personal conversion, the authority of Scripture, and the importance of sharing the Gospel. Emphasis on a personal relationship with Jesus Christ."
        case .charismatic:
            return "Charismatic Christianity emphasizes the gifts of the Holy Spirit, including healing, prophecy, and speaking in tongues. Worship is often expressive and spontaneous."
        case .mainline:
            return "Mainline Protestant churches often emphasize social justice, intellectual engagement with faith, and inclusive theology. They balance tradition with contemporary issues."
        case .nonDenominational:
            return "Non-denominational churches focus on Scripture alone without specific denominational doctrines. They often emphasize unity among believers and practical faith."
        case .messianic:
            return "Messianic Judaism maintains Jewish identity while believing in Yeshua (Jesus) as Messiah. They observe Jewish holidays and traditions with New Testament understanding."
        case .anglican:
            return "Anglican/Episcopal tradition represents the via media (middle way) between Protestantism and Catholicism. It maintains episcopal structure, liturgical worship, and the Book of Common Prayer while embracing reformed theology."
        case .lutheran:
            return "Lutheran theology centers on justification by faith alone (sola fide) and the distinction between Law and Gospel. Sacraments of baptism and communion are means of grace. Strong emphasis on Scripture and the priesthood of all believers."
        case .baptist:
            return "Baptist churches emphasize believer's baptism by immersion, congregational church governance, and religious liberty. Each local church is autonomous. Strong focus on evangelism and personal faith decision."
        case .pentecostal:
            return "Pentecostalism emphasizes direct personal experience with God through baptism in the Holy Spirit. Speaking in tongues is considered the initial evidence. Divine healing and prophecy are actively practiced."
        case .presbyterian:
            return "Presbyterian churches follow Reformed theology with a distinctive presbyterian polity (governance by elected elders). Strong emphasis on God's sovereignty, predestination, and covenant theology."
        case .methodist:
            return "Methodism, rooted in John Wesley's teachings, emphasizes sanctification and Christian perfection. Prevenient grace enables all to respond to God. Social holiness and acts of mercy are central to faith."
        case .adventist:
            return "Seventh-day Adventists observe Saturday Sabbath and emphasize the imminent Second Coming of Christ. Health and wholeness are important, with many following vegetarian diets. Ellen G. White is recognized as a prophetess."
        case .quaker:
            return "Quakers (Religious Society of Friends) emphasize the Inner Light - direct experience of God within. Silent worship allows for divine leading. Strong commitment to peace, simplicity, and social justice."
        }
    }
}
