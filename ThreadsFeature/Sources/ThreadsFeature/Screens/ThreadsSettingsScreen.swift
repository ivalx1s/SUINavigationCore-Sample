import SwiftUI
import SUINavigationFusion

/// A sample settings screen owned by the Threads feature module.
public struct ThreadsSettingsScreen: View {
    @EnvironmentObject private var navigator: Navigator
    @State private var isEnabled = true
    @State private var accent: Accent = .system

    private enum Accent: String, CaseIterable {
        case system = "System"
        case purple = "Purple"
        case green = "Green"
    }

    public init() {}

    public var body: some View {
        Form {
            Section("Example state") {
                Toggle("Feature toggle", isOn: $isEnabled)
                Picker("Accent", selection: $accent) {
                    ForEach(Accent.allCases, id: \.self) { accent in
                        Text(accent.rawValue).tag(accent)
                    }
                }
            }

            Section("Navigation") {
                Button("Pop") { navigator.pop() }
            }
        }
        .tint(tintColor)
        .topNavigationBarTitle("Threads settings")
        .topNavigationBarSubtitle("Feature module")
    }

    private var tintColor: Color? {
        switch accent {
        case .system:
            return nil
        case .purple:
            return .purple
        case .green:
            return .green
        }
    }
}

