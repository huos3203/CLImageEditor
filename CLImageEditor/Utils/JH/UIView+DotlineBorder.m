//
//  UIView+DotlineBorder.m
//  CLImageEditorSDK
//
//  Created by admin on 2019/6/15.
//  Copyright © 2019 CALACULU. All rights reserved.
//

#import "UIView+DotlineBorder.h"

@implementation UIView (DotlineBorder)


-(void)addViewBorder
{
    /**
    _labelBorder = [CAShapeLayer layer];
    UIColor *grayColor = [UIColor colorWithRed:221.0f/255.0f green:221.0f/255.0f blue:221.0f/255.0f alpha:1.0f];
    _labelBorder.strokeColor = grayColor.CGColor;
    _labelBorder.fillColor = nil;
    _labelBorder.path = [UIBezierPath bezierPathWithRect:view.bounds].CGPath;
    _labelBorder.frame = view.bounds;
    _labelBorder.lineWidth = .5;
    _labelBorder.lineCap = @"square";
    _labelBorder.lineDashPattern = @[@1, @2];
    [view.layer addSublayer:_labelBorder];
     */
}

-(void)removeViewBorder
{
    /**
    if (!view) view = self;
    [view.layer.sublayers enumerateObjectsUsingBlock:^(CALayer * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj == _labelBorder) {
            *stop = YES;
            [_labelBorder removeFromSuperlayer];
        }
    }];
    */
    
}

@end
