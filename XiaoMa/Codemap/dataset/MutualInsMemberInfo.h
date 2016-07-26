#import <Foundation/Foundation.h>

@interface MutualInsMemberInfo : NSObject
///车牌
@property (nonatomic,strong) NSString* licensenumber;
///车的品牌logo地址
@property (nonatomic,strong) NSString* brandurl;
///团员记录ID
@property (nonatomic,strong) NSNumber* memberid;
///是否在团详情上面显示
@property (nonatomic,assign) BOOL showflag;
///最后更新的时间戳
@property (nonatomic,assign) long long lstupdatetime;
///其他人的状态描述
@property (nonatomic,strong) NSString* statusdesc;


+ (instancetype)createWithJSONDict:(NSDictionary *)dict;
- (void)resetWithJSONDict:(NSDictionary *)dict;

@end
