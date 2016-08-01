#import <Foundation/Foundation.h>

@interface InsCoveragePrice : NSObject
///保险项id
@property (nonatomic,strong) NSNumber* coverageid;
///险种名称
@property (nonatomic,strong) NSString* coverage;
///每项保费
@property (nonatomic,assign) double fee;
///服务价格
@property (nonatomic,assign) double value;


+ (instancetype)createWithJSONDict:(NSDictionary *)dict;
- (void)resetWithJSONDict:(NSDictionary *)dict;

@end
