#import <Foundation/Foundation.h>

@interface GasCard : NSObject
///油卡id
@property (nonatomic,strong) NSNumber* gid;
///油卡卡号
@property (nonatomic,strong) NSString* gascardno;
///油卡类型 1：石化  2：石油
@property (nonatomic,assign) int cardtype;
///当月可充金额
@property (nonatomic,assign) int availablechargeamt;
///已经享受过的优惠
@property (nonatomic,assign) int couponedmoney;
///浙商的折扣率
@property (nonatomic,assign) int czbdiscountrate;
///浙商的优惠上限
@property (nonatomic,assign) int czbcouponupplimit;
///浙商的已享受优惠
@property (nonatomic,assign) int czbcouponedmoney;


+ (instancetype)createWithJSONDict:(NSDictionary *)dict;
- (void)resetWithJSONDict:(NSDictionary *)dict;
- (void)mergeSimpleGasCard:(GasCard *)other;
- (NSString *)prettyCardNumber;
- (NSInteger)maxCardNumberLength;

@end
