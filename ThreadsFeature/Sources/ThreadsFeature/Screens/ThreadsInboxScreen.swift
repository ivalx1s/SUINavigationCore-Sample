import SwiftUI
import SUINavigationFusion
#if canImport(UIKit)
import UIKit
#endif

/// A simple "threads list" screen owned by the Threads feature module.
///
/// This screen demonstrates:
/// - pushing the module-scoped enum routes (`ThreadsRoute`)
/// - pushing per-screen payload routes (`ThreadDetailsRoute`, `ThreadComposeRoute`)
/// - pushing a split enum route (`ThreadsComposerRoute`)
public struct ThreadsInboxScreen: View {
    public enum Source: String {
        case enumRoute = "ThreadsRoute (enum)"
        case perScreenRoute = "Per-screen route types"
        case splitEnumRoute = "ThreadsComposerRoute (enum)"
    }

    @EnvironmentObject private var navigator: Navigator
    private let source: Source

    public init(source: Source) {
        self.source = source
    }

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("This screen is implemented in a separate Swift module (ThreadsFeature).")
                    .foregroundStyle(.secondary)
                    .padding(.top, 12)

                Text("Opened via: \(source.rawValue)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                GroupBox("Push using module-scoped enum route") {
                    VStack(alignment: .leading, spacing: 12) {
                        Button {
                            navigator.push(route: ThreadsRoute.thread(id: "123"))
                        } label: {
                            Label("Open thread 123", systemImage: "bubble.left.and.bubble.right")
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .buttonStyle(.bordered)

                        Button {
                            navigator.push(route: ThreadsRoute.compose(.init(draftID: "draft-123")))
                        } label: {
                            Label("Compose (draft-123)", systemImage: "square.and.pencil")
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .buttonStyle(.bordered)

                        Button {
                            navigator.push(route: ThreadsRoute.settings)
                        } label: {
                            Label("Settings", systemImage: "gearshape")
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .buttonStyle(.bordered)
                    }
                }

                GroupBox("Push using per-screen route payload types") {
                    VStack(alignment: .leading, spacing: 12) {
                        Button {
                            navigator.push(route: ThreadDetailsRoute(id: "123"))
                        } label: {
                            Label("Open thread 123", systemImage: "bubble.left")
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .buttonStyle(.bordered)

                        Button {
                            navigator.push(route: ThreadComposeRoute(draftID: "draft-123"))
                        } label: {
                            Label("Compose (draft-123)", systemImage: "pencil.line")
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .buttonStyle(.bordered)

                        Button {
                            navigator.push(route: ThreadsSettingsRoute())
                        } label: {
                            Label("Settings", systemImage: "gearshape.fill")
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .buttonStyle(.bordered)
                    }
                }

                GroupBox("Push using a split router enum") {
                    VStack(alignment: .leading, spacing: 12) {
                        Button {
                            navigator.push(route: ThreadsComposerRoute.compose(draftID: "draft-123"))
                        } label: {
                            Label("Compose (draft-123)", systemImage: "square.and.pencil.circle")
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .buttonStyle(.bordered)
                    }
                }

                Divider()
                    .padding(.vertical, 4)

                Text("Rows (scrollable content)")
                    .font(.headline)

                ForEach(0..<18, id: \.self) { idx in
                    Text("Thread \(idx + 1)")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.vertical, 10)
                        .padding(.horizontal, 12)
                        .background(RoundedRectangle(cornerRadius: 12).fill(Color(uiColor: .secondarySystemBackground)))
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 24)
        }
        .topNavigationBarTitle("Threads")
        .topNavigationBarSubtitle(source.rawValue)
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

