//
//  NSString+Utils.m
//  XBWord
//
//  Created by mkzhu on 2017/2/9.
//  Copyright © 2017年 mkzhu. All rights reserved.
//

#import "NSString+Utils.h"
#import <CommonCrypto/CommonDigest.h>


// 登录密码允许的字符
#define ALPHA @"@-_.0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"

// base64用到的字符
static const char encodingTable[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

@implementation NSString (Utils)

- (NSString *)MD5 {
    const char *cStr = [self UTF8String];
    unsigned char result[16];
    CC_MD5( cStr, (CC_LONG)strlen(cStr), result ); // This is the md5 call
    return [NSString stringWithFormat:
        @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
}
- (NSString *)base64EncodedString {
    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding];
    return [data base64EncodedStringWithOptions:0];
}

- (NSString *)base64DecodedString {
    NSData *data = [[NSData alloc]initWithBase64EncodedString:self options:0];
    return [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
}

//时间戳转化为时间
- (NSString *)timeFromDate:(NSString *)timeDate {
    NSTimeInterval time = [timeDate doubleValue];//时差8小时  +28800
    NSDate *detailDate = [NSDate dateWithTimeIntervalSince1970:time];
    //设置时间格式
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    return [dateFormatter stringFromDate:detailDate];
}
/// 时间戳字符串转化为时间格式
- (NSString *)timeWithDateFormat:(NSString *)format {
    NSTimeInterval time = [self doubleValue];//时差8小时  +28800
    NSDate *detailDate = [NSDate dateWithTimeIntervalSince1970:time];
    //设置时间格式
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:format];
    return [dateFormatter stringFromDate:detailDate];
}
- (NSString *)detailTimeFromDate:(NSString *)timeDate {
    NSTimeInterval time = [timeDate doubleValue];//时差8小时 +28800
    NSDate *detailDate = [NSDate dateWithTimeIntervalSince1970:time];
    //设置时间格式
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    return [dateFormatter stringFromDate:detailDate];
}
- (NSString *)timeOFHourMinutes {
    NSTimeInterval time = [self doubleValue];
    NSDate *detailDate = [NSDate dateWithTimeIntervalSince1970:time];
    //设置时间格式
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm:ss"];
    return [dateFormatter stringFromDate:detailDate];
}
+ (NSString *)getUUID {
    CFUUIDRef uuid_ref = CFUUIDCreate(nil);
    CFStringRef uuid_string_ref = CFUUIDCreateString(nil, uuid_ref);
    CFRelease(uuid_ref);
    NSString *uuid = [NSString stringWithString:(__bridge NSString * _Nonnull)(uuid_string_ref)];
    CFRelease(uuid_string_ref);
    return uuid;
}
//字典 转 JSON
+ (NSString *)dictionaryToJsonString:(NSDictionary *)dict {
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
    NSString *jsonString;
    if (!jsonData) {
        NSLog(@"--------%@",error);
    } else {
        jsonString = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    return jsonString;
}
///数组  转  JSON
+ (NSString *)arrayToJSonString:(NSArray *)arr {
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:arr options:kNilOptions error:&error];
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}
//json --> dictionary
- (NSDictionary *)dictionaryWithJsonString
{
    NSString *jsonString = self;
    if (jsonString == nil) {
        return nil;
    }
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if(err)
    {
        NSLog(@"json解析失败：%@",err);
        return nil;
    }
    return dic;
}
// 数组、字典  ——————> json
+ (NSString *)arrayOrNSDictionaryToJSonString:(id)obj {
    if (obj) {
        NSError *error = nil;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:obj options:NSJSONWritingPrettyPrinted | kNilOptions error:&error];
        if ([jsonData length] > 0 && error == nil) {
            return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        }
    }
    return nil;
    /**
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:obj options:NSJSONWritingPrettyPrinted | kNilOptions error:&error];
    if ([jsonData length] > 0 && error == nil) {
        return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    } else {
        return nil;
    }
     */
    //return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}
// json -----> array/dictionary
- (id)jsonStringToArrayOrNSDictionary {
    NSString *json = self;
    if (json == nil) {
        return nil;
    }
    NSData *jsonData = [json dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error = nil;
    id jsonObject = [NSJSONSerialization JSONObjectWithData:jsonData
                                                    options:NSJSONReadingAllowFragments
                                                      error:nil];
    if (jsonObject != nil && error == nil){
        return jsonObject;
    }else{
        // 解析错误
        return nil;
    }
}
//base64 NSData
- (NSString *)base64EncodedStringFromData:(NSData *)data {
    if ([data length] == 0)
        return @"";
    
    char *characters = malloc((([data length] + 2) / 3) * 4);
    if (characters == NULL)
        return nil;
    NSUInteger length = 0;
    
    NSUInteger i = 0;
    while (i < [data length])
    {
        char buffer[3] = {0,0,0};
        short bufferLength = 0;
        while (bufferLength < 3 && i < [data length])
            buffer[bufferLength++] = ((char *)[data bytes])[i++];
        
        //  Encode the bytes in the buffer to four characters, including padding "=" characters if necessary.
        characters[length++] = encodingTable[(buffer[0] & 0xFC) >> 2];
        characters[length++] = encodingTable[((buffer[0] & 0x03) << 4) | ((buffer[1] & 0xF0) >> 4)];
        if (bufferLength > 1)
            characters[length++] = encodingTable[((buffer[1] & 0x0F) << 2) | ((buffer[2] & 0xC0) >> 6)];
        else characters[length++] = '=';
        if (bufferLength > 2)
            characters[length++] = encodingTable[buffer[2] & 0x3F];
        else characters[length++] = '=';
    }
    
    return [[NSString alloc] initWithBytesNoCopy:characters length:length encoding:NSASCIIStringEncoding freeWhenDone:YES];
}
//字典 转 NSData
- (NSData *)returnDataWithDictionary:(NSDictionary*)dict {
    
    NSMutableData *data = [[NSMutableData alloc]init];
    
    NSKeyedArchiver* archiver = [[NSKeyedArchiver alloc]initForWritingWithMutableData:data];
    
    [archiver encodeObject:dict forKey:@"talkData"];
    
    [archiver finishEncoding];
    
    return data;
    
}
//NSData 转 字典
- (NSDictionary*)returnDictionaryWithDataPath:(NSData*)data {
    NSKeyedUnarchiver* unarchiver = [[NSKeyedUnarchiver alloc]initForReadingWithData:data];
    NSDictionary* myDictionary = [unarchiver decodeObjectForKey:@"talkData"];
    [unarchiver finishDecoding];
    return myDictionary;
}

/**
 校验手机号
 */
- (BOOL)mobileNum:(NSString *)mobileNumber {
    
   return [mobileNumber validMobilePhone];
}


+ (BOOL)checkRemainCode:(NSString *)remain {
    NSString *pattern = @"^\\d{6}$";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",pattern];
    return [pred evaluateWithObject:remain];
}
/**
 富文本
 */
+ (NSMutableAttributedString *)attributeString:(NSString *)string color:(UIColor *)color range:(NSRange)range {
    NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:string];
    [attributeString setAttributes:@{NSForegroundColorAttributeName : color} range:range];
    return attributeString;
}

+ (NSMutableAttributedString *)attributeString:(NSString *)string font:(UIFont *)font range:(NSRange)range {
    NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:string];
    [attributeString setAttributes:@{NSFontAttributeName : font} range:range];
    return attributeString;
}

