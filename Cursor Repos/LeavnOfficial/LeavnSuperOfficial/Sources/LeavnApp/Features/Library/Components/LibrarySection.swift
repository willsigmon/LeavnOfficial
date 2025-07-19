import SwiftUI

struct LibrarySection<Content: View>: View {
    let title: String
    let icon: String
    let count: Int?
    let content: () -> Content
    
    init(
        title: String,
        icon: String,
        count: Int? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.title = title
        self.icon = icon
        self.count = count
        self.content = content
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(.leavnPrimary)
                
                Text(title)
                    .font(.title3)
                    .fontWeight(.semibold)
                
                if let count = count {
                    Text("\(count)")
                        .font(.callout)
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color.leavnPrimary)
                        .cornerRadius(12)
                }
                
                Spacer()
            }
            .padding(.horizontal)
            
            content()
        }
    }
}