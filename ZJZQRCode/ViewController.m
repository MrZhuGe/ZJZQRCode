//
//  ViewController.m
//  ZJZQRCode
//
//  Created by 郑家柱 on 16/12/2.
//  Copyright © 2016年 Mobcb. All rights reserved.
//

#import "ViewController.h"
#import "ZJZQRCodeController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.title = @"二维码扫描";
    
    [self initOpenBtn];
}

// MARK: 入口
- (void)initOpenBtn
{
    UIButton *openBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    openBtn.frame = CGRectMake(0, 0, 100, 30);
    openBtn.center = CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2);
    openBtn.backgroundColor = [UIColor orangeColor];
    [openBtn setTitle:@"Open" forState:UIControlStateNormal];
    [openBtn addTarget:self action:@selector(onOpenBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:openBtn];
}

// MARK: 点击事件
- (void)onOpenBtnClicked:(UIButton *)button
{
    ZJZQRCodeController *qrVC = [[ZJZQRCodeController alloc] init];
    [self.navigationController pushViewController:qrVC animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
