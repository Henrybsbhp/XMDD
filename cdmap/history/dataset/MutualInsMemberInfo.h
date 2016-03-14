#import <Foundation/Foundation.h>

@interface MutualInsMemberInfo : NSObject
///车牌
@property (nonatomic,strong) NSString* licensenumber;
///车的品牌logo地址
@property (nonatomic,strong) NSString* 车的品牌logo地址;
///团员记录ID
@property (nonatomic,strong) NSNumber* memberid;
///其他人的状态描述
@property (nonatomic,strong) NSString* statusdesc;


+ (instancetype)createWithJSONDict:(NSDictionary *)dict;
- (void)resetWithJSONDict:(NSDictionary *)dict;

@end
