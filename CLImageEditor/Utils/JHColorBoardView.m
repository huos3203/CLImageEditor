//
//  JHColorBoardView.m
//  CLImageEditorDemo
//
//  Created by admin on 2019/6/14.
//  Copyright © 2019 CALACULU. All rights reserved.
//

#import "JHColorBoardView.h"

@implementation JHColorCellModel

@end


@interface JHColorCell()
@property (strong, nonatomic) UIView *colorView;
@end

@implementation JHColorCell

-(instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self.contentView addSubview:self.colorView];
    }
    return self;
}

-(void)setModel:(JHColorCellModel *)model
{
    _model = model;
    _colorView.backgroundColor = model.color;
}

-(UIView *)colorView
{
    if(!_colorView){
        _colorView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 17, 17)];
        _colorView.backgroundColor = _model.color;
        _colorView.layer.borderWidth = 0;
        _colorView.layer.borderColor = [UIColor whiteColor].CGColor;
        _colorView.layer.masksToBounds = YES;
        [self drawBoardColorView:NO];
    }
    return _colorView;
}

-(void)drawBoardColorView:(BOOL)isSelectd
{
    if (isSelectd) {
        _colorView.frame = CGRectMake(0, 0, 20, 20);
        _colorView.layer.borderWidth = 2;
        _colorView.layer.cornerRadius = _colorView.frame.size.width/2;
    }else{
        _colorView.frame = CGRectMake(0, 0, 17, 17);
        _colorView.layer.borderWidth = 0;
        _colorView.layer.cornerRadius = _colorView.frame.size.width/2;
    }
}

-(void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    [self drawBoardColorView:selected];
}

@end


@interface JHColorBoardView()<UICollectionViewDelegate,UICollectionViewDataSource>
@property (strong, nonatomic) UICollectionView *collectionView;
@property (strong, nonatomic) NSMutableArray *dataArray;
@property (strong, nonatomic) NSArray *colorArray;
@end

@implementation JHColorBoardView
{
    void(^ColorHandler)(UIColor *);
    JHImageEditorType _toolType;
}

-(instancetype)initWithFrame:(CGRect)frame for:(JHImageEditorType)type colorHandler:(void(^)(UIColor *))handler;
{
    self = [super initWithFrame:frame];
    ColorHandler = handler;
    _toolType = type;
    self.collectionView.frame = CGRectMake(10, frame.origin.y, frame.size.width, frame.size.height);
    [self addSubview:self.collectionView];
    //设置默认选中色
    [self performSelector:@selector(delayReloadView) withObject:self afterDelay:.2];
    return self;
}

-(void)delayReloadView
{
    int row = 0;
    if (_toolType == JHImage_Draw) row = 4;
    if (_toolType == JHImage_Text) row = 1;
    JHColorCellModel *model = self.dataArray[row];
    if(ColorHandler) ColorHandler(model.color);
    [self.collectionView selectItemAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0] animated:NO scrollPosition:UICollectionViewScrollPositionNone];
}


#pragma mark - collectionView 代理
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.dataArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    JHColorCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"JHColorCell" forIndexPath:indexPath];
    cell.model = self.dataArray[indexPath.row];
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    JHColorCellModel *model = self.dataArray[indexPath.row];
    if(ColorHandler) ColorHandler(model.color);
}

#pragma mark - getter
-(UICollectionView *)collectionView
{
    if(!_collectionView){
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        CGFloat space = ([UIScreen mainScreen].bounds.size.width - 20)/6;
        layout.estimatedItemSize = CGSizeMake(space, 40);
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.minimumInteritemSpacing = 30;
        layout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);    //item边距
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
//        _collectionView.backgroundColor = [UIColor whiteColor];
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.scrollEnabled = NO;
        [_collectionView registerClass:[JHColorCell class] forCellWithReuseIdentifier:@"JHColorCell"];
        //
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
    }
    return _collectionView;
}

-(NSMutableArray *)dataArray
{
    if (!_dataArray) {
        _dataArray = [NSMutableArray new];
        for (int i = 0; i < self.colorArray.count; i++) {
            JHColorCellModel *model = [JHColorCellModel new];
            model.color = self.colorArray[i];
            [_dataArray addObject:model];
        }
    }
    return _dataArray;
}

-(NSArray *)colorArray
{
    if(!_colorArray){
        _colorArray = [NSArray new];
        NSMutableArray *arr = [NSMutableArray new];
        [arr addObject:[UIColor colorWithRed:42/255.0 green:51/255.0 blue:82/255.0 alpha:1.0]];
        [arr addObject:[UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0]];
        [arr addObject:[UIColor colorWithRed:255/255.0 green:106/255.0 blue:52/255.0 alpha:1.0]];
        [arr addObject:[UIColor colorWithRed:44/255.0 green:215/255.0 blue:115/255.0 alpha:1.0]];
        [arr addObject:[UIColor colorWithRed:232/255.0 green:0/255.0 blue:55/255.0 alpha:1.0]];
        [arr addObject:[UIColor colorWithRed:66/255.0 green:139/255.0 blue:254/255.0 alpha:1.0]];
        _colorArray = [arr copy];
    }
    return _colorArray;
}

@end
