import SwiftUI

struct ReadingModeView: View {
    @State private var selectedMode = "Standard"
    let modes = ["Standard", "Study", "Audio", "Parallel"]
    
    var body: some View {
        VStack {
            Picker("Reading Mode", selection: $selectedMode) {
                ForEach(modes, id: \.self) { mode in
                    Text(mode).tag(mode)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            
            switch selectedMode {
            case "Standard":
                StandardReadingView()
            case "Study":
                StudyModeView()
            case "Audio":
                AudioModeView()
            case "Parallel":
                ParallelModeView()
            default:
                StandardReadingView()
            }
        }
        .navigationTitle("Reading Mode")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct StandardReadingView: View {
    var body: some View {
        ScrollView {
            Text("Standard reading mode content")
                .padding()
        }
    }
}

struct StudyModeView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Study Mode")
                    .font(.headline)
                Text("Commentary and cross-references will appear here")
                    .foregroundColor(.secondary)
            }
            .padding()
        }
    }
}

struct AudioModeView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "speaker.wave.2.fill")
                .font(.system(size: 60))
                .foregroundColor(.blue)
            
            Text("Audio playback controls")
                .font(.headline)
            
            HStack(spacing: 40) {
                Button(action: {}) {
                    Image(systemName: "backward.fill")
                }
                Button(action: {}) {
                    Image(systemName: "play.fill")
                        .font(.title)
                }
                Button(action: {}) {
                    Image(systemName: "forward.fill")
                }
            }
            .font(.title2)
        }
        .padding()
    }
}

struct ParallelModeView: View {
    var body: some View {
        HStack {
            VStack {
                Text("NIV")
                    .font(.headline)
                ScrollView {
                    Text("NIV translation text")
                        .padding()
                }
            }
            
            Divider()
            
            VStack {
                Text("ESV")
                    .font(.headline)
                ScrollView {
                    Text("ESV translation text")
                        .padding()
                }
            }
        }
    }
}

#Preview {
    NavigationView {
        ReadingModeView()
    }
}