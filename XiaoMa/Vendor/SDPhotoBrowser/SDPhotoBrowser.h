//
//  SDPhotoBrowser.h
//  photobrowser
//
//  Created by aier on 15-2-3.
//  Copyright (c) 2015年 aier. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    sourceImagesContainerViewContentFit = 0,
    sourceImagesContainerViewContentFill = 1
} sourceImagesContainerViewContentMode;


@class SDButton, SDPhotoBrowser;

@protocol SDPhotoBrowserDelegate <NSObject>

@required

- (UIImage *)photoBrowser:(SDPhotoBrowser *)browser placeholderImageForIndex:(NSInteger)index;

@optional

- (NSURL *)photoBrowser:(SDPhotoBrowser *)browser highQualityImageURLForIndex:(NSInteger)index;

@end


@interface SDPhotoBrowser : UIView <UIScrollViewDelegate>

@property (nonatomic, weak) UIView *sourceImagesContainerView;
@property (nonatomic, assign) NSInteger currentImageIndex;
@property (nonatomic, assign) NSInteger imageCount;
@property (assign, nonatomic) BOOL showSaveBtn;
@property (assign, nonatomic) BOOL showIndexLabel;

@property (assign, nonatomic) sourceImagesContainerViewContentMode sourceImagesContainerViewContentMode;

@property (nonatomic, weak) id<SDPhotoBrowserDelegate> delegate;



- (void)show;

@end
