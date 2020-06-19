//
//  CLImageToolBase.m
//
//  Created by sho yakushiji on 2013/10/17.
//  Copyright (c) 2013年 CALACULU. All rights reserved.
//

#import "CLImageToolBase.h"

@implementation CLImageToolBase

- (id)initWithImageEditor:(_CLImageEditorViewController*)editor withToolInfo:(CLImageToolInfo*)info
{
    self = [super init];
    if(self){
        self.editor   = editor;
        self.toolInfo = info;
    }
    return self;
}

+ (NSString*)defaultIconImagePath
{
    CLImageEditorTheme *theme = [CLImageEditorTheme theme];
    return [NSString stringWithFormat:@"%@/%@/%@/icon.png", CLImageEditorTheme.bundle.bundlePath, NSStringFromClass([self class]), theme.toolIconColor];
}

+ (CGFloat)defaultDockedNumber
{
    // Image tools are sorted according to the dockedNumber in tool bar.
    // Override point for tool bar customization
    NSArray *tools = @[
                       @"CLFilterTool",
                       @"CLAdjustmentTool",
                       @"CLEffectTool",
                       @"CLBlurTool",
                       @"CLRotateTool",
                       @"CLClippingTool",
                       @"CLToneCurveTool",
                       ];
    return [tools indexOfObject:NSStringFromClass(self)];
}

+ (NSArray*)subtools
{
    return nil;
}

+ (NSString*)defaultTitle
{
    return @"DefaultTitle";
}

+ (BOOL)isAvailable
{
    return NO;
}

+ (NSDictionary*)optionalInfo
{
    return nil;
}

#pragma mark-

- (void)setup
{
    
}

- (void)cleanup
{
    
}

- (void)executeWithCompletionBlock:(void(^)(UIImage *image, NSError *error, NSDictionary *userInfo))completionBlock
{
    completionBlock(self.editor.imageView.image, nil, nil);
}

- (UIImage*)imageForKey:(NSString*)key defaultImageName:(NSString*)defaultImageName
{
    //[UIScreen mainScreen].scale
    NSString *iconName = self.toolInfo.optionalInfo[key];
    
    if(iconName.length>0){
        return [UIImage imageNamed:iconName];
    }
    else{
        return [CLImageEditorTheme imageNamed:[self class] image:defaultImageName];
    }
}

- (UIImage*)imageForJHName:(NSString*)name
{
    int scale = [UIScreen mainScreen].scale;
    NSString *path = [NSString stringWithFormat:@"CLImageEditor.bundle/JH/%@@%dx.png",name,scale];
    UIImage *img = [UIImage imageNamed:path];
    if (!img) {
        img = [self imageForPodName:name];
    }
    return img;
}

- (UIImage*)imageForPodName:(NSString*)name
{
    int scale = [UIScreen mainScreen].scale;
    NSString *bundlePath = [[NSBundle bundleForClass:[self class]] pathForResource:@"CLImageEditor" ofType:@"bundle"];
    NSString *imagePath = [bundlePath stringByAppendingFormat:@"/JH/%@@%dx.png",name,scale];
    UIImage *img = [UIImage fastImageWithContentsOfFile:imagePath];
    return img;
}
@end