+ (NSMutableAttributedString *)attributeString:(NSString *)string font:(UIFont *)font color:(UIColor *)color range:(NSRange)range {
    NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:string];
    [attributeString setAttributes:@{NSFontAttributeName : font , NSForegroundColorAttributeName : color} range:range];
    return attributeString;
}

// 大陆身份证
+ (BOOL)newValidateIDNumber:(NSString *)value {
    // 如果身份证不是18位
    if (value.length != 18)
        return NO;
    
    // 获取前17位
    NSString *idCard17 = [value substringToIndex:17];
    // 获取第18位
    NSString *idCard18Code = [value substringFromIndex:17];
    
    NSString *checkCode = @"";
    
    if ([idCard17 isDigital]) {
        NSInteger sum17 = 0;
        int power[] = { 7, 9, 10, 5, 8, 4, 2, 1, 6, 3, 7, 9, 10, 5, 8, 4, 2 };
        if (idCard17.length == 17) {
            for (int i = 0; i < idCard17.length; i++) {
                for (int j = 0; j <idCard17.length; j++) {
                    if (i == j) {
                        NSInteger temp = [[idCard17 substringWithRange:NSMakeRange(i, 1)] integerValue] * power[j];
                        sum17 = sum17 + temp;
                    }
                }
            }
        }
        
        checkCode = @[@"1", @"0", @"x", @"9", @"8", @"7", @"6", @"5", @"4", @"3", @"2"][sum17 % 11];
        
        if (![idCard18Code.uppercaseString isEqualToString:checkCode.uppercaseString])
            return NO;
    }
    
    return YES;
}
- (BOOL)isDigital
{
    if (self.length == 0 || !self)
        return NO;
    
    NSRegularExpression *regularExpression = [NSRegularExpression regularExpressionWithPattern:@"^[0-9]*$" options:NSRegularExpressionCaseInsensitive error:NULL];
    
    return [regularExpression matchesInString:self options:0 range:NSMakeRange(0, self.length)].count > 0 ? YES : NO;
}

