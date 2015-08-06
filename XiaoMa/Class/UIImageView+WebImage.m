//
//  UIImageView+WebImage.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/8/4.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "UIImageView+WebImage.h"

@implementation UIImageView (WebImage)

- (void)setImageByUrl:(NSString *)strurl withType:(ImageURLType)type defImage:(NSString *)defimg errorImage:(NSString *)errimg
{
    NSURL *url = strurl ? [NSURL URLWithString:[self urlWith:strurl imageType:type]] : nil;
    UIImage *dimg = defimg ? [UIImage imageNamed:defimg] : nil;
    __weak UIImageView *weakView = self;
    [self sd_setImageWithURL:url placeholderImage:dimg completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if (!weakView) {
            return ;
        }
        if (error && errimg) {
            weakView.image = [UIImage imageNamed:errimg];
            [weakView setNeedsLayout];
        }
    }];
}

- (NSString *)urlWith:(NSString *)url imageType:(ImageURLType)type
{
    if (type == ImageURLTypeThumbnail) {
        url = [url append:@"?imageView2/1/w/128/h/128"];
    }
    else if (type == ImageURLTypeMedium) {
        url = [url append:@"?imageView2/0/w/1024/h/1024"];
    }
    return url;
}


@end
