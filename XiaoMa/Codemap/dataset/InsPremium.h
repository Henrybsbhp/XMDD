#import <Foundation/Foundation.h>

@interface InsPremium : NSObject
///公司logo
@property (nonatomic,strong) NSString* inslogo;
///原价
@property (nonatomic,assign) double originprice;
///实际价格
@property (nonatomic,assign) double price;
///优惠列表
@property (nonatomic,strong) NSArray* couponlist;
///保险公司代码
@property (nonatomic,strong) NSString* inscomp;
///核保记录id
@property (nonatomic,strong) NSNumber* carpremiumid;
///保险公司名字
@property (nonatomic,strong) NSString* inscompname;
///购买方式（1.预约购买 2.直接购买）
@property (nonatomic,assign) int ordertype;
///打折方式名称
@property (nonatomic,strong) NSString* couponname;
///核保失败原因
@property (nonatomic,strong) NSString* errmsg;


+ (instancetype)createWithJSONDict:(NSDictionary *)dict;
- (void)resetWithJSONDict:(NSDictionary *)dict;

@end
