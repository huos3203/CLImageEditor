//
//  CLTextTool.m
//
//  Created by sho yakushiji on 2013/12/15.
//  Copyright (c) 2013年 CALACULU. All rights reserved.
//

#import "CLTextTool.h"

#import "CLCircleView.h"
#import "CLColorPickerView.h"
#import "CLFontPickerView.h"
#import "CLTextLabel.h"

#import "CLTextSettingView.h"
#import "JHColorBoardView.h"

static NSString* const CLTextViewActiveViewDidChangeNotification = @"CLTextViewActiveViewDidChangeNotificationString";
static NSString* const CLTextViewActiveViewDidTapNotification = @"CLTextViewActiveViewDidTapNotificationString";

static NSString* const kCLTextToolDeleteIconName = @"deleteIconAssetsName";
static NSString* const kCLTextToolCloseIconName = @"closeIconAssetsName";
static NSString* const kCLTextToolNewTextIconName = @"newTextIconAssetsName";
static NSString* const kCLTextToolEditTextIconName = @"editTextIconAssetsName";
static NSString* const kCLTextToolFontIconName = @"fontIconAssetsName";
static NSString* const kCLTextToolAlignLeftIconName = @"alignLeftIconAssetsName";
static NSString* const kCLTextToolAlignCenterIconName = @"alignCenterIconAssetsName";
static NSString* const kCLTextToolAlignRightIconName = @"alignRightIconAssetsName";


@interface _CLTextView : UIView
@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) UIFont *font;
@property (nonatomic, strong) UIColor *fillColor;
@property (nonatomic, strong) UIColor *borderColor;
@property (nonatomic, assign) CGFloat borderWidth;
@property (nonatomic, assign) NSTextAlignment textAlignment;

+ (void)setActiveTextView:(_CLTextView*)view;
- (id)initWithTool:(CLTextTool*)tool;
- (void)setScale:(CGFloat)scale;
- (void)sizeToFitWithMaxWidth:(CGFloat)width lineHeight:(CGFloat)lineHeight;
-(void)removeViewBorder;

@end



@interface CLTextTool()
<CLColorPickerViewDelegate, CLFontPickerViewDelegate, UITextViewDelegate, CLTextSettingViewDelegate>
@property (nonatomic, strong) _CLTextView *selectedTextView;
@property (strong, nonatomic) UIColor *drawColor;
@end

@implementation CLTextTool
{
    UIImage *_originalImage;
    
    UIView *_workingView;
    
    CLTextSettingView *_settingView;
    
    CLToolbarMenuItem *_textBtn;
    CLToolbarMenuItem *_colorBtn;
    CLToolbarMenuItem *_fontBtn;
    
    CLToolbarMenuItem *_alignLeftBtn;
    CLToolbarMenuItem *_alignCenterBtn;
    CLToolbarMenuItem *_alignRightBtn;
    
    UIScrollView *_menuScroll;
}

+ (NSArray*)subtools
{
    return nil;
}

+ (NSString*)defaultTitle
{
    return [CLImageEditorTheme localizedString:@"CLTextTool_DefaultTitle" withDefault:@"Text"];
}

+ (BOOL)isAvailable
{
    return ([UIDevice iosVersion] >= 5.0);
}

+ (CGFloat)defaultDockedNumber
{
    return 8;
}

#pragma mark- optional info

+ (NSDictionary*)optionalInfo
{
    return @{
             kCLTextToolDeleteIconName:@"",
             kCLTextToolCloseIconName:@"",
             kCLTextToolNewTextIconName:@"",
             kCLTextToolEditTextIconName:@"",
             kCLTextToolFontIconName:@"",
             kCLTextToolAlignLeftIconName:@"",
             kCLTextToolAlignCenterIconName:@"",
             kCLTextToolAlignRightIconName:@"",
             };
}

#pragma mark- implementation

