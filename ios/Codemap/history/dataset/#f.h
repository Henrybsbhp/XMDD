#import <Foundation/Foundation.h>

@interface #f : NSObject
@property (nonatomic,strong) NSNumber* groupid;
@property (nonatomic,strong) NSNumber* carid;
@property (nonatomic,strong) NSNumber* memberid;


+ (instancetype)createWithJSONDict:(NSDictionary *)dict;
- (void)resetWithJSONDict:(NSDictionary *)dict;

@end
