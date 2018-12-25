//
//  NSData+CQDataCache.h
//
//
//  Created by 韦存情 on 16/2/6.
//  Copyright © 2016年 情. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NSData (CQDataCache)

/**
 *  保存数据到Cache
 *
 *  @param identifier 数据标识符
 */
- (void)saveDataCacheWithIdentifier:(NSString *)identifier;

/**
 *  从Cache读取数据
 *
 *  @param identifier 数据标识符
 *
 *  @return 返回的数据
 */
+ (NSData *)getDataCacheWithIdentifier:(NSString *)identifier;

/**
 *  清除Cache的所有缓存
 */
+ (void)clearCache;

/**
 *  获取缓存大小(单位:B)
 *
 *  @return 缓存大小
 */
+ (CGFloat)getCacheSize;

/**
 *  获取缓存大小字符串
 *
 *  @return 缓存大小
 */
+ (NSString *)getCacheSizeString;


@end