- (void)setup
{
    _originalImage = self.editor.imageView.image;
    
    [self.editor fixZoomScaleWithAnimated:YES];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(activeTextViewDidChange:) name:CLTextViewActiveViewDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(activeTextViewDidTap:) name:CLTextViewActiveViewDidTapNotification object:nil];
    
    _menuScroll = [[UIScrollView alloc] initWithFrame:self.editor.menuView.frame];
    _menuScroll.backgroundColor = self.editor.menuView.backgroundColor;
    _menuScroll.showsHorizontalScrollIndicator = NO;
    [self.editor.view addSubview:_menuScroll];
    
    _workingView = [[UIView alloc] initWithFrame:[self.editor.view convertRect:self.editor.imageView.frame fromView:self.editor.imageView.superview]];
    _workingView.clipsToBounds = YES;
    [self.editor.view addSubview:_workingView];
    ///设置页面
    _settingView = [[CLTextSettingView alloc] initWithFrame:CGRectMake(0, 0, self.editor.view.width, 50)];
    _settingView.top = _menuScroll.top - _settingView.height;
    _settingView.backgroundColor = [UIColor whiteColor];
    _settingView.textColor = [UIColor colorWithRed:94/255.0 green:99/255.0 blue:123/255.0 alpha:1.0];
    _settingView.fontPickerForegroundColor = _settingView.backgroundColor;
    _settingView.delegate = self;
    [self.editor.view addSubview:_settingView];
    
    UIButton *okButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [okButton setImage:[self imageForJHName:@"textOK"] forState:UIControlStateNormal];
    okButton.frame = CGRectMake(_settingView.width-40, 8, 32, 32);
    [okButton addTarget:self action:@selector(pushedButton:) forControlEvents:UIControlEventTouchUpInside];
    [_settingView addSubview:okButton];
    
    [self setMenu];
    
    self.selectedTextView = nil;
    
    _menuScroll.transform = CGAffineTransformMakeTranslation(0, self.editor.view.height-_menuScroll.top);
    [UIView animateWithDuration:kCLImageToolAnimationDuration
                     animations:^{
                          self->_menuScroll.transform = CGAffineTransformIdentity;
                     }];
}

- (void)cleanup
{
    [self.editor resetZoomScaleWithAnimated:YES];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [_settingView endEditing:YES];
    [_settingView removeFromSuperview];
    [_workingView removeFromSuperview];
    
    [UIView animateWithDuration:kCLImageToolAnimationDuration
                     animations:^{
                         self->_menuScroll.transform = CGAffineTransformMakeTranslation(0, self.editor.view.height-self->_menuScroll.top);
                     }
                     completion:^(BOOL finished) {
                         [self->_menuScroll removeFromSuperview];
                     }];
}

- (void)executeWithCompletionBlock:(void (^)(UIImage *, NSError *, NSDictionary *))completionBlock
{
    [_CLTextView setActiveTextView:nil];
    [self.selectedTextView removeViewBorder];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIImage *image = [self buildImage:self->_originalImage];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            completionBlock(image, nil, nil);
        });
    });
}

#pragma mark-

