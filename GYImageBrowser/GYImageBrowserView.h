//
//  GYImageBrowserView.h
//  GHCLishi
//
//  Created by Guanyu Yan on 2018/6/25.
//  Copyright © 2018年 lis99. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GYImageBrowserView;
@protocol GYImageBrowserViewDelegate <NSObject>
- (CGRect)imageBrowserView:(GYImageBrowserView *)imageBrowserView willDismissGetDisplayImageViewFrameByImageIndex:(NSUInteger)index;
- (CGRect)imageBrowserView:(GYImageBrowserView *)imageBrowserView willPresentGetDisplayImageViewFrameByImageIndex:(NSUInteger)index;
@end

@interface GYImageBrowserView : UIView
+ (void)showBrowserWithImages:(NSArray *)images currentIndex:(NSUInteger)index;

/* delegate传nil则按照淡入淡出的动画展现，实现代理可以通过缩放的动画展现
   images中可以是imageUrlString，也可以是UIImage
   index为默认显示的页数，从第一页开始显示传0 */
+ (void)showBrowserWithDelegate:(id<GYImageBrowserViewDelegate>)delegate images:(NSArray *)images currentIndex:(NSUInteger)index;
+ (void)showBrowserWithDelegate:(id<GYImageBrowserViewDelegate>)delegate images:(NSArray *)images currentIndex:(NSUInteger)index animated:(BOOL)animated;

/* 用于代理中计算Frame使用，可以计算出该view在window中的frame */
+ (CGRect)frameWithView:(nonnull UIView *)view;
@end
