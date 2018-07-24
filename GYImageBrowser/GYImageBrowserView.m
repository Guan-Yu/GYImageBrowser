//
//  GYImageBrowserView.m
//  GHCLishi
//
//  Created by Guanyu Yan on 2018/6/25.
//  Copyright © 2018年 lis99. All rights reserved.
//

#import "GYImageBrowserView.h"
#import "GYImageBrowserCell.h"
#import "GYMessageView.h"
#import "GYImageUtil.h"
#import <SDWebImage/SDImageCache.h>

@interface GYImageBrowserView ()
<UICollectionViewDelegate, UICollectionViewDataSource, GYImageBrowserCellDelegate>
{
    __weak IBOutlet UILabel *_indexLabel;
    __weak IBOutlet UICollectionView *_collectionView;
    __weak IBOutlet UIButton *_saveBtn;
    IBOutlet UIImageView *_animateImageView;
}
@property (nonatomic, weak) id<GYImageBrowserViewDelegate>delegate;
@property (nonatomic, copy) NSArray *images;
@property (nonatomic, assign) NSUInteger index;
@property (nonatomic, assign) BOOL animated;
@end

@implementation GYImageBrowserView

+ (void)showBrowserWithImages:(NSArray *)images currentIndex:(NSUInteger)index {
    [self showBrowserWithDelegate:nil images:images currentIndex:index animated:YES];
}

+ (void)showBrowserWithDelegate:(id<GYImageBrowserViewDelegate>)delegate images:(NSArray *)images currentIndex:(NSUInteger)index {
    [self showBrowserWithDelegate:delegate images:images currentIndex:index animated:YES];
}

+ (void)showBrowserWithDelegate:(id<GYImageBrowserViewDelegate>)delegate images:(NSArray *)images currentIndex:(NSUInteger)index animated:(BOOL)animated {
    GYImageBrowserView *view = [[NSBundle mainBundle] loadNibNamed:@"GYImageBrowserView" owner:nil options:nil][0];
    UIWindow *window = [[UIApplication sharedApplication].delegate window];
    view.frame = window.rootViewController.view.bounds;
    [window.rootViewController.view addSubview:view];
    
    view.delegate = delegate;
    view.images = images;
    view.index = index;
    view.animated = animated;
    [view show];
}

+ (CGRect)frameWithView:(UIView *)view {
    CGRect frame = view.frame;
    UIView *superview = view.superview;
    UIWindow *window = [[UIApplication sharedApplication].delegate window];
    while (superview != window) {
        if ([superview isKindOfClass:[UIScrollView class]]) {
            UIScrollView *scrollView = (UIScrollView *)superview;
            frame = CGRectMake(frame.origin.x - scrollView.contentOffset.x,
                               frame.origin.y - scrollView.contentOffset.y,
                               frame.size.width,
                               frame.size.height);
        }
        frame = CGRectMake(frame.origin.x + superview.frame.origin.x,
                           frame.origin.y + superview.frame.origin.y,
                           frame.size.width,
                           frame.size.height);
        superview = superview.superview;
    }
    return frame;
}


- (void)awakeFromNib {
    [super awakeFromNib];
    [self setupCollectionView];
}

- (void)show {
    [_collectionView reloadData];
    [self performSelector:@selector(displayIndex) withObject:nil afterDelay:0];
    
    UIImage *image = _images[_index];
    if ([image isKindOfClass:[NSString class]]) {
        NSString *imageUrl = (NSString *)image;
        image = [[SDImageCache sharedImageCache] imageFromCacheForKey:imageUrl];
    }
    if ([_delegate respondsToSelector:@selector(imageBrowserView:willPresentGetDisplayImageViewFrameByImageIndex:)] && [image isKindOfClass:[UIImage class]]) {
        CGRect frame = [_delegate imageBrowserView:self willPresentGetDisplayImageViewFrameByImageIndex:_index];
        [self showAnimateImageViewWithFrame:frame image:image];
    }
    
    if (_animated) {
        self.alpha = 0;
        [UIView animateWithDuration:.25 animations:^{
            self.alpha = 1;
        }];
    }
}

