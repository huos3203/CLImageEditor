//
//  CLDrawTool.m
//
//  Created by sho yakushiji on 2014/06/20.
//  Copyright (c) 2014年 CALACULU. All rights reserved.
//

#import "CLDrawTool.h"
#import "JHColorBoardView.h"

static NSString* const kCLDrawToolEraserIconName = @"eraserIconAssetsName";

@interface CLDrawTool()
@property (strong, nonatomic) UIColor *drawColor;
@end


@implementation CLDrawTool
{
    UIImageView *_drawingView;
    CGSize _originalImageSize;
    
    CGPoint _prevDraggingPosition;
    UIView *_menuView;
    UISlider *_colorSlider;
    UISlider *_widthSlider;
    UIView *_strokePreview;
    UIView *_strokePreviewBackground;
    UIImageView *_eraserIcon;
    
    CLToolbarMenuItem *_colorBtn;
}

+ (NSArray*)subtools
{
    return nil;
}

+ (NSString*)defaultTitle
{
    return [CLImageEditorTheme localizedString:@"CLDrawTool_DefaultTitle" withDefault:@"Draw"];
}

+ (BOOL)isAvailable
{
    return YES;
}

+ (CGFloat)defaultDockedNumber
{
    return 4.5;
}

#pragma mark- optional info

+ (NSDictionary*)optionalInfo
{
    return @{
             kCLDrawToolEraserIconName : @"",
             };
}

#pragma mark- implementation

- (void)setup
{
    _originalImageSize = self.editor.imageView.image.size;
    
    _drawingView = [[UIImageView alloc] initWithFrame:self.editor.imageView.bounds];
    
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(drawingViewDidPan:)];
    panGesture.maximumNumberOfTouches = 1;
    
    _drawingView.userInteractionEnabled = YES;
    [_drawingView addGestureRecognizer:panGesture];
    
    [self.editor.imageView addSubview:_drawingView];
    self.editor.imageView.userInteractionEnabled = YES;
    self.editor.scrollView.panGestureRecognizer.minimumNumberOfTouches = 2;
    self.editor.scrollView.panGestureRecognizer.delaysTouchesBegan = NO;
    self.editor.scrollView.pinchGestureRecognizer.delaysTouchesBegan = NO;
    
    _menuView = [[UIView alloc] initWithFrame:self.editor.menuView.frame];
    _menuView.backgroundColor = self.editor.menuView.backgroundColor;
    [self.editor.view addSubview:_menuView];
    
    [self setMenu];
    
    _menuView.transform = CGAffineTransformMakeTranslation(0, self.editor.view.height-_menuView.top);
    [UIView animateWithDuration:kCLImageToolAnimationDuration
                     animations:^{
                         self->_menuView.transform = CGAffineTransformIdentity;
                     }];
    
}

- (void)cleanup
{
    [_drawingView removeFromSuperview];
    self.editor.imageView.userInteractionEnabled = NO;
    self.editor.scrollView.panGestureRecognizer.minimumNumberOfTouches = 1;
    
    [UIView animateWithDuration:kCLImageToolAnimationDuration
                     animations:^{
                         self->_menuView.transform = CGAffineTransformMakeTranslation(0, self.editor.view.height-self->_menuView.top);
                     }
                     completion:^(BOOL finished) {
                         [self->_menuView removeFromSuperview];
                     }];
}

- (void)executeWithCompletionBlock:(void (^)(UIImage *, NSError *, NSDictionary *))completionBlock
{
    UIImage *backgroundImage = self.editor.imageView.image;
    UIImage *foregroundImage = _drawingView.image;

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIImage *image = [self buildImageWithBackgroundImage:backgroundImage foregroundImage:foregroundImage];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            completionBlock(image, nil, nil);
        });
    });
}

#pragma mark-
-(void)setMenu
{
    __weak typeof(self) weakSelf = self;
    JHColorBoardView *board = [[JHColorBoardView alloc] initWithFrame:_menuView.bounds for:JHImage_Draw colorHandler:^(UIColor *color) {
        weakSelf.drawColor = color;
    }];
    [_menuView addSubview:board];
}

- (void)drawingViewDidPan:(UIPanGestureRecognizer*)sender
{
    CGPoint currentDraggingPosition = [sender locationInView:_drawingView];
    
    if(sender.state == UIGestureRecognizerStateBegan){
        _prevDraggingPosition = currentDraggingPosition;
    }
    
    if(sender.state != UIGestureRecognizerStateEnded){
        [self drawLine:_prevDraggingPosition to:currentDraggingPosition];
    }
    _prevDraggingPosition = currentDraggingPosition;
}

-(void)drawLine:(CGPoint)from to:(CGPoint)to
{
    CGSize size = _drawingView.frame.size;
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    [_drawingView.image drawAtPoint:CGPointZero];
    
    CGFloat strokeWidth = 2;//MAX(1, _widthSlider.value * 65);
    UIColor *strokeColor = self.drawColor;//_strokePreview.backgroundColor;
    
    CGContextSetLineWidth(context, strokeWidth);
    CGContextSetStrokeColorWithColor(context, strokeColor.CGColor);
    CGContextSetLineCap(context, kCGLineCapRound);
//    if(!_eraserIcon.hidden){
//        CGContextSetBlendMode(context, kCGBlendModeClear);
//    }
    
    CGContextMoveToPoint(context, from.x, from.y);
    CGContextAddLineToPoint(context, to.x, to.y);
    CGContextStrokePath(context);
    
    _drawingView.image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
}

- (UIImage*)buildImageWithBackgroundImage:(UIImage*)backgroundImage foregroundImage:(UIImage*)foregroundImage
{
    UIGraphicsBeginImageContextWithOptions(_originalImageSize, NO, backgroundImage.scale);
    
    [backgroundImage drawAtPoint:CGPointZero];
    [foregroundImage drawInRect:CGRectMake(0, 0, _originalImageSize.width, _originalImageSize.height)];
    
    UIImage *tmp = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return tmp;
}

@end
