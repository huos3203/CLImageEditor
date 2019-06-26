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
    
    //存储每一张图片
    NSMutableArray *_lineArray;
    NSMutableArray *_undoLines;
    UIButton *_undo;
    UIButton *_redo;
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
    
    //存储:撤销/重做画笔
    _lineArray = [NSMutableArray new];
    _undoLines = [NSMutableArray new];
}

- (void)cleanup
{
    [_drawingView removeFromSuperview];
    self.editor.imageView.userInteractionEnabled = NO;
    self.editor.scrollView.panGestureRecognizer.minimumNumberOfTouches = 1;
    [_redo removeFromSuperview];
    [_undo removeFromSuperview];
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
    
    _undo = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 22)];
    _redo = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 22)];
    _undo.selected = YES;
    _redo.selected = YES;
    [_undo setImage:[self imageForJHName:@"undoPre"] forState:UIControlStateNormal];
    [_undo setImage:[self imageForJHName:@"undoPre2"] forState:UIControlStateSelected];
    [_redo setImage:[self imageForJHName:@"redoPre"] forState:UIControlStateNormal];
    [_redo setImage:[self imageForJHName:@"redoPre2"] forState:UIControlStateSelected];
    CGFloat reX = [UIScreen mainScreen].bounds.size.width - 16;
    CGFloat reY = _menuView.frame.origin.y - 40;
    _redo.center = CGPointMake(reX, reY);
    _undo.center = CGPointMake(reX - 50, reY);
    [_undo addTarget:self action:@selector(unPreDoAction:) forControlEvents:UIControlEventTouchUpInside];
    [_redo addTarget:self action:@selector(rePreDoAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.editor.view addSubview:_undo];
    [self.editor.view addSubview:_redo];
}

- (void)drawingViewDidPan:(UIPanGestureRecognizer*)sender
{
    CGPoint currentDraggingPosition = [sender locationInView:_drawingView];
    
    if(sender.state == UIGestureRecognizerStateBegan){
        _prevDraggingPosition = currentDraggingPosition;
        //初始化存储一条线的数组
        NSMutableArray *pointArray = [NSMutableArray arrayWithCapacity:1];
        [_lineArray addObject:pointArray];
    }
    
    if(sender.state != UIGestureRecognizerStateEnded){
        [self drawLine:_prevDraggingPosition to:currentDraggingPosition];
        //存储一条线的数组 即:线上的所有点
        NSMutableArray *pointArray = [_lineArray lastObject];
        _undo.selected = NO;
        NSValue *pointValue = [NSValue valueWithCGPoint:currentDraggingPosition];
        [pointArray addObject:pointValue];
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



#pragma mark - 撤销上一步操作
//https://blog.csdn.net/lfl18326162160/article/details/77447787
//撤销
-(void)unPreDoAction:(UIButton *)undo
{
    if(_lineArray.count == 0)return;
    NSArray *unline = [_lineArray lastObject];
    [_undoLines addObject:unline];
    [_lineArray removeLastObject];
    [self clearLine:unline];
    [_undo setHighlighted:YES];
    _redo.selected = _undoLines.count == 0;
    _undo.selected = _lineArray.count == 0;
}

//重做
-(void)rePreDoAction:(UIButton *)redo
{
    if(_undoLines.count == 0)return;
    NSArray *reline = [_undoLines lastObject];
    [_lineArray addObject:reline];
    [_undoLines removeLastObject];
    [self reDrawLine];
    _redo.selected = _undoLines.count == 0;
    _undo.selected = _lineArray.count == 0;
}

-(void)reDrawLine
{
    for (int i = 0; i < [_lineArray count]; i++) {
        NSMutableArray *pointArray = [_lineArray objectAtIndex:i];
        for (int j = 0; j <(int)pointArray.count - 1; j++) {
            //拿出小数组之中的两个点
            NSValue *firstPointValue = [pointArray objectAtIndex:j];
            NSValue *secondPointValue = [pointArray objectAtIndex:j+1];
            CGPoint from = [firstPointValue CGPointValue];
            CGPoint to = [secondPointValue CGPointValue];
            [self drawLine:from to:to];
        }
    }
}

-(void)clearLine:(NSArray *)pointArray
{
    for (int j = 0; j <(int)pointArray.count - 1; j++) {
        //拿出小数组之中的两个点
        NSValue *firstPointValue = [pointArray objectAtIndex:j];
        NSValue *secondPointValue = [pointArray objectAtIndex:j+1];
        CGPoint from = [firstPointValue CGPointValue];
        CGPoint to = [secondPointValue CGPointValue];
        [self clearLine:from to:to];
    }
}

-(void)clearLine:(CGPoint)from to:(CGPoint)to
{
    CGSize size = _drawingView.frame.size;
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    [_drawingView.image drawAtPoint:CGPointZero];
    
    CGFloat strokeWidth = 2;//MAX(1, _widthSlider.value * 65);
    UIColor *strokeColor = self.drawColor;//_strokePreview.backgroundColor;
    
    CGContextSetLineWidth(context, strokeWidth);
    CGContextSetStrokeColorWithColor(context, strokeColor.CGColor);
    CGContextSetBlendMode(context, kCGBlendModeClear);
    
    CGContextMoveToPoint(context, from.x, from.y);
    CGContextAddLineToPoint(context, to.x, to.y);
    CGContextStrokePath(context);
    
    _drawingView.image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
}
@end
