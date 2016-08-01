#import "MutualInsClaimInfo.h"
  
@implementation MutualInsClaimInfo
+ (instancetype)createWithJSONDict:(NSDictionary *)dict
{
    MutualInsClaimInfo *obj = [[self alloc] init];
    [obj resetWithJSONDict:dict];
    return obj;
}

- (void)resetWithJSONDict:(NSDictionary *)dict
{
    self.claimid = dict[@"claimid"];
    self.detailstatus = [dict[@"detailstatus"] intValue];
    self.detailstatusdesc = dict[@"detailstatusdesc"];
    self.statusdesc = dict[@"statusdesc"];
    self.accidentdesc = dict[@"accidentdesc"];
    self.claimfee = [dict[@"claimfee"] floatValue];
    self.lstupdatetime = dict[@"lstupdatetime"];
    self.licensenum = dict[@"licensenum"];
}

@end

