//
//  MutualInsGroupMyDetailCell.m
//  XiaoMa
//
//  Created by jiangjunchen on 16/7/13.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "MutualInsGroupMyDetailCell.h"
#import "CKLine.h"
#import "NSString+RectSize.h"

#define kHorMargin     16

@interface MutualInsGroupMyDetailCell ()
@property (nonatomic, strong) UIView *timesContainerView;
@property (nonatomic, strong) UIView *pricesContainerView;
@end

@implementation MutualInsGroupMyDetailCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self __commonInit];
    }
    return self;
}

- (void)__commonInit {
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    self.feeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.feeLabel.textColor = kDarkTextColor;
    self.feeLabel.font = [UIFont systemFontOfSize:40];
    self.feeLabel.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:self.feeLabel];
    
    self.feeDescLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.feeDescLabel.textColor = kGrayTextColor;
    self.feeDescLabel.font = [UIFont systemFontOfSize:13];
    self.feeDescLabel.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:self.feeDescLabel];
    
    
    self.descLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.descLabel.textColor = kDarkTextColor;
    self.descLabel.font = [UIFont systemFontOfSize:15];
    self.descLabel.textAlignment = NSTextAlignmentCenter;
    self.descLabel.numberOfLines = 0;
    [self.contentView addSubview:self.descLabel];

    self.timesContainerView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.contentView addSubview:self.timesContainerView];
    
    self.pricesContainerView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.contentView addSubview:self.pricesContainerView];
    
    [self makeDefaultConstraints];
}

- (void)makeDefaultConstraints {
    @weakify(self);
    [self.feeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.equalTo(self.contentView).offset(kHorMargin);
        make.right.equalTo(self.contentView).offset(-kHorMargin);
        make.top.equalTo(self.contentView).offset(8);
        make.height.mas_equalTo(40);
    }];
    
    [self.feeDescLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        
        @strongify(self);
        make.left.equalTo(self.contentView).offset(kHorMargin);
        make.right.equalTo(self.contentView).offset(-kHorMargin);
        make.top.equalTo(self.feeLabel.mas_bottom).offset(14);
        make.height.mas_equalTo(18);
    }];
    
    [self.pricesContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        @strongify(self);
        make.top.equalTo(self.feeDescLabel.mas_bottom).offset(8);
        make.height.mas_equalTo(59);
        make.centerX.equalTo(self.contentView);
    }];

    [self.descLabel mas_makeConstraints:^(MASConstraintMaker *make) {
       
        @strongify(self);
        make.left.equalTo(self.contentView).offset(kHorMargin);
        make.right.equalTo(self.contentView).offset(-kHorMargin);
        make.bottom.equalTo(self.contentView).offset(-17);
    }];
    
    [self.timesContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
       
        @strongify(self);
        make.left.equalTo(self.contentView).offset(kHorMargin);
        make.right.equalTo(self.contentView).offset(-kHorMargin);
        make.top.equalTo(self.pricesContainerView.mas_bottom);
    }];
}

#pragma mark - Height
+ (CGFloat)heightWithTimeTupleCount:(NSInteger)count andDesc:(NSString *)desc {
    CGFloat descHeight = ceil([desc labelSizeWithWidth:ScreenWidth font:[UIFont systemFontOfSize:15]].height);
    return 8 + 40 + 14 + 18 + 8 +59 + (8+18)*count + 20 + descHeight + 17;
}

#pragma mark - Setter
- (void)setPriceTuples:(NSArray *)priceTuples {
    if (_priceTuples == priceTuples) {
        return;
    }
    _priceTuples = priceTuples;
    [self.pricesContainerView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    NSInteger count = self.priceTuples.count;
    CGFloat width = floor(ScreenWidth/4);
    id leftObject = self.pricesContainerView.mas_left;
    
    for (NSInteger i = 0; i < count; i++) {
        RACTuple *tuple = self.priceTuples[i];
        
        UIView *container = [[UIView alloc] initWithFrame:CGRectZero];
        
        UILabel *priceL = [[UILabel alloc] initWithFrame:CGRectZero];
        priceL.textColor = kOrangeColor;
        priceL.font = [UIFont systemFontOfSize:13];
        priceL.textAlignment = NSTextAlignmentCenter;
        priceL.text = tuple.second;
        [container addSubview:priceL];
        
        UILabel *descL = [[UILabel alloc] initWithFrame:CGRectZero];
        descL.font = [UIFont systemFontOfSize:13];
        descL.textAlignment = NSTextAlignmentCenter;
        descL.textColor = kGrayTextColor;
        descL.text = tuple.first;
        [container addSubview:descL];
        
        CKLine *line = [[CKLine alloc] initWithFrame:CGRectZero];
        line.lineAlignment = CKLineAlignmentVerticalLeft;
        line.hidden = i == 0;
        [container addSubview:line];
        
        [self.pricesContainerView addSubview:container];

        @weakify(self);
        [container mas_makeConstraints:^(MASConstraintMaker *make) {
            
            @strongify(self);
            make.size.mas_equalTo(CGSizeMake(width, 39));
            make.centerY.equalTo(self.pricesContainerView);
            make.left.equalTo(leftObject);
            if (i == count - 1) {
                make.right.equalTo(self.pricesContainerView);
            }
        }];
        
        [priceL mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.top.equalTo(container);
            make.left.equalTo(container);
            make.right.equalTo(container);
            make.height.mas_equalTo(18);
        }];
        
        [descL mas_makeConstraints:^(MASConstraintMaker *make) {
           
            make.bottom.equalTo(container);
            make.left.equalTo(container);
            make.right.equalTo(container);
        }];
        
        [line mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.width.mas_equalTo(1);
            make.top.equalTo(container);
            make.left.equalTo(container);
            make.bottom.equalTo(container);
        }];
        
        leftObject = container.mas_right;
    }
}

- (void)setTimeTuples:(NSArray *)timeTuples {
    if (_timeTuples == timeTuples) {
        return;
    }
    _timeTuples = timeTuples;
    
    id topObject = self.timesContainerView.mas_top;

    @weakify(self);
    for (RACTuple *tuple in timeTuples) {
        UILabel *leftL = [[UILabel alloc] initWithFrame:CGRectZero];
        leftL.font = [UIFont systemFontOfSize:13];
        leftL.textColor = kGrayTextColor;
        leftL.text = tuple.first;
        [leftL setContentCompressionResistancePriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
        [self.timesContainerView addSubview:leftL];
        
        UILabel *rightL = [[UILabel alloc] initWithFrame:CGRectZero];
        rightL.font = [UIFont systemFontOfSize:13];
        rightL.textColor = kDarkTextColor;
        rightL.text = tuple.second;
        rightL.textAlignment = NSTextAlignmentRight;
        [leftL setContentCompressionResistancePriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
        [self.timesContainerView addSubview:rightL];
        
        [leftL mas_makeConstraints:^(MASConstraintMaker *make) {
            
            @strongify(self);
            make.left.equalTo(self.timesContainerView);
            make.top.equalTo(topObject).offset(8);
        }];
        
        [rightL mas_makeConstraints:^(MASConstraintMaker *make) {
           
            @strongify(self);
            make.right.equalTo(self.timesContainerView);
            make.left.equalTo(leftL.mas_right).offset(5);
            make.baseline.equalTo(leftL);
        }];
        
        topObject = leftL.mas_bottom;
     }
}

@end
