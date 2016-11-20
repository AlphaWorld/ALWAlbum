//
//  ALWAlbumItemCell.m
//  AlphaWorld
//
//  Created by John on 16/11/20.
//  Copyright © 2016年 AlphaWorld. All rights reserved.
//

#import "ALWAlbumItemCell.h"

@implementation ALWAlbumItemCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self _snb_configSubViews];
        [self _snb_configConstraints];
    }
    return self;
}

- (void)_snb_configSubViews
{
    self.imageView = [[UIImageView alloc] init];
    self.imageView.contentMode = UIViewContentModeScaleAspectFill;
    self.imageView.layer.masksToBounds = YES;
    self.selectButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.selectButton setImage:[UIImage imageNamed:@"album_icon_circle_small"] forState:UIControlStateNormal];
    [self.selectButton setImage:[UIImage imageNamed:@"album_icon_checkbox_small"] forState:UIControlStateSelected];
    [self.selectButton setImageEdgeInsets:UIEdgeInsetsMake(0, 20, 20, 0)];
    [self.contentView addSubview:self.imageView];
    [self.contentView addSubview:self.selectButton];
}

- (void)_snb_configConstraints
{
    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.equalTo(self.contentView);
        make.right.bottom.equalTo(self.contentView);
    }];
    [self.selectButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView).offset(5);
        make.right.equalTo(self.contentView).offset(-5);
        make.width.height.equalTo(@(40));
    }];
}

@end
