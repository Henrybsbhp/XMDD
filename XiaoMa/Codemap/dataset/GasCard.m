#import "GasCard.h"
#import "NSString+Split.h"

@implementation GasCard
+ (instancetype)createWithJSONDict:(NSDictionary *)dict
{
    GasCard *obj = [[self alloc] init];
    [obj resetWithJSONDict:dict];
    return obj;
}

- (void)resetWithJSONDict:(NSDictionary *)dict
{
    self.gid = dict[@"gid"];
    self.gascardno = dict[@"gascardno"];
    self.cardtype = [dict[@"cardtype"] intValue];
    self.availablechargeamt = [dict[@"availablechargeamt"] intValue];
    self.couponedmoney = [dict[@"couponedmoney"] intValue];
    self.czbdiscountrate = [dict[@"czbdiscountrate"] intValue];
    self.czbcouponupplimit = [dict[@"czbcouponupplimit"] intValue];
    self.czbcouponedmoney = [dict[@"czbcouponedmoney"] intValue];

}

- (void)mergeSimpleGasCard:(GasCard *)other
{
    self.gascardno = other.gascardno;
}

- (NSString *)prettyCardNumber
{
    return [self.gascardno splitByStep:4 replacement:@" "];
}

- (NSInteger)maxCardNumberLength
{
    if (self.cardtype == 1) {
        return 19;
    }
    return 16;
}

@end

