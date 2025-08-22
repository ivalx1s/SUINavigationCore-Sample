import SwiftUI
import SUINavigationFusion

@main
struct NavigationFusionSampleApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationShell(configuration: demoTopBarConfig) { navigator in
                RootScreen()
                // Root title/subtitle + actions
                    .topNavigationBarTitle("Inbox")
                    .topNavigationBarSubtitle { Text("All messages • 127") }
                    .topNavigationBarLeading {
                        Button(action: { }) {
                            Image(systemName: "person.circle.fill")
                                .font(.title2)
                                .padding(.leading, 4)
                        }
                    }
                    .topNavigationBarTrailing(position: .secondary) {
                        Button { /* search */ } label: {
                            Image(systemName: "magnifyingglass")
                                .font(.title3)
                        }
                        .buttonStyle(.plain)
                        .padding(.trailing, 10)
                    }
                    .topNavigationBarTrailingPrimary {
                        Button {
                            navigator.push(ComposeScreen(), disableBackGesture: true)
                        } label: {
                            Image(systemName: "square.and.pencil")
                                .font(.title3)
                        }
                        .buttonStyle(.plain)
                    }
            }
        }
    }
}

// MARK: - A top bar look
private let demoTopBarConfig = TopNavigationBarConfiguration(
    backgroundMaterial: .regular,
    scrollDependentBackgroundOpacity: true,
    dividerColor: Color.gray.opacity(0.35),
    titleFont: .title3,
    titleFontColor: nil,
    subtitleFont: .footnote,
    subtitleFontColor: .secondary,
    titleFontWeight: .semibold,
    subtitleFontWeight: nil,
    titleStackSpacing: 4,
    tintColor: .accentColor,
    backButtonIcon: nil // system chevron
)

// MARK: - Root screen with a list + scroll offset reporting
struct RootScreen: View {
    @EnvironmentObject private var navigator: Navigator
    @State private var items: [Message] = Message.sample
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Big visual header to demonstrate scroll-dependent opacity
                HeaderHero(title: "Your Inbox")
                
                LazyVStack(spacing: 12, pinnedViews: []) {
                    ForEach(items) { msg in
                        Button {
                            navigator.push(DetailScreen(message: msg))
                        } label: {
                            MessageRow(message: msg)
                        }
                        .buttonStyle(.plain)
                        .padding(.horizontal, 16)
                    }
                    .padding(.vertical, 8)
                }
            }
            // Report content offset via PositionObservingViewPreferenceKey
            // So that we can react to content moving beneath the navigation bar
            // Similar to native behavior
            .background(
                GeometryReader { proxy in
                    Color.clear
                        .preference(
                            key: PositionObservingViewPreferenceKey.self,
                            value: CGPoint(x: 0, y: proxy.frame(in: .named("scroll")).minY)
                        )
                }
            )
        }
        .coordinateSpace(name: "scroll")
    }
}

// MARK: - Detail screen (shows back button and actions)
struct DetailScreen: View {
    @EnvironmentObject private var navigator: Navigator
    let message: Message
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(message.subject)
                    .font(.title2.weight(.semibold))
                Text("From: \(message.sender)")
                    .foregroundStyle(.secondary)
                Divider()
                Text(lorem)
                Spacer(minLength: 40)
                Button("Open next…") {
                    navigator.push(DeepDetailScreen(index: Int.random(in: 2...99)))
                }
                .buttonStyle(.borderedProminent)
            }
            .padding(16)
            .background(
                GeometryReader { proxy in
                    Color.clear
                        .preference(
                            key: PositionObservingViewPreferenceKey.self,
                            value: CGPoint(x: 0, y: proxy.frame(in: .named("scroll")).minY)
                        )
                }
            )
        }
        .coordinateSpace(name: "scroll")
        .topNavigationBarTitle(message.subject)
        .topNavigationBarSubtitle("From \(message.sender)")
        .topNavigationBarTrailing(position: .secondary) {
            Button { /* flag */ } label: {
                Image(systemName: "flag")
            }
            .buttonStyle(.plain)
        }
        .topNavigationBarTrailingPrimary {
            Button { /* more */ } label: {
                Image(systemName: "ellipsis.circle")
            }
            .buttonStyle(.plain)
        }
    }
}

