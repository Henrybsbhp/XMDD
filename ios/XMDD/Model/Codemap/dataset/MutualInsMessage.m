#import "MutualInsMessage.h"
  
@implementation MutualInsMessage
+ (instancetype)createWithJSONDict:(NSDictionary *)dict
{
    MutualInsMessage *obj = [[self alloc] init];
    [obj resetWithJSONDict:dict];
    return obj;
}

- (void)resetWithJSONDict:(NSDictionary *)dict
{
    self.time = dict[@"time"];
    self.carlogourl = dict[@"carlogourl"];
    self.licensenumber = dict[@"licensenumber"];
    self.content = dict[@"content"];
    self.memberid = dict[@"memberid"];

}

@end