- (void)hide {
    GYImageBrowserCell *cell = (GYImageBrowserCell *)[_collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:_index inSection:0]];
    UIImage *image = cell.image;
    if ([_delegate respondsToSelector:@selector(imageBrowserView:willPresentGetDisplayImageViewFrameByImageIndex:)] && image) {
        CGRect frame = [GYImageBrowserView frameWithView:cell.zoomableView.imageView];
        self->_animateImageView.frame = frame;
        self->_animateImageView.image = image;
        self->_animateImageView.hidden = NO;
        
        CGRect toFrame = [_delegate imageBrowserView:self willPresentGetDisplayImageViewFrameByImageIndex:_index];
        _collectionView.hidden = YES;
        [UIView animateWithDuration:.25 animations:^{
            self->_animateImageView.frame = toFrame;
        }];
    }
    [UIView animateWithDuration:.25 animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        if (finished) {
            [self->_animateImageView removeFromSuperview];
            [self removeFromSuperview];
        }
    }];
}

- (void)showAnimateImageViewWithFrame:(CGRect)frame image:(UIImage *)image {
    _animateImageView.frame = frame;
    _animateImageView.image = image;
    UIWindow *window = [[UIApplication sharedApplication].delegate window];
    [window addSubview:_animateImageView];
    CGFloat toX = 0;
    CGFloat toY = 0;
    CGFloat toWidth = window.frame.size.width;
    CGFloat toHeight = window.frame.size.height;
    if (image.size.width/image.size.height > window.frame.size.width/window.frame.size.height) {
        toHeight = image.size.height/image.size.width*window.frame.size.width;
        toY = (window.frame.size.height - toHeight)/2;
    } else {
        toWidth = image.size.width/image.size.height*window.frame.size.height;
        toX = (window.frame.size.width - toWidth)/2;
    }
    _collectionView.hidden = YES;
    self.alpha = 0;
    [UIView animateWithDuration:.25 animations:^{
        self.alpha = 1;
        self->_animateImageView.frame = CGRectMake(toX, toY, toWidth, toHeight);
    } completion:^(BOOL finished) {
        if (finished) {
            self->_collectionView.hidden = NO;
            self->_animateImageView.hidden = YES;
        }
    }];
}

- (void)displayIndex {
    [_collectionView setContentOffset:CGPointMake([UIScreen mainScreen].bounds.size.width * _index, 0)];
    [self updateIndex];
}

- (void)updateIndex {
    _index = floorf((_collectionView.contentOffset.x+_collectionView.frame.size.width/2)/_collectionView.frame.size.width);
    _index = MAX(0, _index);
    _index = MIN(_index, _images.count-1);
    _indexLabel.text = [NSString stringWithFormat:@"%ld/%ld",_index+1, _images.count];

    [self performSelector:@selector(updateSaveBtnState) withObject:nil afterDelay:.1];
}

- (void)updateSaveBtnState {
    GYImageBrowserCell *cell = (GYImageBrowserCell *)[_collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:_index inSection:0]];
    _saveBtn.enabled = cell.image != nil;
}

#pragma mark - Action
- (IBAction)onSave:(id)sender {
    GYImageBrowserCell *cell = (GYImageBrowserCell *)[_collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:_index inSection:0]];
    if (cell.image) {
        [GYImageUtil saveImageToAlbum:cell.image albumName:nil finishedBlock:^(NSError * _Nullable error) {
            if (error) {
                [GYMessageView displayMessage:@"保存失败" style:GYMessageViewStyleErrorBlack];
            } else {
                [GYMessageView displayMessage:@"保存成功" style:GYMessageViewStyleCorrectBlack];
            }
        }];
    }
}

#pragma mark - UICollectionView
- (void)setupCollectionView {
    [_collectionView registerNib:[UINib nibWithNibName:GYImageBrowserCell_ID bundle:nil] forCellWithReuseIdentifier:GYImageBrowserCell_ID];
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)_collectionView.collectionViewLayout;
    layout.itemSize = [UIScreen mainScreen].bounds.size;
    [_collectionView reloadData];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    GYImageBrowserCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:GYImageBrowserCell_ID forIndexPath:indexPath];
    cell.delegate = self;
    id obj = _images[indexPath.row];
    if ([obj isKindOfClass:[NSString class]]) {
        cell.imageUrl = obj;
    } else if([obj isKindOfClass:[UIImage class]]) {
        cell.image = obj;
    } else {
        cell.image = nil;
    }
    return cell;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _images.count;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self updateIndex];
}

#pragma mark - GYImageBrowserCellDelegate
- (void)imageBrowserCell:(GYImageBrowserCell *)cell loadImageFinished:(UIImage *)image {
    GYImageBrowserCell *currnetCell = (GYImageBrowserCell *)[_collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:_index inSection:0]];
    if (cell == currnetCell) {
        _saveBtn.enabled = YES;
    }
}

- (void)zoomableViewDidTapped:(GYZoomableView *)zoomableView {
    [self hide];
}

@end
