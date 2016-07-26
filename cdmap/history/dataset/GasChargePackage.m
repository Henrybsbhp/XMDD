#import "GasChargePackage.h"
  
@implementation GasChargePackage
+ (instancetype)createWithJSONDict:(NSDictionary *)dict
{
    GasChargePackage *obj = [[self alloc] init];
    [obj resetWithJSONDict:dict];
    return obj;
}

- (void)resetWithJSONDict:(NSDictionary *)dict
{
    self.discount = dict[@"discount"];
    self.month = [dict[@"month"] intValue];
    self.pkgid = dict[@"pkgid"];

}

@end

