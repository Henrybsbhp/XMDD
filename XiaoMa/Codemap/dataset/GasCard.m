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
    self.availablechargeamt = dict[@"availablechargeamt"];
    self.couponedmoney = dict[@"couponedmoney"];
    self.desc = dict[@"desc"];

}

- (void)mergeSimpleGasCard:(GasCard *)other
{
    self.gascardno = other.gascardno;
}

- (NSInteger)maxCardNumberLength
{
    if (self.cardtype == 1) {
        return 19;
    }
    return 16;
}

@end

