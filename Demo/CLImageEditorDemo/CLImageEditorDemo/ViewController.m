//
//  ViewController.m
//  CLImageEditorDemo
//
//  Created by sho yakushiji on 2013/11/14.
//  Copyright (c) 2013年 CALACULU. All rights reserved.
//

#import "ViewController.h"

#import "CLImageEditorSDK.h"

@interface ViewController ()
<CLImageEditorDelegate, CLImageEditorTransitionDelegate, CLImageEditorThemeDelegate>
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIView *contentView = [UIView new];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"default.jpg"]];
    [contentView addSubview:imageView];
    [_scrollView addSubview:contentView];
    _imageView = imageView;
    
    //Set a black theme rather than a white one
	/*
    [[CLImageEditorTheme theme] setBackgroundColor:[UIColor blackColor]];
    [[CLImageEditorTheme theme] setToolbarColor:[[UIColor blackColor] colorWithAlphaComponent:0.8]];
    [[CLImageEditorTheme theme] setToolbarTextColor:[UIColor whiteColor]];
    [[CLImageEditorTheme theme] setToolIconColor:@"white"];
    [[CLImageEditorTheme theme] setStatusBarStyle:UIStatusBarStyleLightContent];
    [[UINavigationBar appearance] setBarStyle:UIBarStyleBlack];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    */
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    [self refreshImageView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotate
{
    return NO;
}

#if __IPHONE_OS_VERSION_MAX_ALLOWED < 90000
- (NSUInteger)supportedInterfaceOrientations
#else
- (UIInterfaceOrientationMask)supportedInterfaceOrientations
#endif
{
    return UIInterfaceOrientationMaskPortrait;
}

- (void)pushedNewBtn
{
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Camera", @"Photo Library", nil];
    [sheet showInView:self.view.window];
}

- (void)pushedEditBtn
{
    if(_imageView.image){
        CLImageEditor *editor = [[CLImageEditor alloc] initWithJHImage:_imageView.image delegate:self];
        ///设置皮肤主题
        editor.theme.bundleName = @"CLImageEditor";  //资源bundle名
        editor.theme.backgroundColor = [UIColor blackColor];
        editor.theme.statusBarHidden = YES;
        editor.theme.toolbarColor = [UIColor blackColor];
        editor.theme.toolIconColor = @"white";
        editor.theme.toolbarTextColor = [UIColor whiteColor];
        //CLImageEditor *editor = [[CLImageEditor alloc] initWithDelegate:self];
        
        /**/
        NSLog(@"%@", editor.toolInfo);
        NSLog(@"%@", editor.toolInfo.toolTreeDescription);
        CLImageToolInfo *tool0 = [editor.toolInfo subToolInfoWithToolName:@"CLDrawTool" recursive:NO];
        tool0.title = @"涂鸦";
        tool0.available = YES;//如果available设置为no，则从菜单视图中删除。
        tool0.dockedNumber = -1;//置于顶层
        CLImageToolInfo *tool01 = [editor.toolInfo subToolInfoWithToolName:@"CLTextTool" recursive:NO];
        tool01.title = @"文字";
        tool01.available = YES;//如果available设置为no，则从菜单视图中删除。
        tool01.dockedNumber = -1;//置于顶层
//        [self removeOtherBut:editor];
        
        [self presentViewController:editor animated:YES completion:nil];
        //[editor showInViewController:self withImageView:_imageView];
    }
    else{
        [self pushedNewBtn];
    }
}


-(void)removeOtherBut:(CLImageEditor *)editor
{
    /**两种方式屏蔽
     第一种:在CLImageToolInfo+Private.m中添加如下代码
     ```
     if(![cls isEqualToString:@"CLDrawTool"]
     && ![cls isEqualToString:@"CLTextTool"]) continue;
     ```
     第二种: 如下实现,获取工具实例,然后设置available为NO
     */
    CLImageToolInfo *tool = [editor.toolInfo subToolInfoWithToolName:@"CLToneCurveTool" recursive:NO];
    tool.available = NO;
    
    CLImageToolInfo *tool1 = [editor.toolInfo subToolInfoWithToolName:@"CLRotateTool" recursive:YES];
    tool1.available = NO;
    
    CLImageToolInfo *tool2 = [editor.toolInfo subToolInfoWithToolName:@"CLHueEffect" recursive:YES];
    tool2.available = NO;
    
    CLImageToolInfo *tool3 = [editor.toolInfo subToolInfoWithToolName:@"CLBlurTool" recursive:YES];
    tool3.available = NO;
    CLImageToolInfo *tool4 = [editor.toolInfo subToolInfoWithToolName:@"CLAdjustmentTool" recursive:YES];
    tool4.available = NO;
    CLImageToolInfo *tool5 = [editor.toolInfo subToolInfoWithToolName:@"CLEffectTool" recursive:YES];
    tool5.available = NO;
    //滤镜
    CLImageToolInfo *tool6 = [editor.toolInfo subToolInfoWithToolName:@"CLFilterTool" recursive:YES];
    tool6.available = NO;
    CLImageToolInfo *tool7 = [editor.toolInfo subToolInfoWithToolName:@"CLSplashTool" recursive:YES];
    tool7.available = NO;
    //贴图
    CLImageToolInfo *tool8 = [editor.toolInfo subToolInfoWithToolName:@"CLEmoticonTool" recursive:YES];
    tool8.available = NO;
    CLImageToolInfo *tool9 = [editor.toolInfo subToolInfoWithToolName:@"CLStickerTool" recursive:YES];
    tool9.available = NO;
    //放大缩小
    CLImageToolInfo *tool10 = [editor.toolInfo subToolInfoWithToolName:@"CLResizeTool" recursive:YES];
    tool10.available = NO;
    //剪切
    CLImageToolInfo *tool11 = [editor.toolInfo subToolInfoWithToolName:@"CLClippingTool" recursive:YES];
    tool11.available = NO;
}

- (void)pushedSaveBtn
{
    if(_imageView.image){
        NSArray *excludedActivityTypes = @[UIActivityTypeAssignToContact, UIActivityTypeCopyToPasteboard, UIActivityTypeMessage];
        
        UIActivityViewController *activityView = [[UIActivityViewController alloc] initWithActivityItems:@[_imageView.image] applicationActivities:nil];
        
        activityView.excludedActivityTypes = excludedActivityTypes;
        activityView.completionWithItemsHandler = ^(NSString *activityType, BOOL completed, NSArray *returnedItems, NSError *activityError) {
            if(completed && [activityType isEqualToString:UIActivityTypeSaveToCameraRoll]){
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Saved successfully" message:nil preferredStyle:UIAlertControllerStyleAlert];
                [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
                [self presentViewController:alert animated:YES completion:nil];
            }
        };
        
        [self presentViewController:activityView animated:YES completion:nil];
    }
    else{
        [self pushedNewBtn];
    }
}

#pragma mark- ImagePicker delegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    CLImageEditor *editor = [[CLImageEditor alloc] initWithImage:image];
    editor.delegate = self;
    
    [picker pushViewController:editor animated:YES];
}
/*
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if([navigationController isKindOfClass:[UIImagePickerController class]] && [viewController isKindOfClass:[CLImageEditor class]]){
        viewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelButtonDidPush:)];
    }
}

- (void)cancelButtonDidPush:(id)sender
{
    [self.presentedViewController dismissViewControllerAnimated:YES completion:nil];
}
*/
#pragma mark- CLImageEditor delegate

- (void)imageEditor:(CLImageEditor *)editor didFinishEditingWithImage:(UIImage *)image
{
    _imageView.image = image;
    [self refreshImageView];
    
    [editor dismissViewControllerAnimated:YES completion:nil];
}

- (void)imageEditor:(CLImageEditor *)editor willDismissWithImageView:(UIImageView *)imageView canceled:(BOOL)canceled
{
    [self refreshImageView];
}

#pragma mark- Tapbar delegate

- (void)deselectTabBarItem:(UITabBar*)tabBar
{
    tabBar.selectedItem = nil;
}

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item
{
    [self performSelector:@selector(deselectTabBarItem:) withObject:tabBar afterDelay:0.2];
    
    switch (item.tag) {
        case 0:
            [self pushedNewBtn];
            break;
        case 1:
            [self pushedEditBtn];
            break;
        case 2:
            [self pushedSaveBtn];
            break;
        default:
            break;
    }
}

#pragma mark- Actionsheet delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex==actionSheet.cancelButtonIndex){
        return;
    }
    
    UIImagePickerControllerSourceType type = UIImagePickerControllerSourceTypePhotoLibrary;
    
    if([UIImagePickerController isSourceTypeAvailable:type]){
        if(buttonIndex==0 && [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
            type = UIImagePickerControllerSourceTypeCamera;
        }
        
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.allowsEditing = NO;
        picker.delegate   = self;
        picker.sourceType = type;
        
        [self presentViewController:picker animated:YES completion:nil];
    }
}