- (UIImage*)buildImage:(UIImage*)image
{
    __block CALayer *layer = nil;
    __block CGFloat scale = 1;
    
    safe_dispatch_sync_main(^{
        scale = image.size.width / self->_workingView.width;
        layer = self->_workingView.layer;
    });
    
    UIGraphicsBeginImageContextWithOptions(image.size, NO, image.scale);
    
    [image drawAtPoint:CGPointZero];
    
    CGContextScaleCTM(UIGraphicsGetCurrentContext(), scale, scale);
    [layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage *tmp = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return tmp;
}

- (void)activeTextViewDidChange:(NSNotification*)notification
{
    self.selectedTextView = notification.object;
}

- (void)activeTextViewDidTap:(NSNotification*)notification
{
    [self beginTextEditing];
}
- (void)setMenu
{
    __weak typeof(self) weakSelf = self;
    JHColorBoardView *board = [[JHColorBoardView alloc] initWithFrame:_menuScroll.bounds for:JHImage_Text colorHandler:^(UIColor *color) {
        weakSelf.drawColor = color;
        weakSelf.selectedTextView.fillColor = color;
    }];
    [_menuScroll addSubview:board];
    [self addNewText];
}

- (void)addNewText
{
    _CLTextView *view = [[_CLTextView alloc] initWithTool:self];
    view.fillColor = _settingView.selectedFillColor;
    view.borderColor = _settingView.selectedBorderColor;
    view.borderWidth = _settingView.selectedBorderWidth;
    view.font = _settingView.selectedFont;
    
    CGFloat ratio = MIN( (0.8 * _workingView.width) / view.width, (0.2 * _workingView.height) / view.height);
    [view setScale:ratio];
    view.center = CGPointMake(_workingView.width/2, view.height/2 + 10);
    
    [_workingView addSubview:view];
    [_CLTextView setActiveTextView:view];
    
    [self beginTextEditing];
}

- (void)hideSettingView
{
    [_settingView endEditing:YES];
    _settingView.hidden = YES;
}

- (void)showSettingViewWithMenuIndex:(NSInteger)index
{
    if(_settingView.hidden){
        _settingView.hidden = NO;
        [_settingView showSettingMenuWithIndex:index animated:NO];
    }
    else{
        [_settingView showSettingMenuWithIndex:index animated:YES];
    }
}

- (void)beginTextEditing
{
    [self showSettingViewWithMenuIndex:0];
    [_settingView becomeFirstResponder];
}

- (void)setTextAlignment:(NSTextAlignment)alignment
{
    self.selectedTextView.textAlignment = alignment;
    
    _alignLeftBtn.selected = _alignCenterBtn.selected = _alignRightBtn.selected = NO;
    switch (alignment) {
        case NSTextAlignmentLeft:
            _alignLeftBtn.selected = YES;
            break;
        case NSTextAlignmentCenter:
            _alignCenterBtn.selected = YES;
            break;
        case NSTextAlignmentRight:
            _alignRightBtn.selected = YES;
            break;
        default:
            break;
    }
}

- (void)pushedButton:(UIButton*)button
{
    if(_settingView.isFirstResponder){
        [_settingView resignFirstResponder];
        [self hideSettingView];
    }
    else{
        [self hideSettingView];
    }
}

#pragma mark- Setting view delegate

- (void)textSettingView:(CLTextSettingView *)settingView didChangeText:(NSString *)text
{
    // set text
    self.selectedTextView.text = text;
    [self.selectedTextView sizeToFitWithMaxWidth:0.8*_workingView.width lineHeight:0.2*_workingView.height];
}

- (void)textSettingView:(CLTextSettingView*)settingView didChangeFillColor:(UIColor*)fillColor
{
    _colorBtn.iconView.backgroundColor = fillColor;
    self.selectedTextView.fillColor = fillColor;
}

- (void)textSettingView:(CLTextSettingView*)settingView didChangeBorderColor:(UIColor*)borderColor
{
    _colorBtn.iconView.layer.borderColor = borderColor.CGColor;
    self.selectedTextView.borderColor = borderColor;
}

- (void)textSettingView:(CLTextSettingView*)settingView didChangeBorderWidth:(CGFloat)borderWidth
{
    _colorBtn.iconView.layer.borderWidth = MAX(2, 10*borderWidth);
    self.selectedTextView.borderWidth = borderWidth;
}

- (void)textSettingView:(CLTextSettingView *)settingView didChangeFont:(UIFont *)font
{
//    self.selectedTextView.font = font;
//    [self.selectedTextView sizeToFitWithMaxWidth:0.8*_workingView.width lineHeight:0.2*_workingView.height];
}

@end



const CGFloat MAX_FONT_SIZE = 17.0;


#pragma mark- _CLTextView

@implementation _CLTextView
{
    CLTextLabel *_label;
    UIButton *_deleteButton;
    UIImageView *_circleView;
    
    CGFloat _scale;
    CGFloat _arg;
    
    CGPoint _initialPoint;
    CGFloat _initialArg;
    CGFloat _initialScale;
    CAShapeLayer *_cLTextBorder;
}

+ (void)setActiveTextView:(_CLTextView*)view
{
    static _CLTextView *activeView = nil;
    if(view != activeView){
        [activeView setAvtive:NO];
        activeView = view;
        [activeView setAvtive:YES];
        
        [activeView.superview bringSubviewToFront:activeView];
        
        NSNotification *n = [NSNotification notificationWithName:CLTextViewActiveViewDidChangeNotification object:view userInfo:nil];
        [[NSNotificationCenter defaultCenter] performSelectorOnMainThread:@selector(postNotification:) withObject:n waitUntilDone:NO];
    }
}

- (id)initWithTool:(CLTextTool*)tool
{
    self = [super initWithFrame:CGRectMake(0, 0, 132, 132)];
    if(self){
        _label = [[CLTextLabel alloc] init];
        [_label setTextColor:[CLImageEditorTheme toolbarTextColor]];
        _label.numberOfLines = 0;
        _label.backgroundColor = [UIColor clearColor];
        _label.layer.borderColor = [[UIColor clearColor] CGColor];
        _label.font = [UIFont systemFontOfSize:MAX_FONT_SIZE];
        _label.minimumScaleFactor = 1/MAX_FONT_SIZE;
        _label.adjustsFontSizeToFitWidth = YES;
        _label.textAlignment = NSTextAlignmentCenter;
        self.text = @"";
        [self addSubview:_label];
        
        CGSize size = [_label sizeThatFits:CGSizeMake(FLT_MAX, FLT_MAX)];
        _label.frame = CGRectMake(16, 16, size.width, size.height);
        self.frame = CGRectMake(0, 0, size.width + 32, size.height + 32);
        
        _deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_deleteButton setImage:[tool imageForJHName:@"textDel"] forState:UIControlStateNormal];
        _deleteButton.frame = CGRectMake(-8, -8, 32, 32);
        [_deleteButton addTarget:self action:@selector(pushedDeleteBtn:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_deleteButton];
        
        _circleView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
        _circleView.userInteractionEnabled = YES;
        _circleView.image = [tool imageForJHName:@"controlhandler"];
        _circleView.center = CGPointMake(_label.width + _label.left + 8, _label.height + _label.top + 8);
        _circleView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;
        [self addSubview:_circleView];
        
        //初始化角度/缩放比例
        _arg = 0;
        [self setScale:1];
        
        [self initGestures];
        //添加虚线边框
        [self performSelector:@selector(delayRefreshView) withObject:nil afterDelay:.3];
    }
    return self;
}

- (void)initGestures
{
    _label.userInteractionEnabled = YES;
    [_label addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewDidTap:)]];
    [_label addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(viewDidPan:)]];
    [_circleView addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(circleViewDidPan:)]];
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    UIView* view= [super hitTest:point withEvent:event];
    if(view==self){
        return nil;
    }
    return view;
}

