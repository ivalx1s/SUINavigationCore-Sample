import SwiftUI
import SUINavigationFusion
import ThreadsFeature

@main
struct SUINavigationFusionSampleApp: App {
    var body: some Scene {
        WindowGroup {
            SampleTabs()
        }
    }
}

// MARK: - Restoration (Catalog)

private enum CatalogRoute: NavigationRoute {
    case basicTitles
    case styledTitles
    case barItems
    case shareConfirmation
    case principalView
    case visibility
    case updateKey
    case navigationActions(level: Int)
    case disableBackGesture
    case scrollOpacity
    case about
    case compose
}

// Treat routes as persisted schema.
// If you change case names/associated values in a shipped app, keep decoding for older payloads.
extension CatalogRoute: Codable {
    private static let schemaVersion = 1

    private enum CodingKeys: String, CodingKey {
        case schemaVersion
        case kind
        case level
    }

    private enum Kind: String, Codable {
        case basicTitles
        case styledTitles
        case barItems
        case shareConfirmation
        case principalView
        case visibility
        case updateKey
        case navigationActions
        case disableBackGesture
        case scrollOpacity
        case about
        case compose
    }

    init(from decoder: Decoder) throws {
        // New, versioned format.
        if
            let container = try? decoder.container(keyedBy: CodingKeys.self),
            let version = try? container.decode(Int.self, forKey: .schemaVersion)
        {
            guard version == Self.schemaVersion else {
                throw DecodingError.dataCorruptedError(
                    forKey: .schemaVersion,
                    in: container,
                    debugDescription: "Unsupported CatalogRoute schemaVersion: \(version)"
                )
            }

            let kind = try container.decode(Kind.self, forKey: .kind)
            switch kind {
            case .basicTitles:
                self = .basicTitles
            case .styledTitles:
                self = .styledTitles
            case .barItems:
                self = .barItems
            case .shareConfirmation:
                self = .shareConfirmation
            case .principalView:
                self = .principalView
            case .visibility:
                self = .visibility
            case .updateKey:
                self = .updateKey
            case .navigationActions:
                self = .navigationActions(level: try container.decode(Int.self, forKey: .level))
            case .disableBackGesture:
                self = .disableBackGesture
            case .scrollOpacity:
                self = .scrollOpacity
            case .about:
                self = .about
            case .compose:
                self = .compose
            }

            return
        }

        // Backward-compatibility: decode the old synthesized enum representation
        // (e.g. `{"basicTitles":{}}` or `{"navigationActions":{"level":1}}`).
        let container = try decoder.container(keyedBy: AnyCodingKey.self)
        guard let key = container.allKeys.first else {
            throw DecodingError.dataCorrupted(.init(codingPath: decoder.codingPath, debugDescription: "Empty CatalogRoute payload"))
        }

        switch key.stringValue {
        case "basicTitles":
            self = .basicTitles
        case "styledTitles":
            self = .styledTitles
        case "barItems":
            self = .barItems
        case "shareConfirmation":
            self = .shareConfirmation
        case "principalView":
            self = .principalView
        case "visibility":
            self = .visibility
        case "updateKey":
            self = .updateKey
        case "navigationActions":
            let nested = try container.nestedContainer(keyedBy: AnyCodingKey.self, forKey: key)
            self = .navigationActions(level: try nested.decode(Int.self, forKey: AnyCodingKey("level")))
        case "disableBackGesture":
            self = .disableBackGesture
        case "scrollOpacity":
            self = .scrollOpacity
        case "about":
            self = .about
        case "compose":
            self = .compose
        default:
            throw DecodingError.dataCorruptedError(forKey: key, in: container, debugDescription: "Unknown CatalogRoute case: \(key.stringValue)")
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(Self.schemaVersion, forKey: .schemaVersion)

        switch self {
        case .basicTitles:
            try container.encode(Kind.basicTitles, forKey: .kind)
        case .styledTitles:
            try container.encode(Kind.styledTitles, forKey: .kind)
        case .barItems:
            try container.encode(Kind.barItems, forKey: .kind)
        case .shareConfirmation:
            try container.encode(Kind.shareConfirmation, forKey: .kind)
        case .principalView:
            try container.encode(Kind.principalView, forKey: .kind)
        case .visibility:
            try container.encode(Kind.visibility, forKey: .kind)
        case .updateKey:
            try container.encode(Kind.updateKey, forKey: .kind)
        case .navigationActions(let level):
            try container.encode(Kind.navigationActions, forKey: .kind)
            try container.encode(level, forKey: .level)
        case .disableBackGesture:
            try container.encode(Kind.disableBackGesture, forKey: .kind)
        case .scrollOpacity:
            try container.encode(Kind.scrollOpacity, forKey: .kind)
        case .about:
            try container.encode(Kind.about, forKey: .kind)
        case .compose:
            try container.encode(Kind.compose, forKey: .kind)
        }
    }
}

private enum CatalogRestoration {
    static let stackIDBase = "catalog"
    static let routeKey: NavigationDestinationKey = "com.suinavigationfusion.sample.catalogRoute"
    static let routeKeyAliases: [NavigationDestinationKey] = [.type(CatalogRoute.self)]

    static let encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        return encoder
    }()

    static let decoder = JSONDecoder()
}

private struct AnyCodingKey: CodingKey {
    let stringValue: String
    let intValue: Int?

    init(_ string: String) {
        self.stringValue = string
        self.intValue = nil
    }

    init?(stringValue: String) {
        self.init(stringValue)
    }

    init?(intValue: Int) {
        return nil
    }
}

@MainActor
private struct SampleTabs: View {
    var body: some View {
        TabView {
            CatalogTab()
                .tabItem { Label("Catalog", systemImage: "list.bullet") }
            PlaygroundTab()
                .tabItem { Label("Playground", systemImage: "slider.horizontal.3") }
        }
    }
}

