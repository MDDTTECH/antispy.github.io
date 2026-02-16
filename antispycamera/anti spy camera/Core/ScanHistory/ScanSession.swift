import Foundation

/// A model representing a single network scan session.
/// Stores the devices discovered during the scan, the timestamp, duration and optional network information.
public struct ScanSession: Identifiable, Codable, Equatable {
    public let id: UUID

    /// Date of the scan. Encoded/decoded as an ISO8601 string for JSON-friendliness.
    public let date: Date

    /// Devices discovered during the scan. Reuses `NetworkDevice` from WiFiScannerStore.swift
    public let devices: [NetworkDevice]

    /// Human-readable summary of the scan. If `nil` when initializing, it's computed from devices.
    public let summary: String?

    /// Duration of the scan in seconds.
    public let duration: TimeInterval

    /// Optional network information (SSID, BSSID, gateway etc.)
    public let networkInfo: WiFiNetworkInfo?

    // MARK: - Init

    public init(
        id: UUID = UUID(),
        date: Date = Date(),
        devices: [NetworkDevice],
        summary: String? = nil,
        duration: TimeInterval = 0,
        networkInfo: WiFiNetworkInfo? = nil
    ) {
        self.id = id
        self.date = date
        self.devices = devices
        self.summary = summary ?? ScanSession.generateSummary(for: devices)
        self.duration = duration
        self.networkInfo = networkInfo
    }

    // MARK: - Summary Helper

    /// Generates a compact summary describing the number of devices and the highest threat level found.
    /// Example: "3 devices, highest threat: 8"
    public static func generateSummary(for devices: [NetworkDevice]) -> String {
        let count = devices.count
        let highestThreat = devices.map { $0.threatLevel }.max() ?? 0
        if count == 0 {
            return "No devices found"
        }
        return "\(count) device\(count == 1 ? "" : "s"), highest threat: \(highestThreat)"
    }

    // MARK: - Codable (custom Date formatting)

    enum CodingKeys: String, CodingKey {
        case id
        case date
        case devices
        case summary
        case duration
        case networkInfo
    }

    // Use ISO8601 string representation for Date to be JSON-friendly and human readable.
    private static let iso8601Formatter: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return f
    }()

    /// Internal codable representation for WiFiNetworkInfo because the original WiFiNetworkInfo in the scanner is not Codable.
    private struct CodableNetworkInfo: Codable {
        let ssid: String
        let bssid: String
        let ipRange: String
        let gateway: String
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(UUID.self, forKey: .id)

        // Decode date from ISO8601 string, timestamp double, or as Date fallback
        if let dateString = try? container.decode(String.self, forKey: .date),
           let d = ScanSession.iso8601Formatter.date(from: dateString) {
            self.date = d
        } else if let timestamp = try? container.decode(Double.self, forKey: .date) {
            self.date = Date(timeIntervalSince1970: timestamp)
        } else {
            self.date = try container.decode(Date.self, forKey: .date)
        }

        self.devices = try container.decode([NetworkDevice].self, forKey: .devices)
        self.summary = try container.decodeIfPresent(String.self, forKey: .summary)
        self.duration = try container.decode(TimeInterval.self, forKey: .duration)

        if let wrapped = try container.decodeIfPresent(CodableNetworkInfo.self, forKey: .networkInfo) {
            self.networkInfo = WiFiNetworkInfo(ssid: wrapped.ssid, bssid: wrapped.bssid, ipRange: wrapped.ipRange, gateway: wrapped.gateway)
        } else {
            self.networkInfo = nil
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        let dateString = ScanSession.iso8601Formatter.string(from: date)
        try container.encode(dateString, forKey: .date)
        try container.encode(devices, forKey: .devices)
        try container.encodeIfPresent(summary, forKey: .summary)
        try container.encode(duration, forKey: .duration)

        if let networkInfo = networkInfo {
            let wrapped = CodableNetworkInfo(ssid: networkInfo.ssid, bssid: networkInfo.bssid, ipRange: networkInfo.ipRange, gateway: networkInfo.gateway)
            try container.encode(wrapped, forKey: .networkInfo)
        }
    }

    // Provide custom Equatable because NetworkDevice does not declare Equatable in the scanner file.
    public static func == (lhs: ScanSession, rhs: ScanSession) -> Bool {
        return lhs.id == rhs.id
            && lhs.date == rhs.date
            && lhs.devices.map({ $0.id }) == rhs.devices.map({ $0.id })
            && lhs.summary == rhs.summary
            && lhs.duration == rhs.duration
            && areNetworkInfosEqual(lhs.networkInfo, rhs.networkInfo)
    }

    private static func areNetworkInfosEqual(_ a: WiFiNetworkInfo?, _ b: WiFiNetworkInfo?) -> Bool {
        switch (a, b) {
        case (nil, nil): return true
        case (let x?, let y?): return x.ssid == y.ssid && x.bssid == y.bssid && x.ipRange == y.ipRange && x.gateway == y.gateway
        default: return false
        }
    }
}
