//
//  JTCommentBadge.h
//  JTReader
//
//  Created by jiangjunchen on 14-2-24.
//  Copyright (c) 2014年 jiangjunchen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JTImageBadge : UIView
@property (nonatomic, readonly) UILabel *textLabel;
@property (nonatomic, readonly) UIImageView *backgroundView;
@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) UIFont *textFont;
@property (nonatomic, assign) BOOL highlighted;
@property (nonatomic, assign) UIEdgeInsets textInsets;
///(default is 0)
@property (nonatomic, assign) CGFloat cornerRadius;

- (id)initWithText:(NSString *)text font:(UIFont *)font;
+ (instancetype)badgeWithText:(NSString *)text;

@end
