//
//  JTRatingView.h
//  JTReader
//
//  Created by jiangjunchen on 13-12-31.
//  Copyright (c) 2013年 jiangjunchen. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kJTNormalRatingImage    @"nb_star"
#define kJTHighlightRatingImage @"nb_star1"
#define kJTHalfRatingImage      @"nb_start2"
#define kJTRatingViewMargin     0
#define kJTRatingMaxCount       5
#define kJTRatingImageBaseTag   100000

@interface JTRatingView : UIView
@property (nonatomic, assign) CGFloat ratingValue;
@property (nonatomic, assign) CGFloat imgWidth;
@property (nonatomic, assign) CGFloat imgHeight;
@property (nonatomic, assign) CGFloat imgSpacing;
@property (nonatomic, strong) NSString *normalImageName;
@property (nonatomic, strong) NSString *highlightImageName;

@property (nonatomic, strong) RACSubject *rac_subject;

- (void)setupImgWidth:(CGFloat)w andImgHeight:(CGFloat)h andSpace:(CGFloat)s;

- (void)resetImageViewFrames;
- (void)sizeToFit;

@end
