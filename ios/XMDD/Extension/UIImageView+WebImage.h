//
//  UIImageView+WebImage.h
//  XiaoMa
//
//  Created by jiangjunchen on 15/8/4.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <UIImageView+WebCache.h>

@interface UIImageView (WebImage)

- (void)setImageByUrl:(NSString *)url withType:(ImageURLType)type defImage:(NSString *)defimg errorImage:(NSString *)errimg;
- (void)setImageByUrl:(NSString *)url withType:(ImageURLType)type defImageObj:(UIImage *)defimg errorImageObj:(UIImage *)errimg;

@end
