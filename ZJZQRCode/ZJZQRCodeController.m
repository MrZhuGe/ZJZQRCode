//
//  ZJZQRCodeController.m
//  ZJZQRCode
//
//  Created by 郑家柱 on 16/12/2.
//  Copyright © 2016年 Mobcb. All rights reserved.
//

#import "ZJZQRCodeController.h"
#import <AVFoundation/AVFoundation.h>
#import "ZJZQRView.h"

@interface ZJZQRCodeController () <AVCaptureMetadataOutputObjectsDelegate>

@property (nonatomic, strong) AVCaptureDevice               *device;
@property (nonatomic, strong) AVCaptureDeviceInput          *input;
@property (nonatomic, strong) AVCaptureMetadataOutput       *output;
@property (nonatomic, strong) AVCaptureSession              *session;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer    *preview;

@end

@implementation ZJZQRCodeController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"扫一扫";
    
    [self configureSession];
    [self initView];
}

// MARK: AVCaptureSession
- (void)configureSession
{
    // Device
    self.device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    // Input
    self.input = [AVCaptureDeviceInput deviceInputWithDevice:self.device error:nil];
    
    // Output
    self.output = [[AVCaptureMetadataOutput alloc]init];
    [self.output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    
    // Session
    self.session = [[AVCaptureSession alloc]init];
    [self.session setSessionPreset:AVCaptureSessionPresetHigh];
    
    if ([self.session canAddInput:self.input]) {
        [self.session addInput:self.input];
    }
    
    if ([self.session canAddOutput:self.output]) {
        [self.session addOutput:self.output];
    }
    
    // 初始化条码类型为二维码类型
    self.output.metadataObjectTypes = @[AVMetadataObjectTypeQRCode,
                                        AVMetadataObjectTypeEAN13Code,
                                        AVMetadataObjectTypeEAN8Code,
                                        AVMetadataObjectTypeCode128Code];
    
    // Preview
    self.preview =[AVCaptureVideoPreviewLayer layerWithSession:self.session];
    self.preview.videoGravity =AVLayerVideoGravityResize;
    self.preview.frame =self.view.layer.bounds;
    [self.view.layer insertSublayer:self.preview atIndex:0];
    
    [self.session startRunning];
}

// MARK: Init Current View
- (void)initView
{
    // 主屏宽度
    CGFloat mainWidth = [UIScreen mainScreen].bounds.size.width;
    
    CGRect screenRect = [UIScreen mainScreen].bounds;
    ZJZQRView *qrRectView = [[ZJZQRView alloc] initWithFrame:screenRect];
    qrRectView.transparentArea = CGSizeMake(mainWidth - 80, mainWidth - 80);
    qrRectView.backgroundColor = [UIColor clearColor];
    qrRectView.center = CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2);
    [self.view addSubview:qrRectView];
    
    UIButton *openBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    openBtn.frame = CGRectMake(260, 0, 50, 50);
    [openBtn setTitle:@"开灯" forState:UIControlStateNormal];
    [openBtn addTarget:self action:@selector(openFlashlight:) forControlEvents:UIControlEventTouchUpInside];
    [openBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    
    UIBarButtonItem *openItem = [[UIBarButtonItem alloc] initWithCustomView:openBtn];
    
    self.navigationItem.rightBarButtonItem = openItem;
    
    //修正扫描区域
    CGFloat screenHeight = self.view.frame.size.height;
    CGFloat screenWidth = self.view.frame.size.width;
    CGRect cropRect = CGRectMake((screenWidth - qrRectView.transparentArea.width)/2,
                                 (screenHeight - qrRectView.transparentArea.height)/2,
                                 qrRectView.transparentArea.width,
                                 qrRectView.transparentArea.height);
    
    [self.output setRectOfInterest:CGRectMake(cropRect.origin.y/screenHeight,
                                              cropRect.origin.x/screenWidth,
                                              cropRect.size.height/screenHeight,
                                              cropRect.size.width/screenWidth)];
}

- (void)openFlashlight:(UIButton *)sender
{
    sender.selected = !sender.selected;
    Class captureDeviceClass = NSClassFromString(@"AVCaptureDevice");
    if (captureDeviceClass != nil) {
        AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        if ([device hasTorch] && [device hasFlash]){
            
            [device lockForConfiguration:nil];
            if (sender.selected) {
                [sender setTitle:@"关灯" forState:UIControlStateNormal];
                [device setTorchMode:AVCaptureTorchModeOn];
                [device setFlashMode:AVCaptureFlashModeOn];
            } else {
                [sender setTitle:@"开灯" forState:UIControlStateNormal];
                [device setTorchMode:AVCaptureTorchModeOff];
                [device setFlashMode:AVCaptureFlashModeOff];
            }
            [device unlockForConfiguration];
        }
    }
}

// MARK: AVCaptureMetadataOutputObjectsDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    NSString *stringValue;
    if ([metadataObjects count] > 0) {
        //停止扫描
        [self.session stopRunning];
        AVMetadataMachineReadableCodeObject * metadataObject = [metadataObjects objectAtIndex:0];
        stringValue = metadataObject.stringValue;
    }
    
    NSLog(@"Scan Result:%@", stringValue);
}

- (void)viewDidDisappear:(BOOL)animated
{
    [self.session stopRunning];
    [self.preview removeFromSuperlayer];
}

- (void)dealloc
{
    self.session = nil;
    self.device = nil;
    self.input = nil;
    self.output = nil;
    self.preview = nil;
}

@end
