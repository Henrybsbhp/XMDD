#import "GasChargeRecord.h"
  
@implementation GasChargeRecord
+ (instancetype)createWithJSONDict:(NSDictionary *)dict
{
    GasChargeRecord *obj = [[self alloc] init];
    [obj resetWithJSONDict:dict];
    return obj;
}

- (void)resetWithJSONDict:(NSDictionary *)dict
{
    self.payedtime = [dict[@"payedtime"] longLongValue];
    self.gascardname = dict[@"gascardname"];
    self.gascardno = dict[@"gascardno"];
    self.status = [dict[@"status"] intValue];
    self.statusdesc = dict[@"statusdesc"];
    self.paymoney = [dict[@"paymoney"] intValue];
    self.chargemoney = [dict[@"chargemoney"] intValue];

}

@end

