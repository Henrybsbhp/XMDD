#import "MutualInsMemberInfo.h"
  
@implementation MutualInsMemberInfo
+ (instancetype)createWithJSONDict:(NSDictionary *)dict
{
    MutualInsMemberInfo *obj = [[self alloc] init];
    [obj resetWithJSONDict:dict];
    return obj;
}

- (void)resetWithJSONDict:(NSDictionary *)dict
{
    self.licensenumber = dict[@"licensenumber"];
    self.brandurl = dict[@"brandurl"];
    self.memberid = dict[@"memberid"];
    self.showflag = [dict[@"showflag"] boolValue];
    self.lstupdatetime = [dict[@"lstupdatetime"] longLongValue];
    self.statusdesc = dict[@"statusdesc"];

}

@end

