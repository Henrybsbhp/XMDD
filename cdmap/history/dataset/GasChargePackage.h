#import <Foundation/Foundation.h>

@interface GasChargePackage : NSObject
///折扣率
@property (nonatomic,strong) NSString* discount;
///分期月份
@property (nonatomic,assign) int month;
@property (nonatomic,strong) NSNumber* pkgid;


+ (instancetype)createWithJSONDict:(NSDictionary *)dict;
- (void)resetWithJSONDict:(NSDictionary *)dict;

@end
