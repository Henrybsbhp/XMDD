#import <Foundation/Foundation.h>

@interface InsSimpleCar : NSObject
///车牌
@property (nonatomic,strong) NSString* licenseno;
///车辆相关状态:  0.未关联任何信息; 1.车牌已经关联保险且没有出保单; 2.关联了核保记录; 3.有了核保车辆信息但是无核保记录; 4.关联了保险，且有保单号
@property (nonatomic,assign) int status;
///关联记录ID
@property (nonatomic,strong) NSNumber* refid;


+ (instancetype)createWithJSONDict:(NSDictionary *)dict;
- (void)resetWithJSONDict:(NSDictionary *)dict;

@end
