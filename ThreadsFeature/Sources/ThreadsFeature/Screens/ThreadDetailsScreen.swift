import SwiftUI
import SUINavigationFusion
#if canImport(UIKit)
import UIKit
#endif

/// A sample "thread details" screen owned by the Threads feature module.
public struct ThreadDetailsScreen: View {
    @EnvironmentObject private var navigator: Navigator
    private let id: String

    public init(id: String) {
        self.id = id
    }

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Thread id: \(id)")
                    .font(.headline)
                    .padding(.top, 12)

                Button {
                    navigator.push(route: ThreadsRoute.compose(.init(draftID: "reply-\(id)")))
                } label: {
                    Label("Compose reply (ThreadsRoute)", systemImage: "arrowshape.turn.up.left")
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .buttonStyle(.borderedProminent)

                Button {
                    navigator.push(route: ThreadComposeRoute(draftID: "reply-\(id)"))
                } label: {
                    Label("Compose reply (ThreadComposeRoute)", systemImage: "pencil.tip")
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .buttonStyle(.bordered)

                ForEach(0..<22, id: \.self) { idx in
                    Text("Message \(idx + 1)")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.vertical, 10)
                        .padding(.horizontal, 12)
                        .background(RoundedRectangle(cornerRadius: 12).fill(Color(uiColor: .secondarySystemBackground)))
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 24)
        }
        .topNavigationBarTitle("Thread")
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

