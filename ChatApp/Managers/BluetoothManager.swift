//
//  BluetoothManager.swift
//  ChatApp
//
//  Created by Hiren Metaliya on 28/05/25.
//

import Foundation
import CoreBluetooth

class BluetoothManager: NSObject, CBCentralManagerDelegate, ObservableObject, CBPeripheralManagerDelegate {
    
    
    
    
    @Published var isBluetoothEnabled: Bool = false
    @Published var discoveredPeripherals = [CBPeripheral]()
    @Published var discoveredUsers : [DiscoveredUser] = []
    
    private var centralManager: CBCentralManager!
    private var scanTimer: Timer?
    let serviceUUID = CBUUID(string: "A1B2C3D4-E5F6-1234-5678-9ABCDEF01234")

    
    //timeout to consider device out of range
    private let deviceTimeout: TimeInterval = 10
    
    
    
    private var peripheralManager: CBPeripheralManager!
    
    var userName: String = "Jeet"
    var imageData: Data? = nil
    
    
    func startAdvertising(){
        
        let advertisementData: [String: Any] = [
            CBAdvertisementDataServiceUUIDsKey: [serviceUUID],
            CBAdvertisementDataLocalNameKey: userName,
            ]
        
        peripheralManager.startAdvertising(advertisementData)
    }
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        if peripheral.state == .poweredOn {
            startAdvertising()
        }
    }

    
    override init() {
        super.init()
        self.centralManager = CBCentralManager(delegate: self, queue: .main)
        self.peripheralManager = CBPeripheralManager(delegate: self, queue: .main)
    }
    
    
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            startAdvertising()
            isBluetoothEnabled = true
            startScanning()
        } else{
            isBluetoothEnabled = false
            stopScanning()
        }
    }
    
    func startScanning() {
        centralManager.scanForPeripherals(withServices: [serviceUUID], options: nil)
        
        scanTimer = Timer.scheduledTimer(withTimeInterval: 3, repeats: true){ [weak self] _ in
            self?.removeTimedOutDevices()
            
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
            }else{
                let newUser = DiscoveredUser(id: id, peripheral: peripheral, name: name, lastSeen: now)
                
                self.discoveredUsers.append(newUser)
            }
        }
    }
    
    private func removeTimedOutDevices(){
        let now = Date()
        let filtered = discoveredUsers.filter{ now.timeIntervalSince($0.lastSeen) < deviceTimeout}
        if filtered.count != discoveredUsers.count{
            DispatchQueue.main.async {
                self.discoveredUsers = filtered
            }
        }
    }   
    deinit{
        stopScanning()
    }
}
