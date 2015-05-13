//
//  JTRatingView.h
//  JTReader
//
//  Created by jiangjunchen on 13-12-31.
//  Copyright (c) 2013年 jiangjunchen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JTRatingView : UIView
@property (nonatomic, assign) CGFloat ratingValue;
@property (nonatomic, assign) CGFloat imgWidth;
@property (nonatomic, assign) CGFloat imgHeight;
@property (nonatomic, assign) CGFloat imgSpacing;
@property (nonatomic, strong) NSString *normalImageName;
@property (nonatomic, strong) NSString *highlightImageName;

- (void)resetImageViewFrames;
- (void)sizeToFit;

@end
