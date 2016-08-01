#import "InsBaseCar.h"
  
@implementation InsBaseCar
+ (instancetype)createWithJSONDict:(NSDictionary *)dict
{
    InsBaseCar *obj = [[self alloc] init];
    [obj resetWithJSONDict:dict];
    return obj;
}

- (void)resetWithJSONDict:(NSDictionary *)dict
{
    self.name = dict[@"name"];
    self.frameno = dict[@"frameno"];
    self.brandname = dict[@"brandname"];
    self.engineno = dict[@"engineno"];
    self.province = dict[@"province"];
    self.city = dict[@"city"];
    self.regdate = dict[@"regdate"];
    self.transferflag = [dict[@"transferflag"] intValue];
    self.transferdate = dict[@"transferdate"];

}

@end

