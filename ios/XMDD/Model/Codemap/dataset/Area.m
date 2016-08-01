#import "Area.h"
  
@implementation Area
+ (instancetype)createWithJSONDict:(NSDictionary *)dict
{
    Area *obj = [[self alloc] init];
    [obj resetWithJSONDict:dict];
    return obj;
}

- (void)resetWithJSONDict:(NSDictionary *)dict
{
    self.aid = dict[@"id"];
    self.name = dict[@"name"];
    self.abbr = dict[@"abbr"];
    self.code = dict[@"code"];

}

@end

