//
//  ViewController.m
//  QrcodeView
//
//  Created by Fangjw on 2017/12/13.
//  Copyright © 2017年 Fangjw. All rights reserved.
//

#import "ViewController.h"
#import "QrcodeView.h"
#import <Masonry/Masonry.h>
#import "GetIpAddress.h"

@interface ViewController ()<QrcodeViewDelegate>

@property (nonatomic, strong) QrcodeView *qrcodeView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.qrcodeView=[[QrcodeView alloc]initWithFrame:CGRectNull scanImg:[UIImage imageNamed:@"scan"] lineImg:[UIImage imageNamed:@"scanRectangle"]];
    [self.qrcodeView createTopView:@"xxx" backImg:[UIImage imageNamed:@"back2"]];
    self.qrcodeView.qrcodeViewDelegate=self;
    [self.view addSubview:self.qrcodeView];
    [self.qrcodeView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    NSString *ipStr = [[GetIpAddress getIPAddresses] objectForKey:@"en0/ipv4"];
    NSLog(@"%@",ipStr);
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)QrcodeViewBackStr:(NSString *)backStr ifSuccess:(BOOL)ifSuccess{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"扫描结果" message:backStr preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self.qrcodeView reStartRunning];
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}

@end
