//
//  MutualInsGroupFundCell.m
//  XiaoMa
//
//  Created by jiangjunchen on 16/7/13.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "MutualInsGroupFundCell.h"
#import "NSString+RectSize.h"

#define kHorMargin  18

@interface MutualInsGroupFundCell ()
@property (nonatomic, strong) UIView *tupleContainerView;
@end

@implementation MutualInsGroupFundCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    [self __commonInit];
    return self;
}

- (void)__commonInit {
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    self.progressView = [[GradientView alloc] initWithFrame:CGRectMake(0, 0, 229, 229)];
    self.progressView.backgroundColor = [UIColor whiteColor];
    [self.contentView addSubview:self.progressView];
    
    self.descLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.descLabel.textColor = kDarkTextColor;
    self.descLabel.font = [UIFont systemFontOfSize:15];
    self.descLabel.textAlignment = NSTextAlignmentCenter;
    self.descLabel.numberOfLines = 0;
    [self.contentView addSubview:self.descLabel];
    
    self.tupleContainerView = [[UIView alloc] init];
    [self.contentView addSubview:self.tupleContainerView];
    
    [self makeDefaultConstraints];
}

- (void)makeDefaultConstraints {
    @weakify(self);
    [self.progressView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        @strongify(self);
        make.size.mas_equalTo(CGSizeMake(229, 229));
        make.top.equalTo(self.contentView).offset(11);
        make.centerX.equalTo(self.contentView);
    }];
    
    [self.descLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        
        @strongify(self);
        make.left.equalTo(self.contentView).offset(kHorMargin);
        make.right.equalTo(self.contentView).offset(-kHorMargin);
        make.bottom.equalTo(self.contentView).offset(-32);
    }];
    
    [self.tupleContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        @strongify(self);
        make.left.equalTo(self.contentView);
        make.right.equalTo(self.contentView);
        make.top.equalTo(self.progressView.mas_bottom).offset(20);
        make.bottom.equalTo(self.descLabel.mas_top).offset(32);
    }];
}

+ (CGFloat)heightWithTupleInfoCount:(NSInteger)count andDesc:(NSString *)desc {
    CGFloat descHeight = ceil([desc labelSizeWithWidth:ScreenWidth-2*kHorMargin font:[UIFont systemFontOfSize:15]].height);
    return 11 + 229 + 20 + (20+8)*count + 32 + descHeight + 32;
}

- (void)setTupleInfoList:(NSArray *)tupleInfoList {
    if (_tupleInfoList != tupleInfoList) {
        _tupleInfoList = tupleInfoList;
        [self.tupleContainerView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        [self addTupleLabelsInView:self.tupleContainerView];
    }
}

- (void)addTupleLabelsInView:(UIView *)view {
    id topObject = view.mas_top;
    for (RACTuple *tuple in self.tupleInfoList) {
        UILabel *leftL = [[UILabel alloc] initWithFrame:CGRectZero];
        leftL.textColor = kGrayTextColor;
        leftL.font = [UIFont systemFontOfSize:14];
        leftL.text = tuple.first;
        [leftL setContentCompressionResistancePriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
        [view addSubview:leftL];
        
        UILabel *rightL = [[UILabel alloc] initWithFrame:CGRectZero];
        rightL.textColor = kDarkTextColor;
        rightL.textAlignment = NSTextAlignmentRight;
        rightL.font = [UIFont systemFontOfSize:14];
        rightL.text = tuple.second;
        [rightL setContentCompressionResistancePriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
        [view addSubview:rightL];
        
        [leftL mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(view).offset(kHorMargin);
            make.top.equalTo(topObject).offset(8);
            make.height.mas_equalTo(20);
        }];
        
        [rightL mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(leftL.mas_right).offset(5);
            make.right.equalTo(view).offset(-kHorMargin);
            make.baseline.equalTo(leftL);
        }];
        
        topObject = leftL.mas_bottom;
    }
}

@end
