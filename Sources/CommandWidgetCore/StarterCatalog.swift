import CryptoKit
import Foundation

public enum StarterCatalog {
    public static let currentVersion = 4

    public static let entries: [CommandEntry] = CommandOrdering.normalized(
        KubernetesCatalog.entries
            + HelmCatalog.entries
            + FluxCatalog.entries
            + LinuxCatalog.entries
            + AnsibleCatalog.entries
            + TerraformCatalog.entries
            + OllamaCatalog.entries
            + CrowdSecCatalog.entries
            + MattermostCatalog.entries
            + GitCatalog.entries
    )
}

enum BundledCatalogEntry {
    static func make(
        _ title: String,
        _ command: String,
        _ category: CommandCategory,
        _ tags: [String],
        _ summary: String,
        _ details: String,
        _ examples: [String],
        bundledVersion: Int = 1
    ) -> CommandEntry {
        CommandEntry(
            id: stableID(for: "\(category.rawValue):\(title)", bundledVersion: bundledVersion),
            title: title,
            command: command,
            category: category,
            tags: tags,
            summary: summary,
            details: details,
            examples: examples,
            modifiedAt: Date(timeIntervalSince1970: 0),
            bundledVersion: bundledVersion
        )
    }

    private static func stableID(for value: String, bundledVersion: Int) -> UUID {
        if bundledVersion > 1 {
            return hashedStableID(for: value)
        }

        var bytes = Array(value.utf8.prefix(16))
        bytes.append(contentsOf: repeatElement(0, count: max(0, 16 - bytes.count)))
        bytes[6] = (bytes[6] & 0x0F) | 0x40
        bytes[8] = (bytes[8] & 0x3F) | 0x80
        return uuid(from: bytes)
    }

    private static func hashedStableID(for value: String) -> UUID {
        var bytes = Array(SHA256.hash(data: Data(value.utf8)).prefix(16))
        bytes[6] = (bytes[6] & 0x0F) | 0x40
        bytes[8] = (bytes[8] & 0x3F) | 0x80
        return uuid(from: bytes)
    }

    private static func uuid(from bytes: [UInt8]) -> UUID {
        UUID(uuid: (
            bytes[0], bytes[1], bytes[2], bytes[3],
            bytes[4], bytes[5], bytes[6], bytes[7],
            bytes[8], bytes[9], bytes[10], bytes[11],
            bytes[12], bytes[13], bytes[14], bytes[15]
        ))
    }
}
