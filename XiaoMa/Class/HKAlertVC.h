//
//  HKAlertVC.h
//  XiaoMa
//
//  Created by jiangjunchen on 16/3/11.
//  Copyright © 2016年 huika. All rights reserved.
//

#import <UIKit/UIKit.h>
@class HKAlertActionItem;

@interface HKAlertVC : UIViewController

@property (nonatomic, strong) NSArray *actionItems;
@property (nonatomic, strong) UIView *contentView;

- (void)show;
- (void)showWithActionHandler:(void(^)(NSInteger index, id alertVC))actionHandler;
- (void)dismiss;

@end

@interface HKAlertActionItem : NSObject
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) UIColor *color;
@property (nonatomic, copy) void(^clickBlock)(id alertVC);

+ (instancetype)item;
///(default color is HEXCOLOR(@"#18d06a"), clickBlock is nil)
+ (instancetype)itemWithTitle:(NSString *)title;
+ (instancetype)itemWithTitle:(NSString *)title color:(UIColor *)color clickBlock:(void(^)(id alertVC))block;

@end
