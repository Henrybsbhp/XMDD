#import <Foundation/Foundation.h>

@interface MutualInsMemberInfo2 : NSObject
///状态(1：待完善资料。3：审核中。5：待支付。6：支付完成。8：互助中。10：保障结束。20：重新上传)
@property (nonatomic,assign) int status;
///状态描述
@property (nonatomic,strong) NSString* statusdesc;
///车辆品牌图标url
@property (nonatomic,strong) NSString* carlogourl;
///车牌
@property (nonatomic,strong) NSString* licensenumber;
///其他信息
@property (nonatomic,strong) NSArray* extendinfo;


+ (instancetype)createWithJSONDict:(NSDictionary *)dict;
- (void)resetWithJSONDict:(NSDictionary *)dict;

@end
