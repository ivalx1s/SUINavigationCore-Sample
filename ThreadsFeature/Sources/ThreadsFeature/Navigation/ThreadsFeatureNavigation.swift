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
    /// Registers all destinations owned by this feature module.
    ///
    /// This includes:
    /// - a module-scoped router enum (`ThreadsRoute`) rendered via `switch`
    /// - per-screen route payload types (`ThreadDetailsRoute`, ...)
    /// - a split router enum (`ThreadsComposerRoute`)
    public static let destinations = NavigationDestinations { registry in
        // Option 3: module-scoped enum route.
        registry.register(ThreadsRoute.self) { route in
            destination(for: route)
        }

        // Option 4: per-screen route payload types (unique keys per screen).
        registry.register(ThreadsInboxRoute.self) { _ in
            ThreadsInboxScreen(source: .perScreenRoute)
        }
        registry.register(ThreadDetailsRoute.self) { route in
            ThreadDetailsScreen(id: route.id)
        }
        registry.register(ThreadComposeRoute.self) { route in
            ThreadComposeScreen(draftID: route.draftID, source: .perScreenRoute)
        }
        registry.register(ThreadsSettingsRoute.self) { _ in
            ThreadsSettingsScreen()
        }

        // Split router enum: demonstrates multiple enums owned by one feature module.
        registry.register(ThreadsComposerRoute.self) { route in
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