// MARK: - Catalog (feature coverage)

private struct CatalogTab: View {
    var body: some View {
        RestorableNavigationShell<CatalogRoute>(
            id: CatalogRestoration.stackIDBase,
            idScope: .scene,
            configuration: .defaultMaterial,
            encoder: CatalogRestoration.encoder,
            decoder: CatalogRestoration.decoder,
            key: CatalogRestoration.routeKey,
            aliases: CatalogRestoration.routeKeyAliases,
            additionalDestinations: ThreadsFeatureNavigation.destinations,
            root: { _ in CatalogRootScreen() },
            destination: { route in
                switch route {
                case .basicTitles:
                    BasicTitlesDemoScreen()
                case .styledTitles:
                    StyledTitlesDemoScreen()
                case .barItems:
                    BarItemsDemoScreen()
                case .shareConfirmation:
                    ShareConfirmationScreen()
                case .principalView:
                    PrincipalViewDemoScreen()
                case .visibility:
                    VisibilityDemoScreen()
                case .updateKey:
                    UpdateKeyDemoScreen()
                case .navigationActions(let level):
                    NavigationActionsDemoScreen(level: level)
                case .disableBackGesture:
                    DisableBackGestureDemoScreen()
                case .scrollOpacity:
                    ScrollOpacityDemoScreen()
                case .about:
                    AboutScreen()
                case .compose:
                    ComposeScreen()
                }
            }
        )
    }
}

private struct CatalogRootScreen: View {
    @EnvironmentObject private var navigator: Navigator

    var body: some View {
        OffsetObservingScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Explore navigation-bar APIs, navigation actions, scroll behavior, and update edge cases.")
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 16)
                    .padding(.top, 12)

                DemoSection(title: "Basics") {
                    DemoRow(
                        title: "Title & subtitle (String)",
                        subtitle: "Default fonts/colors from configuration"
                    ) {
                        navigator.push(route: CatalogRoute.basicTitles)
                    }

                    DemoRow(
                        title: "Title & subtitle (Text)",
                        subtitle: "Text modifiers override configuration"
                    ) {
                        navigator.push(route: CatalogRoute.styledTitles)
                    }
                }

                DemoSection(title: "Bar Content") {
                    DemoRow(
                        title: "Leading / trailing items",
                        subtitle: "Primary + secondary actions"
                    ) {
                        navigator.push(route: CatalogRoute.barItems)
                    }

                    DemoRow(
                        title: "Principal view",
                        subtitle: "Replace title/subtitle with custom center content"
                    ) {
                        navigator.push(route: CatalogRoute.principalView)
                    }

                    DemoRow(
                        title: "Visibility controls",
                        subtitle: "Hide/show sections and positions"
                    ) {
                        navigator.push(route: CatalogRoute.visibility)
                    }
                }

                DemoSection(title: "Updates (Edge Cases)") {
                    DemoRow(
                        title: "Updating nav-bar content",
                        subtitle: "Use stable `id` + `updateKey` to refresh"
                    ) {
                        navigator.push(route: CatalogRoute.updateKey)
                    }
                }

                DemoSection(title: "Navigation") {
                    DemoRow(
                        title: "Push / pop / popToRoot / pop(levels:)",
                        subtitle: "Includes animated + non-animated pops"
                    ) {
                        navigator.push(route: CatalogRoute.navigationActions(level: 1))
                    }

                    DemoRow(
                        title: "Disable interactive back swipe",
                        subtitle: "Per-screen `disableBackGesture`"
                    ) {
                        navigator.push(route: CatalogRoute.disableBackGesture, disableBackGesture: true)
                    }
                }

                DemoSection(title: "Feature Modules") {
                    DemoRow(
                        title: "Threads inbox (feature enum router)",
                        subtitle: "Route enum + `switch` destination in ThreadsFeature"
                    ) {
                        navigator.push(route: ThreadsRoute.inbox)
                    }

                    DemoRow(
                        title: "Thread details (feature per-screen route type)",
                        subtitle: "Dedicated payload type + per-screen destination key"
                    ) {
                        navigator.push(route: ThreadDetailsRoute(id: "123"))
                    }

                    DemoRow(
                        title: "Composer (feature split enum route)",
                        subtitle: "Separate enum for a sub-flow"
                    ) {
                        navigator.push(route: ThreadsComposerRoute.compose(draftID: "draft-123"))
                    }
                }

                DemoSection(title: "Scroll") {
                    DemoRow(
                        title: "Scroll-dependent bar background",
                        subtitle: "Using PositionObservingViewPreferenceKey"
                    ) {
                        navigator.push(route: CatalogRoute.scrollOpacity)
                    }
                }

                DemoSection(title: "About") {
                    DemoRow(
                        title: "What this sample covers",
                        subtitle: "Quick notes about design + gotchas"
                    ) {
                        navigator.push(route: CatalogRoute.about)
                    }
                }
            }
            .padding(.bottom, 24)
        }
        .topNavigationBarTitle("Catalog")
        .topNavigationBarSubtitle("SUINavigationFusion")
        .topNavigationBarLeading(id: "about") {
            Button {
                navigator.push(route: CatalogRoute.about)
            } label: {
                Image(systemName: "info.circle")
                    .font(.title3)
                    .accessibilityLabel("About")
            }
            .buttonStyle(.plain)
        }
        .topNavigationBarTrailing(id: "principal", position: .secondary) {
            Button {
                navigator.push(route: CatalogRoute.principalView)
            } label: {
                Image(systemName: "rectangle.3.group")
                    .font(.title3)
                    .accessibilityLabel("Principal view demo")
            }
            .buttonStyle(.plain)
        }
        .topNavigationBarTrailingPrimary(id: "compose") {
            Button {
                navigator.push(route: CatalogRoute.compose, disableBackGesture: true)
            } label: {
                Image(systemName: "square.and.pencil")
                    .font(.title3)
                    .accessibilityLabel("Compose")
            }
            .buttonStyle(.plain)
        }
    }
}

