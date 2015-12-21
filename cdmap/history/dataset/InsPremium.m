#import "InsPremium.h"
  
@implementation InsPremium
+ (instancetype)createWithJSONDict:(NSDictionary *)dict
{
    InsPremium *obj = [[self alloc] init];
    [obj resetWithJSONDict:dict];
    return obj;
}

- (void)resetWithJSONDict:(NSDictionary *)dict
{
    self.inslogo = dict[@"inslogo"];
    self.originprice = [dict[@"originprice"] doubleValue];
    self.price = [dict[@"price"] doubleValue];
    self.couponlist = dict[@"couponlist"];
    self.inscomp = dict[@"inscomp"];
    self.carpremiumid = dict[@"carpremiumid"];
    self.inscompname = dict[@"inscompname"];
    self.ordertype = [dict[@"ordertype"] intValue];
    self.couponname = dict[@"couponname"];
    self.errmsg = dict[@"errmsg"];

}

@end

