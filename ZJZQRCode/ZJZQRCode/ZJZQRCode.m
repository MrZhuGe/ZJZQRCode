//
//  ZJZQRCode.m
//  ZJZQRCode
//
//  Created by 郑家柱 on 16/12/5.
//  Copyright © 2016年 Mobcb. All rights reserved.
//

#import "ZJZQRCode.h"

@implementation ZJZQRCode

// MARK: Public Methods
// 根据指定内容生成二维码
- (UIImage *)imageOfURL:(NSString *)url
{
    return [self imageOfURL:url size:100.0f r:0 g:0 b:0 logo:nil radius: 0.f];
}

// 根据指定内容生成二维码、二维码尺寸
- (UIImage *)imageOfURL:(NSString *)url size:(CGFloat)size
{
    return [self imageOfURL:url size:size r:0 g:0 b:0 logo:nil radius: 0.f];
}

// 根据指定内容生成二维码、二维码尺寸、二维码颜色
- (UIImage *)imageOfURL:(NSString *)url size:(CGFloat)size r:(NSUInteger)r g:(NSUInteger)g b:(NSUInteger)b
{
    return [self imageOfURL:url size:size r:r g:g b:b logo:nil radius: 0.f];
}

// 根据指定内容生成二维码、二维码尺寸、二维码颜色、二维码中间logo、logo圆角半径
- (UIImage *)imageOfURL:(NSString *)url size:(CGFloat)size r:(NSUInteger)r g:(NSUInteger)g b:(NSUInteger)b logo:(UIImage *)logo radius:(CGFloat)radius
{
    NSAssert(!url || (NSNull *)url == [NSNull null], @"This url is nil.");
    NSUInteger rgb = (r << 16) + (g << 8) + b;
    NSAssert((rgb & 0xffffff00) <= 0xd0d0d000, @"The color is very close to white.");
    
    size = [self validateQRSize:size];
    CIImage *originImage = [self ciimageOfURL:url];
    
    // 生成黑白的二维码图片
    UIImage *bwImage = [self imageOfOriginImage:originImage size:size];
    
    // 进行颜色渲染后的二维码
    UIImage *effectiveImage = [self imageOfBWImage:bwImage r:r g:r b:b];
    
    return [self imageInsertImage:effectiveImage insertImage:logo radius:radius];;
}

// MARK: Private Methods
// 验证二维码尺寸是否合理
- (CGFloat)validateQRSize:(CGFloat)size
{
    size = MAX(160, size);
    size = MIN(CGRectGetWidth([UIScreen mainScreen].bounds) - 80, size);
    return size;
}

// 根据指定内容生成原生二维码，需要再次加工
- (CIImage *)ciimageOfURL:(NSString *)url
{
    NSData *strData = [url dataUsingEncoding: NSUTF8StringEncoding];
    CIFilter *qrFilter = [CIFilter filterWithName: @"CIQRCodeGenerator"];
    [qrFilter setValue:strData forKey:@"inputMessage"];
    [qrFilter setValue:@"H" forKey:@"inputCorrectionLevel"];
    
    return qrFilter.outputImage;
}

// 对原始生成的二维码进行加工，返回大小合适的二维码，还需要进行颜色加工
- (UIImage *)imageOfOriginImage:(CIImage *)originImage size:(CGFloat)size
{
    CGRect extent = CGRectIntegral(originImage.extent);
    CGFloat scale = MIN(size/CGRectGetWidth(extent), size/CGRectGetHeight(extent));
    size_t width = CGRectGetWidth(extent) * scale;
    size_t height = CGRectGetHeight(extent) * scale;
    
    //创建灰度色调空间
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
    CGContextRef bitmapRef = CGBitmapContextCreate(nil, width, height, 8, 0, colorSpace, (CGBitmapInfo)kCGImageAlphaNone);
    CIContext *context = [CIContext contextWithOptions: nil];
    CGImageRef bitmapImage = [context createCGImage:originImage fromRect: extent];
    
    CGContextSetInterpolationQuality(bitmapRef, kCGInterpolationNone);
    CGContextScaleCTM(bitmapRef, scale, scale);
    CGContextDrawImage(bitmapRef, extent, bitmapImage);
    
    CGImageRef scaledImage = CGBitmapContextCreateImage(bitmapRef);
    CGContextRelease(bitmapRef);
    CGImageRelease(bitmapImage);
    CGColorSpaceRelease(colorSpace);
    return [UIImage imageWithCGImage: scaledImage];
}

// 对黑白二维码进行颜色加工
- (UIImage *)imageOfBWImage:(UIImage *)bwImage r:(NSUInteger)r g:(NSUInteger)g b:(NSUInteger)b
{
    const int imageWidth = bwImage.size.width;
    const int imageHeight = bwImage.size.height;
    size_t bytesPerRow = imageWidth * 4;
    uint32_t * rgbImageBuf = (uint32_t *)malloc(bytesPerRow * imageHeight);
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(rgbImageBuf, imageWidth, imageHeight, 8, bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaNoneSkipLast);
    CGContextDrawImage(context, (CGRect){(CGPointZero), (bwImage.size)}, bwImage.CGImage);
    
    //遍历像素
    int pixelNumber = imageHeight * imageWidth;
    [self fillWhiteToTransparentOnPixel:rgbImageBuf pixelNum:pixelNumber r:r g:g b:b];
    
    CGDataProviderRef dataProvider = CGDataProviderCreateWithData(NULL, rgbImageBuf, bytesPerRow, ProviderReleaseData);
    CGImageRef imageRef = CGImageCreate(imageWidth, imageHeight, 8, 32, bytesPerRow, colorSpace, kCGImageAlphaLast | kCGBitmapByteOrder32Little, dataProvider, NULL, true, kCGRenderingIntentDefault);
    
    UIImage * resultImage = [UIImage imageWithCGImage: imageRef];
    CGImageRelease(imageRef);
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);
    
    return resultImage;
}

