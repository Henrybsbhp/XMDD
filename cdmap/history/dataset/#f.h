#import <Foundation/Foundation.h>

@interface #f : NSObject
@property (nonatomic,strong) NSArray* carinfolist;


+ (instancetype)createWithJSONDict:(NSDictionary *)dict;
- (void)resetWithJSONDict:(NSDictionary *)dict;

@end
