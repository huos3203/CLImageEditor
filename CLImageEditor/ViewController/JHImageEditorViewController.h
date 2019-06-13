//
//  JHImageEditorViewController.h
//  CLImageEditorDemo
//
//  Created by admin on 2019/6/13.
//  Copyright © 2019 CALACULU. All rights reserved.
//

#import "../CLImageEditor.h"

NS_ASSUME_NONNULL_BEGIN

@interface JHImageEditorViewController : CLImageEditor
<UIScrollViewDelegate, UIBarPositioningDelegate>
{
    IBOutlet __weak UINavigationBar *_navigationBar;
    IBOutlet __weak UIScrollView *_scrollView;
}
@property (nonatomic, strong) UIImageView  *imageView;
@property (nonatomic, weak) IBOutlet UIScrollView *menuView;
@property (nonatomic, readonly) UIScrollView *scrollView;

- (IBAction)pushedCloseBtn:(id)sender;
- (IBAction)pushedFinishBtn:(id)sender;


- (id)initWithImage:(UIImage*)image;


- (void)fixZoomScaleWithAnimated:(BOOL)animated;
- (void)resetZoomScaleWithAnimated:(BOOL)animated;

@end
NS_ASSUME_NONNULL_END

@interface JHMenuToolBar : UIToolbar

@end