// MARK: - Playground (configuration coverage)

@MainActor
private struct PlaygroundTab: View {
    @StateObject private var navigator = Navigator()
    @State private var state = NavBarPlaygroundState()

    var body: some View {
        NavigationShell(navigator: navigator, configuration: state.configuration) {
            NavBarPlaygroundScreen(state: $state)
        }
    }
}

private struct NavBarPlaygroundScreen: View {
    @EnvironmentObject private var navigator: Navigator
    @Binding var state: NavBarPlaygroundState

    var body: some View {
        OffsetObservingScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Change configuration options and observe how the bar updates (including pushed screens).")
                    .foregroundStyle(.secondary)
                    .padding(.top, 12)
                    .accessibilityLabel("Change configuration options and observe how the bar updates, including pushed screens.")

                GroupBox("Background") {
                    VStack(alignment: .leading, spacing: 12) {
                        Picker("Style", selection: $state.backgroundStyle) {
                            ForEach(NavBarPlaygroundState.BackgroundStyle.allCases, id: \.self) { style in
                                Text(style.title).tag(style)
                            }
                        }
                        .pickerStyle(.segmented)

                        if state.backgroundStyle == .material {
                            Picker("Material", selection: $state.materialStyle) {
                                ForEach(NavBarPlaygroundState.MaterialStyle.allCases, id: \.self) { material in
                                    Text(material.title).tag(material)
                                }
                            }
                        } else {
                            Picker("Color", selection: $state.colorStyle) {
                                ForEach(NavBarPlaygroundState.ColorStyle.allCases, id: \.self) { color in
                                    Text(color.title).tag(color)
                                }
                            }
                        }

                        Toggle("Scroll-dependent background opacity", isOn: $state.scrollDependentBackgroundOpacity)
                        Toggle("Divider", isOn: $state.showsDivider)
                    }
                }

                GroupBox("Typography") {
                    VStack(alignment: .leading, spacing: 12) {
                        Picker("Title font", selection: $state.titleFontStyle) {
                            ForEach(NavBarPlaygroundState.FontStyle.allCases, id: \.self) { style in
                                Text(style.title).tag(style)
                            }
                        }
                        Picker("Title weight", selection: $state.titleWeightStyle) {
                            ForEach(NavBarPlaygroundState.WeightStyle.allCases, id: \.self) { style in
                                Text(style.title).tag(style)
                            }
                        }
                        Picker("Title color", selection: $state.titleColorStyle) {
                            ForEach(NavBarPlaygroundState.ColorStyle.allCases, id: \.self) { style in
                                Text(style.title).tag(style)
                            }
                        }

                        Divider()

                        Picker("Subtitle font", selection: $state.subtitleFontStyle) {
                            ForEach(NavBarPlaygroundState.FontStyle.allCases, id: \.self) { style in
                                Text(style.title).tag(style)
                            }
                        }
                        Picker("Subtitle weight", selection: $state.subtitleWeightStyle) {
                            ForEach(NavBarPlaygroundState.WeightStyle.allCases, id: \.self) { style in
                                Text(style.title).tag(style)
                            }
                        }
                        Picker("Subtitle color", selection: $state.subtitleColorStyle) {
                            ForEach(NavBarPlaygroundState.ColorStyle.allCases, id: \.self) { style in
                                Text(style.title).tag(style)
                            }
                        }

                        Divider()

                        Picker("Title/subtitle spacing", selection: $state.titleStackSpacingStyle) {
                            ForEach(NavBarPlaygroundState.SpacingStyle.allCases, id: \.self) { style in
                                Text(style.title).tag(style)
                            }
                        }
                    }
                }

                GroupBox("Icons & Tint") {
                    VStack(alignment: .leading, spacing: 12) {
                        Picker("Configuration tint", selection: $state.tintStyle) {
                            ForEach(NavBarPlaygroundState.ColorStyle.allCases, id: \.self) { style in
                                Text(style.title).tag(style)
                            }
                        }

                        Toggle("Custom back icon", isOn: $state.usesCustomBackIcon)
                        if state.usesCustomBackIcon {
                            Picker("Back icon (SF Symbol)", selection: $state.backIconStyle) {
                                ForEach(NavBarPlaygroundState.BackIconStyle.allCases, id: \.self) { style in
                                    Text(style.title).tag(style)
                                }
                            }
                        }
                    }
                }

                Button {
                    navigator.push(PlaygroundPreviewScreen(state: $state))
                } label: {
                    Label("Push preview screen", systemImage: "arrow.right.square")
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .buttonStyle(.borderedProminent)

                Button(role: .destructive) {
                    state = NavBarPlaygroundState()
                } label: {
                    Label("Reset configuration", systemImage: "arrow.counterclockwise")
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .buttonStyle(.bordered)

                Spacer(minLength: 24)
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 24)
        }
        .topNavigationBarTitle("Playground")
        .topNavigationBarSubtitle(state.summary)
        .topNavigationBarLeading(id: "reset") {
            Button {
                state = NavBarPlaygroundState()
            } label: {
                Image(systemName: "arrow.counterclockwise")
                    .font(.title3)
                    .accessibilityLabel("Reset configuration")
            }
            .buttonStyle(.plain)
        }
        .topNavigationBarTrailingPrimary(id: "preview") {
            Button {
                navigator.push(PlaygroundPreviewScreen(state: $state))
            } label: {
                Image(systemName: "arrow.right.square")
                    .font(.title3)
                    .accessibilityLabel("Preview")
            }
            .buttonStyle(.plain)
        }
    }
}