/// 是否是大陆身份证。这个是最新的销巴身份证规则，没有newValidateIDNumber:验证的那么复杂
- (BOOL)isChinaIDCard {
    
    if (self.length == 15 && [self isPureInt]) {
        //15位规则： 0-9数字，第9位是0或1
        NSString *string = [self substringWithRange:NSMakeRange(8, 1)];
        return ([string isEqualToString:@"0"] || [string isEqualToString:@"1"]);
    }
    if (self.length == 18) {
        // 18位规则：第11位0或1，最后一位数字或X，其它0-9数字
        NSString *string11 = [self substringWithRange:NSMakeRange(10, 1)];
        BOOL isRight11 = ([string11 isEqualToString:@"0"] || [string11 isEqualToString:@"1"]);
        
        NSString *string18 = [self substringWithRange:NSMakeRange(17, 1)];
        BOOL isRight18 = ([string18 isEqualToString:@"X"] || [string18 isPureInt]);
        
        NSString *stringPrefix17 = [self substringWithRange:NSMakeRange(0, 17)];
        BOOL isRightPrefix17 = [stringPrefix17 isPureInt];
        
        return (isRight11 && isRight18 && isRightPrefix17);
    }
    
    return NO;
}

// 统一判断是不是港澳台的身份证
- (BOOL)isHKOrAoMenOrTaiWanIDCard {
    return ([self isHongKangIDCard] || [self isAoMenIDCard] || [self isTaiWanIDCard]);
}

// 香港身份证规则：10位：1位大写字母+6位数字+(1位大写字母或数字)
- (BOOL)isHongKangIDCard {
    
    NSString *HKIDType = @"^[A-Z]\\d{6}\\([0-9A-Z]\\)$";
    NSPredicate *HKRegextestID = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", HKIDType];
    return [HKRegextestID evaluateWithObject:self];
}

// 澳门身份证规则：10位：1/5/7任一数字+6位数字++(1位数字)
- (BOOL)isAoMenIDCard {
    
    NSString *AoMenIDType = @"^[157]\\d{6}\\(\\d{1}\\)$";
    NSPredicate *AoMenRegextestID = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", AoMenIDType];
    return [AoMenRegextestID evaluateWithObject:self];
}

// 台湾身份证规则：1位大写字母+9位数字
- (BOOL)isTaiWanIDCard {
    
    NSString *TaiWanIDType = @"^[A-Z]\\d{9}$";
    NSPredicate *TaiWanRegextestID = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", TaiWanIDType];
    return [TaiWanRegextestID evaluateWithObject:self];
}

/// 身份证密文显示：显示后四位，前面用等量的*代替
- (NSString *)idCardEncrypt {
    
    if (self.length <= 4) {
        return self;
    }
    
    NSMutableString *result = [NSMutableString string];
    
    // 前面是*号
    for (int i = 0; i < self.length - 4; i++) {
        [result appendString:@"*"];
    }
    
    // 显示后四位
    [result appendString:[self substringFromIndex:self.length-4]];
    
    return [NSString stringWithString:result];
}

///银行卡
+ (BOOL)IsBankCard:(NSString *)cardNumber {
    NSString *pattern = @"^\\d{8,21}$";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",pattern];
    return [pred evaluateWithObject:cardNumber];
    /**
    if (cardNumber.length < 15 || cardNumber.length > 21) {
        return NO;
    }
    int oddsum = 0;    //奇数求和
    int evensum = 0;    //偶数求和
    int allsum = 0;
    int cardNumberLength = (int)[cardNumber length];
    int lastNum = [[cardNumber substringFromIndex:cardNumberLength-1] intValue];
    cardNumber = [cardNumber substringToIndex:cardNumberLength -1];
    for (int i = cardNumberLength -1 ; i>=1;i--) {
        NSString *tmpString = [cardNumber substringWithRange:NSMakeRange(i-1,1)];
        int tmpVal = [tmpString intValue];
        if (cardNumberLength % 2 ==1 ) {
            if((i % 2) == 0){
                tmpVal *= 2;
                if(tmpVal>=10)
                    tmpVal -= 9;
                evensum += tmpVal;
            }else{
                oddsum += tmpVal;
            }
        }else{
            if((i % 2) == 1){
                tmpVal *= 2;
                if(tmpVal>=10)
                    tmpVal -= 9;
                evensum += tmpVal;
            }else{
                oddsum += tmpVal;
            }
        }
    }
    allsum = oddsum + evensum;
    allsum += lastNum;
    if((allsum % 10) ==0)
        return YES;
    else
        return NO;
     */
}

