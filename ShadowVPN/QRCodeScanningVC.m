//
//  QRCodeScanningVC.m
//  SGQRCodeExample
//
//  Created by apple on 17/3/21.
//  Copyright © 2017年 JP_lee. All rights reserved.
//

#import "QRCodeScanningVC.h"
#import "ShadowBit-Swift.h"

@interface QRCodeScanningVC ()

@end

@implementation QRCodeScanningVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // 注册观察者
    [SGQRCodeNotificationCenter addObserver:self selector:@selector(SGQRCodeInformationFromeAibum:) name:SGQRCodeInformationFromeAibum object:nil];
    [SGQRCodeNotificationCenter addObserver:self selector:@selector(SGQRCodeInformationFromeScanning:) name:SGQRCodeInformationFromeScanning object:nil];
}

//相册
- (void)SGQRCodeInformationFromeAibum:(NSNotification *)noti {
    NSString *string = noti.object;
    
    ScanConfiguration *jumpVC = [[ScanConfiguration alloc] init];
    jumpVC.jump_URL = string;
    if ([jumpVC.jump_URL hasPrefix:@"shadowvpn://"]) {
        [self.navigationController pushViewController:jumpVC animated:false];
    } else {
        [self alertControllerMessage: @"请参考教程扫描正确的二维码!"];
    }
    
}
//扫描
- (void)SGQRCodeInformationFromeScanning:(NSNotification *)noti {
    NSString *string = noti.object;
    
    ScanConfiguration *jumpVC = [[ScanConfiguration alloc] init];
    jumpVC.jump_URL = string;
    if ([jumpVC.jump_URL hasPrefix:@"shadowvpn://"]) {
        [self.navigationController pushViewController:jumpVC animated:false];
    } else {
        [self alertControllerMessage: @"请参考教程扫描正确的二维码!"];
    }
}

- (void)dealloc {
    SGQRCodeLog(@"QRCodeScanningVC - dealloc");
    [SGQRCodeNotificationCenter removeObserver:self];
}
//弹出消息函数
-(void)alertControllerMessage:(NSString *)message{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
    [alert addAction:action];
    [self presentViewController:alert animated:YES completion:nil];
}


@end


