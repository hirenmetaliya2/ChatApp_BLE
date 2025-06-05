//
//  DiscoveredUser.swift
//  ChatApp
//
//  Created by Hiren Metaliya on 29/05/25.
//

import Foundation
import CoreBluetooth

struct DiscoveredUser: Hashable, Identifiable {
    let id: UUID
    let peripheral: CBPeripheral?
    let name: String
    let lastSeen: Date
}