#pragma mark- ScrollView

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return _imageView.superview;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    CGFloat Ws = _scrollView.frame.size.width - _scrollView.contentInset.left - _scrollView.contentInset.right;
    CGFloat Hs = _scrollView.frame.size.height - _scrollView.contentInset.top - _scrollView.contentInset.bottom;
    CGFloat W = _imageView.superview.frame.size.width;
    CGFloat H = _imageView.superview.frame.size.height;
    
    CGRect rct = _imageView.superview.frame;
    rct.origin.x = MAX((Ws-W)/2, 0);
    rct.origin.y = MAX((Hs-H)/2, 0);
    _imageView.superview.frame = rct;
}

- (void)resetImageViewFrame
{
    CGSize size = (_imageView.image) ? _imageView.image.size : _imageView.frame.size;
    CGFloat ratio = MIN(_scrollView.frame.size.width / size.width, _scrollView.frame.size.height / size.height);
    CGFloat W = ratio * size.width;
    CGFloat H = ratio * size.height;
    _imageView.frame = CGRectMake(0, 0, W, H);
    _imageView.superview.bounds = _imageView.bounds;
}

- (void)resetZoomScaleWithAnimate:(BOOL)animated
{
    CGFloat Rw = _scrollView.frame.size.width / _imageView.frame.size.width;
    CGFloat Rh = _scrollView.frame.size.height / _imageView.frame.size.height;
    
    //CGFloat scale = [[UIScreen mainScreen] scale];
    CGFloat scale = 1;
    Rw = MAX(Rw, _imageView.image.size.width / (scale * _scrollView.frame.size.width));
    Rh = MAX(Rh, _imageView.image.size.height / (scale * _scrollView.frame.size.height));
    
    _scrollView.contentSize = _imageView.frame.size;
    _scrollView.minimumZoomScale = 1;
    _scrollView.maximumZoomScale = MAX(MAX(Rw, Rh), 1);
    
    [_scrollView setZoomScale:_scrollView.minimumZoomScale animated:animated];
    [self scrollViewDidZoom:_scrollView];
}

- (void)refreshImageView
{
    [self resetImageViewFrame];
    [self resetZoomScaleWithAnimate:NO];
}

@end
