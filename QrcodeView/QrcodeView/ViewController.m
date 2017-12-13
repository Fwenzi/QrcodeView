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

@interface ViewController ()

@property (nonatomic, strong) QrcodeView *qrcodeView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    QrcodeView *view=[[QrcodeView alloc]initWithFrame:CGRectNull scanImg:[UIImage imageNamed:@"scan"] lineImg:[UIImage imageNamed:@"scanRectangle"]];
    [view createTopView:@"xxx" backImg:[UIImage imageNamed:@"back2"]];
    [self.view addSubview:view];
    [view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
