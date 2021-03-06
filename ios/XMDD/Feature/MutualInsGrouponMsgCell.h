//
//  MutualInsGrouponMsgCell.h
//  XiaoMa
//
//  Created by jiangjunchen on 16/3/11.
//  Copyright © 2016年 huika. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MutualInsGrouponMsgCell : UITableViewCell

///(default is NO)
@property (nonatomic, assign, readonly) BOOL atRightSide;
@property (nonatomic, strong) NSString *message;
@property (nonatomic, strong) UIImageView *logoView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UITapGestureRecognizer *logoViewTapGesture;


- (instancetype)initWithAtRightSide:(BOOL)rightSide reuseIdentifier:(NSString *)reuseIdentifier;

+ (CGFloat)heightWithBoundsWidth:(CGFloat)width message:(NSString *)msg;

@end
