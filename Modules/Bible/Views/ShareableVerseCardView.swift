import SwiftUI
import PhotosUI

struct ShareableVerseCardView: View {
    @StateObject private var viewModel: ShareableVerseCardViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showShareSheet = false
    @State private var showSuccessAlert = false
    @State private var isGenerating = false
    @State private var generatedImage: UIImage?
    @State private var shareItems: [Any] = []
    
    init(verse: BibleVerse, service: VerseCardServiceProtocol? = nil) {
        _viewModel = StateObject(wrappedValue: ShareableVerseCardViewModel(verse: verse, service: service))
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(UIColor.systemGroupedBackground)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Preview Card
                        cardPreview
                            .padding(.horizontal)
                        
                        // Template Selector
                        templateSelector
                        
                        // Customization Options
                        customizationSection
                        
                        // Share Actions
                        shareActions
                            .padding(.horizontal)
                            .padding(.bottom, 32)
                    }
                    .padding(.top)
                }
            }
            .navigationTitle("Share Verse")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Share") {
                        Task {
                            await generateAndShare()
                        }
                    }
                    .fontWeight(.semibold)
                    .disabled(isGenerating)
                }
            }
        }
        .sheet(isPresented: $showShareSheet) {
            if !shareItems.isEmpty {
                ShareSheet(items: shareItems)
            }
        }
        .alert("Success!", isPresented: $showSuccessAlert) {
            Button("OK") { }
        } message: {
            Text("Your verse card has been saved to Photos")
        }
        .overlay {
            if isGenerating {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .overlay {
                        ProgressView("Creating your verse card...")
                            .padding()
                            .background(.regularMaterial)
                            .cornerRadius(12)
                    }
            }
        }
    }
    
    // MARK: - Components
    
    private var cardPreview: some View {
        VStack(spacing: 16) {
            Text("Preview")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            // Card Preview
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .aspectRatio(1, contentMode: .fit)
                .shadow(radius: 10, y: 5)
                .overlay {
                    if let preview = viewModel.previewImage {
                        Image(uiImage: preview)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .cornerRadius(16)
                    } else {
                        // Live SwiftUI Preview
                        VerseCardPreview(
                            verse: viewModel.verse,
                            template: viewModel.selectedTemplate,
                            customization: viewModel.customization
                        )
                        .cornerRadius(16)
                    }
                }
                .overlay(alignment: .bottomTrailing) {
                    Image(systemName: "arrow.up.forward.square.fill")
                        .font(.title2)
                        .foregroundColor(.accentColor)
                        .background(Color.white)
                        .clipShape(Circle())
                        .padding(8)
                }
        }
    }
    
    private var templateSelector: some View {
        VStack(spacing: 16) {
            Text("Choose Template")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(viewModel.templates) { template in
                        TemplateCard(
                            template: template,
                            isSelected: viewModel.selectedTemplate == template,
                            action: {
                                withAnimation(.spring(response: 0.3)) {
                                    viewModel.selectedTemplate = template
                                    Task {
                                        await viewModel.updatePreview()
                                    }
                                }
                            }
                        )
                    }
                }
                .padding(.horizontal)
            }
        }
    }
    
    private var customizationSection: some View {
        VStack(spacing: 20) {
            Text("Customize")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
            
            VStack(spacing: 16) {
                // Background Color
                HStack {
                    Label("Background", systemImage: "paintbrush.fill")
                    Spacer()
                    ColorPicker("", selection: $viewModel.backgroundColor)
                        .labelsHidden()
                }
                
                // Text Color
                HStack {
                    Label("Text Color", systemImage: "textformat")
                    Spacer()
                    ColorPicker("", selection: $viewModel.textColor)
                        .labelsHidden()
                }
                
                // Font Size
                HStack {
                    Label("Font Size", systemImage: "textformat.size")
                    Spacer()
                    Stepper("\(Int(viewModel.fontSize))pt", value: $viewModel.fontSize, in: 24...48, step: 2)
                        .labelsHidden()
                }
                
                // Leavn Branding
                Toggle(isOn: $viewModel.includeBranding) {
                    Label("Include Leavn Branding", systemImage: "tag.fill")
                }
                .tint(.accentColor)
            }
            .padding()
            .background(Color(UIColor.secondarySystemGroupedBackground))
            .cornerRadius(12)
            .padding(.horizontal)
        }
        .onChange(of: viewModel.backgroundColor) { _ in
            Task { await viewModel.updatePreview() }
        }
        .onChange(of: viewModel.textColor) { _ in
            Task { await viewModel.updatePreview() }
        }
        .onChange(of: viewModel.fontSize) { _ in
            Task { await viewModel.updatePreview() }
        }
        .onChange(of: viewModel.includeBranding) { _ in
            Task { await viewModel.updatePreview() }
        }
    }
    
    private var shareActions: some View {
        VStack(spacing: 12) {
            // Quick Share Buttons
            HStack(spacing: 12) {
                ShareButton(
                    title: "Instagram",
                    icon: "camera.fill",
                    color: .purple,
                    action: {
                        Task {
                            await shareToInstagram()
                        }
                    }
                )
                
                ShareButton(
                    title: "Save",
                    icon: "square.and.arrow.down.fill",
                    color: .green,
                    action: {
                        Task {
                            await saveToPhotos()
                        }
                    }
                )
            }
            
            // More Options
            Button(action: {
                Task {
                    await generateAndShare()
                }
            }) {
                HStack {
                    Image(systemName: "square.and.arrow.up")
                    Text("More Sharing Options")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(UIColor.tertiarySystemGroupedBackground))
                .cornerRadius(12)
            }
            .buttonStyle(.plain)
        }
    }
    
    // MARK: - Actions
    
    private func generateAndShare() async {
        isGenerating = true
        
        do {
            let image = try await viewModel.generateCard()
            generatedImage = image
            
            let shareText = """
            \(viewModel.verse.text)
            
            - \(viewModel.verse.reference) (\(viewModel.verse.translation))
            
            Shared from Leavn - Download on the App Store
            https://apps.apple.com/app/leavn
            """
            
            shareItems = [image, shareText]
            
            await MainActor.run {
                isGenerating = false
                showShareSheet = true
            }
        } catch {
            await MainActor.run {
                isGenerating = false
                // Handle error
            }
        }
    }
    
    private func shareToInstagram() async {
        // Instagram specific sharing
        await generateAndShare()
    }
    
    private func saveToPhotos() async {
        isGenerating = true
        
        do {
            let image = try await viewModel.generateCard()
            
            await MainActor.run {
                UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                isGenerating = false
                showSuccessAlert = true
            }
        } catch {
            await MainActor.run {
                isGenerating = false
                // Handle error
            }
        }
    }
}

