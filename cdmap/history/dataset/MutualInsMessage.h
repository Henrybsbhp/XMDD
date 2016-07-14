#import <Foundation/Foundation.h>

@interface MutualInsMessage : NSObject
///消息生成时间
@property (nonatomic,strong) NSString* time;
///车辆品牌图标url
@property (nonatomic,strong) NSString* carlogourl;
///车牌号码
@property (nonatomic,strong) NSString* licensenumber;
///动态内容
@property (nonatomic,strong) NSString* content;
///成员id
@property (nonatomic,strong) NSNumber* memberid;


+ (instancetype)createWithJSONDict:(NSDictionary *)dict;
- (void)resetWithJSONDict:(NSDictionary *)dict;

@end
