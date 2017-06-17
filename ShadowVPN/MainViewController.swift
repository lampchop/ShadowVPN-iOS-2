//
//  MainViewController.swift
//  ShadowVPN
//
//  Created by clowwindy on 8/6/15.
//  Copyright © 2015 clowwindy. All rights reserved.
//

import UIKit
import NetworkExtension
import SafariServices

let kTunnelProviderBundle = "com.fengqingyang.sv.tunnel"

class MainViewController: UITableViewController {
    

    var vpnManagers = [NETunnelProviderManager]()
    var currentVPNManager: NETunnelProviderManager?
    var vpnStatusSwitch = UISwitch()
    var vpnStatusLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // self.title = "ShadowVPN"
        self.title = "ShadowBit"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "addConfiguration")
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("VPNStatusDidChange:"), name: NEVPNStatusDidChangeNotification, object: nil)
        vpnStatusSwitch.addTarget(self, action: "vpnStatusSwitchValueDidChange:", forControlEvents: .ValueChanged)
        //        vpnStatusLabel.textAlignment = .Right
        //        vpnStatusLabel.textColor = UIColor.grayColor()
    }

    deinit {
       NSNotificationCenter.defaultCenter().removeObserver(self, name: NEVPNStatusDidChangeNotification, object: nil)
    }
    
    func vpnStatusSwitchValueDidChange(sender: UISwitch) {
        do {
            if vpnManagers.count > 0 {
                if let currentVPNManager = self.currentVPNManager {
                    if sender.on {
                        try currentVPNManager.connection.startVPNTunnel()
                    } else {
                        currentVPNManager.connection.stopVPNTunnel()
                    }
                }
            }
        } catch {
            NSLog("%@", String(error))
        }
    }
    
    func VPNStatusDidChange(notification: NSNotification?) {
        var on = false
        var enabled = false
        if let currentVPNManager = self.currentVPNManager {
            let status = currentVPNManager.connection.status
            switch status {
            case .Connecting:
                on = true
                enabled = false
                vpnStatusLabel.text = "Connecting..."
                break
            case .Connected:
                on = true
                enabled = true
                vpnStatusLabel.text = "Connected"
                break
            case .Disconnecting:
                on = false
                enabled = false
                vpnStatusLabel.text = "Disconnecting..."
                break
            case .Disconnected:
                on = false
                enabled = true
                vpnStatusLabel.text = "Not Connected"
                break
            default:
                on = false
                enabled = true
                break
            }
            vpnStatusSwitch.on = on
            vpnStatusSwitch.enabled = enabled
            UIApplication.sharedApplication().networkActivityIndicatorVisible = !enabled
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.loadConfigurationFromSystem()
        
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = UITableViewCell(style: .Value1, reuseIdentifier: "status")
            cell.selectionStyle = .None
            cell.textLabel?.text = "Status"
            vpnStatusLabel = cell.detailTextLabel!
            cell.accessoryView = vpnStatusSwitch
            return cell
        } else {
            let cell = UITableViewCell(style: .Subtitle, reuseIdentifier: "configuration")
            let vpnManager = self.vpnManagers[indexPath.row]
            // original shows domain resolved ip address
            // cell.textLabel?.text = vpnManager.protocolConfiguration?.serverAddress
            
            // set text to show original domain
            let server_address: String = ((vpnManager.protocolConfiguration as! NETunnelProviderProtocol).providerConfiguration!["server"] as? String)!
            NSLog("ui get server_address %@", server_address)
            
            cell.textLabel?.text = server_address
            cell.detailTextLabel?.text = (vpnManager.protocolConfiguration as! NETunnelProviderProtocol).providerConfiguration!["description"] as? String
            if vpnManager.enabled {
                cell.imageView?.image = UIImage(named: "checkmark")
            } else {
                cell.imageView?.image = UIImage(named: "checkmark_empty")
            }
            cell.accessoryType = .DetailButton
            return cell
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 1 {
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
            let vpnManager = self.vpnManagers[indexPath.row]
            vpnManager.enabled = true
            vpnManager.saveToPreferencesWithCompletionHandler { (error) -> Void in
                self.loadConfigurationFromSystem()
            }
        }
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            return self.vpnManagers.count
        }
    }
    
    override func tableView(tableView: UITableView, accessoryButtonTappedForRowWithIndexPath indexPath: NSIndexPath) {
        let configurationController = ConfigurationViewController(style:.Grouped)
        configurationController.providerManager = self.vpnManagers[indexPath.row]
        self.navigationController?.pushViewController(configurationController, animated: true)
    }
    
    //添加配置
    func addConfiguration() {
        let menuArray = [KxMenuItem.init("Scan QR img",image: UIImage(named: "Scan QR img"),target: self,action: "clickMenu_1"),KxMenuItem.init("Manually Add",image: UIImage(named: "Manually Add"),target: self,action: "clickMenu_2"),KxMenuItem.init("Official Site",image: UIImage(named: "Official Site"),target: self,action: "clickMenu_3")]
        /*设置菜单字体*/
        KxMenu.setTitleFont(UIFont(name: "HelveticaNeue", size: 15))
        
        let options = OptionalConfiguration(arrowSize: 9,  //指示箭头大小
            marginXSpacing: 7,  //MenuItem左右边距
            marginYSpacing: 9,  //MenuItem上下边距
            intervalSpacing: 25,  //MenuItemImage与MenuItemTitle的间距
            menuCornerRadius: 6.5,  //菜单圆角半径
            maskToBackground: true,  //是否添加覆盖在原View上的半透明遮罩
            shadowOfMenu: false,  //是否添加菜单阴影
            hasSeperatorLine: true,  //是否设置分割线
            seperatorLineHasInsets: false,  //是否在分割线两侧留下Insets
            textColor: Color(R: 0, G: 0, B: 0),  //menuItem字体颜色
            menuBackgroundColor: Color(R: 1, G: 1, B: 1)  //菜单的底色
        )
        
        /*菜单位置*/
        let a = CGRect(x: self.view.frame.width-27, y: 70, width: 0, height: 0)
        KxMenu.showMenuInView(self.view, fromRect: a, menuItems: menuArray, withOptions: options)
    }
    
    /** 扫描二维码方法 */
    func clickMenu_1() {
        // 1、 获取摄像设备
        let device = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        if (device != nil) {
            let status = AVCaptureDevice.authorizationStatusForMediaType(AVMediaTypeVideo)
            if status == .NotDetermined {
                AVCaptureDevice.requestAccessForMediaType(AVMediaTypeVideo, completionHandler: {(granted: Bool) -> Void in
                    if granted {
                        dispatch_async(dispatch_get_main_queue(), {() -> Void in
                            let vc = QRCodeScanningVC()
                            self.navigationController!.pushViewController(vc, animated: true)
                        })
                        NSLog("当前线程 - - %@", NSThread.currentThread())
                        // 用户第一次同意了访问相机权限
                        NSLog("用户第一次同意了访问相机权限")
                    } else {
                        // 用户第一次拒绝了访问相机权限
                        NSLog("用户第一次拒绝了访问相机权限")
                    }
                })
            } else if status == .Authorized {
                // 用户允许当前应用访问相机
                let vc = QRCodeScanningVC()
                self.navigationController!.pushViewController(vc, animated: true)
            }
            else if status == .Denied {
                // 用户拒绝当前应用访问相机
                let alertC = UIAlertController(title: "⚠️ 警告", message: "请去-> [设置 - 隐私 - 相机 - SGQRCodeExample] 打开访问开关", preferredStyle: (.Alert))
                let alertA = UIAlertAction(title: "确定", style: .Default, handler: {(action: UIAlertAction) -> Void in
                })
                alertC.addAction(alertA)
                self.presentViewController(alertC, animated: true, completion: { _ in })
            }
            else if status == .Restricted {
                print("因为系统原因, 无法访问相册")
            } else {
                let alertC = UIAlertController(title: "温馨提示", message: "未检测到您的摄像头", preferredStyle: (.Alert))
                let alertA = UIAlertAction(title: "确定", style: .Default, handler: {(action: UIAlertAction) -> Void in
                })
                alertC.addAction(alertA)
                self.presentViewController(alertC, animated: true, completion: { _ in })            }
            
        }

    }
    
    ///手动添加
    func clickMenu_2() {
        let manager = NETunnelProviderManager()
        manager.loadFromPreferencesWithCompletionHandler { (error) -> Void in
            let providerProtocol = NETunnelProviderProtocol()
            providerProtocol.providerBundleIdentifier = kTunnelProviderBundle
            providerProtocol.providerConfiguration = [String: AnyObject]()
            manager.protocolConfiguration = providerProtocol
            
            let configurationController = ConfigurationViewController(style:.Grouped)
            configurationController.providerManager = manager
            self.navigationController?.pushViewController(configurationController, animated: true)
            manager.saveToPreferencesWithCompletionHandler({ (error) -> Void in
                print(error)
            })
        }
    }

    func clickMenu_3() {
        print("成功啦")
        let safari = SFSafariViewController(URL: NSURL(string: "http://freesv.ishadow.pub")!)
        self.presentViewController(safari, animated: true, completion: nil)
    }
    func loadConfigurationFromSystem() {
        NETunnelProviderManager.loadAllFromPreferencesWithCompletionHandler() { newManagers, error in
            print(error)
            guard let vpnManagers = newManagers else { return }
            self.vpnManagers.removeAll()
            for vpnManager in vpnManagers {
                if let providerProtocol = vpnManager.protocolConfiguration as? NETunnelProviderProtocol {
                    if providerProtocol.providerBundleIdentifier == kTunnelProviderBundle {
                        if vpnManager.enabled {
                            self.currentVPNManager = vpnManager
                        }
                        self.vpnManagers.append(vpnManager)
                    }
                }
            }
            self.vpnStatusSwitch.enabled = vpnManagers.count > 0
            self.tableView.reloadData()
            self.VPNStatusDidChange(nil)
        }
    }
    
}
