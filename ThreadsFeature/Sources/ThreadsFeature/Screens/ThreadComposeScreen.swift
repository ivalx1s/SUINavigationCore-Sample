import SwiftUI
import SUINavigationFusion
#if canImport(UIKit)
import UIKit
#endif

/// A sample "compose" screen owned by the Threads feature module.
public struct ThreadComposeScreen: View {
    public enum Source: String {
        case enumRoute = "ThreadsRoute.compose"
        case perScreenRoute = "ThreadComposeRoute"
        case splitEnumRoute = "ThreadsComposerRoute.compose"
    }

    @EnvironmentObject private var navigator: Navigator
    @State private var text: String
    private let source: Source

    public init(draftID: String?, source: Source) {
        self.source = source
        self._text = State(initialValue: draftID.map { "Draft: \($0)\n\n" } ?? "")
    }

    public var body: some View {
        VStack(spacing: 16) {
            Text("Opened via: \(source.rawValue)")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)

            TextEditor(text: $text)
                .frame(minHeight: 180)
                .overlay {
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color(uiColor: .separator), lineWidth: 1)
                }

            Button {
                navigator.pop()
            } label: {
                Label("Send & pop", systemImage: "paperplane.fill")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 16)
        .padding(.top, 12)
        .padding(.bottom, 24)
        .topNavigationBarTitle("Compose")
        .topNavigationBarSubtitle("Feature module")
        .topNavigationBarTrailingPrimary(id: "close") {
            Button {
                navigator.pop()
            } label: {
                Image(systemName: "xmark")
                    .font(.title3)
                    .accessibilityLabel("Close")
            }
            .buttonStyle(.plain)
        }
    }
}