// MARK: - A screen with back gesture disabled (uses push(..., disableBackGesture: true))
struct ComposeScreen: View {
    @EnvironmentObject private var navigator: Navigator
    @State private var text: String = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Compose")
                .font(.title2.weight(.semibold))
            TextEditor(text: $text)
                .frame(minHeight: 180)
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(.quaternary))
            HStack {
                Button("Send") {
                    navigator.pop()
                }
                .buttonStyle(.borderedProminent)
                Button("Cancel") {
                    navigator.pop()
                }
                .buttonStyle(.bordered)
            }
            Spacer()
        }
        .padding(16)
        .background(
            GeometryReader { proxy in
                Color.clear
                    .preference(
                        key: PositionObservingViewPreferenceKey.self,
                        value: CGPoint(x: 0, y: proxy.frame(in: .named("scroll")).minY)
                    )
            }
        )
        .topNavigationBarTitle("New Message")
        .topNavigationBarHidesBackButton(true) // hide chevron; user must tap actions
    }
}

// MARK: - Another pushed screen for the stack depth demo
struct DeepDetailScreen: View {
    @EnvironmentObject private var navigator: Navigator
    let index: Int
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Deep detail #\(index)")
                    .font(.title2.weight(.semibold))
                Text(lorem + "\n\n" + lorem)
                Button("Pop 2 levels (or to root if not enough)") {
                    navigator.pop(levels: 2)
                }
                .buttonStyle(.bordered)
                Button("Pop to root") {
                    navigator.popToRoot()
                }
                .buttonStyle(.bordered)
            }
            .padding(16)
            .background(
                GeometryReader { proxy in
                    Color.clear
                        .preference(
                            key: PositionObservingViewPreferenceKey.self,
                            value: CGPoint(x: 0, y: proxy.frame(in: .named("scroll")).minY)
                        )
                }
            )
        }
        .coordinateSpace(name: "scroll")
        .topNavigationBarTitle("Details #\(index)")
        .topNavigationBarSubtitle("Nested navigation")
        .topNavigationBarTrailingPrimary {
            Button {
                navigator.push(DeepDetailScreen(index: index + 1))
            } label: {
                Image(systemName: "arrow.right.circle")
            }
            .buttonStyle(.plain)
        }
    }
}

// MARK: - Simple UI bits

private struct HeaderHero: View {
    let title: String
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            LinearGradient(
                colors: [.blue.opacity(0.45), .purple.opacity(0.45)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .frame(height: 160)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            Text(title)
                .font(.largeTitle.weight(.bold))
                .padding(16)
                .foregroundStyle(.white)
        }
        .padding(.horizontal, 16)
        .padding(.top, 12)
        .padding(.bottom, 8)
    }
}

private struct MessageRow: View {
    let message: Message
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Circle()
                .fill(Color.blue.opacity(0.15))
                .frame(width: 36, height: 36)
                .overlay(Text(String(message.sender.prefix(1))).font(.headline))
            VStack(alignment: .leading, spacing: 4) {
                Text(message.subject).font(.headline)
                Text(message.preview).foregroundStyle(.secondary).lineLimit(2)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundStyle(.tertiary)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(uiColor: .secondarySystemBackground))
        )
    }
}

// MARK: - Model & data

struct Message: Identifiable, Hashable {
    var id = UUID()
    var sender: String
    var subject: String
    var preview: String
    
    static let sample: [Message] = [
        .init(sender: "Alice", subject: "Design sync", preview: lorem),
        .init(sender: "Bob", subject: "Contract update", preview: lorem),
        .init(sender: "Carol", subject: "Roadmap Q3", preview: lorem),
        .init(sender: "Dave", subject: "Bug triage", preview: lorem),
        .init(sender: "Eve", subject: "Team offsite", preview: lorem),
        .init(sender: "Mallory", subject: "Security review", preview: lorem)
    ] + (0..<30).map {
        .init(sender: "User \($0)", subject: "Subject \($0)", preview: lorem)
    }
}

private let lorem =
"""
Lorem ipsum dolor sit amet, consectetur adipiscing elit. Duis nec nunc in justo varius venenatis. Praesent a turpis vitae leo gravida egestas. Integer ultricies purus et augue pulvinar, ac tempor nisl tempor.
"""
