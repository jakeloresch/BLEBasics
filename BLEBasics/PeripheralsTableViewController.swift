//
//  PeripheralsTableViewController.swift
// 
//
//  Created by Jack Rickard 7/24/16.
//  Copyright (c) 2016 Jack Rickard. All rights reserved.
//

import UIKit
import CoreBluetooth

struct Peripheral
{
    var peripheral: CBPeripheral
    var name: String?
    var UUID: String
    var RSSI: String
    var connectable = "No"
    
    init(peripheral: CBPeripheral, RSSI: String, advertisementDictionary: NSDictionary)
        {
            self.peripheral = peripheral
            name = peripheral.name ?? "No name."
            UUID = peripheral.identifier.uuidString
            self.RSSI = RSSI
            if let isConnectable = advertisementDictionary[CBAdvertisementDataIsConnectable] as? NSNumber
                {
                    connectable = (isConnectable.boolValue) ? "Yes" : "No"
                }
        }
}

class PeripheralsTableViewController: UITableViewController, CBCentralManagerDelegate
{
    var manager: CBCentralManager!
    var isBluetoothEnabled = false
    var visiblePeripheralUUIDs = NSMutableOrderedSet()
    var visiblePeripherals = [String: Peripheral]()
    var scanTimer: Timer?
    var connectionAttemptTimer: Timer?
    var connectedPeripheral: CBPeripheral?
    
    required init?(coder aDecoder: NSCoder)
        {
            super.init(coder: aDecoder)
            manager = CBCentralManager(delegate: self, queue: nil, options: [CBCentralManagerOptionShowPowerAlertKey: true])
        }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?)
        {
            super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
            manager = CBCentralManager(delegate: self, queue: nil, options: [CBCentralManagerOptionShowPowerAlertKey: true])
        }
    
    override func viewDidLoad()
        {
            super.viewDidLoad()
            tableView.delegate = self
            tableView.dataSource = self
        tableView.rowHeight = UITableView.automaticDimension
            tableView.estimatedRowHeight = 134
        self.refreshControl?.addTarget(self, action: #selector(PeripheralsTableViewController.startScanning), for: .valueChanged)
        }
    
    
    override func viewDidAppear(_ animated: Bool)
        {
        if isBluetoothEnabled
            {
                if let peripheral = connectedPeripheral
                    {
                        manager.cancelPeripheralConnection(peripheral)
                    }
            }
        }
    
    @objc func startScanning()
        {
            print("Started scanning.")
            visiblePeripheralUUIDs.removeAllObjects()
        visiblePeripherals.removeAll(keepingCapacity: true)
            tableView.reloadData()
        manager.scanForPeripherals(withServices: nil, options: nil)
        scanTimer = Timer.scheduledTimer(timeInterval: 40, target: self, selector: #selector(PeripheralsTableViewController.stopScanning), userInfo: nil, repeats: false)
        }
    
    @objc func stopScanning()
        {
            print("Stopped scanning.")
            print("Found \(visiblePeripherals.count) peripherals.")
            manager.stopScan()
            refreshControl?.endRefreshing()
            scanTimer?.invalidate()
        }
    
    
    @objc func timeoutPeripheralConnectionAttempt()
        {
            print("Peripheral connection attempt timed out.")
            if let connectedPeripheral = connectedPeripheral
                {
                    manager.cancelPeripheralConnection(connectedPeripheral)
                }
            connectionAttemptTimer?.invalidate()
        }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager)
        {
            var printString: String
            switch central.state
                {
            case .poweredOff:
                        printString = "Bluetooth hardware power off."
                        isBluetoothEnabled = false
            case .poweredOn:
                        printString = "Bluetooth hardware power on."
                        isBluetoothEnabled = true
                        startScanning()
            case .resetting:
                        printString = "Bluetooth hardware resetting."
                        isBluetoothEnabled = false
            case .unauthorized:
                        printString = "Bluetooth hardware unauthorized."
                        isBluetoothEnabled = false
            case .unsupported:
                        printString = "Bluetooth hardware not supported."
                        isBluetoothEnabled = false
            case .unknown:
                        printString = "Bluetooth hardware state unknown."
                        isBluetoothEnabled = false
                }
        
            print("State updated to: \(printString)")
        }
    
    
    func centralManager(central: CBCentralManager, didDiscoverPeripheral peripheral: CBPeripheral, advertisementData: [String : AnyObject], RSSI: NSNumber)
        {
        print("Peripheral found: \(String(describing: peripheral.name))\nUUID: \(peripheral.identifier.uuidString)\nRSSI: \(RSSI)\nAdvertisement Data: \(advertisementData)")
        visiblePeripheralUUIDs.add(peripheral.identifier.uuidString)
        visiblePeripherals[peripheral.identifier.uuidString] = Peripheral(peripheral: peripheral, RSSI: RSSI.stringValue, advertisementDictionary: advertisementData as NSDictionary)
            tableView.reloadData()
        }
    
    func centralManager(central: CBCentralManager, didConnectPeripheral peripheral: CBPeripheral)
    {
        print("Peripheral connected: \(peripheral.name ?? peripheral.identifier.uuidString)")
        connectionAttemptTimer?.invalidate()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let peripheralViewController = storyboard.instantiateViewController(withIdentifier: "PeripheralViewController") as! PeripheralViewController
        peripheralViewController.peripheral = peripheral
        navigationController?.pushViewController(peripheralViewController, animated: true)
    }
    
    
    func centralManager(central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: NSError?)
    {
        if peripheral != connectedPeripheral
            {
                print("Disconnected peripheral not currently connected.")
            }
        else
            {
                connectedPeripheral = nil
            }
        if let error = error
            {
                print("Failed to disconnect peripheral with error: \(error)")
            }
        else
            {
                print("Successfully disconnected peripheral: \(peripheral.name ?? peripheral.identifier.uuidString)")
            }
        
        if let selectedIndexPath = tableView.indexPathForSelectedRow
            {
               
            tableView.deselectRow(at: selectedIndexPath, animated: true)
            }
    }
    
    func centralManager(central: CBCentralManager, didFailToConnectPeripheral peripheral: CBPeripheral, error: NSError?)
    {
        print("Failed to connect peripheral: \(peripheral.name ?? peripheral.identifier.uuidString)\nBecause of error: \(String(describing: error))")
        connectedPeripheral = nil
        connectionAttemptTimer?.invalidate()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return visiblePeripherals.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
        {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PeripheralCell", for: indexPath as IndexPath) as! PeripheralTableViewCell
        
        if let visibleUUID = visiblePeripheralUUIDs[indexPath.row] as? String
            {
                if let visiblePeripheral = visiblePeripherals[visibleUUID]
                    {
                        if visiblePeripheral.connectable == "No"
                            {
                            cell.accessoryType = .none
                            }
                    cell.setupWithPeripheral(peripheral: visiblePeripheral)
                    }
            }

        return cell
        }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
       
        if let selectedUUID = visiblePeripheralUUIDs[indexPath.row] as? String, let selectedPeripheral = visiblePeripherals[selectedUUID]
            {
                if selectedPeripheral.connectable == "Yes"
                    {
                        connectedPeripheral = selectedPeripheral.peripheral
                    connectionAttemptTimer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(PeripheralsTableViewController.timeoutPeripheralConnectionAttempt), userInfo: nil, repeats: false)
                    manager.connect(connectedPeripheral!, options: nil)
                    }
            }
        
    }
}//end class
