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
    var providerManager: NETunnelProviderManager?
    var bindMap = [String: UITextField]()
    var configuration = [String: AnyObject]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        jump_URL = String(jump_URL.characters.dropFirst(12))
        print(jump_URL)
        
        // 将base64字符串转换成NSData
        let base64EncodedData = NSData(base64EncodedString:jump_URL,options:NSDataBase64DecodingOptions(rawValue: 0))
        // 对NSData数据进行UTF8解码
        let stringWithDecode = NSString(data: base64EncodedData!, encoding: NSUTF8StringEncoding)

        
        ///-------拿到的stringWithDecode处理添加配置就可以了
        
        self.navigationController?.popToRootViewControllerAnimated(true)

    }

    //  手动填写配置的表单里的数据，映射成 key/value的 map数据结构
    func bindData(textField: UITextField, property: String) {
        let val: AnyObject? = configuration[property]
        if let val = val {
            textField.text = String(val)
        }
        bindMap[property] = textField
    }

    //  先更新下map这个数据结构 ，后面再把这些配置保存到providerManager里，并且跳转到主界面
    func save() {
        updateConfiguration()
        if let result = ConfigurationValidator.validate(self.configuration) {
            let alertController = UIAlertController(title: "Error", message: result, preferredStyle: .Alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: { (action) -> Void in
            }))
            self.presentViewController(alertController, animated: true, completion: { () -> Void in
            })
            return
        }
        (self.providerManager?.protocolConfiguration as! NETunnelProviderProtocol).providerConfiguration = self.configuration
        // self.providerManager?.protocolConfiguration?.serverAddress = self.configuration["server"] as? String
        // get server_ip from resolve result, as config item may be an ip address or a domain
        var server_ip: String = ""
        server_ip = self.domain_resolve((self.configuration["server"] as? String)!)
        self.providerManager?.protocolConfiguration?.serverAddress = server_ip
        NSLog("set vpn server ip address [%@]", server_ip)
        
        self.providerManager?.localizedDescription = self.configuration["server"] as? String
        
        self.providerManager?.saveToPreferencesWithCompletionHandler { (error) -> Void in
            self.navigationController?.popViewControllerAnimated(true)
        }
    }
    //更新 self.configuration 这个map数据结构。 map主是key/value映射
    func updateConfiguration() {
        for (k, v) in self.bindMap {
            self.configuration[k] = v.text
        }
        //        self.configuration["route"] = "chnroutes"
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

}