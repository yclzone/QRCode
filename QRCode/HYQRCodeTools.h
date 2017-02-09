//
//  HYQRCodeTools.h
//  QRCode
//
//  Created by YCLZONE on 9/6/16.
//  Copyright © 2016 YCLZONE. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HYQRCodeTools : UIView
- (UIImage *)QRCodeImageWithString:(NSString *)text logo:(UIImage *)logo size:(CGFloat)size;
@end
