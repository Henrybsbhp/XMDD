//
//  HKImageView.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/9/14.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "HKImageView.h"
#import "DAProgressOverlayView.h"

@interface HKImageView ()
@property (nonatomic, strong) DAProgressOverlayView *overlayView;
@property (nonatomic, copy) void (^tapBlock)(HKImageView *imgv);
@property (nonatomic, strong) UIView *maskView;
@end
@implementation HKImageView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInitWithFrame:frame];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self commonInitWithFrame:self.frame];
    }
    return self;
}

- (void)commonInitWithFrame:(CGRect)frame
{
    self.userInteractionEnabled = YES;
    
    self.overlayView = [[DAProgressOverlayView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
    self.overlayView.triggersDownloadDidFinishAnimationAutomatically = NO;
    self.overlayView.innerRadiusRatio = 0.5;
    self.overlayView.autoresizingMask = UIViewAutoresizingFlexibleAll;
    self.overlayView.allowActivityIndicator = YES;
    self.overlayView.hidden = YES;
    [self addSubview:self.overlayView];
    
    [self createMaskView];
    
    _tapGesture = [[UITapGestureRecognizer alloc] init];
    [self addGestureRecognizer:self.tapGesture];
    

}

- (void)createMaskView
{
    UIView *maskView = [[UIView alloc] initWithFrame:self.bounds];
    maskView.autoresizingMask = UIViewAutoresizingFlexibleAll;
    maskView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
    [self addSubview:maskView];
    self.maskView = maskView;
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.font = [UIFont systemFontOfSize:18];
    label.textColor = [UIColor colorWithWhite:1 alpha:0.8];
    label.text = @"上传失败 !";
    label.textAlignment = NSTextAlignmentCenter;
    [maskView addSubview:label];
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(maskView).offset(22);
        make.right.equalTo(maskView);
        make.left.equalTo(maskView);
    }];
    
    UIView *leftV = [[UIView alloc] initWithFrame:CGRectZero];
    leftV.backgroundColor = [UIColor clearColor];
    [maskView addSubview:leftV];
    
    
    UIView *rightV = [[UIView alloc] initWithFrame:CGRectZero];
    rightV.backgroundColor = [UIColor clearColor];
    [maskView addSubview:rightV];
    
    [leftV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(maskView);
        make.top.equalTo(label.mas_bottom).offset(10);
        make.right.equalTo(rightV.mas_left);
        make.bottom.equalTo(maskView);
        make.size.width.equalTo(rightV.mas_width);
    }];
    
    [rightV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(maskView);
        make.top.equalTo(leftV.mas_top);
        make.bottom.equalTo(maskView);
    }];
    
    UIButton *reuploadBtn = [[UIButton alloc] initWithFrame:CGRectZero];
    [reuploadBtn setImage:[UIImage imageNamed:@"insu_upload"] forState:UIControlStateNormal];
    [leftV addSubview:reuploadBtn];
    self.reuploadButton = reuploadBtn;
    [reuploadBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(65, 65));
        make.centerX.equalTo(leftV);
        make.centerY.equalTo(leftV).offset(-10);
    }];
    
    UIButton *pickImgBtn = [[UIButton alloc] initWithFrame:CGRectZero];
    [pickImgBtn setImage:[UIImage imageNamed:@"insu_camera"] forState:UIControlStateNormal];
    [rightV addSubview:pickImgBtn];
    self.pickImageButton = pickImgBtn;
    [pickImgBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(65, 65));
        make.centerX.equalTo(rightV);
        make.centerY.equalTo(rightV).offset(-10);
    }];
    
    UILabel *leftLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    leftLabel.textAlignment = NSTextAlignmentCenter;
    leftLabel.backgroundColor = [UIColor clearColor];
    leftLabel.textColor = [UIColor colorWithWhite:1 alpha:0.8];
    leftLabel.font = [UIFont systemFontOfSize:15];
    leftLabel.text = @"重新上传";
    [leftV addSubview:leftLabel];
    [leftLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(leftV);
        make.right.equalTo(leftV);
        make.top.equalTo(reuploadBtn.mas_bottom).offset(8);
    }];
    
    UILabel *rightLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    rightLabel.textAlignment = NSTextAlignmentCenter;
    rightLabel.backgroundColor = [UIColor clearColor];
    rightLabel.textColor = [UIColor colorWithWhite:1 alpha:0.8];
    rightLabel.font = [UIFont systemFontOfSize:15];
    rightLabel.text = @"重新拍照";
    [rightV addSubview:rightLabel];
    [rightLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(rightV);
        make.right.equalTo(rightV);
        make.top.equalTo(pickImgBtn.mas_bottom).offset(8);
    }];
}
#pragma mark - Public
- (void)setImageByUrl:(NSString *)url withType:(ImageURLType)type defImageObj:(UIImage *)defimg errorImageObj:(UIImage *)errimg
{
    [self hideMaskView];
    [super setImageByUrl:url withType:type defImageObj:defimg errorImageObj:errimg];
}

- (void)setImage:(UIImage *)image
{
    [self sd_cancelCurrentImageLoad];
    [super setImage:image];
}

- (RACSignal *)rac_setUploadingImage:(UIImage *)img withImageType:(UploadFileType)type
{
    [self hideMaskView];
    [self sd_cancelCurrentImageLoad];
    if (![img isEqual:self.image]) {
        self.image = img;
    }
    
    @weakify(self);
    return [[[[[self rac_startOverlayViewAnimation] flattenMap:^RACStream *(id value) {
        
        UploadFileOp *op = [[UploadFileOp alloc] init];
        op.req_fileType = type;
        op.req_fileExtType = @"jpg";
        [op setFileArray:[NSArray arrayWithObject:img] withGetDataBlock:^NSData *(UIImage *img) {
            return UIImageJPEGRepresentation(img, 0.5);
        }];
        return [op rac_postRequest];
    }] deliverOn:[RACScheduler mainThreadScheduler]] flattenMap:^RACStream *(id value) {

        @strongify(self);
        return [[self rac_stopOverlayViewAnimation] map:^id(id x) {
            return value;
        }];
    }] doError:^(NSError *error) {

        [self.overlayView displayOperationDidFinishAnimation];
        [self showMaskView];
    }];
}

#pragma mark - Private
- (RACSignal *)rac_stopOverlayViewAnimation
{
    [self.overlayView displayOperationDidFinishAnimation];
    @weakify(self);
    return [[[RACSignal return:nil] delay:self.overlayView.stateChangeAnimationDuration] doNext:^(id x) {
        @strongify(self);
        self.overlayView.hidden = YES;
    }];
}

- (RACSignal *)rac_startOverlayViewAnimation
{
    self.overlayView.progress = 1;
    self.overlayView.hidden = NO;
    [self.overlayView displayOperationWillTriggerAnimation];
    return [[RACSignal return:nil] delay:self.overlayView.stateChangeAnimationDuration];
}

- (void)showMaskView
{
    self.tapGesture.enabled = NO;
    self.overlayView.hidden = YES;
    [self bringSubviewToFront:self.maskView];
    self.maskView.hidden = NO;
}

- (void)hideMaskView
{
    self.maskView.hidden = YES;
    self.tapGesture.enabled = YES;
}

- (void)removeTagGesture
{
    [self removeGestureRecognizer:_tapGesture];
}

@end
