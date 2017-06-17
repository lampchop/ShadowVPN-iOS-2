//
//  ScanConfiguration.swift
//  ShadowBit
//
//  Created by lolizzZ on 2017/6/12.
//  Copyright © 2017年 clowwindy. All rights reserved.
//

import UIKit
import NetworkExtension


class ScanConfiguration: UITableViewController {
    var jump_URL: String = ""
//    var providerManager: NETunnelProviderManager?
//    var bindMap = [String: AnyObject]()
//    var configuration = [String: AnyObject]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        jump_URL = String(jump_URL.characters.dropFirst(12))
        // 将base64字符串转换成NSData
        let base64EncodedData = NSData(base64EncodedString:jump_URL,options:NSDataBase64DecodingOptions(rawValue: 0))
        // 对NSData数据进行UTF8解码
        let stringWithDecode = NSString(data: base64EncodedData!, encoding: NSUTF8StringEncoding)

        print(stringWithDecode)
        var conf_dictionary:NSDictionary?
        if let data = stringWithDecode!.dataUsingEncoding(NSUTF8StringEncoding) {
            
            do {
                conf_dictionary =  try NSJSONSerialization.JSONObjectWithData(data, options: []) as? [String:AnyObject]
                
                if let myDictionary = conf_dictionary
                {
                    print(" First name is: \(myDictionary["port"]!)")
                }
            } catch let error as NSError {
                print(error)
            }
        }


