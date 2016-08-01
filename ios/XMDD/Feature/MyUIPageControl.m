#import "MyUIPageControl.h"

#define kButtonTag 150

#define kPointWidth 10
#define kPointHeight 10
#define kPointDistance 6


@implementation MyUIPageControl


- (void)awakeFromNib
{
    self.backgroundColor = [UIColor clearColor];
    
    _numberOfPages = 0;
    _currentPage = 0;
    _imagePageStateNormal = [UIImage imageNamed:@"page_dot"];
    _imagePageStateHightlighted = [UIImage imageNamed:@"page_dot2"];
}

- (id)init
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        _numberOfPages = 0;
        _currentPage = 0;
        _imagePageStateNormal = [UIImage imageNamed:@"page_dot"];
        _imagePageStateHightlighted = [UIImage imageNamed:@"page_dot2"];
    }
    return self;
}

-(void)dealloc {
}



-(void) setNumberOfPages:(NSUInteger)m_numberOfPages {
    
    _numberOfPages = m_numberOfPages;
    
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    CGFloat selfWidth = _numberOfPages*kPointWidth+(_numberOfPages-1)*kPointDistance;
    self.bounds = CGRectMake(0, 0, selfWidth, kPointHeight);
    
    for (NSInteger i = 0; i< _numberOfPages; i++) {
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake((kPointWidth+kPointDistance)*i, 0, kPointWidth, kPointHeight)];
        button.backgroundColor = [UIColor clearColor];
        [button setImage:_imagePageStateNormal forState:UIControlStateNormal];
        [button setImage:_imagePageStateHightlighted forState:UIControlStateSelected];
        button.tag = kButtonTag+i;
        button.userInteractionEnabled = NO;
        [self addSubview:button];
    }
    
    [self updateStateImage];
}

-(void)setCurrentPage:(NSUInteger)m_currentPage {
    if (m_currentPage>=_numberOfPages) {
        return;
    }
    _currentPage = m_currentPage;
    
    [self updateStateImage];
}

-(void)updateStateImage {
    for (int i=0; i<_numberOfPages; i++) {
        UIButton *button = (UIButton *)[self viewWithTag:kButtonTag+i];
        if (_currentPage==i) {
            button.selected = YES;
        }else{
            button.selected = NO;
        }
    }
}

- (CGSize)sizeForNumberOfPages:(NSInteger)pageCount {
    return CGSizeMake(pageCount*kPointWidth+(pageCount-1)*kPointDistance, kPointHeight);
}
@end