- (BOOL) deptNumInputShouldNumber:(NSString *)str
{
    NSString *regex = @"[0-9]*";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex];
    if ([pred evaluateWithObject:str]) {
        return YES;
    }
    return NO;
}

///判断是否是纯数字
- (BOOL)isPureInt {
    
    NSString *match = @"[0-9]*";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF matches %@", match];
    return [predicate evaluateWithObject:self];
}

///判断是否是详细地址。中英文数字和空格
- (BOOL)isDetailAddress {
    
    NSString *match = @"^[\u4e00-\u9fa5A-Za-z0-9 ]+$";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF matches %@", match];
    return [predicate evaluateWithObject:self];
}
///判断是否是联系人。中英文和· 长度2-25
- (BOOL)isNameString {
    
    NSString *match = @"^[\u4e00-\u9fa5A-Za-z·]{2,25}$";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF matches %@", match];                                                                                                                                                                                                                                                                                                                                                                                                                            
    return (self.length >= 2 && self.length <= 25 && [predicate evaluateWithObject:self]);
}
- (BOOL)isPureChinese
{
    NSString *match = @"^[\u4e00-\u9fa5]+$";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF matches %@", match];
    return [predicate evaluateWithObject:self];
}

- (BOOL)includeChinese
{
    for(int i=0; i< [self length];i++)
        {
        int a =[self characterAtIndex:i];
        if( a >0x4e00&& a <0x9fff){
            return YES;
        }
        }
    return NO;
}
- (BOOL)isValidUrl
{
    NSString *regex =@"(https|http|ftp|rtsp|igmp|file|rtspt|rtspu)://[^\\s]*";
    NSPredicate *urlTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex];
    return [urlTest evaluateWithObject:self];
}

///判断是否是有效的邮箱
- (BOOL)isValidEmail {
    NSString *regex =@"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *urlTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex];
    return [urlTest evaluateWithObject:self];
}
///判断是否是邮箱允许的字符类型
- (BOOL)isValidEmailLimitString {
    NSString *match = @"^[A-Z0-9a-z._@]+$";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF matches %@", match];
    return [predicate evaluateWithObject:self];
}

///判断是否是物流单号
- (BOOL)isValidLogisticOrdersn {
    NSString *regex =@"[A-Za-z0-9]{8,20}";
    NSPredicate *urlTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex];
    return [urlTest evaluateWithObject:self];
}


///获取text的宽度
- (CGFloat)widthWithStringAttributes:(NSDictionary <NSString *, id> *)attributes {
    
    NSParameterAssert(attributes);
    
    CGFloat width = 0;
    
    if (self.length) {
        
        CGRect rect = [self boundingRectWithSize:CGSizeMake(MAXFLOAT, 0)
                                         options:NSStringDrawingTruncatesLastVisibleLine |NSStringDrawingUsesLineFragmentOrigin |
                       NSStringDrawingUsesFontLeading
                                      attributes:attributes
                                         context:nil];
        
        width = rect.size.width;
    }
    
    return width;
}

- (BOOL)isPhoneVerificationCode {
    NSString *verificationCodeRegex = @"^\\d{6}$";
    NSPredicate *verificationTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",verificationCodeRegex];
    return [verificationTest evaluateWithObject:self];
}

- (BOOL)validString {
    if (self.length == 0 || self == nil || [self isKindOfClass:[NSNull class]] || self == NULL) {
        return NO;
    }
    return YES;
}

- (BOOL)validPassword {
    if (self.length == 0 || self == nil) {
        return NO;
    }
    if (self.length < 6 || self.length > 32) {
        return NO;
    }
    NSCharacterSet *charset = [[NSCharacterSet characterSetWithCharactersInString:ALPHA] invertedSet];
    NSString *filtered = [[self componentsSeparatedByCharactersInSet:charset] componentsJoinedByString:@""];
    return [self isEqualToString:filtered];
}