private struct PlaygroundPreviewScreen: View {
    @EnvironmentObject private var navigator: Navigator
    @Binding var state: NavBarPlaygroundState
    @State private var isFavorite = false

    var body: some View {
        OffsetObservingScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("This screen is here to preview configuration on a non-root view (back button, tint, divider, etc.).")
                    .foregroundStyle(.secondary)
                    .padding(.top, 12)

                GroupBox("Configuration tint (stack-wide)") {
                    VStack(alignment: .leading, spacing: 12) {
                        Picker("Tint", selection: $state.tintStyle) {
                            ForEach(NavBarPlaygroundState.ColorStyle.allCases, id: \.self) { style in
                                Text(style.title).tag(style)
                            }
                        }

                        Text("This updates `TopNavigationBarConfiguration.tintColor` and behaves like a SwiftUI `.tint(...)` for the whole navigation stack.")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }

                Button {
                    navigator.push(PlaygroundPreviewScreen(state: $state))
                } label: {
                    Label("Push another preview screen", systemImage: "square.stack.3d.up")
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .buttonStyle(.borderedProminent)

                Text("Scroll a bit to see scroll-dependent background opacity (if enabled).")
                    .foregroundStyle(.secondary)

                ForEach(0..<30) { idx in
                    Text("Row \(idx + 1)")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.vertical, 10)
                        .padding(.horizontal, 12)
                        .background(RoundedRectangle(cornerRadius: 12).fill(Color(uiColor: .secondarySystemBackground)))
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 24)
        }
        .topNavigationBarTitle("Preview")
        .topNavigationBarSubtitle("Back icon + tint • config: \(state.tintStyle.title)")
        .topNavigationBarTrailingPrimary(id: "favorite", updateKey: isFavorite) {
            Button {
                isFavorite.toggle()
            } label: {
                Image(systemName: isFavorite ? "heart.fill" : "heart")
                    .font(.title3)
                    .accessibilityLabel(isFavorite ? "Unfavorite" : "Favorite")
            }
            .buttonStyle(.plain)
        }
        .topNavigationBarTrailing(id: "close", position: .secondary) {
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

// MARK: - Demos (individual screens)

private struct BasicTitlesDemoScreen: View {
    @EnvironmentObject private var navigator: Navigator
    @State private var showsSubtitle = true

    var body: some View {
        OffsetObservingScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("This screen uses the String-based title/subtitle APIs, so fonts/colors come from TopNavigationBarConfiguration.")
                    .foregroundStyle(.secondary)
                    .padding(.top, 12)

                Toggle("Show subtitle", isOn: $showsSubtitle)

                Button {
                    navigator.push(route: CatalogRoute.basicTitles)
                } label: {
                    Label("Push another copy", systemImage: "square.stack.3d.up")
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .buttonStyle(.borderedProminent)

                ForEach(0..<25) { idx in
                    Text("Row \(idx + 1)")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.vertical, 10)
                        .padding(.horizontal, 12)
                        .background(RoundedRectangle(cornerRadius: 12).fill(Color(uiColor: .secondarySystemBackground)))
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 24)
        }
        .topNavigationBarTitle("String Title")
        .topNavigationBarSubtitle(showsSubtitle ? "Uses configuration styling" : nil)
        .topNavigationBarTrailingPrimary(id: "toggleSubtitle", updateKey: showsSubtitle) {
            Button {
                showsSubtitle.toggle()
            } label: {
                Image(systemName: showsSubtitle ? "text.bubble.fill" : "text.bubble")
                    .font(.title3)
                    .accessibilityLabel("Toggle subtitle")
            }
            .buttonStyle(.plain)
        }
    }
}

private struct StyledTitlesDemoScreen: View {
    @State private var style: TitleStyle = .accent

    var body: some View {
        OffsetObservingScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("This screen uses the Text-based APIs. Any Text modifiers here override configuration fonts/colors.")
                    .foregroundStyle(.secondary)
                    .padding(.top, 12)

                Picker("Style", selection: $style) {
                    ForEach(TitleStyle.allCases, id: \.self) { style in
                        Text(style.title).tag(style)
                    }
                }
                .pickerStyle(.segmented)

                ForEach(0..<20) { idx in
                    Text("Row \(idx + 1)")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.vertical, 10)
                        .padding(.horizontal, 12)
                        .background(RoundedRectangle(cornerRadius: 12).fill(Color(uiColor: .secondarySystemBackground)))
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 24)
        }
        .topNavigationBarTitle {
            switch style {
            case .accent:
                Text("Styled Title")
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(.tint)
            case .mono:
                Text("Styled Title")
                    .font(.system(.headline, design: .monospaced).weight(.bold))
            }
        }
        .topNavigationBarSubtitle {
            switch style {
            case .accent:
                Text("Text modifiers override configuration")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            case .mono:
                Text("Monospaced subtitle")
                    .font(.system(.subheadline, design: .monospaced))
                    .foregroundStyle(.secondary)
            }
        }
    }

    private enum TitleStyle: String, CaseIterable, Hashable {
        case accent
        case mono

        var title: String {
            switch self {
            case .accent: "Accent"
            case .mono: "Monospaced"
            }
        }
    }
}

private struct BarItemsDemoScreen: View {
    @EnvironmentObject private var navigator: Navigator
    @State private var isPinned = false
    @State private var isMuted = false

