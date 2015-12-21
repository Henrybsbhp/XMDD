#import <Foundation/Foundation.h>

@interface Area : NSObject
///地区id
@property (nonatomic,strong) NSNumber* aid;
///名称
@property (nonatomic,strong) NSString* name;
///简称
@property (nonatomic,strong) NSString* abbr;
///地理代码
@property (nonatomic,strong) NSString* code;


+ (instancetype)createWithJSONDict:(NSDictionary *)dict;
- (void)resetWithJSONDict:(NSDictionary *)dict;

@end
