//
//  GYImageBrowserCell.h
//  GHCLishi
//
//  Created by Guanyu Yan on 2018/6/22.
//  Copyright © 2018年 lis99. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GYZoomableView.h"

static NSString *const GYImageBrowserCell_ID = @"GYImageBrowserCell";

@class GYImageBrowserCell;
@protocol GYImageBrowserCellDelegate<GYZoomableViewDelegate>
- (void)imageBrowserCell:(GYImageBrowserCell *)cell loadImageFinished:(UIImage *)image;
@end

@interface GYImageBrowserCell : UICollectionViewCell
@property (nonatomic, weak) id<GYImageBrowserCellDelegate>delegate;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) NSString *imageUrl;
@property (nonatomic, readonly) GYImageZoomableView *zoomableView;
- (void)setImageUrl:(NSString *)imageUrl placeholder:(UIImage *)placeholder;
@end
