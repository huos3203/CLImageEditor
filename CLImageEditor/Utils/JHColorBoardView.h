//
//  JHColorBoardView.h
//  CLImageEditorDemo
//
//  Created by admin on 2019/6/14.
//  Copyright © 2019 CALACULU. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
    JHImage_Draw,
    JHImage_Text,
} JHImageEditorType;

@interface JHColorCellModel : NSObject
@property (strong, nonatomic) UIColor *color;
@end


@interface JHColorCell : UICollectionViewCell
@property (strong, nonatomic) JHColorCellModel *model;
@end


@interface JHColorBoardView : UIView

-(instancetype)initWithFrame:(CGRect)frame for:(JHImageEditorType)type colorHandler:(void(^)(UIColor *))handler;

@end

NS_ASSUME_NONNULL_END
