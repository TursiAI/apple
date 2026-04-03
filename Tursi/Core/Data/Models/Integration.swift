import Foundation

public struct Integration: Identifiable, Codable {
    public let id: String                 // "gmail", "web-search", etc.
    public var displayName: String
    public var icon: String               // SF Symbol name
    public var isEnabled: Bool
    public var permissionLevel: PermissionLevel
    public var mcpEndpoint: MCPEndpoint
    public var authState: AuthState

    public init(
        id: String,
        displayName: String,
        icon: String,
        isEnabled: Bool = false,
        permissionLevel: PermissionLevel = .askEveryTime,
        mcpEndpoint: MCPEndpoint = .builtIn,
        authState: AuthState = .none
    ) {
        self.id = id
        self.displayName = displayName
        self.icon = icon
        self.isEnabled = isEnabled
        self.permissionLevel = permissionLevel
        self.mcpEndpoint = mcpEndpoint
        self.authState = authState
    }
}

public enum PermissionLevel: String, Codable {
    public case askEveryTime
    public case allowAlways
}

public enum MCPEndpoint: Codable {
    public case builtIn
    public case local(path: String)
    public case remote(url: URL)
}

public enum AuthState: String, Codable {
    public case none          // no auth needed
    public case required      // needs auth, not yet done
    public case authenticated // auth complete
}
