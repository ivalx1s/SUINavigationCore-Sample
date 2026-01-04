import Foundation
import SUINavigationFusion

// MARK: - Option 3 (module-scoped enum route)

/// An example of a "module-scoped router enum":
/// the feature owns a single route type and renders destinations via an exhaustive `switch`.
///
/// This is ergonomic (similar to SwiftUI's `NavigationStack` + `navigationDestination(for:)`) and keeps routing logic
/// encapsulated inside the feature module.
public enum ThreadsRoute: NavigationRoute {
    case inbox
    case thread(id: String)
    case compose(ComposeContext)
    case settings

    /// Nested payload used by a route case to demonstrate "route composition".
    public struct ComposeContext: Codable, Hashable, Sendable {
        public var draftID: String?

        public init(draftID: String? = nil) {
            self.draftID = draftID
        }
    }
}

// MARK: - Option 4 (per-screen route payload types)

/// Per-screen route payload type.
///
/// Registering each screen as its own payload type allows using a unique destination key per screen.
public struct ThreadsInboxRoute: NavigationRoute {
    public init() {}
}

/// Per-screen route payload type.
public struct ThreadDetailsRoute: NavigationRoute {
    public let id: String

    public init(id: String) {
        self.id = id
    }
}

/// Per-screen route payload type.
public struct ThreadComposeRoute: NavigationRoute {
    public var draftID: String?

    public init(draftID: String? = nil) {
        self.draftID = draftID
    }
}

/// Per-screen route payload type.
public struct ThreadsSettingsRoute: NavigationRoute {
    public init() {}
}

// MARK: - Split router enum (multiple enums owned by the same feature)

/// An example of splitting routing into multiple enums inside one feature module.
///
/// You may choose this when a feature has multiple independent sub-flows, and you want each to evolve separately.
public enum ThreadsComposerRoute: NavigationRoute {
    case compose(draftID: String?)
}