// MARK: - Template Card
struct TemplateCard: View {
    let template: VerseCardTemplate
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        VStack(spacing: 8) {
            RoundedRectangle(cornerRadius: 12)
                .fill(LinearGradient(
                    colors: template.defaultColors,
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))
                .frame(width: 80, height: 80)
                .overlay {
                    if isSelected {
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.accentColor, lineWidth: 3)
                    }
                }
            
            Text(template.rawValue)
                .font(.caption)
                .foregroundColor(isSelected ? .accentColor : .secondary)
        }
        .onTapGesture(perform: action)
    }
}

// MARK: - Share Button
struct ShareButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                Text(title)
                    .font(.caption)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(color)
            .cornerRadius(12)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Live Preview
struct VerseCardPreview: View {
    let verse: BibleVerse
    let template: VerseCardTemplate
    let customization: VerseCardCustomization
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background
                backgroundView
                
                // Content
                VStack(spacing: 20) {
                    Spacer()
                    
                    // Verse Text
                    Text(verse.text)
                        .font(.custom("Georgia", size: customization.fontSize ?? 36))
                        .foregroundColor(Color(customization.textColor ?? .black))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, customization.padding)
                    
                    // Reference
                    Text("\(verse.reference) (\(verse.translation))")
                        .font(.custom("Georgia", size: 20))
                        .foregroundColor(Color(customization.textColor ?? .black).opacity(0.8))
                    
                    Spacer()
                    
                    // Branding
                    if customization.includeLeavnBranding {
                        VStack(spacing: 4) {
                            Text("Shared from Leavn")
                                .font(.system(size: 16, weight: .medium))
                            Text("Download on the App Store")
                                .font(.system(size: 12))
                        }
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.black.opacity(0.3))
                    }
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.width)
        }
        .aspectRatio(1, contentMode: .fit)
    }
    
    private var backgroundView: some View {
        Group {
            switch template {
            case .gradient:
                LinearGradient(
                    colors: [customization.backgroundColor ?? template.defaultColors[0], template.defaultColors[1]],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            case .minimalist:
                Color(customization.backgroundColor ?? template.defaultColors[0])
            default:
                LinearGradient(
                    colors: template.defaultColors,
                    startPoint: .top,
                    endPoint: .bottom
                )
            }
        }
    }
}

// MARK: - Share Sheet
struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// MARK: - View Model
@MainActor
class ShareableVerseCardViewModel: ObservableObject {
    let verse: BibleVerse
    private let service: VerseCardServiceProtocol
    
    @Published var selectedTemplate: VerseCardTemplate = .gradient
    @Published var backgroundColor: Color = .blue
    @Published var textColor: Color = .white
    @Published var fontSize: CGFloat = 36
    @Published var includeBranding: Bool = true
    @Published var previewImage: UIImage?
    
    var templates: [VerseCardTemplate] {
        service.getAvailableTemplates()
    }
    
    var customization: VerseCardCustomization {
        VerseCardCustomization(
            backgroundColor: backgroundColor,
            textColor: textColor,
            fontSize: fontSize,
            includeLeavnBranding: includeBranding
        )
    }
    
    init(verse: BibleVerse, service: VerseCardServiceProtocol? = nil) {
        self.verse = verse
        self.service = service ?? VerseCardService()
        
        Task {
            await updatePreview()
        }
    }
    
    func generateCard() async throws -> UIImage {
        try await service.generateCard(for: verse, template: selectedTemplate, customization: customization)
    }
    
    func updatePreview() async {
        do {
            let preview = try await service.generateCard(for: verse, template: selectedTemplate, customization: customization)
            await MainActor.run {
                self.previewImage = preview
            }
        } catch {
            // Handle error
        }
    }
}