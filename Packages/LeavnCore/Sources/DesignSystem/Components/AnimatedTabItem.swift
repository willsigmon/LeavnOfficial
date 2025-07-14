import SwiftUI

public struct AnimatedTabItem: View {
    let icon: String
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    @State private var animateScale = false
    
    public init(icon: String, title: String, isSelected: Bool, action: @escaping () -> Void) {
        self.icon = icon
        self.title = title
        self.isSelected = isSelected
        self.action = action
    }
    
    public var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                action()
            }
        }) {
            VStack(spacing: 6) {
                Image(systemName: isSelected ? "\(icon).fill" : icon)
                    .font(.system(size: 22))
                    .scaleEffect(isSelected ? 1.1 : 1.0)
                    .symbolRenderingMode(.multicolor)
                
                Text(title)
                    .font(LeavnTheme.Typography.micro)
                    .fontWeight(isSelected ? .semibold : .regular)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .foregroundColor(isSelected ? LeavnTheme.Colors.accent : .secondary)
            .frame(maxWidth: .infinity, minHeight: 60)
            .scaleEffect(animateScale ? 0.95 : 1.0)
            .contentShape(Rectangle())
        }
        .accessibilityLabel(title)
        .accessibilityHint(isSelected ? "\(title) tab is currently selected" : "Double tap to switch to \(title) tab")
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
        .buttonStyle(PlainButtonStyle())
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.1)) {
                animateScale = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                animateScale = false
            }
        }
    }
}

#if DEBUG
struct AnimatedTabItem_Previews: PreviewProvider {
    static var previews: some View {
        HStack {
            AnimatedTabItem(icon: "house.fill", title: "Home", isSelected: true) {}
            AnimatedTabItem(icon: "book.fill", title: "Bible", isSelected: false) {}
            AnimatedTabItem(icon: "magnifyingglass", title: "Search", isSelected: false) {}
        }
        .padding()
        .background(Color(.systemBackground))
    }
}
#endif