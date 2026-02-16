import XCTest
@testable import `anti spy camera`

final class ScanSessionCodableTests: XCTestCase {

    func testScanSessionEncodeDecode_roundtrip() throws {
        // Prepare sample network devices
        let now = Date()
        let device1 = NetworkDevice(
            id: UUID(),
            ipAddress: "192.168.1.10",
            macAddress: "AA:BB:CC:DD:EE:FF",
            manufacturer: "Hikvision",
            deviceName: "IPCam-01",
            openPorts: [80, 554],
            services: ["http", "rtsp"],
            signalStrength: -40,
            lastSeen: now,
            trafficPattern: TrafficAnalysis(uploadRate: 0.5, downloadRate: 0.1, isConstantUpload: true, peakHours: [12,13])
        )

        let device2 = NetworkDevice(
            id: UUID(),
            ipAddress: "192.168.1.20",
            macAddress: nil,
            manufacturer: "Apple",
            deviceName: "iPhone",
            openPorts: [80],
            services: ["http"],
            signalStrength: -55,
            lastSeen: now,
            trafficPattern: nil
        )

        let networkInfo = WiFiNetworkInfo(ssid: "HomeNet", bssid: "11:22:33:44:55:66", ipRange: "192.168.1.0/24", gateway: "192.168.1.1")

        let session = ScanSession(
            id: UUID(),
            date: now,
            devices: [device1, device2],
            summary: nil,
            duration: 12.5,
            networkInfo: networkInfo
        )

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]

        let data = try encoder.encode(session)
        // Decode back
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(ScanSession.self, from: data)

        // Assert basic properties equal
        XCTAssertEqual(session.id, decoded.id)
        XCTAssertEqual(Int(session.date.timeIntervalSince1970), Int(decoded.date.timeIntervalSince1970))
        XCTAssertEqual(session.devices.count, decoded.devices.count)
        XCTAssertEqual(session.summary, decoded.summary)
        XCTAssertEqual(session.duration, decoded.duration)
        XCTAssertEqual(session.networkInfo?.ssid, decoded.networkInfo?.ssid)
        XCTAssertEqual(session.networkInfo?.bssid, decoded.networkInfo?.bssid)
        XCTAssertEqual(session.networkInfo?.gateway, decoded.networkInfo?.gateway)
    }
}
