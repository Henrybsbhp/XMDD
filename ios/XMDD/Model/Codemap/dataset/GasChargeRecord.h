#import <Foundation/Foundation.h>

@interface GasChargeRecord : NSObject
///支付时间
@property (nonatomic,assign) long long payedtime;
///油卡名称
@property (nonatomic,strong) NSString* gascardname;
///油卡卡号
@property (nonatomic,strong) NSString* gascardno;
///油卡类型
@property (nonatomic,assign) int cardtype;
///记录状态 (2:支付成功 3:充值成功 4:充值失败)
@property (nonatomic,assign) int status;
///状态说明
@property (nonatomic,strong) NSString* statusdesc;
///支付金额
@property (nonatomic,assign) int paymoney;
///充值金额
@property (nonatomic,assign) int chargemoney;
///分期加油第几期
@property (nonatomic, assign) NSInteger fqjyPeriod;
///分期加油总期数
@property (nonatomic, assign) NSInteger fqjyMonths;


+ (instancetype)createWithJSONDict:(NSDictionary *)dict;
- (void)resetWithJSONDict:(NSDictionary *)dict;

@end
