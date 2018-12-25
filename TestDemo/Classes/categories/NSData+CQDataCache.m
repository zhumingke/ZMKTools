//
//  NSData+CQDataCache.m
//  
//
//  Created by 韦存情 on 16/2/6.
//  Copyright © 2016年 情. All rights reserved.
//

#import "NSData+CQDataCache.h"
#import <CommonCrypto/CommonDigest.h>


@implementation NSData (CQDataCache)

- (void)saveDataCacheWithIdentifier:(NSString *)identifier
{
    NSString *path = [NSData creatDataPathWithString:identifier];
    [self writeToFile:path atomically:YES];
}

+ (NSData *)getDataCacheWithIdentifier:(NSString *)identifier
{
    NSString *path = [NSData creatDataPathWithString:identifier];
    NSData *data = [NSData dataWithContentsOfFile:path];
    return data;
}

+ (void)clearCache
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSArray * files = [[NSFileManager defaultManager ] subpathsAtPath :[NSData cachePath]];
        for (NSString * file in files) {
            
            NSError * error = nil ;
            
            NSString * fileAbsolutePath = [[NSData cachePath] stringByAppendingPathComponent:file];
            
            if ([[NSFileManager defaultManager ] fileExistsAtPath:fileAbsolutePath]) {
                [[NSFileManager defaultManager ] removeItemAtPath:fileAbsolutePath error:&error];
            }
        }
        
    });
}
// 获取缓存大小
+ (CGFloat)getCacheSize {
    __block NSUInteger size = 0;
    NSFileManager * fileManger = [NSFileManager defaultManager];
    
    NSString * cachePath =  [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    
    NSDirectoryEnumerator * fileEnumrator = [fileManger enumeratorAtPath:cachePath];
    
    for (NSString * fileName in fileEnumrator)
        {
        NSString * filePath = [cachePath stringByAppendingPathComponent:fileName];
        
        //获取文件属性
        NSDictionary * fileAttributes = [fileManger attributesOfItemAtPath:filePath error:nil];
        
        //根据文件属性判断是否是文件夹（如果是文件夹就跳过文件夹，不将文件夹大小累加到文件总大小）
        if ([fileAttributes[NSFileType] isEqualToString:NSFileTypeDirectory]) continue;
        
        //获取单个文件大小,并累加到总大小
        size += [fileAttributes[NSFileSize] integerValue];
        
        }
    
       return size;
}
// 获取缓存大小
+ (NSString *)getCacheSizeString {
    CGFloat size = [NSData getCacheSize];
    float mBytes = size/1024/1024;
    float kBytes = size/1024;
    
    if (kBytes < 1024) {
        return [NSString stringWithFormat:@"%.2fK",kBytes];
    }else {
        return [NSString stringWithFormat:@"%.1fM",mBytes];
    }
    
    return [NSString stringWithFormat:@"%.0fB",size];
}

#pragma mark private
//获取缓存路径
+ (NSString *)cachePath
{
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) lastObject];
    path = [path stringByAppendingPathComponent:@"Caches"];
   // path = [path stringByAppendingPathComponent:@"Caches/CQDataCache"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    return path;
}

+ (NSString *)creatMD5StringWithString:(NSString *)string
{
    static int suffix = 0;;
    if (string == nil) {
        string = [NSString stringWithFormat:@"defalut_%d",suffix];
        suffix++;
    }
    const char *original_str = [string UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(original_str, (CC_LONG)strlen(original_str), result);
    NSMutableString *hash = [NSMutableString string];
    for (int i = 0; i < 16; i++)
        [hash appendFormat:@"%02X", result[i]];
    [hash lowercaseString];
    return hash;
}
//创建数据路径
+ (NSString *)creatDataPathWithString:(NSString *)string
{
    NSString *path = [NSData cachePath];
    path = [path stringByAppendingPathComponent:[self creatMD5StringWithString:string]];
    return path;
}



@end