#pragma mark- Properties

- (void)setAvtive:(BOOL)active
{
    _deleteButton.hidden = !active;
    _circleView.hidden = !active;
    _label.layer.borderWidth = (active) ? 1/_scale : 0;
}

- (BOOL)active
{
    return !_deleteButton.hidden;
}

- (void)sizeToFitWithMaxWidth:(CGFloat)width lineHeight:(CGFloat)lineHeight
{
    self.transform = CGAffineTransformIdentity;
    _label.transform = CGAffineTransformIdentity;
    
    CGSize size = [_label sizeThatFits:CGSizeMake(width / (15/MAX_FONT_SIZE), FLT_MAX)];
    _label.frame = CGRectMake(16, 16, size.width, size.height);
    [self removeViewBorder];
    [self addViewBorder];
    CGFloat viewW = (_label.width + 32);
    CGFloat viewH = _label.font.lineHeight;
    
    CGFloat ratio = MIN(width / viewW, lineHeight / viewH);
    [self setScale:ratio];
}

- (void)setScale:(CGFloat)scale
{
    if(scale < .5) scale = .5;
    if(scale > 4) scale = 4;
    _scale = scale;
    
    self.transform = CGAffineTransformIdentity;
    
    _label.transform = CGAffineTransformMakeScale(_scale, _scale);
    
    CGRect rct = self.frame;
    rct.origin.x += (rct.size.width - (_label.width + 32)) / 2;
    rct.origin.y += (rct.size.height - (_label.height + 32)) / 2;
    rct.size.width  = _label.width + 32;
    rct.size.height = _label.height + 32;
    self.frame = rct;
    
    _label.center = CGPointMake(rct.size.width/2, rct.size.height/2);
    self.transform = CGAffineTransformMakeRotation(_arg);
    
    _label.layer.borderWidth = 1/_scale;
    _label.layer.cornerRadius = 3/_scale;
}

- (void)setFillColor:(UIColor *)fillColor
{
    _label.textColor = fillColor;
}

- (UIColor*)fillColor
{
    return [UIColor whiteColor];
    return _label.textColor;
}

- (void)setBorderColor:(UIColor *)borderColor
{
    _label.outlineColor = borderColor;
}

- (UIColor*)borderColor
{
    return _label.outlineColor;
}

- (void)setBorderWidth:(CGFloat)borderWidth
{
    _label.outlineWidth = borderWidth;
}

- (CGFloat)borderWidth
{
    return _label.outlineWidth;
}

//- (void)setFont:(UIFont *)font
//{
//    _label.font = [font fontWithSize:MAX_FONT_SIZE];
//}
//
//- (UIFont*)font
//{
//    return _label.font;
//}

- (void)setTextAlignment:(NSTextAlignment)textAlignment
{
    _label.textAlignment = textAlignment;
}

- (NSTextAlignment)textAlignment
{
    return _label.textAlignment;
}

- (void)setText:(NSString *)text
{
    if(![text isEqualToString:_text]){
        _text = text;
        _label.text = (_text.length>0) ? _text : @"点击输入文字";
    }
}

#pragma mark- gesture events

