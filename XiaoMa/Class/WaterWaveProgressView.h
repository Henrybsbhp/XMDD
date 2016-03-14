//
//  WaterWaveProgressView.h
//  XiaoMa
//
//  Created by jiangjunchen on 16/3/8.
//  Copyright © 2016年 huika. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WaterWaveProgressView : UIView
///(Default is 0)
@property (nonatomic, assign, readonly) CGFloat progress;
@property (nonatomic, strong, readonly) UILabel *titleLable;
@property (nonatomic, strong, readonly) UILabel *subTitleLabel;

- (void)setProgress:(CGFloat)progress withAnimation:(BOOL)animate;
- (void)startWave;
- (void)stopWave;
- (void)showArcLightOnce;

@end
