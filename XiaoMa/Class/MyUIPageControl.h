#import <UIKit/UIKit.h>

@interface MyUIPageControl : UIView{
    CGPoint m_center;
}

@property (nonatomic, strong) UIImage *imagePageStateNormal;  //普通点点图片
@property (nonatomic, strong) UIImage *imagePageStateHightlighted; //当前页面点点图片

@property (nonatomic) NSUInteger numberOfPages;
@property (nonatomic) NSUInteger currentPage;

- (CGSize)sizeForNumberOfPages:(NSInteger)pageCount;
@end