- (void)pushedDeleteBtn:(id)sender
{
    _CLTextView *nextTarget = nil;
    
    const NSInteger index = [self.superview.subviews indexOfObject:self];
    
    for(NSInteger i=index+1; i<self.superview.subviews.count; ++i){
        UIView *view = [self.superview.subviews objectAtIndex:i];
        if([view isKindOfClass:[_CLTextView class]]){
            nextTarget = (_CLTextView*)view;
            break;
        }
    }
    
    if(nextTarget==nil){
        for(NSInteger i=index-1; i>=0; --i){
            UIView *view = [self.superview.subviews objectAtIndex:i];
            if([view isKindOfClass:[_CLTextView class]]){
                nextTarget = (_CLTextView*)view;
                break;
            }
        }
    }
    
    [[self class] setActiveTextView:nextTarget];
    [self removeFromSuperview];
}

- (void)viewDidTap:(UITapGestureRecognizer*)sender
{
    if(self.active){
        NSNotification *n = [NSNotification notificationWithName:CLTextViewActiveViewDidTapNotification object:self userInfo:nil];
        [[NSNotificationCenter defaultCenter] performSelectorOnMainThread:@selector(postNotification:) withObject:n waitUntilDone:NO];
    }
    [[self class] setActiveTextView:self];
}

- (void)viewDidPan:(UIPanGestureRecognizer*)sender
{
    [[self class] setActiveTextView:self];
    
    CGPoint p = [sender translationInView:self.superview];
    
    if(sender.state == UIGestureRecognizerStateBegan){
        _initialPoint = self.center;
    }
    CGPoint centerPoint = CGPointMake(_initialPoint.x + p.x, _initialPoint.y + p.y);
    if (centerPoint.x < 0) {
        centerPoint.x = 0;
    }
    if (centerPoint.x > CGRectGetWidth(self.superview.frame)) {
        centerPoint.x = CGRectGetWidth(self.superview.frame);
    }
    if (centerPoint.y < 0) {
        centerPoint.y = 0;
    }
    if (centerPoint.y > CGRectGetHeight(self.superview.frame)) {
        centerPoint.y = CGRectGetHeight(self.superview.frame);
    }
    self.center = centerPoint;
}

- (void)circleViewDidPan:(UIPanGestureRecognizer*)sender
{
    CGPoint p = [sender translationInView:self.superview];
    
    static CGFloat tmpR = 1;
    static CGFloat tmpA = 0;
    if(sender.state == UIGestureRecognizerStateBegan){
        _initialPoint = [self.superview convertPoint:_circleView.center fromView:_circleView.superview];
        
        CGPoint p = CGPointMake(_initialPoint.x - self.center.x, _initialPoint.y - self.center.y);
        tmpR = sqrt(p.x*p.x + p.y*p.y);
        tmpA = atan2(p.y, p.x);
        
        _initialArg = _arg;
        _initialScale = _scale;
    }
    
    p = CGPointMake(_initialPoint.x + p.x - self.center.x, _initialPoint.y + p.y - self.center.y);
    CGFloat R = sqrt(p.x*p.x + p.y*p.y);
    CGFloat arg = atan2(p.y, p.x);
    
    _arg   = _initialArg + arg - tmpA;
    [self setScale:MAX(_initialScale * R / tmpR, 3/MAX_FONT_SIZE)];
}


#pragma mark - 虚线框
//初始化
-(void)delayRefreshView
{
    [self addViewBorder];
}
-(void)addViewBorder
{
    _cLTextBorder = [CAShapeLayer layer];
    UIColor *grayColor = [UIColor colorWithRed:221.0f/255.0f green:221.0f/255.0f blue:221.0f/255.0f alpha:1.0f];
    _cLTextBorder.strokeColor = grayColor.CGColor;
    _cLTextBorder.fillColor = nil;
    CGRect rect = CGRectMake(_label.bounds.origin.x - 2,
                             _label.bounds.origin.y - 2,
                             _label.bounds.size.width + 8,
                             _label.bounds.size.height + 8);
    _cLTextBorder.path = [UIBezierPath bezierPathWithRect:rect].CGPath;
    _cLTextBorder.frame = rect;
    _cLTextBorder.lineWidth = .5;
    _cLTextBorder.lineCap = @"square";
    _cLTextBorder.lineDashPattern = @[@1, @2];
    [_label.layer addSublayer:_cLTextBorder];
}

-(void)removeViewBorder
{
    [_label.layer.sublayers enumerateObjectsUsingBlock:^(CALayer * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj == _cLTextBorder) {
            *stop = YES;
            [_cLTextBorder removeFromSuperlayer];
        }
    }];
}

@end


