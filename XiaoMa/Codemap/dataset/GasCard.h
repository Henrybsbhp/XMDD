#import <Foundation/Foundation.h>

@interface GasCard : NSObject
///油卡id
@property (nonatomic,strong) NSNumber* gid;
///油卡卡号
@property (nonatomic,strong) NSString* gascardno;
///油卡类型 1：石化  2：石油
@property (nonatomic,assign) int cardtype;
///当月可充金额
@property (nonatomic,strong) NSNumber* availablechargeamt;
///已经享受过的优惠
@property (nonatomic,strong) NSNumber* couponedmoney;
///油卡优惠描述
@property (nonatomic,strong) NSString* desc;


+ (instancetype)createWithJSONDict:(NSDictionary *)dict;
- (void)resetWithJSONDict:(NSDictionary *)dict;
- (void)mergeSimpleGasCard:(GasCard *)other;
- (NSInteger)maxCardNumberLength;

@end
