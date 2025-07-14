import SwiftUI

// TheologicalPerspective is now defined in LeavnCore/AppModels.swift

struct TheologicalPerspectivePickerView: View {
    @Binding var selectedPerspectives: Set<TheologicalPerspective>
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            List {
                ForEach(TheologicalPerspective.allCases, id: \.self) { perspective in
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(perspective.rawValue)
                                .font(.system(size: 17, weight: .medium))
                            Text(perspective.description)
                                .font(.system(size: 14))
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        if selectedPerspectives.contains(perspective) {
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                                .font(.system(size: 16, weight: .semibold))
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            if selectedPerspectives.contains(perspective) {
                                selectedPerspectives.remove(perspective)
                            } else {
                                selectedPerspectives.insert(perspective)
                            }
                        }
                        HapticManager.shared.impact(.light)
                    }
                }
                
                if !selectedPerspectives.isEmpty {
                    Section {
                        HStack {
                            Text("Selected: \(selectedPerspectives.count)")
                                .font(.system(size: 14))
                                .foregroundColor(.secondary)
                            
                            Spacer()
                            
                            Button("Clear All") {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    selectedPerspectives.removeAll()
                                }
                                HapticManager.shared.impact(.light)
                            }
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.red)
                        }
                    }
                }
            }
            .navigationTitle("Theological Perspectives")
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
}

#Preview {
    TheologicalPerspectivePickerView(selectedPerspectives: .constant([.evangelical, .reformed]))
}