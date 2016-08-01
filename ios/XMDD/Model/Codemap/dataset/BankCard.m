#import "BankCard.h"
  
@implementation BankCard
+ (instancetype)createWithJSONDict:(NSDictionary *)dict
{
    BankCard *obj = [[self alloc] init];
    [obj resetWithJSONDict:dict];
    return obj;
}

- (void)resetWithJSONDict:(NSDictionary *)dict
{
    self.cardid = dict[@"cardid"];
    self.cardno = dict[@"cardno"];

}

@end

