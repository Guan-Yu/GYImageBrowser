//
//  GYImageBrowserCell.m
//  GHCLishi
//
//  Created by Guanyu Yan on 2018/6/22.
//  Copyright © 2018年 lis99. All rights reserved.
//

#import "GYImageBrowserCell.h"
#import "GYZoomableView.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface GYImageBrowserCell() {
    __weak IBOutlet GYImageZoomableView *_zoomableView;
    id <SDWebImageOperation> _operation;
}
@end

@implementation GYImageBrowserCell

- (void)setDelegate:(id<GYImageBrowserCellDelegate>)delegate {
    _delegate = delegate;
    
    _zoomableView.tapDelegate = delegate;
}

- (void)setImageUrl:(NSString *)imageUrl {
    _imageUrl = imageUrl;
    
    NSURL *URL = [NSURL URLWithString:imageUrl];
    [_zoomableView.imageView sd_setImageWithURL:URL completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        self.image = image;
    }];
}

- (void)setImage:(UIImage *)image {
    _image = image;
    
    if (image) {
        _zoomableView.scrollEnabled = YES;
        _zoomableView.image = image;
        if ([_delegate respondsToSelector:@selector(imageBrowserCell:loadImageFinished:)]) {
            [_delegate imageBrowserCell:self loadImageFinished:image];
        }
    }
}

- (void)setImageUrl:(NSString *)imageUrl placeholder:(UIImage *)placeholder {
    self.image = nil;
    _zoomableView.image = placeholder;
    _zoomableView.scrollEnabled = NO;
    self.imageUrl = imageUrl;
}

- (GYImageZoomableView *)zoomableView {
    return _zoomableView;
}

@end
