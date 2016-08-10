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
    self.cardtype = [dict[@"cardtype"] intValue];
    self.status = [dict[@"status"] intValue];
    self.statusdesc = dict[@"statusdesc"];
    self.paymoney = [dict[@"paymoney"] intValue];
    self.chargemoney = [dict[@"chargemoney"] intValue];
    self.fqjyPeriod = [dict[@"fqjyperiod"] integerValue];
    self.fqjyMonths = [dict[@"fqjymonths"] integerValue];

}

@end