    var body: some View {
        OffsetObservingScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Leading and trailing items are arbitrary SwiftUI views (often Buttons).")
                    .foregroundStyle(.secondary)
                    .padding(.top, 12)

                Toggle("Pinned (updates trailing icon)", isOn: $isPinned)
                Toggle("Muted (updates leading icon)", isOn: $isMuted)

                Button {
                    navigator.push(route: CatalogRoute.barItems)
                } label: {
                    Label("Push another copy", systemImage: "square.stack.3d.up")
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .buttonStyle(.borderedProminent)

                ForEach(0..<24) { idx in
                    Text("Row \(idx + 1)")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.vertical, 10)
                        .padding(.horizontal, 12)
                        .background(RoundedRectangle(cornerRadius: 12).fill(Color(uiColor: .secondarySystemBackground)))
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 24)
        }
        .topNavigationBarTitle("Bar Items")
        .topNavigationBarSubtitle("Leading + trailing actions")
        .topNavigationBarLeading(id: "leading", updateKey: isMuted) {
            Button {
                isMuted.toggle()
            } label: {
                Image(systemName: isMuted ? "speaker.slash.fill" : "speaker.wave.2.fill")
                    .font(.title3)
                    .accessibilityLabel(isMuted ? "Unmute" : "Mute")
            }
            .buttonStyle(.plain)
        }
        .topNavigationBarTrailing(id: "share", position: .secondary) {
            Button {
                navigator.push(route: CatalogRoute.shareConfirmation)
            } label: {
                Image(systemName: "square.and.arrow.up")
                    .font(.title3)
                    .accessibilityLabel("Share")
            }
            .buttonStyle(.plain)
        }
        .topNavigationBarTrailingPrimary(id: "pin", updateKey: isPinned) {
            Button {
                isPinned.toggle()
            } label: {
                Image(systemName: isPinned ? "pin.fill" : "pin")
                    .font(.title3)
                    .accessibilityLabel(isPinned ? "Unpin" : "Pin")
            }
            .buttonStyle(.plain)
        }
    }
}

private struct ShareConfirmationScreen: View {
    @EnvironmentObject private var navigator: Navigator

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Shared")
                .font(.title2.weight(.semibold))
            Text("This is a simple screen pushed from a nav-bar button.")
                .foregroundStyle(.secondary)
            Button("OK") {
                navigator.pop()
            }
            .buttonStyle(.borderedProminent)
            Spacer()
        }
        .padding(16)
        .topNavigationBarTitle("Share")
        .topNavigationBarSubtitle("Confirmation")
        .topNavigationBarTrailingPrimary(id: "done") {
            Button("Done") { navigator.pop() }
                .font(.headline)
        }
    }
}

private struct PrincipalViewDemoScreen: View {
    @EnvironmentObject private var navigator: Navigator
    @State private var selection: Filter = .all

    var body: some View {
        OffsetObservingScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("When a principal view is set, it replaces the title/subtitle stack.")
                    .foregroundStyle(.secondary)
                    .padding(.top, 12)

                Text("Selected: \(selection.title)")
                    .font(.headline)

                ForEach(0..<28) { idx in
                    Text("\(selection.title) item \(idx + 1)")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.vertical, 10)
                        .padding(.horizontal, 12)
                        .background(RoundedRectangle(cornerRadius: 12).fill(Color(uiColor: .secondarySystemBackground)))
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 24)
        }
        .topNavigationBarPrincipalView(id: "filter", updateKey: selection) {
            Picker("Filter", selection: $selection) {
                ForEach(Filter.allCases, id: \.self) { item in
                    Text(item.title).tag(item)
                }
            }
            .pickerStyle(.segmented)
            .frame(width: 260)
        }
        .topNavigationBarTrailingPrimary(id: "pop") {
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

    private enum Filter: String, CaseIterable, Hashable {
        case all
        case unread
        case flagged

        var title: String {
            switch self {
            case .all: "All"
            case .unread: "Unread"
            case .flagged: "Flagged"
            }
        }
    }
}

private struct VisibilityDemoScreen: View {
    @State private var showsLeading = true
    @State private var showsPrincipal = true
    @State private var showsTrailingPrimary = true
    @State private var showsTrailingSecondary = true
    @State private var hidesBackButton = false
    @State private var isAlertPresented = false
    @State private var alertMessage = ""

    var body: some View {
        OffsetObservingScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Visibility is controlled per screen via preferences. Use it to hide sections without removing their content.")
                    .foregroundStyle(.secondary)
                    .padding(.top, 12)

                Toggle("Leading", isOn: $showsLeading)
                Toggle("Principal (title/subtitle)", isOn: $showsPrincipal)
                Toggle("Trailing primary", isOn: $showsTrailingPrimary)
                Toggle("Trailing secondary", isOn: $showsTrailingSecondary)
                Toggle("Hide back button", isOn: $hidesBackButton)

                ForEach(0..<20) { idx in
                    Text("Row \(idx + 1)")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.vertical, 10)
                        .padding(.horizontal, 12)
                        .background(RoundedRectangle(cornerRadius: 12).fill(Color(uiColor: .secondarySystemBackground)))
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 24)
        }
        .topNavigationBarTitle("Visibility")
        .topNavigationBarSubtitle("Toggle sections and positions")
        .topNavigationBarLeading(id: "leading") {
            Button {
                showAlert("Leading button tapped")
            } label: {
                Image(systemName: "person.circle.fill")
                    .font(.title3)
                    .accessibilityLabel("Leading")
            }
            .buttonStyle(.plain)
        }
        .topNavigationBarTrailing(id: "secondary", position: .secondary) {
            Button {
                showAlert("Trailing secondary button tapped")
            } label: {
                Image(systemName: "magnifyingglass")
                    .font(.title3)
                    .accessibilityLabel("Secondary")
            }
            .buttonStyle(.plain)
        }
        .topNavigationBarTrailingPrimary(id: "primary") {
            Button {
                showAlert("Trailing primary button tapped")
            } label: {
                Image(systemName: "ellipsis.circle")
                    .font(.title3)
                    .accessibilityLabel("Primary")
            }
            .buttonStyle(.plain)
        }
        .topNavigationBarVisibility(showsLeading ? .visible : .hidden, for: .leading)
        .topNavigationBarVisibility(showsPrincipal ? .visible : .hidden, for: .principal)
        .topNavigationBarVisibility(showsTrailingPrimary ? .visible : .hidden, for: .trailingPosition(.primary))
        .topNavigationBarVisibility(showsTrailingSecondary ? .visible : .hidden, for: .trailingPosition(.secondary))
        .topNavigationBarHidesBackButton(hidesBackButton)
        .alert("Action", isPresented: $isAlertPresented) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(alertMessage)
        }
    }

    private func showAlert(_ message: String) {
        alertMessage = message
        isAlertPresented = true
    }
}

