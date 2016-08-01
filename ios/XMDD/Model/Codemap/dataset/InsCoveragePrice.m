#import "InsCoveragePrice.h"
  
@implementation InsCoveragePrice
+ (instancetype)createWithJSONDict:(NSDictionary *)dict
{
    InsCoveragePrice *obj = [[self alloc] init];
    [obj resetWithJSONDict:dict];
    return obj;
}

- (void)resetWithJSONDict:(NSDictionary *)dict
{
    self.coverageid = dict[@"id"];
    self.coverage = dict[@"coverage"];
    self.fee = [dict[@"fee"] doubleValue];
    self.value = [dict[@"value"] doubleValue];

}

@end

