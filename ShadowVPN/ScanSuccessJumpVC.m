//
//  ScanSuccessJumpVC.m
//  SGQRCodeExample
//
//  Created by Sorgle on 16/8/29.
//  Copyright © 2016年 Sorgle. All rights reserved.
//

#import "ScanSuccessJumpVC.h"
#import "SGWebView.h"
#import "SGQRCodeConst.h"

@interface ScanSuccessJumpVC () <SGWebViewDelegate>
@property (nonatomic , strong) SGWebView *webView;
@end

@implementation ScanSuccessJumpVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self setupNavigationItem];
    
    [self setupLabel];
    
    //    [self alertControllerMessage: @"扫描不成功"];
}

- (void)setupNavigationItem {
    UIButton *left_Button = [[UIButton alloc] init];
    [left_Button setTitle:@"back" forState:UIControlStateNormal];
    [left_Button setTitleColor:[UIColor colorWithRed: 21/ 255.0f green: 126/ 255.0f blue: 251/ 255.0f alpha:1.0] forState:(UIControlStateNormal)];
    [left_Button sizeToFit];
    [left_Button addTarget:self action:@selector(left_BarButtonItemAction) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *left_BarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:left_Button];
    self.navigationItem.leftBarButtonItem = left_BarButtonItem;
    
}
- (void)left_BarButtonItemAction {
    [self.navigationController popToRootViewControllerAnimated:YES];
}


// 添加Label，加载扫描过来的内容
- (void)setupLabel {
    // 提示文字
    UILabel *prompt_message = [[UILabel alloc] init];
    prompt_message.frame = CGRectMake(0, 200, self.view.frame.size.width, 30);
    prompt_message.text = @"您扫描的二维码结果如下： ";
    prompt_message.textColor = [UIColor redColor];
    prompt_message.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:prompt_message];
    
    // 扫描结果
    CGFloat label_Y = CGRectGetMaxY(prompt_message.frame);
    UILabel *label = [[UILabel alloc] init];
    label.frame = CGRectMake(0, label_Y, self.view.frame.size.width, 30);
    label.text = self.jump_URL;
    label.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:label];
}


- (void)webView:(SGWebView *)webView didFinishLoadWithURL:(NSURL *)url {
    SGQRCodeLog(@"didFinishLoad");
    self.title = webView.navigationItemTitle;
}

////弹出消息函数
//-(void)alertControllerMessage:(NSString *)message{
//    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:message preferredStyle:UIAlertControllerStyleAlert];
//    UIAlertAction *action = [UIAlertAction actionWithTitle:@"cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
//    }];
//    [alert addAction:action];
//    [self presentViewController:alert animated:YES completion:nil];
//}


@end

