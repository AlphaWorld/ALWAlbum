//
//  UIView+ALWAlbumAnimation.m
//  AlphaWorld
//
//  Created by John on 16/11/20.
//  Copyright © 2016年 AlphaWorld. All rights reserved.
//

#import "UIView+ALWAlbumAnimation.h"
#import <pop/POP.h>

@implementation UIView (ALWAlbumAnimation)

+ (void)alw_showOscillatoryAnimationWithLayer:(CALayer *)layer
{
    [layer pop_removeAllAnimations];
    POPSpringAnimation *spring = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerScaleXY];
    spring.fromValue = [NSValue valueWithCGSize:CGSizeMake(1.1f, 1.1f)];
    spring.toValue = [NSValue valueWithCGSize:CGSizeMake(1.f, 1.f)];
    //速度
    spring.springSpeed = 16.7f;
    //弹力
    spring.springBounciness = 9.08f;
    //质量
    spring.dynamicsMass = 2.01f;
    //摩擦
    spring.dynamicsFriction = 17.90f;
    //拉力
    spring.dynamicsTension = 700;
    [layer pop_addAnimation:spring forKey:nil];
}

@end
