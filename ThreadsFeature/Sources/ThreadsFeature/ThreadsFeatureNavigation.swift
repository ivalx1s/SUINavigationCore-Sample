import SwiftUI
import SUINavigationFusion
#if canImport(UIKit)
import UIKit
#endif

/// A typed route payload owned by the Threads feature module.
///
/// This type is pushed from the host app via `navigator.push(route:)` and must be registered in a
/// destination registry installed by the host navigation shell.
public struct ThreadRoute: NavigationRoute {
    public let id: String

    public init(id: String) {
        self.id = id
    }
}

/// Destination registrations exported by the Threads feature module.
///
/// The host app composes this bundle into its navigation stack configuration, allowing the feature module
/// to remain independent from any specific stack/container.
@MainActor
public enum ThreadsFeatureNavigation {
    public static let destinations = NavigationDestinations { registry in
        registry.register(ThreadRoute.self, key: "com.suinavigation.sample.thread") { route in
            ThreadScreen(id: route.id)
        }
    }
}

/// A sample screen owned by the Threads feature module.
public struct ThreadScreen: View {
    @EnvironmentObject private var navigator: Navigator
    private let id: String

    public init(id: String) {
        self.id = id
    }

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("This screen is implemented in a separate Swift module (ThreadsFeature).")
                    .foregroundStyle(.secondary)
                    .padding(.top, 12)

                Text("Thread id: \(id)")
                    .font(.headline)

                Button {
                    navigator.pop()
                } label: {
                    Label("Pop", systemImage: "arrow.backward")
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .buttonStyle(.bordered)

                ForEach(0..<25, id: \.self) { idx in
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
