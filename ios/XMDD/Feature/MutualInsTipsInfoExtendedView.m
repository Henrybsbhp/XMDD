//
//  MutualInsTipsInfoExtendedView.m
//  XMDD
//
//  Created by St.Jimmy on 8/22/16.
//  Copyright © 2016 huika. All rights reserved.
//

#import "MutualInsTipsInfoExtendedView.h"

@interface MutualInsTipsInfoExtendedView ()

@property (nonatomic, strong) UILabel *peopleSumLabel;
@property (nonatomic, strong) UILabel *moneySumLabel;
@property (nonatomic, strong) UILabel *countingLabel;
@property (nonatomic, strong) UILabel *claimSumLabel;
@property (nonatomic, strong) UILabel *bottomTipsLabel;

@end

@implementation MutualInsTipsInfoExtendedView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self bundleInit];
    }
    
    return self;
}

- (void)bundleInit
{
    self.backgroundColor = [UIColor whiteColor];
    self.clipsToBounds = YES;
    UIImageView *horizontalSep = [[UIImageView alloc] initWithFrame:CGRectZero];
    horizontalSep.image = [UIImage imageNamed:@"Horizontaline"];
    UIImageView *verticalSep1 = [[UIImageView alloc] initWithFrame:CGRectZero];
    verticalSep1.image = [UIImage imageNamed:@"Verticalline"];
    UIImageView *verticalSep2 = [[UIImageView alloc] initWithFrame:CGRectZero];
    verticalSep2.image = [UIImage imageNamed:@"Verticalline"];
    UIImageView *bottomSep = [[UIImageView alloc] initWithFrame:CGRectZero];
    bottomSep.image = [UIImage imageNamed:@"Horizontaline"];
    
    UIImageView *peopleImgView = [[UIImageView alloc] initWithFrame:CGRectZero];
    peopleImgView.contentMode = UIViewContentModeScaleAspectFit;
    peopleImgView.image = [UIImage imageNamed:@"mutualIns_people"];
    
    UIImageView *sumImgView = [[UIImageView alloc] initWithFrame:CGRectZero];
    sumImgView.contentMode = UIViewContentModeScaleAspectFit;
    sumImgView.image = [UIImage imageNamed:@"mutualIns_moneySum"];
    
    UIImageView *stackImgView = [[UIImageView alloc] initWithFrame:CGRectZero];
    stackImgView.contentMode = UIViewContentModeScaleAspectFit;
    stackImgView.image = [UIImage imageNamed:@"mutualIns_stack"];
    
    UIImageView *statisticsImgView = [[UIImageView alloc] initWithFrame:CGRectZero];
    statisticsImgView.contentMode = UIViewContentModeScaleAspectFit;
    statisticsImgView.image = [UIImage imageNamed:@"mutualIns_statistics"];
    
    UIImageView *arrowImgView = [[UIImageView alloc] initWithFrame:CGRectZero];
    arrowImgView.contentMode = UIViewContentModeScaleAspectFit;
    arrowImgView.image = [UIImage imageNamed:@"ins_arrow_right_gray_300"];
    
    self.peopleSumLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.peopleSumLabel.textColor = HEXCOLOR(@"#FF7428");
    self.peopleSumLabel.minimumScaleFactor = .7f;
    self.peopleSumLabel.adjustsFontSizeToFitWidth = YES;
    
    self.moneySumLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.moneySumLabel.textColor = HEXCOLOR(@"#FF7428");
    self.moneySumLabel.minimumScaleFactor = .7f;
    self.moneySumLabel.adjustsFontSizeToFitWidth = YES;
    
    self.countingLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.countingLabel.textColor = HEXCOLOR(@"#FF7428");
    self.countingLabel.minimumScaleFactor = .7f;
    self.countingLabel.adjustsFontSizeToFitWidth = YES;
    
    self.claimSumLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.claimSumLabel.textColor = HEXCOLOR(@"#FF7428");
    self.claimSumLabel.minimumScaleFactor = .7f;
    self.claimSumLabel.adjustsFontSizeToFitWidth = YES;
    
    self.bottomTipsLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.bottomTipsLabel.textColor = HEXCOLOR(@"#454545");
    self.bottomTipsLabel.font = [UIFont systemFontOfSize:14];
    self.bottomTipsLabel.minimumScaleFactor = .7f;
    self.bottomTipsLabel.adjustsFontSizeToFitWidth = YES;
    
    UILabel *peoDescLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    peoDescLabel.textColor = HEXCOLOR(@"#888888");
    peoDescLabel.font = [UIFont systemFontOfSize:13];
    peoDescLabel.minimumScaleFactor = .7f;
    peoDescLabel.adjustsFontSizeToFitWidth = YES;
    peoDescLabel.text = @"参加人数";
    
    UILabel *sumDescLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    sumDescLabel.textColor = HEXCOLOR(@"#888888");
    sumDescLabel.font = [UIFont systemFontOfSize:13];
    sumDescLabel.minimumScaleFactor = .7f;
    sumDescLabel.adjustsFontSizeToFitWidth = YES;
    sumDescLabel.text = @"互助金额";
    
    UILabel *stackDescLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    stackDescLabel.textColor = HEXCOLOR(@"#888888");
    stackDescLabel.font = [UIFont systemFontOfSize:13];
    stackDescLabel.minimumScaleFactor = .7f;
    stackDescLabel.adjustsFontSizeToFitWidth = YES;
    stackDescLabel.text = @"补偿次数";
    
    UILabel *statDescLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    statDescLabel.textColor = HEXCOLOR(@"#888888");
    statDescLabel.font = [UIFont systemFontOfSize:13];
    statDescLabel.minimumScaleFactor = .7f;
    statDescLabel.adjustsFontSizeToFitWidth = YES;
    statDescLabel.text = @"补偿金额";
    
    UIButton *bottomButton = [[UIButton alloc] initWithFrame:CGRectZero];
    [[bottomButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        if (self.bottomButtonClicked) {
            self.bottomButtonClicked();
        }
    }];
    
    [self addSubview:horizontalSep];
    [self addSubview:verticalSep1];
    [self addSubview:verticalSep2];
    [self addSubview:bottomSep];
    [self addSubview:peopleImgView];
    [self addSubview:sumImgView];
    [self addSubview:stackImgView];
    [self addSubview:statisticsImgView];
    [self addSubview:arrowImgView];
    [self addSubview:self.peopleSumLabel];
    [self addSubview:self.moneySumLabel];
    [self addSubview:self.countingLabel];
    [self addSubview:self.claimSumLabel];
    [self addSubview:self.bottomTipsLabel];
    [self addSubview:peoDescLabel];
    [self addSubview:sumDescLabel];
    [self addSubview:stackDescLabel];
    [self addSubview:statDescLabel];
    [self addSubview:bottomButton];
    
    [horizontalSep mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self).offset(-20);
        make.left.equalTo(self).offset(15);
        make.right.equalTo(self).offset(-15);
        make.height.mas_equalTo(1);
    }];
    
    [verticalSep1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.top.equalTo(self).offset(10);
        make.bottom.equalTo(horizontalSep).offset(-10);
        make.width.mas_equalTo(1);
    }];
    
    [verticalSep2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.top.equalTo(horizontalSep).offset(10);
        make.bottom.equalTo(bottomSep).offset(-10);
        make.width.mas_equalTo(1);
    }];
    
    [bottomSep mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self);
        make.right.equalTo(self);
        make.bottom.equalTo(self.bottomTipsLabel.mas_top).offset(-16);
        make.height.mas_equalTo(1);
    }];
    
    [peopleImgView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.equalTo(self).offset(30);
        
        // 根据设备屏幕大小来设置距离中心位置的约束
        if (gAppMgr.deviceInfo.screenSize.height == 568) {
            make.centerX.equalTo(self).offset(-120);
        } else {
            make.centerX.equalTo(self).offset(-145);
        }
        make.centerY.equalTo(self).offset(-65);
        make.width.mas_equalTo(20);
        make.height.mas_equalTo(20);
    }];
    
    [sumImgView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.equalTo(verticalSep1).offset(12);
        make.centerX.equalTo(self).offset(35);
        make.centerY.equalTo(self).offset(-65);
        make.width.mas_equalTo(20);
        make.height.mas_equalTo(20);
    }];
    
    [stackImgView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.equalTo(self).offset(30);
        
        // 根据设备屏幕大小来设置距离中心位置的约束
        if (gAppMgr.deviceInfo.screenSize.height == 568) {
            make.centerX.equalTo(self).offset(-120);
        } else {
            make.centerX.equalTo(self).offset(-145);
        }
        make.centerY.equalTo(self).offset(23);
        make.width.mas_equalTo(20);
        make.height.mas_equalTo(20);
    }];
    
    [statisticsImgView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.equalTo(verticalSep1).offset(12);
        make.centerX.equalTo(self).offset(35);
        make.centerY.equalTo(self).offset(23);
        make.width.mas_equalTo(20);
        make.height.mas_equalTo(20);
    }];
    
    [self.peopleSumLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(peopleImgView.mas_right).offset(10);
        make.centerY.equalTo(self).offset(-76);
        make.right.equalTo(self);
    }];
    
    [self.moneySumLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(sumImgView.mas_right).offset(10);
        make.centerY.equalTo(self).offset(-76);
        make.right.equalTo(self);
    }];
    
    [self.countingLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(stackImgView.mas_right).offset(10);
        make.centerY.equalTo(self).offset(13);
        make.right.equalTo(self);
    }];
    
    [self.claimSumLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(statisticsImgView.mas_right).offset(10);
        make.centerY.equalTo(self).offset(13);
        make.right.equalTo(self);
    }];
    
    [peoDescLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(peopleImgView.mas_right).offset(10);
        make.centerY.equalTo(self).offset(-52);
        make.right.equalTo(self);
    }];
    
    [sumDescLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(sumImgView.mas_right).offset(10);
        make.centerY.equalTo(self).offset(-52);
        make.right.equalTo(self);
    }];
    
    [stackDescLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(stackImgView.mas_right).offset(10);
        make.centerY.equalTo(self).offset(36);
        make.right.equalTo(self);
    }];
    
    [statDescLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(statisticsImgView.mas_right).offset(10);
        make.centerY.equalTo(self).offset(36);
        make.right.equalTo(self);
    }];
    
    [self.bottomTipsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.bottom.equalTo(self).offset(-15);
    }];
    
    [arrowImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(10);
        make.height.equalTo(self.bottomTipsLabel);
        make.left.equalTo(self.bottomTipsLabel.mas_right).offset(2);
        make.bottom.equalTo(self).offset(-15);
    }];
    
    [bottomButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self);
        make.right.equalTo(self);
        make.top.equalTo(bottomSep);
        make.bottom.equalTo(self);
    }];
}

- (void)showInfo
{
    self.peopleSumLabel.text = self.peopleSumString;
    self.moneySumLabel.text = self.moneySumString;
    self.countingLabel.text = self.countingString;
    self.claimSumLabel.text = self.claimSumString;
    
    if (self.bottomTipsString.length > 0) {
        self.bottomTipsLabel.text = self.bottomTipsString;
    } else {
        self.bottomTipsLabel.text = @"查看互助团";
    }
}

@end
