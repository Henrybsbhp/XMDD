#import "MutualInsMemberInfo2.h"
  
@implementation MutualInsMemberInfo2
+ (instancetype)createWithJSONDict:(NSDictionary *)dict
{
    MutualInsMemberInfo2 *obj = [[self alloc] init];
    [obj resetWithJSONDict:dict];
    return obj;
}

- (void)resetWithJSONDict:(NSDictionary *)dict
{
    self.status = [dict[@"status"] intValue];
    self.statusdesc = dict[@"statusdesc"];
    self.carlogourl = dict[@"carlogourl"];
    self.licensenumber = dict[@"licensenumber"];
    self.extendinfo = dict[@"extendinfo"];

}

@end

