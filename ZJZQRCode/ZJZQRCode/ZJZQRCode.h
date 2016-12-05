//
//  ZJZQRCode.h
//  ZJZQRCode
//
//  Created by 郑家柱 on 16/12/5.
//  Copyright © 2016年 Mobcb. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZJZQRCode : NSObject

// MARK: 二维码
// 根据指定内容生成二维码
- (UIImage *)imageOfURL:(NSString *)url;

// 根据指定内容生成二维码、二维码尺寸
- (UIImage *)imageOfURL:(NSString *)url size:(CGFloat)size;

// 根据指定内容生成二维码、二维码尺寸、二维码颜色
- (UIImage *)imageOfURL:(NSString *)url size:(CGFloat)size r:(NSUInteger)r g:(NSUInteger)g b:(NSUInteger)b;

// 根据指定内容生成二维码、二维码尺寸、二维码颜色、二维码中间logo
- (UIImage *)imageOfURL:(NSString *)url size:(CGFloat)size r:(NSUInteger)r g:(NSUInteger)g b:(NSUInteger)b logo:(UIImage *)logo radius:(CGFloat)radius;

// MARK: 条形码 iOS8.0以上
- (CIImage *)barCodeImageOfURL:(NSString *)url;

@end
