import SwiftUI
import SUINavigationFusion

/// Destination registrations exported by the Threads feature module.
///
/// The host app composes this bundle into its navigation stack configuration, allowing the feature module
/// to remain independent from any specific stack/container.
///
/// Note: `NavigationDestinations` is not `Sendable`, so expose static bundles from a `@MainActor` context.
@MainActor
public enum ThreadsFeatureNavigation {
    // Stable keys persisted in snapshots. Prefer explicit, namespaced strings.
    private static let threadsRouteKey: NavigationDestinationKey = "com.suinavigation.sample.threads.route"
    private static let inboxKey: NavigationDestinationKey = "com.suinavigation.sample.threads.inbox"
    private static let threadDetailsKey: NavigationDestinationKey = "com.suinavigation.sample.threads.thread"
    private static let composeKey: NavigationDestinationKey = "com.suinavigation.sample.threads.compose"
    private static let settingsKey: NavigationDestinationKey = "com.suinavigation.sample.threads.settings"
    private static let composerRouteKey: NavigationDestinationKey = "com.suinavigation.sample.threads.composerRoute"

    /// Registers all destinations owned by this feature module.
    ///
    /// This includes:
    /// - a module-scoped router enum (`ThreadsRoute`) rendered via `switch`
    /// - per-screen route payload types (`ThreadDetailsRoute`, ...)
    /// - a split router enum (`ThreadsComposerRoute`)
    public static let destinations = NavigationDestinations { registry in
        // Option 3: module-scoped enum route.
        registry.register(ThreadsRoute.self, key: threadsRouteKey) { route in
            destination(for: route)
        }

        // Option 4: per-screen route payload types (unique keys per screen).
        registry.register(ThreadsInboxRoute.self, key: inboxKey) { _ in
            ThreadsInboxScreen(source: .perScreenRoute)
        }
        registry.register(ThreadDetailsRoute.self, key: threadDetailsKey) { route in
            ThreadDetailsScreen(id: route.id)
        }
        registry.register(ThreadComposeRoute.self, key: composeKey) { route in
            ThreadComposeScreen(draftID: route.draftID, source: .perScreenRoute)
        }
        registry.register(ThreadsSettingsRoute.self, key: settingsKey) { _ in
            ThreadsSettingsScreen()
        }

        // Split router enum: demonstrates multiple enums owned by one feature module.
        registry.register(ThreadsComposerRoute.self, key: composerRouteKey) { route in
            destination(for: route)
        }
    }

    // MARK: - Module-owned destination switch (Option 3)

    @ViewBuilder
    private static func destination(for route: ThreadsRoute) -> some View {
        switch route {
        case .inbox:
            ThreadsInboxScreen(source: .enumRoute)
        case .thread(let id):
            ThreadDetailsScreen(id: id)
        case .compose(let context):
            ThreadComposeScreen(draftID: context.draftID, source: .enumRoute)
        case .settings:
            ThreadsSettingsScreen()
        }
    }

    // MARK: - Split router enum destination switch

    @ViewBuilder
    private static func destination(for route: ThreadsComposerRoute) -> some View {
        switch route {
        case .compose(let draftID):
            ThreadComposeScreen(draftID: draftID, source: .splitEnumRoute)
        }
    }
}

