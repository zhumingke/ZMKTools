//
//  UIColor+ColorChange.h
//  XBWord
//
//  Created by mkzhu on 2017/1/3.
//  Copyright © 2017年 mkzhu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (ColorChange)

/**
 16进制 ---- 》  UIcolor
 */
+ (UIColor *)colorWithHexString:(NSString *)color;

/**
 UIColor  ------ >>  UIImage
 */
+ (UIImage*)createImageWithColor:(UIColor*)color;

/// 渐变色
+ (CAGradientLayer *)setGradualChangingColor:(CGRect)viewBounds fromColor:(UIColor *)fromColor toColor:(UIColor *)toColor;

@end
