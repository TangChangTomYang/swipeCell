//
//  KSSideslipConfirmActionView.m
//  LYSideslipCellDemo
//
//  Created by edz on 2020/7/13.
//  Copyright © 2020 Louis. All rights reserved.
//

#import "KSSideslipConfirmActionView.h"

@interface KSSideslipConfirmActionView ()
@property (nonatomic, strong) UIButton *btn;
@end
 

@implementation KSSideslipConfirmActionView


- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.btn];
    }
    return self;
}
 

-(UIButton *)btn{
    if (!_btn) {
        _btn = [[UIButton alloc] init];
    }
    return _btn;
}

-(void)setAction:(KSSideslipCellAction *)action{
    _action = action;
    if (action.title ) {
        [self.btn setTitle:action.title forState:UIControlStateNormal];
    }
    
    if (action.image) {
        [self.btn setImage:action.image forState:UIControlStateNormal];
    }
    
    if (action.fontSize > 0) {
        self.btn.titleLabel.font = [UIFont systemFontOfSize:action.fontSize];
    }
    
    if (action.backgroundColor) {
        self.backgroundColor = action.backgroundColor;
    }
    
    if (action.titleColor) {
        [self.btn setTitleColor:action.titleColor forState:UIControlStateNormal];
    }
}

-(void)setTargetCell:(id)targetCell{
    _targetCell = targetCell;
    if(self.btn.allTargets.count > 0){
       [self.btn removeTarget:targetCell action:@selector(confirmActionBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    if (targetCell) {
        [self.btn addTarget:targetCell action:@selector(confirmActionBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
}

-(void)layoutSubviews{
    [super layoutSubviews];
    self.btn.frame = self.bounds;
}

@end
