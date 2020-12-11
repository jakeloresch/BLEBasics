
//
//  charsTableViewController.swift
//  
//
//  Created by MARION JACK RICKARD on 8/2/16. blah not blah
//  Copyright © 2016 Jack Rickard. All rights reserved.
//

import UIKit
import Foundation
import CoreBluetooth

var NumericType: [String] = [
    "none",
    "Boolean",
    "unsigned 2-bit integer",
    "unsigned 4-bit integer",
    "unsigned 8-bit integer",
    "unsigned 12-bit integer",
    "unsigned 16-bit integer",
    "unsigned 24-bit integer",
    "unsigned 32-bit integer",
    "unsigned 48-bit integer",
    "unsigned 64-bit integer",
    "unsigned 128-bit integer",
    "signed 8-bit integer",
    "signed 12-bit integer",
    "signed 16-bit integer",
    "signed 24-bit integer",
    "signed 32-bit integer",
    "signed 48-bit integer",
    "signed 64-bit integer",
    "signed 128-bit integer",
    "IEEE-754 32-bit floating point",
    "IEEE-754 64-bit floating point",
    "IEEE-11073 16-bit SFLOAT",
    "IEEE-11073 32-bit FLOAT",
    "IEEE-20601 format",
    "UTF-8 string",
    "UTF-16 string",
    "Opaque Structure",]


var unitDefinitions: [UInt16: String] = [0x2700:" ",0x2701:"Meters",0x2702:"Kilograms",0x2703:"Seconds",0x2704:"Amperes",0x2705:"K",0x2706:"Moles",0x2707:"Candelas",0x2710:"m2",0x2711:"m3",0x2712:"m/s",0x2713:"m/s2",0x2714:"Wavenumber",0x2715:"kg/m3",0x2716:"kg/m2",0x2717:"m3/kg",0x2718:"A/m2",0x2719:"A/m",0x271A:"mol/m3",0x271B:"kg/m3",0x271C:"cd/m2",0x271D:"n",0x271E:"Kri",0x2720:"Radians",0x2721:"Steradians",0x2722:"Hz",0x2723:"N",0x2724:"Pa",0x2725:"Joules",0x2726:"Watts",0x2727:"Coulombs",0x2728:"Volts",0x2729:"Farads",0x272A:"Ohms",0x272B:"Siemens",0x272C:"Webers",0x272D:"Teslas",0x272E:"H",0x272F:"C",0x2730:"Lumens",0x2731:"Lux",0x2732:"Bq",0x2733:"Gy",0x2734:"Sv",0x2735:"kat",0x2740:"Pa/s",0x2741:"Nm",0x2742:"N/m",0x2743:"rad/s",0x2744:"rad/s2",0x2745:"W/m2)",0x2746:"J/K0",0x2747:"J/kgK",0x2748:"J/kg",0x2749:"W/(mK)",0x274A:"J/m3",0x274B:"V/m",0x274C:"Coulomb/m3",0x274D:"Coulomb/m2",0x274E:"Coulomb/m2",0x274F:"Farad/m",0x2750:"H/m",0x2751:"Joule/mole",0x2752:"J/molK",0x2753:"Coulomb/kg",0x2754:"Gy/s",0x2755:"W/sr",0x2756:"W/m2sr",0x2757:"Katal/m3",0x2760:"Minutes",0x2761:"Hours",0x2762:"Days",0x2763:"Degrees",0x2764:"Minutes",0x2765:"Seconds",0x2766:"Hectares",0x2767:"Litres",0x2768:"Tonnes",0x2780:"bar",0x2781:"mmHg",0x2782:"Angstroms",0x2783:"NM",0x2784:"Barns",0x2785:"Knots",0x2786:"Nepers",0x2787:"bel",0x27A0:"Yards",0x27A1:"Parsecs",0x27A2:"Inches",0x27A3:"Feet",0x27A4:"Miles",0x27A5:"psi",0x27A6:"KPH",0x27A7:"MPH",0x27A8:"RPM",0x27A9:"cal",0x27AA:"Cal",0x27AB:"kWh",0x27AC:"F",0x27AD:"Percent",0x27AE:"Per Mile",0x27AF:"bp/m",0x27B0:"Ah",0x27B1:"mg/Decilitre",0x27B2:"mmol/l",0x27B3:"Years",0x27B4:"Months",0x27B5:"Count/m3",0x27B6:"Watt/m2",0x27B7:"ml/kg/min",0x27B8:"lbs"]

