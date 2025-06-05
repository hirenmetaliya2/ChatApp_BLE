import Foundation
import CoreBluetooth
import SwiftUI

class BluetoothManager: NSObject, CBCentralManagerDelegate, ObservableObject, CBPeripheralManagerDelegate, CBPeripheralDelegate {
    @Published var isBluetoothEnabled: Bool = false
    @Published var discoveredPeripherals = [CBPeripheral]()
    @Published var discoveredUsers: [DiscoveredUser] = []
    @Published var receivedMessages: [Message] = []
    
    private var centralManager: CBCentralManager!
    private var scanTimer: Timer?
    let serviceUUID = CBUUID(string: "A1B2C3D4-E5F6-1234-5678-9ABCDEF01234")
    
    //message
    let messageCharacteristicID = CBUUID(string: "abc83144-c59b-4bd9-aa74-cf616cc05293")
    private var messageCharacteristic: CBMutableCharacteristic!
    
    //connection and communication
    private var connectedPeripheral: CBPeripheral?
    private var discoveredCharacteristic: CBCharacteristic?
    
    //timeout to consider device out of range
    private let deviceTimeout: TimeInterval = 10
    
    private var peripheralManager: CBPeripheralManager!
    
    var userName: String = "Hiren"
    var imageData: Data? = nil
    
    override init() {
        super.init()
        self.centralManager = CBCentralManager(delegate: self, queue: .main)
        self.peripheralManager = CBPeripheralManager(delegate: self, queue: .main)
    }
    
    func startAdvertising() {
        let advertisementData: [String: Any] = [
            CBAdvertisementDataServiceUUIDsKey: [serviceUUID],
            CBAdvertisementDataLocalNameKey: userName,
        ]
        
        peripheralManager.startAdvertising(advertisementData)
    }
    
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        if peripheral.state == .poweredOn {
            setupPeripheralService()
            startAdvertising()
        }
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveWrite requests: [CBATTRequest]) {
        for request in requests {
            if request.characteristic.uuid == messageCharacteristicID,
               let value = request.value,
               let messageText = String(data: value, encoding: .utf8) {
                print("📩 Received message: \(messageText)")
                let message = Message(text: messageText, senderID: "remote")
                DispatchQueue.main.async {
                    self.receivedMessages.append(message)
                }
            }
            peripheral.respond(to: request, withResult: .success)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if characteristic.uuid == messageCharacteristicID,
           let value = characteristic.value,
           let messageText = String(data: value, encoding: .utf8) {
            print("📩 Received message via notification: \(messageText)")
            let message = Message(text: messageText, senderID: "remote")
            DispatchQueue.main.async {
                self.receivedMessages.append(message)
            }
        }
    }
    
    private func setupPeripheralService() {
        messageCharacteristic = CBMutableCharacteristic(
            type: messageCharacteristicID,
            properties: [.read, .write, .notify],
            value: nil,
            permissions: [.readable, .writeable]
        )
        
        let service = CBMutableService(type: serviceUUID, primary: true)
        service.characteristics = [messageCharacteristic]
        
        peripheralManager.add(service)
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            startAdvertising()
            isBluetoothEnabled = true
            startScanning()
        } else {
            isBluetoothEnabled = false
            stopScanning()
        }
    }
    
    func startScanning() {
        centralManager.stopScan()
        centralManager.scanForPeripherals(withServices: [serviceUUID], options: nil)
        scanTimer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.centralManager.stopScan()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.centralManager.scanForPeripherals(withServices: [self.serviceUUID], options: nil)
            }
            self.removeTimedOutDevices()
        }
    }
    
    func stopScanning() {
        centralManager.stopScan()
        scanTimer?.invalidate()
        scanTimer = nil
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        let id = peripheral.identifier
        let name = (advertisementData[CBAdvertisementDataLocalNameKey] as? String) ?? "Unknown Device"
        let now = Date()
        
        DispatchQueue.main.async {
            if let index = self.discoveredUsers.firstIndex(where: {$0.id == id}) {
                self.discoveredUsers[index] = DiscoveredUser(id: id, peripheral: peripheral, name: name, lastSeen: now)
            } else {
                let newUser = DiscoveredUser(id: id, peripheral: peripheral, name: name, lastSeen: now)
                self.discoveredUsers.append(newUser)
            }
        }
        
        central.connect(peripheral, options: nil)
        connectedPeripheral = peripheral
        peripheral.delegate = self
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        peripheral.delegate = self
        peripheral.discoverServices([serviceUUID])
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else { return }
        for service in services where service.uuid == serviceUUID {
            peripheral.discoverCharacteristics([messageCharacteristicID], for: service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: (any Error)?) {
        guard let characteristics = service.characteristics else { return }
        for characteristic in characteristics where characteristic.uuid == messageCharacteristicID {
            discoveredCharacteristic = characteristic
            peripheral.setNotifyValue(true, for: characteristic)
            print("Ready to send and receive messages")
        }
    }
    
    func sendMessage(_ message: Message) {
        guard let peripheral = connectedPeripheral,
              let characteristic = discoveredCharacteristic else { 
            print("❌ Cannot send message: No connected peripheral or characteristic")
            return 
        }
        
        if let data = message.text.data(using: .utf8) {
            print("📤 Sending message: \(message.text)")
            peripheral.writeValue(data, for: characteristic, type: .withResponse)
            DispatchQueue.main.async {
                self.receivedMessages.append(message)
            }
        }
    }
    
    private func removeTimedOutDevices() {
        let now = Date()
        let filtered = discoveredUsers.filter { now.timeIntervalSince($0.lastSeen) < deviceTimeout }
        if filtered.count != discoveredUsers.count {
            DispatchQueue.main.async {
                self.discoveredUsers = filtered
            }
        }
    }
    
    func toggleBluetooth() {
        if centralManager.state == .poweredOn {
            centralManager.stopScan()
            centralManager = nil
        } else {
            centralManager = CBCentralManager(delegate: self, queue: nil)
        }
    }
    
    deinit {
        stopScanning()
    }
}
