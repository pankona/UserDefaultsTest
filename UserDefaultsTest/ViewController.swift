//
//  ViewController.swift
//  UserDefaultsTest
//
//  Created by yosuke.akatsuka on 2015/12/14.
//  Copyright © 2015年 access. All rights reserved.
//

import UIKit
import CommonCrypto

class MyUserDefaults {
    static let m_ud = NSUserDefaults.standardUserDefaults()
    
    static func save(in_key: String, in_value: String) {
        m_ud.setObject(in_value, forKey: in_key)
        m_ud.synchronize()
    }
    
    static func loadString(in_key: String) -> String {
        m_ud.registerDefaults([in_key: ""])
        return m_ud.objectForKey(in_key) as! String
    }
    
    static func remove(in_key: String) {
        m_ud.removeObjectForKey(in_key)
    }
}

class ViewController: UIViewController {

    func encryptTest() -> NSData {

        let keyString        = "12345678901234567890123456789012"
        let keyData: NSData! = (keyString as NSString).dataUsingEncoding(NSUTF8StringEncoding) as NSData!
        let keyBytes         = UnsafeMutablePointer<Void>(keyData.bytes)
        print("keyLength   = \(keyData.length), keyData   = \(keyData)")
        
        let message       = "Don´t try to read this text. Top Secret Stuff"
        let data: NSData! = (message as NSString).dataUsingEncoding(NSUTF8StringEncoding) as NSData!
        let dataLength    = size_t(data.length)
        let dataBytes     = UnsafeMutablePointer<Void>(data.bytes)
        print("dataLength  = \(dataLength), data      = \(data)")
        
        let cryptData    = NSMutableData(length: Int(dataLength) + kCCBlockSizeAES128)
        let cryptPointer = UnsafeMutablePointer<Void>(cryptData!.mutableBytes)
        let cryptLength  = size_t(cryptData!.length)
        
        let keyLength              = size_t(kCCKeySizeAES256)
        let operation: CCOperation = UInt32(kCCEncrypt)
        let algoritm:  CCAlgorithm = UInt32(kCCAlgorithmAES128)
        let options:   CCOptions   = UInt32(kCCOptionPKCS7Padding + kCCOptionECBMode)
        
        var numBytesEncrypted :size_t = 0
        
        let cryptStatus = CCCrypt(operation,
            algoritm,
            options,
            keyBytes, keyLength,
            nil,
            dataBytes, dataLength,
            cryptPointer, cryptLength,
            &numBytesEncrypted)
        
        if UInt32(cryptStatus) == UInt32(kCCSuccess) {
            //  let x: UInt = numBytesEncrypted
            cryptData!.length = Int(numBytesEncrypted)
            print("cryptLength = \(numBytesEncrypted), cryptData = \(cryptData)")
            
            // Not all data is a UTF-8 string so Base64 is used
            let base64cryptString = cryptData!.base64EncodedStringWithOptions(.Encoding64CharacterLineLength)
            print("base64cryptString = \(base64cryptString)")
            
        } else {
            print("Error: \(cryptStatus)")
        }
        
        return NSData(bytes: cryptPointer, length: Int(numBytesEncrypted))
    }
    
    func decryptTest(data: NSData) {
        let keyString        = "12345678901234567890123456789012"
        let keyData: NSData! = (keyString as NSString).dataUsingEncoding(NSUTF8StringEncoding) as NSData!
        let keyBytes         = UnsafeMutablePointer<Void>(keyData.bytes)
        print("keyLength   = \(keyData.length), keyData   = \(keyData)")
        
        //let message       = "Don´t try to read this text. Top Secret Stuff"
        //let data: NSData! = (message as NSString).dataUsingEncoding(NSUTF8StringEncoding) as NSData!
        let dataLength    = size_t(data.length)
        let dataBytes     = UnsafeMutablePointer<Void>(data.bytes)
        print("dataLength  = \(dataLength), data      = \(data)")
        
        let cryptData    = NSMutableData(length: Int(dataLength) + kCCBlockSizeAES128)
        let cryptPointer = UnsafeMutablePointer<Void>(cryptData!.mutableBytes)
        let cryptLength  = size_t(cryptData!.length)
        
        let keyLength              = size_t(kCCKeySizeAES256)
        let operation: CCOperation = UInt32(kCCDecrypt)
        let algoritm:  CCAlgorithm = UInt32(kCCAlgorithmAES128)
        let options:   CCOptions   = UInt32(kCCOptionPKCS7Padding + kCCOptionECBMode)
        
        var numBytesEncrypted :size_t = 0
        
        let cryptStatus = CCCrypt(operation,
            algoritm,
            options,
            keyBytes, keyLength,
            nil,
            dataBytes, dataLength,
            cryptPointer, cryptLength,
            &numBytesEncrypted)
        
        if UInt32(cryptStatus) == UInt32(kCCSuccess) {
            //  let x: UInt = numBytesEncrypted
            cryptData!.length = Int(numBytesEncrypted)
            print("DecryptcryptLength = \(numBytesEncrypted), Decrypt = \(cryptData)")
            
            // Not all data is a UTF-8 string so Base64 is used
            let base64cryptString = cryptData!.base64EncodedStringWithOptions(.Encoding64CharacterLineLength)
            print("base64DecryptString = \(base64cryptString)")
            print( "utf8 actual string = \(NSString(data: cryptData!, encoding: NSUTF8StringEncoding))");
        } else {
            print("Error: \(cryptStatus)")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        MyUserDefaults.save("test", in_value: "Test")
        //MyUserDefaults.remove("test")
        let str: String = MyUserDefaults.loadString("test")
        NSLog("str = " + str)
        
        decryptTest(encryptTest())
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