private struct UpdateKeyDemoScreen: View {
    @State private var count = 0
    @State private var usesUpdateKey = true

    var body: some View {
        OffsetObservingScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(
                    """
                    The library stores bar items as equatable preference values.
                    If an item keeps the same `id`, its view content may not refresh when local state changes.

                    Use `updateKey` to force a refresh when the identity stays the same but the rendered content must update.
                    """
                )
                .foregroundStyle(.secondary)
                .padding(.top, 12)

                Toggle("Use updateKey", isOn: $usesUpdateKey)

                Button {
                    count += 1
                } label: {
                    Label("Increment count (\(count))", systemImage: "plus.circle")
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .buttonStyle(.borderedProminent)

                Text("Now tap the bell button in the nav bar. The badge updates only when updateKey is enabled.")
                    .foregroundStyle(.secondary)

                ForEach(0..<22) { idx in
                    Text("Row \(idx + 1)")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.vertical, 10)
                        .padding(.horizontal, 12)
                        .background(RoundedRectangle(cornerRadius: 12).fill(Color(uiColor: .secondarySystemBackground)))
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 24)
        }
        .topNavigationBarTitle("Update Keys")
        .topNavigationBarSubtitle("Stable id + refresh key")
        .topNavigationBarTrailingPrimary(
            id: "badge",
            updateKey: usesUpdateKey ? AnyHashable(count) : nil
        ) {
            Button {
                count += 1
            } label: {
                BadgeIcon(systemName: "bell", count: count)
            }
            .buttonStyle(.plain)
        }
    }
}

private struct NavigationActionsDemoScreen: View {
    @EnvironmentObject private var navigator: Navigator
    let level: Int
    @State private var disableBackGestureForNextPush = false
    @State private var hidesBackButton = false

    var body: some View {
        OffsetObservingScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("This screen demonstrates stack operations via Navigator.")
                    .foregroundStyle(.secondary)
                    .padding(.top, 12)

                Text("Stack level: \(level)")
                    .font(.title2.weight(.semibold))

                Toggle("Disable back swipe on next push", isOn: $disableBackGestureForNextPush)
                Toggle("Hide back button (this screen)", isOn: $hidesBackButton)

                Button {
                    navigator.push(
                        route: CatalogRoute.navigationActions(level: level + 1),
                        animated: true,
                        disableBackGesture: disableBackGestureForNextPush
                    )
                } label: {
                    Label("Push next (animated)", systemImage: "arrow.right")
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .buttonStyle(.borderedProminent)

                Button {
                    navigator.push(
                        route: CatalogRoute.navigationActions(level: level + 1),
                        animated: false,
                        disableBackGesture: disableBackGestureForNextPush
                    )
                } label: {
                    Label("Push next (not animated)", systemImage: "arrow.right.to.line")
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .buttonStyle(.bordered)

                Divider()

                Button {
                    navigator.pop()
                } label: {
                    Label("Pop", systemImage: "arrow.left")
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .buttonStyle(.bordered)

                Button {
                    navigator.popNonAnimated()
                } label: {
                    Label("Pop (not animated)", systemImage: "arrow.left.to.line")
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .buttonStyle(.bordered)

                Button {
                    navigator.pop(levels: 2)
                } label: {
                    Label("Pop 2 levels", systemImage: "arrow.uturn.left.circle")
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .buttonStyle(.bordered)

                Button {
                    navigator.popToRoot()
                } label: {
                    Label("Pop to root", systemImage: "house")
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .buttonStyle(.bordered)

                Spacer(minLength: 24)
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 24)
        }
        .topNavigationBarTitle("Navigation")
        .topNavigationBarSubtitle("Level \(level)")
        .topNavigationBarHidesBackButton(hidesBackButton)
        .topNavigationBarTrailingPrimary(id: "pushAgain", updateKey: disableBackGestureForNextPush) {
            Button {
                navigator.push(
                    route: CatalogRoute.navigationActions(level: level + 1),
                    animated: true,
                    disableBackGesture: disableBackGestureForNextPush
                )
            } label: {
                Image(systemName: disableBackGestureForNextPush ? "hand.raised.slash" : "hand.raised")
                    .font(.title3)
                    .accessibilityLabel("Push next")
            }
            .buttonStyle(.plain)
        }
    }
}

private struct DisableBackGestureDemoScreen: View {
    @EnvironmentObject private var navigator: Navigator

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Interactive swipe-back is disabled for this screen.")
                .font(.title2.weight(.semibold))
            Text("Use the back button (tap) or the actions in the nav bar to leave.")
                .foregroundStyle(.secondary)
            Spacer()
        }
        .padding(16)
        .topNavigationBarTitle("Back Gesture")
        .topNavigationBarSubtitle("Disabled on this screen")
        .topNavigationBarTrailing(id: "pop", position: .secondary) {
            Button("Back") {
                navigator.pop()
            }
            .font(.headline)
        }
        .topNavigationBarTrailingPrimary(id: "toRoot") {
            Button("Root") {
                navigator.popToRoot()
            }
            .font(.headline)
        }
    }
}

private struct ScrollOpacityDemoScreen: View {
    var body: some View {
        OffsetObservingScrollView {
            VStack(spacing: 16) {
                HeroHeader(
                    title: "Scroll-Dependent Background",
                    subtitle: "Scroll down to make the bar background appear"
                )
                ForEach(0..<40) { idx in
                    Text("Row \(idx + 1)")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.vertical, 10)
                        .padding(.horizontal, 12)
                        .background(RoundedRectangle(cornerRadius: 12).fill(Color(uiColor: .secondarySystemBackground)))
                        .padding(.horizontal, 16)
                }
                .padding(.bottom, 24)
            }
        }
        .topNavigationBarTitle("Scroll")
        .topNavigationBarSubtitle("PositionObservingViewPreferenceKey")
    }
}

private struct ComposeScreen: View {
    @EnvironmentObject private var navigator: Navigator
    @State private var text = ""

