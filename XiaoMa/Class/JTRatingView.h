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
///(default is 29)
@property (nonatomic, assign) CGFloat imgWidth;
///(default is 28)
@property (nonatomic, assign) CGFloat imgHeight;
///(default is 5)
@property (nonatomic, assign) CGFloat imgSpacing;

- (void)resetImageViewFrames;
- (void)sizeToFit;
@end
