#import <Foundation/Foundation.h>

@interface GasChargeRecord : NSObject
///支付时间
@property (nonatomic,assign) long long payedtime;
///油卡名称
@property (nonatomic,strong) NSString* gascardname;
///油卡卡号
@property (nonatomic,strong) NSString* gascardno;
///记录状态 (2:支付成功 3:充值成功 4:充值失败)
@property (nonatomic,assign) int status;
///状态说明
@property (nonatomic,strong) NSString* statusdesc;
///支付金额
@property (nonatomic,assign) int paymoney;
///充值金额
@property (nonatomic,assign) int chargemoney;


+ (instancetype)createWithJSONDict:(NSDictionary *)dict;
- (void)resetWithJSONDict:(NSDictionary *)dict;

@end
