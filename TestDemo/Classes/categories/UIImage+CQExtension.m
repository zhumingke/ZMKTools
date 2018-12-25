//
//  UIImage+CQExtension.m
//  BaseTest
//
//  Created by 韦存情 on 2017/4/11.
//  Copyright © 2017年 qing. All rights reserved.
//

#import "UIImage+CQExtension.h"
#import <ImageIO/ImageIO.h>


//由角度转换弧度
#define kDegreesToRadian(x)      (M_PI * (x) / 180.0)
//由弧度转换角度
#define kRadianToDegrees(radian) (radian * 180.0) / (M_PI)

@implementation UIImage (CQExtension)

#pragma mark -- Color

/** 根据颜色生成纯色图片 */
+ (UIImage *)imageWithColor:(UIColor *)color {
    
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

/** 取图片某一像素的颜色 */
- (UIColor *)colorAtPixel:(CGPoint)point {
    
    if (!CGRectContainsPoint(CGRectMake(0.0f, 0.0f, self.size.width, self.size.height), point))
        {
        return nil;
        }
    
    NSInteger pointX = trunc(point.x);
    NSInteger pointY = trunc(point.y);
    CGImageRef cgImage = self.CGImage;
    NSUInteger width = self.size.width;
    NSUInteger height = self.size.height;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    int bytesPerPixel = 4;
    int bytesPerRow = bytesPerPixel * 1;
    NSUInteger bitsPerComponent = 8;
    unsigned char pixelData[4] = { 0, 0, 0, 0 };
    CGContextRef context = CGBitmapContextCreate(pixelData,
                                                 1,
                                                 1,
                                                 bitsPerComponent,
                                                 bytesPerRow,
                                                 colorSpace,
                                                 kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGColorSpaceRelease(colorSpace);
    CGContextSetBlendMode(context, kCGBlendModeCopy);
    
    CGContextTranslateCTM(context, -pointX, pointY-(CGFloat)height);
    CGContextDrawImage(context, CGRectMake(0.0f, 0.0f, (CGFloat)width, (CGFloat)height), cgImage);
    CGContextRelease(context);
    
    CGFloat red   = (CGFloat)pixelData[0] / 255.0f;
    CGFloat green = (CGFloat)pixelData[1] / 255.0f;
    CGFloat blue  = (CGFloat)pixelData[2] / 255.0f;
    CGFloat alpha = (CGFloat)pixelData[3] / 255.0f;
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

/** 获得灰度图 */
- (UIImage *)convertToGrayImage {
    
    int width = self.size.width;
    int height = self.size.height;
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
    CGContextRef context = CGBitmapContextCreate(nil,width,height,8,0,colorSpace,kCGImageAlphaNone);
    CGColorSpaceRelease(colorSpace);
    
    if (context == NULL)
        {
        return nil;
        }
    
    CGContextDrawImage(context,CGRectMake(0, 0, width, height), self.CGImage);
    CGImageRef contextRef = CGBitmapContextCreateImage(context);
    UIImage *grayImage = [UIImage imageWithCGImage:contextRef];
    CGContextRelease(context);
    CGImageRelease(contextRef);
    
    return grayImage;
}


#pragma mark -- SubImage

/** 圆角图片 */
- (UIImage *)clipImageWithRadius:(CGFloat)radius{
    
    CGFloat w = self.size.width;
    CGFloat h = self.size.height;
    
    if(radius<0){radius = 0;}
    if (radius>MIN(w, h)) {
        radius = MIN(w, h);
    }
    
    CGRect imgFrame = CGRectMake(0, 0, w, h);
    
    UIGraphicsBeginImageContextWithOptions(imgFrame.size, NO, 0);
    UIBezierPath  *path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, w, h) cornerRadius:radius];
    [path addClip];
    [self drawInRect:imgFrame];
    
    UIImage * img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

/** 截取当前image对象rect区域内的图像 */
- (UIImage *)subImageWithRect:(CGRect)rect {
    
    CGImageRef newImageRef = CGImageCreateWithImageInRect(self.CGImage, rect);
    
    UIImage *newImage = [UIImage imageWithCGImage:newImageRef];
    
    CGImageRelease(newImageRef);
    
    return newImage;
}


//判断图片，如果大于maxLength K，循环压缩
- (NSData *)compressImageToLength:(CGFloat)maxLength {
    
    CGFloat compression = 1.0;
    if (maxLength <= 0) {
        maxLength = 600;
    }
    NSLog(@"图片最大允许的大小:%.2fK",maxLength);
    
    NSData* data = UIImageJPEGRepresentation(self, compression);
    NSLog(@"原始图片的data:%.2fK",data.length/1024.0);
    
    while(data.length > maxLength * 1024 && compression > 0.05) {
        
        if(data.length > 1024*1024* 3) {
            
            compression *= 0.5;
        }else if(data.length > 1024*1024) {
            
            compression *= 0.85;
        }else if(data.length > maxLength*1024) {
            
            compression *= 0.95;
        }
        
       // NSLog(@"某次压缩 compression:%f",compression);
        data = UIImageJPEGRepresentation(self, compression);
      //  NSLog(@"某次压缩后的data:%.2fK",data.length/1024.0);
    }
    
    NSLog(@"压缩后最终返回的data:%.2fK",data.length/1024.0);
    return data;
}


/// 压缩图片 -通过size压缩。 限制高和宽的较大者不超过默认值，保持宽高比
- (UIImage *)compressImageToDefaultSize
{
    // 限制宽和高的较大者 最大不能多少
    CGFloat limitLength = 1000;
    
    // 图片宽和高的较大者
    CGFloat originMaxLine = (self.size.width > self.size.height) ? self.size.width : self.size.height;
    // 较大边都小于1000px，直接返回图片
    if (originMaxLine <= limitLength) {
        return self;
    }else if (originMaxLine == self.size.width) {
        // 图片 宽 > 高
        CGFloat hight = limitLength/self.size.width * self.size.height;
        return [self compressImageToSize:CGSizeMake(limitLength, hight)];
    }else {
        // 图片 高 > 宽
        CGFloat width = limitLength/self.size.height * self.size.width;
        return [self compressImageToSize:CGSizeMake(width, limitLength)];
    }
   
}
    
// 压缩图片到指定size
- (UIImage *)compressImageToSize:(CGSize)size {
    
    // 开启图片上下文
    UIGraphicsBeginImageContext(size);
    // 将图片渲染到图片上下文
    [self drawInRect:CGRectMake(0, 0, size.width, size.height)];
    // 获取图片
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    // 关闭图片上下文
    UIGraphicsEndImageContext();
    return img;
}

/** 在指定的size里面生成一个平铺的图片 */
- (UIImage *)getTiledImageWithSize:(CGSize)size {
    
    UIView *tempView = [[UIView alloc] init];
    tempView.bounds = (CGRect){CGPointZero, size};
    tempView.backgroundColor = [UIColor colorWithPatternImage:self];
    
    UIGraphicsBeginImageContext(size);
    [tempView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *bgImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return bgImage;
}

/** UIView转化为UIImage */
+ (UIImage *)imageFromView:(UIView *)view {
    
    CGFloat scale = [UIScreen mainScreen].scale;
    UIGraphicsBeginImageContextWithOptions(view.frame.size, NO, scale);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

/** 将两个图片生成一张图片 */
+ (UIImage*)mergeImage:(UIImage*)firstImage withImage:(UIImage*)secondImage {
    
    CGImageRef firstImageRef = firstImage.CGImage;
    CGFloat firstWidth = CGImageGetWidth(firstImageRef);
    CGFloat firstHeight = CGImageGetHeight(firstImageRef);
    CGImageRef secondImageRef = secondImage.CGImage;
    CGFloat secondWidth = CGImageGetWidth(secondImageRef);
    CGFloat secondHeight = CGImageGetHeight(secondImageRef);
    CGSize mergedSize = CGSizeMake(MAX(firstWidth, secondWidth), MAX(firstHeight, secondHeight));
    UIGraphicsBeginImageContext(mergedSize);
    [firstImage drawInRect:CGRectMake(0, 0, firstWidth, firstHeight)];
    [secondImage drawInRect:CGRectMake(0, 0, secondWidth, secondHeight)];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}


#pragma mark -- Rotate

/** 纠正图片的方向 */
- (UIImage *)fixOrientation {
    
    if (self.imageOrientation == UIImageOrientationUp) return self;
    
    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (self.imageOrientation)
    {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
        transform = CGAffineTransformTranslate(transform, self.size.width, self.size.height);
        transform = CGAffineTransformRotate(transform, M_PI);
        break;
        
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        transform = CGAffineTransformTranslate(transform, self.size.width, 0);
        transform = CGAffineTransformRotate(transform, M_PI_2);
        break;
        
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
        transform = CGAffineTransformTranslate(transform, 0, self.size.height);
        transform = CGAffineTransformRotate(transform, -M_PI_2);
        break;
        case UIImageOrientationUp:
        case UIImageOrientationUpMirrored:
        break;
    }
    
    switch (self.imageOrientation)
    {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
        transform = CGAffineTransformTranslate(transform, self.size.width, 0);
        transform = CGAffineTransformScale(transform, -1, 1);
        break;
        
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
        transform = CGAffineTransformTranslate(transform, self.size.height, 0);
        transform = CGAffineTransformScale(transform, -1, 1);
        break;
        case UIImageOrientationUp:
        case UIImageOrientationDown:
        case UIImageOrientationLeft:
        case UIImageOrientationRight:
        break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, self.size.width, self.size.height,
                                             CGImageGetBitsPerComponent(self.CGImage), 0,
                                             CGImageGetColorSpace(self.CGImage),
                                             CGImageGetBitmapInfo(self.CGImage));
    CGContextConcatCTM(ctx, transform);
    
    switch (self.imageOrientation)
    {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
        CGContextDrawImage(ctx, CGRectMake(0,0,self.size.height,self.size.width), self.CGImage);
        break;
        
        default:
        CGContextDrawImage(ctx, CGRectMake(0,0,self.size.width,self.size.height), self.CGImage);
        break;
    }
    
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    
    return img;
 
}

/** 按给定的方向旋转图片 */
- (UIImage*)rotate:(UIImageOrientation)orient {
    
    CGRect bnds = CGRectZero;
    UIImage* copy = nil;
    CGContextRef ctxt = nil;
    CGImageRef imag = self.CGImage;
    CGRect rect = CGRectZero;
    CGAffineTransform tran = CGAffineTransformIdentity;
    
    rect.size.width = CGImageGetWidth(imag);
    rect.size.height = CGImageGetHeight(imag);
    
    bnds = rect;
    
    switch (orient)
    {
        case UIImageOrientationUp:
        return self;
        
        case UIImageOrientationUpMirrored:
        tran = CGAffineTransformMakeTranslation(rect.size.width, 0.0);
        tran = CGAffineTransformScale(tran, -1.0, 1.0);
        break;
        
        case UIImageOrientationDown:
        tran = CGAffineTransformMakeTranslation(rect.size.width,
                                                rect.size.height);
        tran = CGAffineTransformRotate(tran, M_PI);
        break;
        
        case UIImageOrientationDownMirrored:
        tran = CGAffineTransformMakeTranslation(0.0, rect.size.height);
        tran = CGAffineTransformScale(tran, 1.0, -1.0);
        break;
        
        case UIImageOrientationLeft:
        bnds = swapWidthAndHeight(bnds);
        tran = CGAffineTransformMakeTranslation(0.0, rect.size.width);
        tran = CGAffineTransformRotate(tran, 3.0 * M_PI / 2.0);
        break;
        
        case UIImageOrientationLeftMirrored:
        bnds = swapWidthAndHeight(bnds);
        tran = CGAffineTransformMakeTranslation(rect.size.height,
                                                rect.size.width);
        tran = CGAffineTransformScale(tran, -1.0, 1.0);
        tran = CGAffineTransformRotate(tran, 3.0 * M_PI / 2.0);
        break;
        
        case UIImageOrientationRight:
        bnds = swapWidthAndHeight(bnds);
        tran = CGAffineTransformMakeTranslation(rect.size.height, 0.0);
        tran = CGAffineTransformRotate(tran, M_PI / 2.0);
        break;
        
        case UIImageOrientationRightMirrored:
        bnds = swapWidthAndHeight(bnds);
        tran = CGAffineTransformMakeScale(-1.0, 1.0);
        tran = CGAffineTransformRotate(tran, M_PI / 2.0);
        break;
        
        default:
        return self;
    }
    
    UIGraphicsBeginImageContext(bnds.size);
    ctxt = UIGraphicsGetCurrentContext();
    
    switch (orient)
    {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
        CGContextScaleCTM(ctxt, -1.0, 1.0);
        CGContextTranslateCTM(ctxt, -rect.size.height, 0.0);
        break;
        
        default:
        CGContextScaleCTM(ctxt, 1.0, -1.0);
        CGContextTranslateCTM(ctxt, 0.0, -rect.size.height);
        break;
    }
    
    CGContextConcatCTM(ctxt, tran);
    CGContextDrawImage(UIGraphicsGetCurrentContext(), rect, imag);
    
    copy = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return copy;
}

/** 垂直翻转 */
- (UIImage *)flipVertical {
    
    return [self rotate:UIImageOrientationDownMirrored];
}

/** 水平翻转 */
- (UIImage *)flipHorizontal {
    
    return [self rotate:UIImageOrientationUpMirrored];
}

/** 将图片旋转degrees角度 */
- (UIImage *)imageRotatedByDegrees:(CGFloat)degrees {
    
    return [self imageRotatedByRadians:kDegreesToRadian(degrees)];
}

/** 将图片旋转radians弧度 */
- (UIImage *)imageRotatedByRadians:(CGFloat)radians {
    
    // calculate the size of the rotated view's containing box for our drawing space
    UIView *rotatedViewBox = [[UIView alloc] initWithFrame:CGRectMake(0,0,self.size.width, self.size.height)];
    CGAffineTransform t = CGAffineTransformMakeRotation(radians);
    rotatedViewBox.transform = t;
    CGSize rotatedSize = rotatedViewBox.frame.size;
    
    // Create the bitmap context
    UIGraphicsBeginImageContext(rotatedSize);
    CGContextRef bitmap = UIGraphicsGetCurrentContext();
    
    // Move the origin to the middle of the image so we will rotate and scale around the center.
    CGContextTranslateCTM(bitmap, rotatedSize.width/2, rotatedSize.height/2);
    
    //   // Rotate the image context
    CGContextRotateCTM(bitmap, radians);
    
    // Now, draw the rotated/scaled image into the context
    CGContextScaleCTM(bitmap, 1.0, -1.0);
    CGContextDrawImage(bitmap, CGRectMake(-self.size.width / 2, -self.size.height / 2, self.size.width, self.size.height), [self CGImage]);
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;

}

/** 交换宽和高 */
static CGRect swapWidthAndHeight(CGRect rect)
{
    CGFloat swap = rect.size.width;
    
    rect.size.width = rect.size.height;
    rect.size.height = swap;
    
    return rect;
}

#pragma mark -- GIF

static int delayCentisecondsForImageAtIndex(CGImageSourceRef const source, size_t const i)
{
    int delayCentiseconds = 1;
    CFDictionaryRef const properties = CGImageSourceCopyPropertiesAtIndex(source, i, NULL);
    if (properties)
        {
        CFDictionaryRef const gifProperties = CFDictionaryGetValue(properties, kCGImagePropertyGIFDictionary);
        if (gifProperties)
            {
            NSNumber *number = (__bridge id) CFDictionaryGetValue(gifProperties, kCGImagePropertyGIFUnclampedDelayTime);
            if (number == NULL || [number doubleValue] == 0)
                {
                number = (__bridge id) CFDictionaryGetValue(gifProperties, kCGImagePropertyGIFDelayTime);
                }
            if ([number doubleValue] > 0)
                {
                delayCentiseconds = (int)lrint([number doubleValue] * 100);
                }
            }
        CFRelease(properties);
        }
    return delayCentiseconds;
}

static void createImagesAndDelays(CGImageSourceRef source, size_t count, CGImageRef imagesOut[count], int delayCentisecondsOut[count])
{
    for (size_t i = 0; i < count; ++i)
        {
        imagesOut[i] = CGImageSourceCreateImageAtIndex(source, i, NULL);
        delayCentisecondsOut[i] = delayCentisecondsForImageAtIndex(source, i);
        }
}

static int sum(size_t const count, int const *const values)
{
    int theSum = 0;
    for (size_t i = 0; i < count; ++i)
        {
        theSum += values[i];
        }
    return theSum;
}

static int pairGCD(int a, int b)
{
    if (a < b)
        {
        return pairGCD(b, a);
        }
    
    while (true)
        {
        int const r = a % b;
        if (r == 0)
            {
            return b;
            }
        a = b;
        b = r;
        }
}

static int vectorGCD(size_t const count, int const *const values)
{
    int gcd = values[0];
    for (size_t i = 1; i < count; ++i)
        {
        gcd = pairGCD(values[i], gcd);
        }
    return gcd;
}

static NSArray *frameArray(size_t const count, CGImageRef const images[count], int const delayCentiseconds[count], int const totalDurationCentiseconds)
{
    int const gcd = vectorGCD(count, delayCentiseconds);
    size_t const frameCount = totalDurationCentiseconds / gcd;
    UIImage *frames[frameCount];
    for (size_t i = 0, f = 0; i < count; ++i)
        {
        UIImage *const frame = [UIImage imageWithCGImage:images[i]];
        for (size_t j = delayCentiseconds[i] / gcd; j > 0; --j)
            {
            frames[f++] = frame;
            }
        }
    return [NSArray arrayWithObjects:frames count:frameCount];
}

static void releaseImages(size_t const count, CGImageRef const images[count])
{
    for (size_t i = 0; i < count; ++i)
        {
        CGImageRelease(images[i]);
        }
}

static UIImage *animatedImageWithAnimatedGIFImageSource(CGImageSourceRef const source)
{
    size_t const count = CGImageSourceGetCount(source);
    CGImageRef images[count];
    int delayCentiseconds[count]; // in centiseconds
    createImagesAndDelays(source, count, images, delayCentiseconds);
    int const totalDurationCentiseconds = sum(count, delayCentiseconds);
    NSArray *const frames = frameArray(count, images, delayCentiseconds, totalDurationCentiseconds);
    UIImage *const animation = [UIImage animatedImageWithImages:frames duration:(NSTimeInterval)totalDurationCentiseconds / 100.0];
    releaseImages(count, images);
    return animation;
}

static UIImage *animatedImageWithAnimatedGIFReleasingImageSource(CGImageSourceRef CF_RELEASES_ARGUMENT source)
{
    if (source)
        {
        UIImage *const image = animatedImageWithAnimatedGIFImageSource(source);
        CFRelease(source);
        return image;
        }
    else
        {
        return nil;
        }
}


/** 用一个Gif生成UIImage，传入一个GIFData */
+ (UIImage *)animatedImageWithAnimatedGIFData:(NSData *)data {
    
    return animatedImageWithAnimatedGIFReleasingImageSource(CGImageSourceCreateWithData((__bridge CFTypeRef) data, NULL));
}

/** 用一个Gif生成UIImage，传入一个GIF路径 */
+ (UIImage *)animatedImageWithAnimatedGIFURL:(NSURL *)URL {
    
    return animatedImageWithAnimatedGIFReleasingImageSource(CGImageSourceCreateWithURL((__bridge CFTypeRef) URL, NULL));
}





@end
