#import <Foundation/Foundation.h>

@interface MutualInsContract : NSObject
///协议记录ID
@property (nonatomic,strong) NSNumber* contractid;
///协议状态 1：待支付，2：支付完成，3待协议寄出。4协议已寄出
@property (nonatomic,assign) int status;
///受益人
@property (nonatomic,strong) NSString* insurancedname;
///协议期限
@property (nonatomic,strong) NSString* contractperiod;
///车牌
@property (nonatomic,strong) NSString* licencenumber;
///证件号
@property (nonatomic,strong) NSString* idno;
///共计保费
@property (nonatomic,assign) float total;
///优惠金额
@property (nonatomic,assign) float couponmoney;
///保险列表 {insname:sum}
@property (nonatomic,strong) NSArray* inslist;
///交强险期限,如果查出了该车可以代买交强险则有值
@property (nonatomic,strong) NSString* insperiod;
///交强险
@property (nonatomic,assign) float forcefee;
///车船税
@property (nonatomic,assign) float taxshipfee;
///协议期限
@property (nonatomic,strong) NSArray* inscomp;
///投保月份数
@property (nonatomic,strong) NSNumber* totalmonth;
///小马达达互助logo
@property (nonatomic,strong) NSString* xmddlogo;
///互助名字
@property (nonatomic,strong) NSString* xmddname;
///提醒文案
@property (nonatomic,strong) NSString* remindtip;
///优惠活动文案
@property (nonatomic,strong) NSString* couponname;
///优惠活动详细列表
@property (nonatomic,strong) NSArray* couponlist;



+ (instancetype)createWithJSONDict:(NSDictionary *)dict;
- (void)resetWithJSONDict:(NSDictionary *)dict;

@end
