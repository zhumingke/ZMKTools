//
//  NSString+Utils.h
//  XBWord
//
//  Created by mkzhu on 2017/2/9.
//  Copyright © 2017年 mkzhu. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSString (Utils)

#pragma mark -- 安全

- (NSString *)MD5;
- (NSString *)base64EncodedString;
- (NSString *)base64DecodedString;

+ (NSString *)getUUID;

#pragma mark -- 时间 --

/// 时间戳字符串转化为时间格式
- (NSString *)timeWithDateFormat:(NSString *)format;
- (NSString *)timeFromDate:(NSString *)timeDate;
- (NSString *)detailTimeFromDate:(NSString *)timeDate;
- (NSString *)timeOFHourMinutes;

#pragma mark -- Json --

/** NSarray、NSDictionary -> JSON */
+ (NSString *)arrayOrNSDictionaryToJSonString:(id)obj;
/// NSDic转JSON
+ (NSString *)dictionaryToJsonString:(NSDictionary *)dict;
/// NSArray 转 JSON
+ (NSString *)arrayToJSonString:(NSArray *)arr;

/** JSON -> NSarray、NSDictionary */
- (id)jsonStringToArrayOrNSDictionary;
/// json解析
- (NSDictionary *)dictionaryWithJsonString;


#pragma mark -- 字符串格式

/// 手机号码检验
- (BOOL)validMobilePhone;
/// 校验手机号
- (BOOL)mobileNum:(NSString *)mobileNumber;
/// 检测手机号码归属地
- (NSString *)checkPhoneBelong;

/**
 密码规则6-32位：A-Za-z0-9@-_.
 */
- (BOOL)validPassword;
/**
 *  验证密码复杂度，必须是字母，数字，字符两种以上,前提是validPassword
 */
- (BOOL)isPasswordComplexity;

/// 校验验证码 6位数字
+ (BOOL)checkRemainCode:(NSString *)remain;
/// 6位数字验证码
- (BOOL)isPhoneVerificationCode;


/** 最新检查身份证合法性 */
// 注：.h里注释掉了，.m里的判断代码还在，需要的时候打开这个注释即可使用。也可以按下面的销巴规则来判断
//+ (BOOL)newValidateIDNumber:(NSString *)value;

/// 是否是大陆身份证。这个是最新的销巴身份证规则，没有newValidateIDNumber:验证的那么复杂
- (BOOL)isChinaIDCard;

/** 港澳台身份身份证统一判断 */
- (BOOL)isHKOrAoMenOrTaiWanIDCard;
/** 验证香港身份证 */
- (BOOL)isHongKangIDCard;
/** 验证澳门身份证 */
- (BOOL)isAoMenIDCard;
/** 验证台湾身份证 */
- (BOOL)isTaiWanIDCard;

/// 身份证密文显示：显示后四位，前面用等量的*代替
- (NSString *)idCardEncrypt;

/// 是否为银行卡
+ (BOOL)IsBankCard:(NSString *)cardNumber;

///判断是否是中英文姓名。中文和· 长度2-25
- (BOOL)isNameString;
///判断是否是详细地址。中英文数字和空格 - 未使用
- (BOOL)isDetailAddress;
///判断是否是物流单号
- (BOOL)isValidLogisticOrdersn;

///判断是否是有效的url地址
- (BOOL)isValidUrl;

///判断是否是有效的邮箱
- (BOOL)isValidEmail;
///判断是否是邮箱允许输入的字符
- (BOOL)isValidEmailLimitString;

/// 检测字符串 非nil,非null,并且length > 0
- (BOOL)validString;
/// 是否纯数字
- (BOOL)isPureInt;
/// 是否纯汉字
- (BOOL)isPureChinese;
/// 是否含有汉字
- (BOOL)includeChinese;
/// 是否含表情字符
- (BOOL)stringContainsEmoji;

/**
 过滤regex外的字符--
  中文 [^\u4e00-\u9fa5]
 */
- (NSString *)filterCharactorWithRegex:(NSString *)regexString;

/// 过滤其它字符 regex:允许的字符 maxLength:最大长度，超出了截取前面的部分
- (NSString *)filterCharactorWithRegex:(NSString *)regex maxLength:(NSInteger)maxLength;

/// 过滤非姓名字符 中英文和· 长度2-25
- (NSString *)filterNameString;

/// 昵称加密。返回加密后的字符串
- (NSString *)nicknameEncrypt;

#pragma mark -- 富文本 --

/** 指定字段颜色 */
+ (NSMutableAttributedString *)attributeString:(NSString *)string color:(UIColor *)color range:(NSRange)range;
/** 指定字段字体字号 */
+ (NSMutableAttributedString *)attributeString:(NSString *)string font:(UIFont *)font range:(NSRange)range;
/** 自定字段字体颜色和字号 */
+ (NSMutableAttributedString *)attributeString:(NSString *)string font:(UIFont *)font color:(UIColor *)color range:(NSRange)range;


#pragma maek -- 文本宽高
/// 获取text的宽度
- (CGFloat)widthWithStringAttributes:(NSDictionary <NSString *, id> *)attributes;

- (CGFloat)calculateRowHeightFont:(UIFont *)font rowWidth:(CGFloat)rowWidth;
- (CGFloat)calculateRowWidthFont:(UIFont *)font rowHeight:(CGFloat)rowHeight;


#pragma mark -- 金额 --

///转换为金额number 默认保留小数点后2位，超出位数舍去
- (NSDecimalNumber *)numberWithMoneyFormat;
/// 转换为金额number mode保留方式 position为小数点后最多位数
- (NSDecimalNumber *)numberWithRoundingMode:(NSRoundingMode)mode Position:(int)position;

/// 正则验证
- (BOOL)regularPredicate:(NSString *)predicate;


@end
