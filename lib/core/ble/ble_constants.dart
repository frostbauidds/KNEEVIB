// lib/core/ble/ble_constants.dart
// ---------------------------------------------------------------------------
// ALL BLE UUIDs and protocol strings are centralised here.
// TODO: Replace every UUID below with the actual firmware UUIDs before
//       connecting to real hardware.
// ---------------------------------------------------------------------------

/// The single BLE service exposed by the ESP32.
// TODO: match firmware
const String kBleServiceUuid = '4FAFC201-1FB5-459E-8FCC-C5C9C331914B';

/// Write characteristic: send UTF-8 command strings here.
// TODO: match firmware
const String kBleCommandCharUuid = 'BEB5483E-36E1-4688-B7F5-EA07361B26A8';

/// Notify characteristic: receives JSON status updates.
// TODO: match firmware
const String kBleStatusCharUuid = 'BEB5483F-36E1-4688-B7F5-EA07361B26A8';

/// Advertised device name the scanner looks for.
// TODO: match firmware
const String kBleDeviceName = 'KneeVib';

// ---------------------------------------------------------------------------
// Command strings (write to kBleCommandCharUuid)
// ---------------------------------------------------------------------------

/// Poll current device status.
const String kCmdStatus = 'STATUS';

/// Begin the 20-second calibration routine.
const String kCmdCal = 'CAL';

/// Start a recording session.
/// Format: 'START|<participantId>|<L or R>|<durationSeconds>'
/// Example: 'START|P001|L|120'
String kCmdStart(String participantId, String side, int durationSeconds) =>
    'START|$participantId|$side|$durationSeconds';

/// Enter Wi-Fi sync mode. Device will broadcast SSID/password in next status.
const String kCmdSync = 'SYNC';

// ---------------------------------------------------------------------------
// Device state strings (from Status JSON "state" field)
// ---------------------------------------------------------------------------
const String kStateIdle = 'IDLE';
const String kStateCalibrating = 'CALIBRATING';
const String kStateRecording = 'RECORDING';
const String kStateSaved = 'SAVED';
const String kStateSync = 'SYNC';

// ---------------------------------------------------------------------------
// Wi-Fi / hotspot API (ESP32 hosts at 192.168.4.1)
// ---------------------------------------------------------------------------
const String kHotspotBaseUrl = 'http://192.168.4.1';
const String kApiSessions = '/api/sessions';
String kApiSessionFile(String name, String file) =>
    '/api/sessions/$name/$file';
const String kApiDone = '/api/done';

/// Standard filenames inside a session folder on the SD card.
const String kFileVib = 'vib.bin';
const String kFileImu = 'imu.csv';
const String kFileMeta = 'meta.json';