- (UIImage *)imageInsertImage:(UIImage *)originImage insertImage:(UIImage *)insertImage radius:(CGFloat)radius
{
    if (!insertImage) { return originImage; }
    insertImage = [self imageOfRoundRectWithImage: insertImage size: insertImage.size radius: radius];
    UIImage * whiteBG = [UIImage imageNamed: @"whiteBG"];
    whiteBG = [self imageOfRoundRectWithImage: whiteBG size: whiteBG.size radius: radius];
    
    //白色边缘宽度
    const CGFloat whiteSize = 5.f;
    CGSize brinkSize = CGSizeMake(originImage.size.width / 4, originImage.size.height / 4);
    CGFloat brinkX = (originImage.size.width - brinkSize.width) * 0.5;
    CGFloat brinkY = (originImage.size.height - brinkSize.height) * 0.5;
    
    CGSize imageSize = CGSizeMake(brinkSize.width - 2 * whiteSize, brinkSize.height - 2 * whiteSize);
    CGFloat imageX = brinkX + whiteSize;
    CGFloat imageY = brinkY + whiteSize;
    
    UIGraphicsBeginImageContext(originImage.size);
    [originImage drawInRect: (CGRect){ 0, 0, (originImage.size) }];
    [whiteBG drawInRect: (CGRect){ brinkX, brinkY, (brinkSize) }];
    [insertImage drawInRect: (CGRect){ imageX, imageY, (imageSize) }];
    UIImage * resultImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return resultImage;
}

// 遍历像素，将白色区域填充为透明色
- (void)fillWhiteToTransparentOnPixel:(uint32_t *)rgbImageBuf pixelNum:(int)pixelNum r:(NSUInteger)r g:(NSUInteger)g b:(NSUInteger)b
{
    uint32_t * pCurPtr = rgbImageBuf;
    for (int i = 0; i < pixelNum; i++, pCurPtr++) {
        if ((*pCurPtr & 0xffffff00) < 0x99999900) {
            uint8_t * ptr = (uint8_t *)pCurPtr;
            ptr[3] = r;
            ptr[2] = g;
            ptr[1] = b;
        } else {
            //将白色变成透明色
            uint8_t * ptr = (uint8_t *)pCurPtr;
            ptr[0] = 0;
        }
    }
}

// 回调函数
void ProviderReleaseData(void * info, const void * data, size_t size) {
    free((void *)data);
}

// 给传入的图片设置圆角后返回
- (UIImage *)imageOfRoundRectWithImage: (UIImage *)image size: (CGSize)size radius: (CGFloat)radius
{
    if (!image || (NSNull *)image == [NSNull null]) { return nil; }
    
    const CGFloat width = size.width;
    const CGFloat height = size.height;
    
    radius = MAX(5.f, radius);
    radius = MIN(10.f, radius);
    
    UIImage * img = image;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(NULL, width, height, 8, 4 * width, colorSpace, kCGImageAlphaPremultipliedFirst);
    CGRect rect = CGRectMake(0, 0, width, height);
    
    //绘制圆角
    CGContextBeginPath(context);
    [self addRoundRectToPath:context rect:rect radius:radius imageRef:img.CGImage];
    CGImageRef imageMasked = CGBitmapContextCreateImage(context);
    img = [UIImage imageWithCGImage: imageMasked];
    
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    CGImageRelease(imageMasked);
    
    return img;
}

// 给上下文添加圆角蒙版
- (void)addRoundRectToPath:(CGContextRef)context rect:(CGRect)rect radius:(float)radius imageRef:(CGImageRef)image
{
    float width, height;
    if (radius == 0) {
        CGContextAddRect(context, rect);
        return;
    }
    
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, CGRectGetMinX(rect), CGRectGetMinY(rect));
    width = CGRectGetWidth(rect);
    height = CGRectGetHeight(rect);
    
    //裁剪路径
    CGContextMoveToPoint(context, width, height / 2);
    CGContextAddArcToPoint(context, width, height, width / 2, height, radius);
    CGContextAddArcToPoint(context, 0, height, 0, height / 2, radius);
    CGContextAddArcToPoint(context, 0, 0, width / 2, 0, radius);
    CGContextAddArcToPoint(context, width, 0, width, height / 2, radius);
    CGContextClosePath(context);
    CGContextClip(context);
    
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), image);
    CGContextRestoreGState(context);
}

// MARK: 条形码 iOS8.0以上
- (CIImage *)barCodeImageOfURL:(NSString *)url
{
    // iOS 8.0以上的系统才支持条形码的生成，iOS8.0以下使用第三方控件生成
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0) {
        // 注意生成条形码的编码方式
        NSData *data = [url dataUsingEncoding: NSASCIIStringEncoding];
        CIFilter *filter = [CIFilter filterWithName:@"CICode128BarcodeGenerator"];
        [filter setValue:data forKey:@"inputMessage"];
        
        // 设置生成的条形码的上，下，左，右的margins的值
        [filter setValue:[NSNumber numberWithInteger:0] forKey:@"inputQuietSpace"];
        return filter.outputImage;
    } else {
        return nil;
    }
}

@end
