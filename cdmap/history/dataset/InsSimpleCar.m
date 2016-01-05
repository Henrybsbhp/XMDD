#import "InsSimpleCar.h"
  
@implementation InsSimpleCar
+ (instancetype)createWithJSONDict:(NSDictionary *)dict
{
    InsSimpleCar *obj = [[self alloc] init];
    [obj resetWithJSONDict:dict];
    return obj;
}

- (void)resetWithJSONDict:(NSDictionary *)dict
{
    self.licenseno = dict[@"licenseno"];
    self.status = [dict[@"status"] intValue];
    self.refid = dict[@"refid"];
    self.carpremiumid = dict[@"carpremiumid"];

}

@end

