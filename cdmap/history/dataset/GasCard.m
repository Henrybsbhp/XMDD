#import "GasCard.h"
  
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

@end

