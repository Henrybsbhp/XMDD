//
//  MutualInsGroupMemberCell.m
//  XiaoMa
//
//  Created by jiangjunchen on 16/7/12.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "MutualInsGroupMemberCell.h"
#import "UILabel+MarkupExtensions.h"

#define kHorMargin     16
#define kDetailLabelFontSize    13

@interface MutualInsGroupMemberCell ()
@property (nonatomic, strong) UIView *detailContainerView;
@end

@implementation MutualInsGroupMemberCell

- (void)awakeFromNib {
    // Initialization code
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self __commonInit];
    }
    return self;
}

- (void)__commonInit {
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    self.logoView = [[UIImageView alloc] initWithFrame:CGRectZero];
    [self.contentView addSubview:self.logoView];
    
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.titleLabel.textColor = kDarkTextColor;
    self.titleLabel.font = [UIFont systemFontOfSize:17];
    [self.contentView addSubview:self.titleLabel];

    self.tipButton = [[UIButton alloc] initWithFrame:CGRectZero];
    self.tipButton.userInteractionEnabled = NO;
    self.tipButton.titleLabel.font = [UIFont systemFontOfSize:14];
    [self.tipButton setTitleColor:HEXCOLOR(@"#fd5d20") forState:UIControlStateNormal];
    UIImage *tipBgImg = [[UIImage imageNamed:@"mins_tip_bg1"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 13, 0, 0)];
    [self.tipButton setBackgroundImage:tipBgImg forState:UIControlStateNormal];
    self.tipButton.contentEdgeInsets = UIEdgeInsetsMake(0, 20, 0, 15);
    [self.contentView addSubview:self.tipButton];
    
    self.detailContainerView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.contentView addSubview:self.detailContainerView];
    
    [self addOrUpdateBorderLineWithAlignment:CKLineAlignmentHorizontalTop insets:UIEdgeInsetsMake(0, kHorMargin, 0, 0)];
    [self makeConstraints];
}

- (void)makeConstraints {
    @weakify(self);
    [self.logoView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        @strongify(self);
        make.left.equalTo(self.contentView).offset(kHorMargin);
        make.top.equalTo(self.contentView).offset(21);
        make.size.mas_equalTo(CGSizeMake(42, 42));
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
       
        @strongify(self);
        make.left.equalTo(self.logoView.mas_right).offset(10);
        make.right.equalTo(self.contentView).offset(-kHorMargin);
        make.centerY.equalTo(self.logoView.mas_centerY);
    }];
    
    [self.tipButton mas_makeConstraints:^(MASConstraintMaker *make) {
        
        @strongify(self);
        make.right.equalTo(self.contentView);
        make.top.equalTo(self.contentView).offset(9);
    }];
    
    [self.detailContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        @strongify(self);
        make.top.equalTo(self.logoView.mas_bottom).offset(7);
        make.left.equalTo(self.contentView);
        make.right.equalTo(self.contentView);
    }];
}

+ (CGFloat)heightWithExtendInfoCount:(NSInteger)count {
    return 21 + 42 + 10 + (20+6)*count + 4;
}

- (void)setExtendInfoList:(NSArray *)extendInfoList {
    if (_extendInfoList != extendInfoList) {
        _extendInfoList = extendInfoList;
        [self.detailContainerView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        [self addExtendLabelsInView:self.detailContainerView];
    }
}

- (void)addExtendLabelsInView:(UIView *)view {
    id topObject = view.mas_top;
    CGFloat padding = 0;
    for (NSDictionary *info in self.extendInfoList) {
        NSString *key = info.allKeys[0];
        NSString *value = info[key];
        
        UILabel *leftL = [[UILabel alloc] initWithFrame:CGRectZero];
        leftL.textColor = kGrayTextColor;
        leftL.font = [UIFont systemFontOfSize:kDetailLabelFontSize];
        leftL.text = key;
        [leftL setContentCompressionResistancePriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
        [view addSubview:leftL];
        
        UILabel *rightL = [[UILabel alloc] initWithFrame:CGRectZero];
        rightL.textAlignment = NSTextAlignmentRight;
        rightL.font = [UIFont systemFontOfSize:kDetailLabelFontSize];
        [rightL setMarkup:value];
        [rightL setContentCompressionResistancePriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
        [view addSubview:rightL];
        
        [leftL mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(view).offset(kHorMargin);
            make.top.equalTo(topObject).offset(padding);
            make.height.mas_equalTo(20);
        }];
        
        [rightL mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(leftL.mas_right).offset(5);
            make.right.equalTo(view).offset(-kHorMargin);
            make.baseline.equalTo(leftL);
        }];
        
        padding = 6;
        topObject = leftL.mas_bottom;
    }
}
@end
