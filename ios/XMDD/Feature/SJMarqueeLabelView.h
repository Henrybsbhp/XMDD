//
//  SJMarqueeLabelView.h
//  XMDD
//
//  Created by St.Jimmy on 8/22/16.
//  Copyright © 2016 huika. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SJMarqueeLabelView : UIView

@property (nonatomic, strong) UILabel *label1;
@property (nonatomic, strong) UILabel *label2;

- (instancetype)initWithFrame:(CGRect)frame tipsArray:(NSArray *)tipsArray;
- (void)showScrollingMessageView;

@end