/**
 *  验证密码复杂度，必须是字母，数字，字符两种以上,前提是validPassword
 */
- (BOOL)isPasswordComplexity {
    
    NSInteger count = 0;
    
    NSString *characters = @"@-_.";
    NSString *numbers = @"0123456789";
    NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ";
    
    BOOL hasLetter = NO;
    BOOL hasNumber = NO;
    BOOL hasCharacter = NO;
    
    for (NSInteger i = 0; i < self.length; i++) {
        NSString *temp = [self substringWithRange:NSMakeRange(i, 1)];
        
        if ([letters containsString:temp]) {
            // 是不是第一个字母
            if (hasLetter == NO) {
                hasLetter = YES;
                count ++;
            }
        }else if ([numbers containsString:temp]) {
            // 是不是第一个数字
            if (hasNumber == NO) {
                hasNumber = YES;
                count ++;
            }
        }else if ([characters containsString:temp]) {
            // 是不是第一个字符
            if (hasCharacter == NO) {
                hasCharacter = YES;
                count ++;
            }
        }
        
        if (count >= 2) {
            return YES;
        }
    }
    
    return NO;
}


- (BOOL)validMobilePhone {
    
    // 注意: 校验手机号 有两个方法，项目中都有用到，修改正则时两个方法都要改
    // 后面港澳台
    NSString *MOBILE = @"^((13[0-9])|(14[5-9])|(15[^4,\\D])|(166)|(17[0-9])|(18[0-9])|(19[89])|(852)|(853)|(886[0-9]))\\d{8}$";
    NSPredicate *regextestmobile = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", MOBILE];
    return [regextestmobile evaluateWithObject:self];
    
}

- (NSString *)checkPhoneBelong {
    // 中国移动
    NSString *cm = @"^1((3[4-9])|(4[78])|(5[012789])|(7[28])|(8[23478])|(98))";
    NSPredicate *predCM = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",cm];
    if ([predCM evaluateWithObject:self]) {
        return @"中国移动";
    }
    // 中国电信
    NSString *ct = @"^1((33)|(49)|(53)|(7[37])|(8[019])|(99))";
    NSPredicate *predCT = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",ct];
    if ([predCT evaluateWithObject:self]) {
        return @"中国电信";
    }
    // 中国联通
    NSString *cu = @"^1((3[0-2])|(4[56])|(5[56])|(66)|(7[56])|(8[56]))";
    NSPredicate *predCU = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",cu];
    if ([predCU evaluateWithObject:self]) {
        return @"中国联通";
    }
    return nil;
}

- (NSString *)filterCharactorWithRegex:(NSString *)regexString {
    NSString *searchText = self;
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regexString options:NSRegularExpressionCaseInsensitive error:&error];
    NSString *result = [regex stringByReplacingMatchesInString:searchText options:NSMatchingReportCompletion range:NSMakeRange(0, searchText.length) withTemplate:@""];
    return result;
}

/// 过滤其它字符 regex:允许的字符 maxLength:最大长度，超出了截取前面的部分
- (NSString *)filterCharactorWithRegex:(NSString *)regex maxLength:(NSInteger)maxLength {
    
    NSString *string = [self filterCharactorWithRegex:regex];
    
    if (string.length > maxLength) {
        string = [string substringToIndex:maxLength];
    }
    return string;
}


/// 过滤非姓名字符 中英文和· 长度2-25
- (NSString *)filterNameString {
    
   return [self filterCharactorWithRegex:@"[^\u4e00-\u9fa5A-Za-z·]" maxLength:25];
}

- (BOOL)stringContainsEmoji {
    __block BOOL returnValue = NO;
    [self enumerateSubstringsInRange:NSMakeRange(0, [self length])
                               options:NSStringEnumerationByComposedCharacterSequences
                            usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
                                const unichar hs = [substring characterAtIndex:0];
                                if (0xd800 <= hs && hs <= 0xdbff) {
                                    if (substring.length > 1) {
                                        const unichar ls = [substring characterAtIndex:1];
                                        const int uc = ((hs - 0xd800) * 0x400) + (ls - 0xdc00) + 0x10000;
                                        if (0x1d000 <= uc && uc <= 0x1f77f) {
                                            returnValue = YES;
                                        }
                                    }
                                } else if (substring.length > 1) {
                                    const unichar ls = [substring characterAtIndex:1];
                                    if (ls == 0x20e3) {
                                        returnValue = YES;
                                    }
                                } else {
                                    if (0x2100 <= hs && hs <= 0x27ff) {
                                        returnValue = YES;
                                    } else if (0x2B05 <= hs && hs <= 0x2b07) {
                                        returnValue = YES;
                                    } else if (0x2934 <= hs && hs <= 0x2935) {
                                        returnValue = YES;
                                    } else if (0x3297 <= hs && hs <= 0x3299) {
                                        returnValue = YES;
                                    } else if (hs == 0xa9 || hs == 0xae || hs == 0x303d || hs == 0x3030 || hs == 0x2b55 || hs == 0x2b1c || hs == 0x2b1b || hs == 0x2b50) {
                                        returnValue = YES;
                                    }
                                }
                            }];
    return returnValue;
}