    var body: some View {
        OffsetObservingScrollView {
            VStack(alignment: .leading, spacing: 12) {
                Text("Compose")
                    .font(.title2.weight(.semibold))
                    .padding(.top, 12)

                TextEditor(text: $text)
                    .frame(minHeight: 180)
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(.quaternary))

                Text("Back button is intentionally hidden on this screen, so the user must take an explicit action.")
                    .foregroundStyle(.secondary)

                Spacer(minLength: 24)
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 24)
        }
        .topNavigationBarTitle("New Message")
        .topNavigationBarSubtitle("Back is hidden")
        .topNavigationBarHidesBackButton(true)
        .topNavigationBarTrailing(id: "cancel", position: .secondary) {
            Button("Cancel") {
                navigator.pop()
            }
            .font(.headline)
        }
        .topNavigationBarTrailingPrimary(id: "send") {
            Button("Send") {
                navigator.pop()
            }
            .font(.headline)
        }
    }
}

private struct AboutScreen: View {
    var body: some View {
        OffsetObservingScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Sample goals")
                    .font(.title2.weight(.semibold))
                    .padding(.top, 12)

                BulletList(items: [
                    "Show all public APIs: NavigationShell, Navigator, top bar modifiers, visibility API, scroll hook.",
                    "All buttons are functional (no placeholder actions).",
                    "Demonstrate update edge cases for bar items (`id` + `updateKey`).",
                    "Demonstrate scroll-dependent background using PositionObservingViewPreferenceKey.",
                    "Demonstrate stack-wide tint via `TopNavigationBarConfiguration.tintColor`.",
                    "Demonstrate navigation stack restoration via `RestorableNavigationShell` + `navigator.push(route:)`."
                ])

                Text("Notes")
                    .font(.headline)

                Text("The scroll hook preference key is intentionally written by a single dedicated scroll wrapper per screen. If you add multiple emitters in the same subtree, define merge semantics in the preference key reduce.")
                    .foregroundStyle(.secondary)

                Text("The Catalog tab is hosted by RestorableNavigationShell. Push a few screens, terminate the app, and relaunch to verify the stack is restored.")
                    .foregroundStyle(.secondary)

                Spacer(minLength: 24)
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 24)
        }
        .topNavigationBarTitle("About")
        .topNavigationBarSubtitle("Sample guidance")
    }
}

// MARK: - Playground model

private struct NavBarPlaygroundState: Equatable {
    enum BackgroundStyle: CaseIterable { case material; case color
        var title: String { self == .material ? "Material" : "Color" }
    }

    enum MaterialStyle: CaseIterable { case ultraThin, thin, regular, thick, ultraThick
        var title: String {
            switch self {
            case .ultraThin: "Ultra Thin"
            case .thin: "Thin"
            case .regular: "Regular"
            case .thick: "Thick"
            case .ultraThick: "Ultra Thick"
            }
        }
        var material: Material {
            switch self {
            case .ultraThin: .ultraThin
            case .thin: .thin
            case .regular: .regular
            case .thick: .thick
            case .ultraThick: .ultraThick
            }
        }
    }

    enum ColorStyle: CaseIterable { case system; case secondarySystem; case red; case blue; case green; case orange; case purple
        var title: String {
            switch self {
            case .system: "System"
            case .secondarySystem: "Secondary"
            case .red: "Red"
            case .blue: "Blue"
            case .green: "Green"
            case .orange: "Orange"
            case .purple: "Purple"
            }
        }
        var color: Color? {
            switch self {
            case .system: nil
            case .secondarySystem: Color(uiColor: .secondarySystemBackground)
            case .red: .red
            case .blue: .blue
            case .green: .green
            case .orange: .orange
            case .purple: .purple
            }
        }
    }

    enum FontStyle: CaseIterable { case systemDefault; case headline; case title3; case body; case footnote; case caption
        var title: String {
            switch self {
            case .systemDefault: "System Default"
            case .headline: "Headline"
            case .title3: "Title 3"
            case .body: "Body"
            case .footnote: "Footnote"
            case .caption: "Caption"
            }
        }
        var font: Font? {
            switch self {
            case .systemDefault: nil
            case .headline: .headline
            case .title3: .title3
            case .body: .body
            case .footnote: .footnote
            case .caption: .caption
            }
        }
    }

    enum WeightStyle: CaseIterable { case systemDefault; case regular; case medium; case semibold; case bold
        var title: String {
            switch self {
            case .systemDefault: "System Default"
            case .regular: "Regular"
            case .medium: "Medium"
            case .semibold: "Semibold"
            case .bold: "Bold"
            }
        }
        var weight: Font.Weight? {
            switch self {
            case .systemDefault: nil
            case .regular: .regular
            case .medium: .medium
            case .semibold: .semibold
            case .bold: .bold
            }
        }
    }

    enum SpacingStyle: CaseIterable { case systemDefault; case compact; case iOSLike; case relaxed
        var title: String {
            switch self {
            case .systemDefault: "Default"
            case .compact: "Compact (0)"
            case .iOSLike: "iOS-like (2)"
            case .relaxed: "Relaxed (8)"
            }
        }
        var spacing: CGFloat? {
            switch self {
            case .systemDefault: nil
            case .compact: 0
            case .iOSLike: 2
            case .relaxed: 8
            }
        }
    }

