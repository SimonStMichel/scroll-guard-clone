import Foundation

/// On/off state for each filter rule, persisted in `UserDefaults`.
///
/// Stores the *disabled* ids rather than the enabled ones, so rules added in
/// later versions default to enabled without any migration.
final class FilterSettings: ObservableObject {
    private static let defaultsKey = "sg.disabledFilterIDs"

    @Published private var disabledIDs: Set<String> {
        didSet {
            defaults.set(Array(disabledIDs).sorted(), forKey: Self.defaultsKey)
        }
    }

    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        disabledIDs = Set(defaults.stringArray(forKey: Self.defaultsKey) ?? [])
    }

    var enabledRules: [FilterRule] {
        FilterRule.all.filter { !disabledIDs.contains($0.id) }
    }

    func isEnabled(_ rule: FilterRule) -> Bool {
        !disabledIDs.contains(rule.id)
    }

    func setEnabled(_ enabled: Bool, for rule: FilterRule) {
        if enabled {
            disabledIDs.remove(rule.id)
        } else {
            disabledIDs.insert(rule.id)
        }
    }
}