class charsTableViewController: UITableViewController, CBPeripheralDelegate, UITextFieldDelegate

{
    var foundCharacteristics = [Int: CBCharacteristic]()
   // var foundCharacteristics = NSMutableOrderedSet()
    var characteristicProps = [CBUUID: UInt]()
    var characteristicPropString = [CBUUID: String]()
    var characteristicFormatString = [CBUUID: String]()
    var characteristicNumberFormat = [CBUUID: Int]()
    var characteristicNumberFormatString = [CBUUID: String]()
    var characteristicExponent = [CBUUID: Int8]()
    var characteristicUnits = [CBUUID: UInt16]()
    var characteristicUnitString = [CBUUID: String]()
    var characteristicValue = [CBUUID: NSData]()
    var characteristicASCIIValue = [CBUUID: NSString]()
    var characteristicDecimalValue = [CBUUID: String]()
    var characteristicHexValue = [CBUUID: String]()
    var characteristicUserDescription = [CBUUID: String]()
    var characteristicSubscribed = [CBUUID: UInt]()
    var subString: String = "Subscribed"
    var writeString: String = ""
    var writeFlag: Bool = false
    
    
    @IBOutlet var characteristicsTableView: UITableView!
   
    var service: CBService!
    var peripheral: CBPeripheral!
    
    @IBOutlet var serviceUUID: UILabel!
   
