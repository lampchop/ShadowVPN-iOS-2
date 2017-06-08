//
//  MainViewController.swift
//  ShadowVPN
//
//  Created by clowwindy on 8/6/15.
//  Copyright © 2015 clowwindy. All rights reserved.
//

import UIKit
import NetworkExtension

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
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(MainViewController.addConfiguration))
        
        NotificationCenter.default.addObserver(self, selector: #selector(MainViewController.VPNStatusDidChange(_:)), name: NSNotification.Name.NEVPNStatusDidChange, object: nil)
        vpnStatusSwitch.addTarget(self, action: #selector(MainViewController.vpnStatusSwitchValueDidChange(_:)), for: .valueChanged)
//        vpnStatusLabel.textAlignment = .Right
//        vpnStatusLabel.textColor = UIColor.grayColor()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.NEVPNStatusDidChange, object: nil)
    }
    
    func vpnStatusSwitchValueDidChange(_ sender: UISwitch) {
        do {
            if vpnManagers.count > 0 {
                if let currentVPNManager = self.currentVPNManager {
                    if sender.isOn {
                        try currentVPNManager.connection.startVPNTunnel()
                    } else {
                        currentVPNManager.connection.stopVPNTunnel()
                    }
                }
            }
        } catch {
            NSLog("%@", String(describing: error))
        }
    }

    func VPNStatusDidChange(_ notification: Notification?) {
        var on = false
        var enabled = false
        if let currentVPNManager = self.currentVPNManager {
            let status = currentVPNManager.connection.status
            switch status {
            case .connecting:
                on = true
                enabled = false
                vpnStatusLabel.text = "Connecting..."
                break
            case .connected:
                on = true
                enabled = true
                vpnStatusLabel.text = "Connected"
                break
            case .disconnecting:
                on = false
                enabled = false
                vpnStatusLabel.text = "Disconnecting..."
                break
            case .disconnected:
                on = false
                enabled = true
                vpnStatusLabel.text = "Not Connected"
                break
            default:
                on = false
                enabled = true
                break
            }
            vpnStatusSwitch.isOn = on
            vpnStatusSwitch.isEnabled = enabled
            UIApplication.shared.isNetworkActivityIndicatorVisible = !enabled
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.loadConfigurationFromSystem()
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = UITableViewCell(style: .value1, reuseIdentifier: "status")
            cell.selectionStyle = .none
            cell.textLabel?.text = "Status"
            vpnStatusLabel = cell.detailTextLabel!
            cell.accessoryView = vpnStatusSwitch
            return cell
        } else {
            let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "configuration")
            let vpnManager = self.vpnManagers[indexPath.row]
            // original shows domain resolved ip address
            // cell.textLabel?.text = vpnManager.protocolConfiguration?.serverAddress
            
            // set text to show original domain
            let server_address: String = ((vpnManager.protocolConfiguration as! NETunnelProviderProtocol).providerConfiguration!["server"] as? String)!
            NSLog("ui get server_address %@", server_address)
            
            cell.textLabel?.text = server_address
            cell.detailTextLabel?.text = (vpnManager.protocolConfiguration as! NETunnelProviderProtocol).providerConfiguration!["description"] as? String
            if vpnManager.isEnabled {
                cell.imageView?.image = UIImage(named: "checkmark")
            } else {
                cell.imageView?.image = UIImage(named: "checkmark_empty")
            }
            cell.accessoryType = .detailButton
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            tableView.deselectRow(at: indexPath, animated: true)
            let vpnManager = self.vpnManagers[indexPath.row]
            vpnManager.isEnabled = true
            vpnManager.saveToPreferences { (error) -> Void in
                self.loadConfigurationFromSystem()
            }
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            return self.vpnManagers.count
        }
    }
    
    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        let configurationController = ConfigurationViewController(style:.grouped)
        configurationController.providerManager = self.vpnManagers[indexPath.row]
        self.navigationController?.pushViewController(configurationController, animated: true)
    }
    
    func addConfiguration() {
        let menuArray = [KxMenuItem.init("Scan QR img",image: UIImage(named: "Scan QR img"),target: self,action: #selector(self.clickMenu1(sender:))),KxMenuItem.init("Manually Add",image: UIImage(named: "Manually Add"),target: self,action: #selector(self.clickMenu_2(sender:)))]
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
        KxMenu.show(in: self.view, from: a, menuItems: menuArray as Any as! [Any], withOptions: options)
    }

    func clickMenu1(sender: AnyObject) {
        print("调用成功")
        /** 扫描二维码方法 */
        // 1、 获取摄像设备
        var device = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        if ((device) != nil) {
            var status: AVAuthorizationStatus = AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo)
            if status == .notDetermined {
                AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeVideo, completionHandler: {(_ granted: Bool) -> Void in
                    if granted {
                        DispatchQueue.main.async(execute: {() -> Void in
                            var vc = QRCodeScanningVC()
                            self.navigationController?.pushViewController(vc, animated: true)
                        })
                        NSLog("当前线程 - - %@", Thread.current)
                        // 用户第一次同意了访问相机权限
                        NSLog("用户第一次同意了访问相机权限")
                    } else {
                        // 用户第一次拒绝了访问相机权限
                        NSLog("用户第一次拒绝了访问相机权限")
                    }
                })
            } else if status == .authorized {
                // 用户允许当前应用访问相机
                var vc = QRCodeScanningVC()
                navigationController?.pushViewController(vc, animated: true)
            } else if status == .denied {
                // 用户拒绝当前应用访问相机
                var alertC = UIAlertController(title: "⚠️ 警告", message: "请去-> [设置 - 隐私 - 相机 - SGQRCodeExample] 打开访问开关", preferredStyle: (.alert))
                var alertA = UIAlertAction(title: "确定", style: (.default), handler: {(_ action: UIAlertAction) -> Void in
                })
                alertC.addAction(alertA)
                present(alertC, animated: true, completion: { _ in })
            } else if status == .restricted {
                print("因为系统原因, 无法访问相册")
            } else {
                var alertC = UIAlertController(title: "温馨提示", message: "未检测到您的摄像头", preferredStyle: (.alert))
                var alertA = UIAlertAction(title: "确定", style: (.default), handler: {(_ action: UIAlertAction) -> Void in
                })
                alertC.addAction(alertA)
                present(alertC, animated: true, completion: { _ in })
            }
            
        }
    }
    
    func clickMenu_2(sender: AnyObject){
        print("点击成功")
        
        let manager = NETunnelProviderManager()
        manager.loadFromPreferences { (error) -> Void in
            let providerProtocol = NETunnelProviderProtocol()
            providerProtocol.providerBundleIdentifier = kTunnelProviderBundle
            providerProtocol.providerConfiguration = [String: AnyObject]()
            manager.protocolConfiguration = providerProtocol
            
            let configurationController = ConfigurationViewController(style:.grouped)
            configurationController.providerManager = manager
            self.navigationController?.pushViewController(configurationController, animated: true)
            manager.saveToPreferences(completionHandler: { (error) -> Void in
                print(error as Any)
            })
        }
        
    }

    func loadConfigurationFromSystem() {
        NETunnelProviderManager.loadAllFromPreferences() { newManagers, error in
            print(error as Any)
            guard let vpnManagers = newManagers else { return }
            self.vpnManagers.removeAll()
            for vpnManager in vpnManagers {
                if let providerProtocol = vpnManager.protocolConfiguration as? NETunnelProviderProtocol {
                    if providerProtocol.providerBundleIdentifier == kTunnelProviderBundle {
                        if vpnManager.isEnabled {
                            self.currentVPNManager = vpnManager
                        }
                        self.vpnManagers.append(vpnManager)
                    }
                }
            }
            self.vpnStatusSwitch.isEnabled = vpnManagers.count > 0
            self.tableView.reloadData()
            self.VPNStatusDidChange(nil)
        }
    }

}
