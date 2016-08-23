//
//  SJMarqueeLabelView.h
//  XMDD
//
//  Created by St.Jimmy on 8/22/16.
//  Copyright © 2016 huika. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SJMarqueeLabelView : UIView

/// 交替滚动的第一个 Label
@property (nonatomic, strong) UILabel *label1;
/// 交替滚动的第二个 Label
@property (nonatomic, strong) UILabel *label2;

- (instancetype)initWithFrame:(CGRect)frame tipsArray:(NSArray *)tipsArray;

/// 使两个 Label 交替滚动
- (void)showScrollingMessageView;

@end
