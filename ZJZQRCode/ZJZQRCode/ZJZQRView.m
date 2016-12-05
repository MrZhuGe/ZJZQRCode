//
//  ZJZQRView.m
//  ZJZQRCode
//
//  Created by 郑家柱 on 16/12/2.
//  Copyright © 2016年 Mobcb. All rights reserved.
//

#import "ZJZQRView.h"

static NSTimeInterval kQrLineanimateDuration = 0.02;

@interface ZJZQRView ()

@property (nonatomic, strong) UIImageView           *qrLine;
@property (nonatomic, assign) CGFloat               qrLineY;

@end

@implementation ZJZQRView

- (void)layoutSubviews
{
    [super layoutSubviews];
    if (!self.qrLine) {
        
        [self initQRLine];
        [self initDescLabel];
        
        NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:kQrLineanimateDuration target:self selector:@selector(show) userInfo:nil repeats:YES];
        [timer fire];
    }
}

// MARK: 扫描线
- (void)initQRLine
{
    self.qrLine  = [[UIImageView alloc] initWithFrame:CGRectMake(self.bounds.size.width/2 - self.transparentArea.width/2, self.bounds.size.height/2 - self.transparentArea.height/2, self.transparentArea.width, 2)];
    self.qrLine.image = [UIImage imageNamed:@"qr_scan_line"];
    self.qrLine.contentMode = UIViewContentModeScaleAspectFill;
    [self addSubview:self.qrLine];
    
    self.qrLineY = self.qrLine.frame.origin.y;
}

// MARK: 文字描述
- (void)initDescLabel
{
    UILabel *descL= [[UILabel alloc] init];
    descL.frame = CGRectMake(15, self.frame.size.height/2 + self.transparentArea.height/2 + 15, self.frame.size.width - 30, 20);
    descL.textAlignment = NSTextAlignmentCenter;
    descL.textColor = [UIColor whiteColor];
    descL.text = @"将二维码/条码放入框内，即可自动扫描";
    descL.font = [UIFont systemFontOfSize:14];
    [self addSubview:descL];
}

- (void)show
{
    [UIView animateWithDuration:kQrLineanimateDuration animations:^{
        
        CGRect rect = self.qrLine.frame;
        rect.origin.y = self.qrLineY;
        self.qrLine.frame = rect;
        
    } completion:^(BOOL finished) {
        
        CGFloat maxBorder = self.frame.size.height/2 + self.transparentArea.height/2 - 4;
        if (self.qrLineY > maxBorder) {
            
            self.qrLineY = self.frame.size.height/2 - self.transparentArea.height/2;
        }
        self.qrLineY++;
    }];
}

- (void)drawRect:(CGRect)rect
{
    // 整个二维码扫描界面的颜色
    CGRect screenDrawRect = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    
    // 中间清空的矩形框
    CGRect clearDrawRect = CGRectMake(screenDrawRect.size.width/2 - self.transparentArea.width/2,
                                      screenDrawRect.size.height/2 - self.transparentArea.height/2,
                                      self.transparentArea.width, self.transparentArea.height);
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    [self addScreenFillRect:ctx rect:screenDrawRect];
    
    [self addCenterClearRect:ctx rect:clearDrawRect];
    
    [self addWhiteRect:ctx rect:clearDrawRect];
    
    [self addCornerLineWithContext:ctx rect:clearDrawRect];
}

- (void)addScreenFillRect:(CGContextRef)ctx rect:(CGRect)rect
{
    CGContextSetRGBFillColor(ctx, 40/255.0, 40/255.0, 40/255.0,0.5);
    
    //draw the transparent layer
    CGContextFillRect(ctx, rect);
}

- (void)addCenterClearRect :(CGContextRef)ctx rect:(CGRect)rect
{
    //clear the center rect  of the layer
    CGContextClearRect(ctx, rect);
}

- (void)addWhiteRect:(CGContextRef)ctx rect:(CGRect)rect {
    
    CGContextStrokeRect(ctx, rect);
    CGContextSetRGBStrokeColor(ctx, 1, 1, 1, 1);
    CGContextSetLineWidth(ctx, 0.8);
    CGContextAddRect(ctx, rect);
    CGContextStrokePath(ctx);
}

- (void)addCornerLineWithContext:(CGContextRef)ctx rect:(CGRect)rect {
    
    // 画四个边角
    CGContextSetLineWidth(ctx, 5);
    
    // 绿色
    CGContextSetRGBStrokeColor(ctx, 83/255.0, 239/255.0, 111/255.0, 1);
    
    // 左上角
    CGPoint poinsTopLeftA[] = {
        CGPointMake(rect.origin.x + 0.7, rect.origin.y),
        CGPointMake(rect.origin.x + 0.7 , rect.origin.y + 15)
    };
    
    CGPoint poinsTopLeftB[] = {CGPointMake(rect.origin.x, rect.origin.y + 0.7), CGPointMake(rect.origin.x + 15, rect.origin.y + 0.7)};
    [self addLine:poinsTopLeftA pointB:poinsTopLeftB ctx:ctx];
    
    // 左下角
    CGPoint poinsBottomLeftA[] = {CGPointMake(rect.origin.x + 0.7, rect.origin.y + rect.size.height - 15), CGPointMake(rect.origin.x + 0.7, rect.origin.y + rect.size.height)};
    CGPoint poinsBottomLeftB[] = {CGPointMake(rect.origin.x, rect.origin.y + rect.size.height - 0.7), CGPointMake(rect.origin.x + 0.7 + 15, rect.origin.y + rect.size.height - 0.7)};
    [self addLine:poinsBottomLeftA pointB:poinsBottomLeftB ctx:ctx];
    
    // 右上角
    CGPoint poinsTopRightA[] = {CGPointMake(rect.origin.x + rect.size.width - 15, rect.origin.y + 0.7), CGPointMake(rect.origin.x + rect.size.width, rect.origin.y +0.7 )};
    CGPoint poinsTopRightB[] = {CGPointMake(rect.origin.x + rect.size.width - 0.7, rect.origin.y), CGPointMake(rect.origin.x + rect.size.width - 0.7,rect.origin.y + 15 + 0.7)};
    [self addLine:poinsTopRightA pointB:poinsTopRightB ctx:ctx];
    
    CGPoint poinsBottomRightA[] = {CGPointMake(rect.origin.x + rect.size.width - 0.7, rect.origin.y + rect.size.height - 15),CGPointMake(rect.origin.x - 0.7 + rect.size.width, rect.origin.y + rect.size.height)};
    CGPoint poinsBottomRightB[] = {CGPointMake(rect.origin.x + rect.size.width - 15 , rect.origin.y + rect.size.height - 0.7),CGPointMake(rect.origin.x + rect.size.width, rect.origin.y + rect.size.height - 0.7)};
    [self addLine:poinsBottomRightA pointB:poinsBottomRightB ctx:ctx];
    CGContextStrokePath(ctx);
}

- (void)addLine:(CGPoint[])pointA pointB:(CGPoint[])pointB ctx:(CGContextRef)ctx {
    
    CGContextAddLines(ctx, pointA, 2);
    CGContextAddLines(ctx, pointB, 2);
}

@end
