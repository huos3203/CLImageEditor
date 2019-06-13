//
//  CLImageEditor.m
//
//  Created by sho yakushiji on 2013/10/17.
//  Copyright (c) 2013年 CALACULU. All rights reserved.
//

#import "CLImageEditor.h"

#import "_CLImageEditorViewController.h"
#import "JHImageEditorViewController.h"

@interface CLImageEditor ()

@end


@implementation CLImageEditor

- (id)init
{
    return [_CLImageEditorViewController new];
}

- (id)initWithImage:(UIImage*)image
{
    return [self initWithImage:image delegate:nil];
}

- (id)initWithImage:(UIImage*)image delegate:(id<CLImageEditorDelegate>)delegate
{
    return [[_CLImageEditorViewController alloc] initWithImage:image delegate:delegate];
}

- (id)initWithDelegate:(id<CLImageEditorDelegate>)delegate
{
    return [[_CLImageEditorViewController alloc] initWithDelegate:delegate];
}

#pragma mark - 金和模块
- (id)initWithJHImage:(UIImage*)image
{
    return [_CLImageEditorViewController new];
}
- (id)initWithJHImage:(UIImage*)image delegate:(id<CLImageEditorDelegate>)delegate
{
    return [[JHImageEditorViewController alloc] initWithImage:image delegate:delegate];
}
- (id)initWithJHDelegate:(id<CLImageEditorDelegate>)delegate
{
    return [[JHImageEditorViewController alloc] initWithDelegate:delegate];
}



- (void)showInViewController:(UIViewController*)controller withImageView:(UIImageView*)imageView;
{
    
}

- (void)refreshToolSettings
{
    
}

- (CLImageEditorTheme*)theme
{
    return [CLImageEditorTheme theme];
}

@end

