#import "#f.h"
  
@implementation #f
+ (instancetype)createWithJSONDict:(NSDictionary *)dict
{
    #f *obj = [[self alloc] init];
    [obj resetWithJSONDict:dict];
    return obj;
}

- (void)resetWithJSONDict:(NSDictionary *)dict
{
    
}

@end

