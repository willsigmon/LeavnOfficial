import SwiftUI

/// A reusable ShareSheet component for sharing content across the app
struct ShareSheet: UIViewControllerRepresentable {
    /// The items to be shared
    let items: [Any]
    
    /// Optional callback when the share sheet is dismissed
    var onComplete: ((Bool) -> Void)? = nil
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: items,
            applicationActivities: nil
        )
        controller.completionWithItemsHandler = { (_, completed, _, _) in
            onComplete?(completed)
        }
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// MARK: - Preview
#Preview {
    ShareSheet(items: ["Sample sharing content"])
        .frame(width: 300, height: 200)
}
