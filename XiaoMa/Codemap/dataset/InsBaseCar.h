#import <Foundation/Foundation.h>

@interface InsBaseCar : NSObject
///姓名
@property (nonatomic,strong) NSString* name;
///车架号
@property (nonatomic,strong) NSString* frameno;
///车型中非中文部分
@property (nonatomic,strong) NSString* brandname;
///发动机号
@property (nonatomic,strong) NSString* engineno;
///行驶的省份
@property (nonatomic,strong) NSString* province;
///行使城市
@property (nonatomic,strong) NSString* city;
///注册日期(YYYY-MM-DD)
@property (nonatomic,strong) NSString* regdate;
///过户标志 1：过户  0：非过户
@property (nonatomic,assign) int transferflag;
///过户日期(YYYY-MM-DD)
@property (nonatomic,strong) NSString* transferdate;


+ (instancetype)createWithJSONDict:(NSDictionary *)dict;
- (void)resetWithJSONDict:(NSDictionary *)dict;

@end
