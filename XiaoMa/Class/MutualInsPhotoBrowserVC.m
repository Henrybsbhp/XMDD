//
//  MutualInsPhotoBrowserVC.m
//  XiaoMa
//
//  Created by RockyYe on 16/3/10.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "MutualInsPhotoBrowserVC.h"

@interface MutualInsPhotoBrowserVC ()<UIGestureRecognizerDelegate>
@property (strong, nonatomic) UIImageView *imgView;

@end

@implementation MutualInsPhotoBrowserVC

-(void)dealloc
{
    DebugLog(@"MutualInsPhotoBrowserVC dealloc");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.imgView.image = self.img;
    self.navigationController.navigationBar.translucent = NO;
    [self setGesture];
    self.imgView.userInteractionEnabled = YES;
}

-(void)setGesture
{
    
    UIPinchGestureRecognizer *pinchGR = [[UIPinchGestureRecognizer alloc]initWithTarget:self action:@selector(pinch:)];
    pinchGR.delegate = self;
    [self.view addGestureRecognizer:pinchGR];
    
    UIPanGestureRecognizer *panGR = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(pan:)];
    panGR.delegate = self;
    [self.view addGestureRecognizer:panGR];
}

-(void)pinch:(UIPinchGestureRecognizer *)gr
{
    self.imgView.transform  = CGAffineTransformScale(self.imgView.transform, gr.scale, gr.scale);

    gr.scale = 1;
    
    if (gr.state == UIGestureRecognizerStateEnded)
    {
        [UIView animateWithDuration:0.5 animations:^{
            self.imgView.transform = CGAffineTransformIdentity;
        }];
    }
}

-(void)pan:(UIPanGestureRecognizer *)gr
{
    CGPoint translation = [gr translationInView:self.imgView];
    self.imgView.transform = CGAffineTransformTranslate(self.imgView.transform, translation.x, translation.y);
    [gr setTranslation:CGPointZero inView:self.imgView];
    if (gr.state == UIGestureRecognizerStateEnded)
    {
        [UIView animateWithDuration:0.5 animations:^{
            self.imgView.transform = CGAffineTransformIdentity;
        }];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(UIImageView *)imgView
{
    if (!_imgView)
    {
        _imgView = [[UIImageView alloc]initWithFrame:CGRectMake(100, 100, self.view.bounds.size.width, self.view.bounds.size.height)];
        _imgView.contentMode = UIViewContentModeScaleAspectFit;
        [self.view addSubview:_imgView];
        [_imgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(0);
        }];
        
    }
    return _imgView;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}


@end
