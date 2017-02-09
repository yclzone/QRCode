//
//  HYQRCodeTools.m
//  QRCode
//
//  Created by YCLZONE on 9/6/16.
//  Copyright © 2016 YCLZONE. All rights reserved.
//

#import "HYQRCodeTools.h"

@implementation HYQRCodeTools

- (void)dealloc {
    NSLog(@"%s", __FUNCTION__);
}

- (CIImage *)imageWithString:(NSString *)sourceString {
    CIFilter *filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    [filter setDefaults];
    
    NSData *inputData = [sourceString dataUsingEncoding:NSUTF8StringEncoding];
    
    [filter setValue:inputData forKey:@"inputMessage"];
    [filter setValue:@"M" forKey:@"inputCorrectionLevel"];
    
    CIImage *outputImage = filter.outputImage;
    return outputImage;
}

- (UIImage *)nonInterpolatedImageWithCIImage:(CIImage *)image size:(CGFloat)size {
    CGRect extent = CGRectIntegral(image.extent);
    CGFloat scale = MIN(size/CGRectGetWidth(extent), size/CGRectGetHeight(extent));
    
    // 1.创建bitmap;
    size_t width = CGRectGetWidth(extent) * scale;
    size_t height = CGRectGetHeight(extent) * scale;
    CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceGray();
    CGContextRef bitmapContextRef = CGBitmapContextCreate(nil, width, height, 8, 0, colorSpaceRef, (CGBitmapInfo)kCGImageAlphaNone);
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef bitmapImage = [context createCGImage:image fromRect:extent];
    CGContextSetInterpolationQuality(bitmapContextRef, kCGInterpolationNone);
    CGContextScaleCTM(bitmapContextRef, scale, scale);
    CGContextDrawImage(bitmapContextRef, extent, bitmapImage);
    
    // 2.保存bitmap到图片
    CGImageRef scaledImage = CGBitmapContextCreateImage(bitmapContextRef);
    CGContextRelease(bitmapContextRef);
    CGImageRelease(bitmapImage);
    return [UIImage imageWithCGImage:scaledImage];
}

- (UIImage *)createImageBigImage:(UIImage *)bigImage smallImage:(UIImage *)smallImage sizeWH:(CGFloat)sizeWH
{
    CGSize size = bigImage.size;
    
    // 1.开启一个图形山下文
    UIGraphicsBeginImageContext(size);
    
    // 2.绘制大图片
    [bigImage drawInRect:CGRectMake(0, 0, size.width, size.height)];
    
    // 3.绘制小图片
    CGFloat x = (size.width - sizeWH) * 0.5;
    CGFloat y = (size.height - sizeWH) *0.5;
    [smallImage drawInRect:CGRectMake(x, y, sizeWH, sizeWH)];
    
    // 4.取出合成图片
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // 5.关闭图形上下文
    UIGraphicsEndImageContext();
    
    return newImage;
}

- (UIImage *)QRCodeImageWithString:(NSString *)text logo:(UIImage *)logo size:(CGFloat)size {
    UIImage *codeImage = [self nonInterpolatedImageWithCIImage:[self imageWithString:text]
                                            size:size];
    if (!logo) {
        return codeImage;
    }
    
    return [self createImageBigImage:codeImage smallImage:logo sizeWH:60];
    
}

@end
