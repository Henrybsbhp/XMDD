//
//  HKPopoverView.h
//  XiaoMa
//
//  Created by jiangjunchen on 16/3/7.
//  Copyright © 2016年 huika. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HKPopoverViewItem;

@interface HKPopoverView : UIView
@property (nonatomic, readonly) NSArray *items;
@property (nonatomic, assign, readonly) BOOL isActivated;
@property (nonatomic, copy) void(^didSelectedBlock)(NSUInteger index);
@property (nonatomic, copy) void(^didDismissedBlock)(BOOL animated);

- (instancetype)initWithMaxWithContentSize:(CGSize)size items:(NSArray *)items;
- (void)showAtAnchorPoint:(CGPoint)point inView:(UIView *)view dismissTargetView:(UIView *)view2 animated:(BOOL)animated;
- (void)dismissWithAnimated:(BOOL)animated;

@end

@interface HKPopoverViewItem : NSObject

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *imageName;

+ (instancetype)itemWithTitle:(NSString *)title imageName:(NSString *)imgname;

@end