    enum BackIconStyle: CaseIterable { case arrowLeft; case chevronLeft; case xmark
        var title: String {
            switch self {
            case .arrowLeft: "arrow.left"
            case .chevronLeft: "chevron.left"
            case .xmark: "xmark"
            }
        }
        var symbolName: String {
            switch self {
            case .arrowLeft: "arrow.left"
            case .chevronLeft: "chevron.left"
            case .xmark: "xmark"
            }
        }
    }

    var backgroundStyle: BackgroundStyle = .material
    var materialStyle: MaterialStyle = .regular
    var colorStyle: ColorStyle = .secondarySystem
    var scrollDependentBackgroundOpacity = true
    var showsDivider = true

    var titleFontStyle: FontStyle = .systemDefault
    var titleWeightStyle: WeightStyle = .systemDefault
    var titleColorStyle: ColorStyle = .system

    var subtitleFontStyle: FontStyle = .systemDefault
    var subtitleWeightStyle: WeightStyle = .systemDefault
    var subtitleColorStyle: ColorStyle = .system

    var titleStackSpacingStyle: SpacingStyle = .systemDefault
    var tintStyle: ColorStyle = .system

    var usesCustomBackIcon = false
    var backIconStyle: BackIconStyle = .arrowLeft

    var summary: String {
        "\(backgroundStyle.title) • \(scrollDependentBackgroundOpacity ? "Scroll opacity" : "Always opaque")"
    }

    var configuration: TopNavigationBarConfiguration {
        let dividerColor: Color? = showsDivider ? Color.gray.opacity(0.5) : nil
        let tintColor: Color? = tintStyle.color
        let backIcon: TopNavigationBarConfiguration.BackButtonIconResource? =
            usesCustomBackIcon ? .init(name: backIconStyle.symbolName) : nil

        if backgroundStyle == .material {
            return TopNavigationBarConfiguration(
                backgroundMaterial: materialStyle.material,
                scrollDependentBackgroundOpacity: scrollDependentBackgroundOpacity,
                dividerColor: dividerColor,
                titleFont: titleFontStyle.font,
                titleFontColor: titleColorStyle.color,
                subtitleFont: subtitleFontStyle.font,
                subtitleFontColor: subtitleColorStyle.color,
                titleFontWeight: titleWeightStyle.weight,
                subtitleFontWeight: subtitleWeightStyle.weight,
                titleStackSpacing: titleStackSpacingStyle.spacing,
                tintColor: tintColor,
                backButtonIcon: backIcon
            )
        }

        return TopNavigationBarConfiguration(
            backgroundColor: colorStyle.color ?? Color(uiColor: .systemBackground),
            scrollDependentBackgroundOpacity: scrollDependentBackgroundOpacity,
            dividerColor: dividerColor,
            titleFont: titleFontStyle.font,
            titleFontColor: titleColorStyle.color,
            subtitleFont: subtitleFontStyle.font,
            subtitleFontColor: subtitleColorStyle.color,
            titleFontWeight: titleWeightStyle.weight,
            subtitleFontWeight: subtitleWeightStyle.weight,
            titleStackSpacing: titleStackSpacingStyle.spacing,
            tintColor: tintColor,
            backButtonIcon: backIcon
        )
    }
}

// MARK: - Shared UI

private struct OffsetObservingScrollView<Content: View>: View {
    let content: () -> Content

    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }

    var body: some View {
        ScrollView {
            content()
                .background(
                    GeometryReader { proxy in
                        Color.clear.preference(
                            key: PositionObservingViewPreferenceKey.self,
                            value: CGPoint(x: 0, y: proxy.frame(in: .named("scroll")).minY)
                        )
                    }
                )
        }
        .coordinateSpace(name: "scroll")
    }
}

private struct DemoSection<Content: View>: View {
    let title: String
    let content: () -> Content

    init(title: String, @ViewBuilder content: @escaping () -> Content) {
        self.title = title
        self.content = content
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.headline)
                .padding(.horizontal, 16)

            VStack(spacing: 10) {
                content()
            }
            .padding(.horizontal, 16)
        }
    }
}

private struct DemoRow: View {
    let title: String
    let subtitle: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(alignment: .top, spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title).font(.headline)
                    Text(subtitle).font(.subheadline).foregroundStyle(.secondary)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundStyle(.tertiary)
                    .padding(.top, 2)
            }
            .padding(12)
            .background(RoundedRectangle(cornerRadius: 12).fill(Color(uiColor: .secondarySystemBackground)))
        }
        .buttonStyle(.plain)
    }
}

private struct HeroHeader: View {
    let title: String
    let subtitle: String

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            LinearGradient(
                colors: [.blue.opacity(0.45), .purple.opacity(0.45)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .frame(height: 180)
            .clipShape(RoundedRectangle(cornerRadius: 20))

            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.largeTitle.weight(.bold))
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.9))
            }
            .padding(16)
            .foregroundStyle(.white)
        }
        .padding(.horizontal, 16)
        .padding(.top, 12)
    }
}

private struct BadgeIcon: View {
    let systemName: String
    let count: Int

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Image(systemName: systemName)
                .font(.title3)
                .padding(.trailing, 1)

            if count > 0 {
                Text("\(min(count, 99))")
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 5)
                    .padding(.vertical, 2)
                    .background(Capsule().fill(Color.red))
                    .offset(x: 8, y: -6)
                    .accessibilityLabel("\(count) notifications")
            }
        }
    }
}

private struct BulletList: View {
    let items: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(items, id: \.self) { item in
                HStack(alignment: .top, spacing: 8) {
                    Text("•")
                        .font(.body.weight(.semibold))
                    Text(item)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
}
