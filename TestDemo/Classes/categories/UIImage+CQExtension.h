//
//  UIImage+CQExtension.h
//  BaseTest
//
//  Created by 韦存情 on 2017/4/11.
//  Copyright © 2017年 qing. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (CQExtension)

#pragma mark -- Color

/** 根据颜色生成纯色图片 */
+ (UIImage *)imageWithColor:(UIColor *)color;

/** 取图片某一像素的颜色 */
- (UIColor *)colorAtPixel:(CGPoint)point;

/** 获得灰度图 */
- (UIImage *)convertToGrayImage;


#pragma mark -- SubImage

/** 圆角图片 */
- (UIImage *)clipImageWithRadius:(CGFloat)radius;

/** 截取当前image对象rect区域内的图像 */
- (UIImage *)subImageWithRect:(CGRect)rect;

/** 在指定的size里面生成一个平铺的图片 */
- (UIImage *)getTiledImageWithSize:(CGSize)size;

/** UIView转化为UIImage */
+ (UIImage *)imageFromView:(UIView *)view;

/** 将两个图片生成一张图片 */
+ (UIImage*)mergeImage:(UIImage*)firstImage withImage:(UIImage*)secondImage;

#pragma mark =====  图片压缩
// 压缩图片到指定size
- (UIImage *)compressImageToSize:(CGSize)size;


/**  说明：对于销巴商家版app，在MKJRequestManager的单图片上传和多图片上传方法中针对UIImage进行了处理，所以在调接口之前无需自行压缩图片，直接将UIImage或者NSData传给对于的参数就行了      */

/// 通过默认size压缩图片。上传方法中做处理，一般不需要调用
- (UIImage *)compressImageToDefaultSize;
/** 压缩图片-通过质量压缩。多图上传时建议通过size压缩，单图两种压缩都可以。注意：经实测缩放系数有临界值（约为0.05），小于临界值会返回和临界值一样的结果，而拍照的原图有时候甚至10M，即使压缩到最小，仍然有可能七八百K*/
- (NSData *)compressImageToLength:(CGFloat)maxLength;

#pragma mark -- Rotate

/** 纠正图片的方向 */
- (UIImage *)fixOrientation;

/** 按给定的方向旋转图片 */
- (UIImage*)rotate:(UIImageOrientation)orient;

/** 垂直翻转 */
- (UIImage *)flipVertical;

/** 水平翻转 */
- (UIImage *)flipHorizontal;

/** 将图片旋转degrees角度 */
- (UIImage *)imageRotatedByDegrees:(CGFloat)degrees;

/** 将图片旋转radians弧度 */
- (UIImage *)imageRotatedByRadians:(CGFloat)radians;


#pragma mark -- GIF

/** 用一个Gif生成UIImage，传入一个GIFData */
+ (UIImage *)animatedImageWithAnimatedGIFData:(NSData *)data;

/** 用一个Gif生成UIImage，传入一个GIF路径 */
+ (UIImage *)animatedImageWithAnimatedGIFURL:(NSURL *)URL;

@end