        let manager = NETunnelProviderManager()
        manager.loadFromPreferencesWithCompletionHandler { (error) -> Void in
            let providerProtocol = NETunnelProviderProtocol()
            providerProtocol.providerBundleIdentifier = kTunnelProviderBundle
            providerProtocol.providerConfiguration = [String: AnyObject]()
            manager.protocolConfiguration = providerProtocol
            
            // save config action demo
            // TODO remove
            // var configuration = self.convertStringToDictionary(stringWithDecode!)
            var configuration = [String: AnyObject]()
            
            configuration["description"] = "Conf from QRcode"
            configuration["usertoken"] = ""

            
            // TODO: configuration maybe nil !!!
            // if configuration is nil, pop error messsage and return to root view
            
            configuration["password"] =  String(conf_dictionary!["password"]! as AnyObject)
            // TODO this will fail if QRcode does not provide "usertoken"
            //configuration["usertoken"] =  String(conf_dictionary!["usertoken"]! as AnyObject)
            configuration["port"] = String(conf_dictionary!["port"]! as AnyObject)
            configuration["ip"] = String(conf_dictionary!["ip"]! as AnyObject)
            configuration["subnet"] = String(conf_dictionary!["subnet"]! as AnyObject)
            configuration["dns"] = String(conf_dictionary!["dns"]! as AnyObject)
            configuration["mtu"] = String(conf_dictionary!["mtu"]! as AnyObject)
            configuration["server"] = String(conf_dictionary!["server"]! as AnyObject)

            configuration["route"] = "chnroutes"
            
            (manager.protocolConfiguration as! NETunnelProviderProtocol).providerConfiguration = configuration
            manager.protocolConfiguration?.serverAddress =  configuration["server"] as? String
            manager.localizedDescription = configuration["server"] as? String
            
            manager.saveToPreferencesWithCompletionHandler({ (error) -> Void in
                print(error)
                self.navigationController?.popToRootViewControllerAnimated(true)
            })
            
            
        }
    }
    ///配置不成功弹出信息
    func errorConfig() {
        navigationController?.popToRootViewControllerAnimated(true)
        let alert = UIAlertView(title: "ERROR", message: "Configuration error", delegate: nil, cancelButtonTitle: "cancel")
        alert.show()
    }

    //  对“server” 这个字段
    //    1. 若是域名转化为 ip地址
    //    2. 若非域名也就是已经是ip地址了，直接返回原字串
    func domain_resolve(server_string: String) -> String {
        // server string is already ip address
        if true == is_ip_address(server_string) {
            NSLog("%@ is already ip addres, skip resolve", server_string)
            return server_string
        }
        let host = CFHostCreateWithName(nil,server_string).takeRetainedValue()
        CFHostStartInfoResolution(host, .Addresses, nil)
        var success: DarwinBoolean = false
        var resolve_ip_address: String = ""
        if let addresses = CFHostGetAddressing(host, &success)?.takeUnretainedValue() as NSArray?,
            let theAddress = addresses.firstObject as? NSData {
            var hostname = [CChar](count: Int(NI_MAXHOST), repeatedValue: 0)
            if getnameinfo(UnsafePointer(theAddress.bytes), socklen_t(theAddress.length),
                           &hostname, socklen_t(hostname.count), nil, 0, NI_NUMERICHOST) == 0 {
                if let numAddress = String.fromCString(hostname) {
                    // print(numAddress)
                    NSLog("%@ resolve result:%@", server_string, String(numAddress))
                    resolve_ip_address = numAddress
                }
            }
        }
        NSLog("get resolved ip address[%@]", resolve_ip_address)
        return resolve_ip_address
    }
    
    
    func is_ip_address(server_str: String) -> Bool {
        let parts = server_str.componentsSeparatedByString(".")
        if parts.count != 4 {
            return false;
        }
        for part in parts {
            let ip_part_int = Int(part)
            if nil == ip_part_int || ip_part_int < 0 || ip_part_int > 255 {
                return false
            }
        }
        return true;
    }
    
    
    // return nil if there's no error
    class func validateIP(ip: String) -> String? {
        let parts = ip.componentsSeparatedByString(".")
        if parts.count != 4 {
            return "Invalid IP: " + ip
        }
        for part in parts {
            let n = Int(part)
            if n == nil || n < 0 || n > 255 {
                return "Invalid IP: " + ip
            }
        }
        return nil
    }
    
    // return nil if there's no error
    class func validate(configuration: [String: AnyObject]) -> String? {
        // 1. server must be not empty
        if configuration["server"] == nil || configuration["server"]?.length == 0 {
            return "Server must not be empty"
        }
        // 2. port must be int 1, 65535
        if configuration["port"] == nil || configuration["port"]?.length == 0 {
            return "Port must not be empty"
        }
        let port = Int(configuration["port"] as! NSNumber)
        if port < 1 || port > 65535 {
            return "Port is invalid"
        }
        // 3. password must be not empty
        if configuration["password"] == nil || configuration["password"]?.length == 0 {
            return "Password must not be empty"
        }
        // 4. usertoken must be empty or hex of 8 bytes
        if configuration["usertoken"] != nil {
            if let usertoken = configuration["usertoken"] as? String {
                if NSData.fromHexString(usertoken).length != 8 && NSData.fromHexString(usertoken).length != 0 {
                    return "Usertoken must be HEX of 8 bytes (example: 7e335d67f1dc2c01)"
                }
            }
        }
        // 5. ip must be valid IP
        if configuration["ip"] == nil || configuration["ip"]?.length == 0 {
            return "IP must not be empty"
        }
        if let ip = configuration["ip"] as? String {
            let r = validateIP(ip)
            if r != nil {
                return r
            }
        }
        // 6. subnet must be valid subnet
        if configuration["subnet"] == nil || configuration["subnet"]?.length == 0 {
            return "Subnet must not be empty"
        }
        if let subnet = configuration["subnet"] as? String {
            let r = validateIP(subnet)
            if r != nil {
                return r
            }
        }
        // 7. dns must be comma separated ip addresses
        if configuration["dns"] == nil || configuration["dns"]?.length == 0 {
            return "DNS must not be empty"
        }
        if let dns = configuration["dns"] as? String {
            let ips = dns.componentsSeparatedByString(",")
            if ips.count == 0 {
                return "DNS must not be empty"
            }
            for ip in ips {
                let r = validateIP(ip)
                if r != nil {
                    return r
                }
            }
        }
        // 8. mtu must be int
        if configuration["mtu"] == nil || configuration["mtu"]?.length == 0 {
            return "MTU must not be empty"
        }
        let mtu = Int(configuration["mtu"] as! NSNumber)
        if mtu < 100 || mtu > 9000 {
            return "MTU is invalid"
        }
        
        // 9. ip must be valid IP
        if configuration["remote_tun_ip"] == nil || configuration["remote_tun_ip"]?.length == 0 {
            return "IP must not be empty"
        }
        if let ip = configuration["remote_tun_ip"] as? String {
            let r = validateIP(ip)
            if r != nil {
                return r
            }
        }
        // 10. routes must be empty or chnroutes
        return nil
    }

}
