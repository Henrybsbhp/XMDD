#import <Foundation/Foundation.h>

@interface BankCard : NSObject
///银行卡id
@property (nonatomic,strong) NSNumber* cardid;
///银行卡卡号
@property (nonatomic,strong) NSString* cardno;


+ (instancetype)createWithJSONDict:(NSDictionary *)dict;
- (void)resetWithJSONDict:(NSDictionary *)dict;

@end
