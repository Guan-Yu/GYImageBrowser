//
//  ViewController.m
//  GYImageBrowserDemo
//
//  Created by Guanyu Yan on 2018/7/24.
//  Copyright © 2018年 Guanyu Yan. All rights reserved.
//

#import "ViewController.h"
#import "GYImageBrowserView.h"

@interface ViewController ()
<GYImageBrowserViewDelegate>
@property (nonatomic, copy) NSArray *images;
@property (nonatomic, copy) NSArray *image1s;
@property (nonatomic, copy) NSArray *imageViews;
@end

@implementation ViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    self.images = @[[UIImage imageNamed:@"icon_message_correct"],
                    @"https://gss2.bdstatic.com/-fo3dSag_xI4khGkpoWK1HF6hhy/baike/c0%3Dbaike116%2C5%2C5%2C116%2C38/sign=209108c2da160924c828aa49b56e5e9f/f636afc379310a552575b160bd4543a9832610d4.jpg",
                    @"https://gss0.bdstatic.com/94o3dSag_xI4khGkpoWK1HF6hhy/baike/w%3D268/sign=5bd9a005560fd9f9a017526f1d2dd42b/5882b2b7d0a20cf4818c71a671094b36acaf99af.jpg",
                    [UIImage imageNamed:@"icon_message_error"],
                    @"https://gss1.bdstatic.com/-vo3dSag_xI4khGkpoWK1HF6hhy/baike/c0%3Dbaike150%2C5%2C5%2C150%2C50/sign=9e37a9a09f13b07ea9b0585a6dbefa46/e61190ef76c6a7efabde86a7f1faaf51f2de66b2.jpg"];
    
    NSMutableArray *images = [NSMutableArray array];
    NSMutableArray *imageViews = [NSMutableArray array];
    for (NSInteger i=0; i<5; i++) {
        UIImageView *view = [[UIImageView alloc] initWithFrame:CGRectMake(0, i*120+50, 100, 100)];
        view.userInteractionEnabled = YES;
        view.clipsToBounds = YES;
        [view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onImage:)]];
        UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"%ld.jpeg",i]];
        view.tag = i;
        [self.view addSubview:view];
        view.image = image;
        view.contentMode = UIViewContentModeScaleAspectFill;
        
        [images addObject:image];
        [imageViews addObject:view];
    }
    self.image1s = images;
    self.imageViews = imageViews;
}

- (IBAction)onShowImageBrowser:(id)sender {
    [GYImageBrowserView showBrowserWithImages:_images currentIndex:0];
}

- (void)onImage:(UIGestureRecognizer *)gesture {
    [GYImageBrowserView showBrowserWithDelegate:self images:_image1s currentIndex:gesture.view.tag];
}

#pragma mark - GYImageBrowserViewDelegate
//根据index得到当前展示的图片的容器在当前controller里的位置，并通过以下方法算出在window中的展示的frame是多少
- (CGRect)imageBrowserView:(GYImageBrowserView *)imageBrowserView willPresentGetDisplayImageViewFrameByImageIndex:(NSUInteger)index {
    //用于打开的缩放动画
    return [GYImageBrowserView frameWithView:_imageViews[index]];
}
- (CGRect)imageBrowserView:(GYImageBrowserView *)imageBrowserView willDismissGetDisplayImageViewFrameByImageIndex:(NSUInteger)index {
    //用于关闭的缩放动画
    return [GYImageBrowserView frameWithView:_imageViews[index]];
}

@end