    override func viewDidLoad()
        {
            super.viewDidLoad()
             peripheral.readRSSI()
            characteristicsTableView.dataSource = self
            characteristicsTableView.delegate = self
             characteristicsTableView.estimatedRowHeight = 474
            //characteristicsTableView.rowHeight = UITableViewAutomaticDimension
            
             print("\nSelected PeripheralUUID: \(peripheral.identifier.uuidString)")
       
        print("Selected Peripheral Name: \(peripheral.name as NSString?)")
            
            peripheral.delegate = self
        self.refreshControl?.addTarget(self, action: #selector(charsTableViewController.startScanningCharacteristics), for: .valueChanged)
        print("Selected Service: \(service.uuid.description)")
            
            startScanningCharacteristics()
           

        //serviceUUID.text = service!.UUID.description
       
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    @objc func startScanningCharacteristics()
    {
       
        
        print("\n...Started scanning for Characteristics...")
       // foundCharacteristics.removeAllObjects()
        
       // peripheral.discoverCharacteristics(nil, forService: (service as CBService))
        foundCharacteristics.removeAll()
        peripheral.discoverCharacteristics(nil, for: service)
    }


    private func peripheral(peripheral: CBPeripheral, didDiscoverCharacteristicsForService service: CBService, error: NSError?)

{
     var index:Int=0
    for characteristic in service.characteristics!
        {
            foundCharacteristics[index] = characteristic
            index += 1
            print("\nCharacteristic Index: \(index)")
            
            print("Number of Characteristics Discovered: \(foundCharacteristics.count)")
            
                print("Discovered characteristic:\(characteristic) with properties: \(characteristic.properties)")
                //print("Characteristic service: \(characteristic.service.UUID)")
        print("Characteristic UUID: \(characteristic.uuid)")

            characteristicProps[characteristic.uuid] = characteristic.properties.rawValue
                print("Characteristic Properties: \(characteristicProps[characteristic.uuid]!)")
            
            var prpString = ""
            
                if 0 != characteristicProps[characteristic.uuid]! & 1
                    {
                        prpString += "Broadcast."
                    }
                if 0 != characteristicProps[characteristic.uuid]! & 2
                    {
                        prpString += "Read."
                    }
                if 0 != characteristicProps[characteristic.uuid]! & 4
                    {
                        prpString +=  "Write without Response."
                    }
                if 0 != characteristicProps[characteristic.uuid]! & 8
                    {
                        prpString +=  "Write."
                    }
                if 0 != characteristicProps[characteristic.uuid]! & 16
                    {
                        prpString +=  "Notify."
                        //peripheral.setNotifyValue(true, forCharacteristic: characteristic) //If NOTIFY, let's subscribe for updates
                    }
                if 0 != characteristicProps[characteristic.uuid]! & 32
                    {
                        prpString +=  "Indicate."
                    }
                if 0 != characteristicProps[characteristic.uuid]! & 64
                    {
                        prpString +=  "Authenticated Signed Writes."
                    }
                if 0 != characteristicProps[characteristic.uuid]! & 128
                    {
                        prpString +=  "Extended Properties."
                    }
            
            characteristicPropString[characteristic.uuid] = prpString
                print("Characteristic Properties String: \(characteristicPropString[characteristic.uuid]!)")
            
            
            tableView.reloadData()
        peripheral.discoverDescriptors(for: characteristic)
        peripheral.readValue(for: characteristic)
            
            
        }
    
    print("\n....READING CHARACTERISTIC VALUES....\n")
    
}

    
func peripheral(peripheral: CBPeripheral, didUpdateValueForCharacteristic characteristic: CBCharacteristic, error: NSError?)
{
    if let error = error
        {
           print("Failed to update value for characteristic with error: \(error)")
        }
        
    else
        {
            var UpdateValue: Int = 0
            
            characteristic.value!.getBytes(&UpdateValue, length: sizeof(Int)) //Converts NSData object to Integer

            print("\nCharacteristic NSData: \(characteristic)")
           // print("Characteristic Value string: \(characteristic.value!)")
           // print("UpdateValue: \(UpdateValue)")
            var notMuch: Int = 0
            let notMuchNS = NSData(bytes: &notMuch, length: sizeof(Int))

            characteristicValue[characteristic.uuid] = characteristic.value ?? notMuchNS
            print("Stored value: \(characteristicValue[characteristic.uuid]!)")
 
            if let ASCIIstr = NSString(data: characteristic.value!, encoding: NSUTF8StringEncoding.rawValue)
                {
                    characteristicASCIIValue[characteristic.uuid] = ASCIIstr
                    print("Stored ASCII: \(characteristicASCIIValue[characteristic.uuid]!)")
                }
            
            characteristicHexValue[characteristic.uuid] = (String(format:"%2X",UpdateValue))
            print("Stored Hex value: \(characteristicHexValue[characteristic.uuid]!)")
            characteristicDecimalValue[characteristic.uuid] = (String(format:"%2D",UpdateValue))
            print("Stored Decimal value: \(characteristicDecimalValue[characteristic.uuid]!)")
        
            /* Interesting experiment to update just the TableView rows corresponding to the updated value
                It didn't actually work.  You need to update the entire tableview.  But interesting...

            let keyArray = [CBUUID](characteristicValue.keys)
            var row:Int = 0
            for (index,value)in keyArray.enumerate(){if value == characteristic.UUID {row = index-1}}
            This line above calculates an integer value of the position of our updated value to use as a ROW in Indexpath
             
            let index = NSIndexPath(forRow: row, inSection: 0)
            tableView.reloadRowsAtIndexPaths([index], withRowAnimation: UITableViewRowAnimation.None)
             With no animation, the row simply updates with no visuals indicating a change but the change in values.
             it does so at row INDEX which corresponds to the current charactersitic value position.
             */
            
            if writeFlag == false{tableView.reloadData()}
                 }
}
    
 
    
func peripheral(peripheral: CBPeripheral, didDiscoverDescriptorsForCharacteristic characteristic: CBCharacteristic, error: NSError?)
{
    if characteristic.descriptors?.count != 0
        {
            print("\nDid discover DESCRIPTORS for Characteristic: \(characteristic.uuid)")
            
            for desc in characteristic.descriptors!
                {
                    
                peripheral.readValue(for: desc)
                }
            
        }
}

func peripheral(peripheral: CBPeripheral, didUpdateValueForDescriptor desc: CBDescriptor, error: NSError?)
{
    if let error = error
        {
            print("Failed to update value for characteristic with error: \(error)")
        }
    else
        {
            
            var numFormat: Int = 0
            var exponent: Int8 = 0
            var Units: UInt16 = 0

            print("\nDESCRIPTOR: \(desc.characteristic.uuid)....\(desc)....\(desc.uuid)...\(desc.value!)")
        
            if desc.description.range(of: "Characteristic User Description") != nil
                {
                    characteristicUserDescription[desc.characteristic.uuid] = desc.value as?String
                    print("Stored User Description: \(desc.characteristic.uuid) : \(characteristicUserDescription[desc.characteristic.uuid]!) ")
                }
            
            if desc.description.range(of: "Client Characteristic Configuration") != nil
                {
                characteristicSubscribed[desc.characteristic.uuid] = (desc.value! as AnyObject).uintValue
                print("Stored Client Characteristic Configuration (subscribed) : \(desc.characteristic.uuid) : \(characteristicSubscribed[desc.characteristic.uuid]!) ")
                }
            
            //SHORT FORM if let r = desc.description.rangeOfString("Characteristic Format")
            if desc.description.rangeOfString("Characteristic Format", options: NSString.CompareOptions.LiteralSearch, range: desc.description.startIndex..<desc.description.endIndex,locale: nil) != nil
                {
                   
                    characteristicFormatString[desc.characteristic.uuid] = "\(desc.value!)"
                    
                   
                        print("Presentation Format Descriptor:\(characteristicFormatString[desc.characteristic.uuid]!) ")
                    
                    
                (desc.value! as AnyObject).getBytes(&numFormat, range:NSMakeRange(0,1)) //Converts NSData object to Integer
                   // print("Value data format: 0x\(NSString(format:"%2X",numFormat))....\(NumericType[numFormat]) ")
                    characteristicNumberFormat[desc.characteristic.uuid] = numFormat
                    characteristicNumberFormatString[desc.characteristic.uuid] = NumericType[numFormat]
                    print("Stored Number Format: \(desc.characteristic.uuid) : \(characteristicNumberFormat[desc.characteristic.uuid]!) ")
                    print("Stored Number Format String: \(desc.characteristic.uuid) : \(characteristicNumberFormatString[desc.characteristic.uuid]!) ")
                    
            
                (desc.value! as AnyObject).getBytes(&exponent, range: NSMakeRange(1,1)) //Converts NSData object to Integer
                   // print("Value Exponent: \(exponent) ")
                    characteristicExponent[desc.characteristic.uuid] = exponent
                    print("Stored Exponent: \(desc.characteristic.uuid) : \(characteristicExponent[desc.characteristic.uuid]!) ")
                    
                (desc.value! as AnyObject).getBytes(&Units, range: NSMakeRange(2,2)) //Converts NSData object to Integer
                    characteristicUnits[desc.characteristic.uuid] = Units
                    characteristicUnitString[desc.characteristic.uuid] = unitDefinitions[Units ?? 0x2700]
                    
                    print("Stored Units: \(desc.characteristic.uuid) : 0x\(NSString(format:"%2X",characteristicUnits[desc.characteristic.uuid]!))")
 
                    print("Stored Unit String: \(desc.characteristic.uuid) : \(characteristicUnitString[desc.characteristic.uuid] ?? "None")")
                    
                    tableView.reloadData()
                    
                }
        }
}




     func numberOfSectionsInTableView(characteristicsTableView: UITableView) -> Int
        {
            // #warning Incomplete implementation, return the number of sections
            return 1
        }

    override func tableView(_ characteristicsTableView: UITableView, numberOfRowsInSection section: Int) -> Int
        {
        // #warning Incomplete implementation, return the number of rows
           // return characteristicValue.count
            return foundCharacteristics.count
        }

    
func tableView(characteristicsTableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    var UpdateValue: Int64 = 0
    let date=NSDate()
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "HH:mm:ss.SSS"
    let convertedDate = dateFormatter.string(from: date as Date)
    
    
    if foundCharacteristics.count > 0
        {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "charsCell", for: indexPath as IndexPath) as!    CharacteristicTableViewCell
                    //  print("Index path and row: \(indexPath.row)")
           // print("Number of characteristics found: \(foundCharacteristics.count)")
           
            if foundCharacteristics[indexPath.row] != nil
                {
                    let Mycharacteristic = self.foundCharacteristics[indexPath.row]!
                //    print("Characteristic uuid: \(characteristic.uuid)")
                
                    cell.uuid.text = Mycharacteristic.uuid.uuidString ?? " - "
                    let testString: String = "0x" + String(format:"%2X",(self.characteristicProps[Mycharacteristic.uuid] ?? 0))
                     //print("Properties value retrieved: \(testString)")
                    cell.rawProperties.text = testString
                    
                    subString = ""
                    let MyProperties = characteristicProps[Mycharacteristic.uuid] ?? 0
                    
                    
                    if 0 != MyProperties & 4 || 0 != MyProperties & 8 
                        {
                        cell.ValueEntryField.isHidden = false
                            cell.ValueEntryField.delegate = self
                            if self.characteristicValue[Mycharacteristic.uuid] != nil
                                {
                                    let myString = String(self.characteristicValue[Mycharacteristic.uuid]!)
                                    cell.ValueEntryField.text = myString
                                }
                            
                        cell.ValueEntryField.textColor = UIColor.red
                        cell.ValueEntryField.borderStyle = UITextField.BorderStyle.bezel
                            cell.ValueEntryField.tag = indexPath.row
                        cell.ValueEntryField.addTarget(self,action: #selector(charsTableViewController.newValue(_:)),forControlEvents: UIControl.Event.EditingDidEnd)
                            
                        }
                    else { cell.ValueEntryField.isHidden = true}
                    

                    if 0 != MyProperties & 16 || 0 != MyProperties & 2 || 0 != MyProperties & 32
                        {
                        cell.Unsubscribe.isHidden = false
                            cell.Unsubscribe.tag = indexPath.row
                            cell.Unsubscribe.addTarget(self,action:#selector(charsTableViewController.unSubscribe(_:)),forControlEvents: .TouchUpInside)
                        }
                    else { cell.Unsubscribe.isHidden = true}
                    
                    if 0 != MyProperties & 2
                        {
                            let date2=NSDate()
                        let dateFormatter2 = DateFormatter()
                            dateFormatter2.dateFormat = "HH:mm:ss.SSS"
                        let convertedDate2 = dateFormatter2.string(from: date2 as Date)
  
                            subString = " - READ AT " + convertedDate2
                        }

                    if 0 != MyProperties & 16 || 0 != MyProperties & 32
                        {
                            if ((self.characteristicSubscribed[Mycharacteristic.uuid] ?? 0) == 0)
                                {
                                    subString = "  - UNSUBSCRIBED"
                                }
                            if ((self.characteristicSubscribed[Mycharacteristic.uuid] ?? 0) == 1 || (self.characteristicSubscribed[Mycharacteristic.uuid] ?? 0) == 2)
                                {
                                    subString = "  - SUBSCRIBED updated:" + convertedDate
                                }
                        }

                    else if 0 != MyProperties & 2
                        {
                            let date=NSDate()
                        let dateFormatter = DateFormatter()
                            dateFormatter.dateFormat = "HH:mm:ss.SSS"
                        let convertedDate = dateFormatter.string(from: date as Date)
                        
                            subString = " - READ AT " + convertedDate
                        }

                    
                    cell.propertyString.text = (self.characteristicPropString[Mycharacteristic.uuid] ?? "None") + subString

                    //print("\nCharacteristic Value string in cell: \(self.characteristicValue[Mycharacteristic.uuid] ?? "empty")")
                    
                    if self.characteristicValue[Mycharacteristic.uuid] != nil
                        {
                            cell.rawValue.text = String(self.characteristicValue[Mycharacteristic.uuid]!)
                            
                             characteristicValue[Mycharacteristic.uuid]!.getBytes(&UpdateValue, length: sizeof(Int64)) //Converts NSData object to Integer
                        
                            cell.hexValue.text = String(format:"%2X",UpdateValue)
                            cell.decValue.text = String(format:"%2d",UpdateValue)
                            //Let's take our decimal value and apply any exponents available
                        let UpdateValue2 = NumberFormatter().number(from: cell.decValue.text!)
                            
                            var x : Int8 = self.characteristicExponent[Mycharacteristic.uuid] ?? 0
                            
                            
                            cell.valueExponent.text = String(format:"%2d",x)
                            
                            
                        var exponentValue = Double(truncating: UpdateValue2!)
                        let exponentValueSimple = Int(truncating: UpdateValue2!)
                            
                            switch x
                            {
                            case 1 ... 100:
                                for _ in 1 ... x
                                    {
                                        exponentValue *= 10
                                    }
                           
                            default:         //Exponent is either zero or negative
                                x *= -1      //Convert it to a positive
                                if x > 0
                                    {
                                        for _ in 1...x
                                            {
                                                exponentValue /= 10  //and divide instead of multiply
                                            }
                                    }
                                
                            }                            
                            
                        if let ASCIIstr = String(data: self.characteristicValue[Mycharacteristic.uuid]! as Data, encoding: String.Encoding.utf8)
                                {
                                    cell.ASCIIvalue.text = ASCIIstr
                                }
                            else
                                {
                                    cell.ASCIIvalue.text = " - "
                                }

                            if (x==0)
                                {
                                cell.presentedValue.text = String(exponentValueSimple)
                                }
                            
                            if (cell.ASCIIvalue.text!.count > 5)
                                {
                                    cell.presentedValue.text = cell.ASCIIvalue.text
                                }
                            else
                                {
                                    if (x==0) //If the exponents is zero we want to print as a simple integer
                                        {
                                            cell.presentedValue.text = String(exponentValueSimple)
                                        }
                                    else     //If exponent is non-zero, we want to print the value in decimal
                                        {
                                            cell.presentedValue.text = String(exponentValue)
                                        }
                                }

                            
                        }
                    
                    cell.presentationFormat.text = self.characteristicFormatString[Mycharacteristic.uuid] ?? " None "
                    
                    cell.valueFormat.text = self.characteristicNumberFormatString[Mycharacteristic.uuid] ?? " None given"
                    
                   let MyUnitString = "0x" + String(format:"%2X",self.characteristicUnits[Mycharacteristic.uuid] ?? 0x2700)
                 
                    let MyUnitString2 = self.characteristicUnitString[Mycharacteristic.uuid] ?? " "
                    
                    cell.valueUnits.text = MyUnitString + " " + MyUnitString2
                    
                    cell.userDescription.text = self.characteristicUserDescription[Mycharacteristic.uuid] ?? " "
                    
                    let combinedString = " " + (cell.userDescription.text ?? " - ")
                    
                    cell.presentedValue.text = cell.presentedValue.text! + " " + (self.characteristicUnitString[Mycharacteristic.uuid] ?? " ") + combinedString
                    
                    }
            return cell
            }
        else
    
          {
             return UITableViewCell()
          }
}

    
    
@IBAction func unSubscribe(sender: UIButton)
{
    let UNScharacteristic = self.foundCharacteristics[sender.tag]!
    let MyProperties = characteristicProps[UNScharacteristic.uuid] ?? 0
    
    if 0 != MyProperties & 16 || 0 != MyProperties & 32
        {
            let subs = (characteristicSubscribed[UNScharacteristic.uuid] ?? 0)
            if subs == 1 || subs == 2
                {
                peripheral.setNotifyValue(false, for: UNScharacteristic)
                    self.characteristicSubscribed[UNScharacteristic.uuid] = 0
                }
            if subs == 0
                {
                peripheral.setNotifyValue(true, for: UNScharacteristic)
                    self.characteristicSubscribed[UNScharacteristic.uuid] = 1
                }
        peripheral.discoverDescriptors(for: UNScharacteristic)
        peripheral.readValue(for: UNScharacteristic)
        }
    
    else if 0 != MyProperties & 2
        {
        peripheral.readValue(for: UNScharacteristic)
        }
}
@IBAction func newValue(sender: UITextField)
    
    {
        //This method picks up a string entered on the keyboard to write to a write type characterisic
        //It processes it to send as a string, a 32-bit value, or a bool
        
        let UNScharacteristic = self.foundCharacteristics[sender.tag]!
        print("Picked up writeString: \(writeString)")
    let myNSString: NSString = writeString as NSString
        print("NEW NSString: \(myNSString)")

        var newValue: Int32 = 0
        var dummyValue: Int8 = 1
        var anothernewValue: UInt32 = 0
        var anothernewValue64: UInt64 = 0
    let newvalScanner = Scanner (string: writeString)
        var newValueNSD: NSData
        
        newValueNSD = NSData(bytes: &newValue, length: sizeof(Int64)) //First let's set it to zero so we have SOMETHING
        
    if myNSString.contains("\"")  //If it contains text in quotes, let's send the text (without the quotes)
            {
        let wrongString = writeString.replacingOccurrences(of: "\"", with: "", options: NSString.CompareOptions.LiteralSearch, range: nil)
                let myNSString2: NSString = wrongString
        newValueNSD = myNSString2.data(using: String.Encoding.utf8.rawValue)! as NSData
            }
            
    else if myNSString.contains("0x") //But if it leads with 0x, let's scan for hex and send 32-bit hex value
            {
                if writeString.count < 11
                    {
                    newvalScanner.scanHexInt32(&anothernewValue)
                        newValueNSD = NSData(bytes: &anothernewValue, length: sizeof(Int32))
                    }
                else
                    {
                        newvalScanner.scanHexInt64(&anothernewValue64)
                        newValueNSD = NSData(bytes: &anothernewValue64, length: sizeof(Int64))
                        
                    }
            }
            
            else
                {
                    newvalScanner.scanInt32(&newValue)// Let's scan for decimal digits and send as 32bits
                    newValueNSD = NSData(bytes: &newValue, length: sizeof(Int32))
                }
        
        
    if myNSString.contains("on") || myNSString.contains("ON") //If it contains "on" send an 8-bit containing 1
            {
                dummyValue = 1
                newValueNSD = NSData(bytes: &dummyValue, length: sizeof(Int8))
            }
    
    if myNSString.contains("off") || myNSString.contains("OFF")//If it contains "off" send an 8-bit containing 0
            {
                dummyValue = 0
                newValueNSD = NSData(bytes: &dummyValue, length: sizeof(Int8))
            }
        
       print ("After scanning we get...\(newValueNSD)")

        characteristicValue[UNScharacteristic.uuid] = newValueNSD
        print("New characteristic value = \(characteristicValue[UNScharacteristic.uuid]!)")
 
    peripheral.writeValue(newValueNSD as Data, for: UNScharacteristic, type: CBCharacteristicWriteType.withResponse)
  
        writeFlag = false //resume characteristic updates for notifies
    }
    
    func peripheral(peripheral: CBPeripheral, didWriteValueForCharacteristic characteristic: CBCharacteristic, error: NSError?)
    {
        
        //After writing out new value to a characteristic, this delegate will catch returned errors or responses.
        //It's nothing we need, but it is important to have a delegate to catch them so they don't just show up with 
        //nowhere to go.
        
        if let error = error
            {
                print("Failed to write data to characteristic with error: \(error)")
            }
            
        else
            {
                print("Apparently our write data to characteristic was successful...: \(error)")
            }
    }

    
    func textFieldShouldReturn(textField: UITextField) -> Bool
    {
        //We have pressed DONE on keyboard.  This picks up our entered string and stores it in a global variable, then removes
        //keyboard from screen
        
        writeString = textField.text!
        print("We created writeString: \(writeString)")
        textField.resignFirstResponder()
        return true
    }

    
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool
    {

        writeFlag = true  //When we bring up the keyboard, we use this to stop NOTIFIES from updating 
                          //our tableview while we are trying to enter data
       return true
    }
    


   
    
   
    // In a storyboard-based application, you will often want to do a little preparation before navigation
 /*   override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    
    {
        let Mycharacteristic = self.foundCharacteristics[characteristicsTableView.indexPathForSelectedRow!.row]!
        print(".............S..E..G..U..E............")
        peripheral.setNotifyValue(false, forCharacteristic: Mycharacteristic)
    }*/
 
    
    func peripheral(peripheral: CBPeripheral, didReadRSSI RSSI: NSNumber, error: NSError?)
    {
        //print("Did read RSSI.")
        if let error = error
            {
                print("Error getting RSSI: \(error)")
                //RSSILabel.text = "Error getting RSSI."
            }
        else
            {
                print("RSSI: \(RSSI.intValue)")
                // RSSILabel.text = "\(RSSI.integerValue)"
            }
    }


} //end of charsTableViewController class