/// 昵称加密。返回加密后的字符串
- (NSString *)nicknameEncrypt {
    
    NSString *origin = self;
    NSString *result = nil;
    
    //文本类加密规则：<=3位，首1显示，其它加密**
    //              >3位，首1尾2显示，其它加密**,中间最多两个*
    if (origin.length > 0 && origin.length <= 3) {
        
        NSMutableString *star = [[NSMutableString alloc]init];
        for (NSInteger i = 0; i < origin.length-1; i++) {
            [star appendString:@"*"];
        }
        
        result = [origin stringByReplacingCharactersInRange:NSMakeRange(1, origin.length-1) withString:star];
        
    }else if (self.length > 3) {
        
        result = [origin stringByReplacingCharactersInRange:NSMakeRange(1, origin.length-3) withString:@"**"];
    }
    
    return result;
}


///转换为金额number 默认保留小数点后2位，超出位数舍去
- (NSDecimalNumber *)numberWithMoneyFormat {
    return [self numberWithRoundingMode:NSRoundDown Position:2];
}
/// 转换为金额number mode保留方式 position为小数点后最多位数
- (NSDecimalNumber *)numberWithRoundingMode:(NSRoundingMode)mode Position:(int)position {
    /*
     NSRoundPlain,   // 四舍五入
     NSRoundDown,    // 向下取整
     NSRoundUp,      // 向上取整
     NSRound Bankers  // 四舍六入五留双
     关于四舍六入五留双：
     当尾数为4，舍。
     当尾数为5，而尾数后面的数字均为0时，应看尾数“5”的前一位：若前一位数字此时为奇数，就应向前进一位；若前一位数字此时为偶数，则应将尾数舍去。数字“0”在此时应被视为偶数。
     当尾数为5，而尾数“5”的后面还有任何不是0的数字时，无论前一位在此时为奇数还是偶数，也无论“5”后面不为0的数字在哪一位上，都应向前进一位。
     当尾数为6，入。
     11.135按11.1350002进行操作，当保留两位小数，尾数为5，尾数后不全为0，所以进位，不看前一位，结果为11.14
     11.125按11.1250000进行操作，当保留两位小数，尾数为5，尾数后全为0，前一位为偶数，所以不进位，结果为11.12
     */
    
    //初始化小数保留操作，定义规则为四舍五入
    NSDecimalNumberHandler* roundingBehavior = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:mode scale:position raiseOnExactness:NO raiseOnOverflow:NO raiseOnUnderflow:NO raiseOnDivideByZero:YES];
    
    //定义两个NSDecimalNumber 对象
    NSDecimalNumber *oldFloatNum;
    NSDecimalNumber *newFloatNum;
    
    //用float初始化
    oldFloatNum = [[NSDecimalNumber alloc] initWithDouble:[self doubleValue]];
    //用上面定义的操作，对flaot 进行小数保留
    newFloatNum = [oldFloatNum decimalNumberByRoundingAccordingToBehavior:roundingBehavior];
    
    return newFloatNum;
}

- (CGFloat)calculateRowHeightFont:(UIFont *)font rowWidth:(CGFloat)rowWidth {
    CGRect rect = [self boundingRectWithSize:CGSizeMake(rowWidth, 0) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName : font} context:nil];
    return rect.size.height;
}
- (CGFloat)calculateRowWidthFont:(UIFont *)font rowHeight:(CGFloat)rowHeight {
    CGRect rect = [self boundingRectWithSize:CGSizeMake(0, rowHeight) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName : font} context:nil];
    return rect.size.width;
}

- (BOOL)regularPredicate:(NSString *)predicate {
    NSPredicate *regextestmobile = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", predicate];
    return [regextestmobile evaluateWithObject:self];
}


@end
