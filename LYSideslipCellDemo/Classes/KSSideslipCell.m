//
//  KSSideslipCell.m
//  KSSideslipCellDemo
//
//  Created by Kirito_Song on 2019/4/9.
//  Copyright © 2019年 infoq. All rights reserved.
//

#import "KSSideslipCell.h"
#import "KSSideslipCellProxy.h"
#import "UITableView+KSSideslipCell.h"
#import "KSSideslipCellAction.h"
#import "KSSideslipContainerView.h"
#import "KSSideslipConfirmActionView.h"

CGFloat KS_getX(UIView *v){
    return v.frame.origin.x;
};

CGFloat KS_getW(UIView *v){
    return v.frame.size.width;
};

void KS_setX(UIView *v,CGFloat x){
    CGRect frame = v.frame;
    frame.origin.x = x;
    v.frame = frame;
};

void KS_setW(UIView *v,CGFloat w){
    CGRect frame = v.frame;
    frame.size.width = w;
    v.frame = frame;
};


 

 







 

@implementation KSSideslipCell

#pragma mark - Life Cycle
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setupSideslipCell];
    }
    return self;
}


- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self setupSideslipCell];
    }
    return self;
}

- (void)dealloc {
    [self.contentView removeObserver:self forKeyPath:@"frame"];
}

- (void)setupSideslipCell {
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(contentViewPan:)];
    panGesture.delegate = self;
    [self.contentView addGestureRecognizer:panGesture];
    self.contentView.backgroundColor = [UIColor whiteColor];
    
    [self.contentView addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionNew context:nil];
}

/***
 关于Bug1 的说明
 bug位置在下方#waring Bug1
 
 这里，存在一个我没能解决的bug。如果不通过监听self.contentView.frame的方式让btnContainView进行跟随。
 而是在手势中，与self.contentView.frame同步进行修改，会导致系统
 [UITableViewCellLayoutManager layoutSubviewsOfCell:]
 将self.contentView的x修改为0。你可以在kvo中当x被修改为0尝试打印堆栈
 
 
 如果有您有了新的进展，还望不吝赐教
 
 */

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context  {
    if ([keyPath isEqualToString:@"frame"]) {
        
        if (self.btnContainView) {
            KS_setX(self.btnContainView, self.contentView.frame.size.width + self.contentView.frame.origin.x);
        }
    }
}


- (void)layoutSubviews {
    CGFloat x = 0;
    if (_sideslip) x = self.contentView.frame.origin.x;

    [super layoutSubviews];
    
    // 侧滑状态旋转屏幕时, 保持侧滑
    if (_sideslip) KS_setX(self.contentView, x);
    KS_setW(self.contentView, KS_getW(self));
}



- (void)prepareForReuse {
    [super prepareForReuse];
    if (_sideslip) [self hiddenSideslipNoAnimation];
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        if ([gestureRecognizer.view.superview isKindOfClass:[KSSideslipCell class]]) {
            KSSideslipCell * cell = (KSSideslipCell *)gestureRecognizer.view.superview;
            //如果当前的cell，不是已经展示的cell
            if (!cell.sideslip) {
                [self hiddenAllSideslip];
            }else {
                //否则只是二次滑动而已
                return YES;
            }
        }
        
        UIPanGestureRecognizer *gesture = (UIPanGestureRecognizer *)gestureRecognizer;
        CGPoint translation = [gesture translationInView:gesture.view];
        
        // 如果手势相对于水平方向的角度大于45°, 则不触发侧滑
        BOOL shouldBegin = fabs(translation.y) <= fabs(translation.x);
        if (!shouldBegin) return NO;
        
        // 询问代理是否需要侧滑
        if ([_delegate respondsToSelector:@selector(sideslipCell:canSideslipActionAtIndexPath:)]) {
            shouldBegin = [_delegate sideslipCell:self canSideslipActionAtIndexPath:self.indexPath] || _sideslip;
        }
        
        if (shouldBegin) {
            // 向代理获取侧滑展示内容数组
            if ([_delegate respondsToSelector:@selector(sideslipCell:editActionsForRowAtIndexPath:)]) {
                
                NSArray <KSSideslipCellAction*> *actions = [_delegate sideslipCell:self editActionsForRowAtIndexPath:self.indexPath];
                if (!actions || actions.count == 0) return NO;
                [self setActions:actions];
            } else {
                return NO;
            }
        }
        return shouldBegin;
    }
    return NO;
}

#pragma mark - Response Events

- (void)contentViewPan:(UIPanGestureRecognizer *)pan {

    CGPoint point = [pan translationInView:pan.view];
    UIGestureRecognizerState state = pan.state;
    [pan setTranslation:CGPointZero inView:pan.view];
    
    if (self.confirmActionView) {
        [self.confirmActionView removeFromSuperview];
        self.confirmActionView = nil;
        //这里防止有手贱党，在0.2s动画执行完之前又开始滑动
        [_btnContainView.subButtons setValue:@(NO) forKeyPath:@"hidden"];
    }
    
    if (state == UIGestureRecognizerStateChanged) {
        CGRect frame = self.contentView.frame;
        CGRect cframe = self.btnContainView.frame;

        if (frame.origin.x + point.x <= -(self.btnContainView.totalWidth)) {
            //超过最大距离，加阻尼
            CGFloat hindrance = (point.x/5);
            if (frame.origin.x + hindrance <= -(self.btnContainView.totalWidth)) {
                frame.origin.x += hindrance;
                cframe.size.width += -hindrance;
                cframe.origin.x += hindrance;
            }else {
                //这里修复了一个当滑动过快时，导致最初减速时闪动的bug
                frame.origin.x = - self.btnContainView.totalWidth;
                cframe.origin.x = self.contentView.frame.size.width - self.btnContainView.totalWidth;
            }
        }else {
            //未到最大距离，正常拖拽
            frame.origin.x += point.x;
            cframe.origin.x += point.x;
        }
        
        //不允许右滑--原版这里右滑的话有一个回弹小动画，但我感觉浪费用户时间，并且微信也没有。
        if (frame.origin.x > 0) {
            frame.origin.x = 0;
        }
        self.contentView.frame = frame;
        
#warning Bug1: 详见上方Bug1的说明
//        self.btnContainView.frame = cframe;
        [self.btnContainView scaleToWidth:-frame.origin.x];
        
    } else if (state == UIGestureRecognizerStateEnded) {
        CGPoint velocity = [pan velocityInView:pan.view];
        if (self.contentView.frame.origin.x == 0) {
            self.state = KSSideslipCellStateNormal;
            return;
        } else if (self.contentView.frame.origin.x > 5) {
            [self hiddenWithBounceAnimation];
        } else if (fabs(self.contentView.frame.origin.x) >= 40 && velocity.x <= 0) {
            [self showSideslip];
        } else {
            [self hiddenSideslip];
        }
        
    } else if (state == UIGestureRecognizerStateCancelled) {
        [self hiddenAllSideslip];
    }
}



- (void)actionBtnDidClicked:(UIButton *)btn {
    if (self.confirmActionView) {
        [self.confirmActionView removeFromSuperview];
        self.confirmActionView = nil;
    }
    
    if ([self.delegate respondsToSelector:@selector(sideslipCell:confirmActionAtIndexPath:forAction:)]) {
        
        if (self.actions.count > 0) {
            KSSideslipCellAction *forAction = self.actions[btn.tag];
            KSSideslipCellAction *confirmAction= [self.delegate sideslipCell:self confirmActionAtIndexPath:self.indexPath forAction:forAction];
            
            if(confirmAction){
                CGFloat confirmActionViewWidth = [confirmAction actonViewWidth];
                CGFloat confirmActionViewHeight = self.contentView.frame.size.height;
                
                KSSideslipConfirmActionView *confirmActionView = [[KSSideslipConfirmActionView alloc] init];
                confirmActionView.action = confirmAction;
                confirmActionView.targetCell = self;
                confirmActionView.frame = CGRectMake(0, 0, confirmActionViewWidth, confirmActionViewHeight);
                
                self.confirmActionView = confirmActionView ;
               [_btnContainView addSubview:self.confirmActionView];
                
               CGRect frame = CGRectMake(0, 0, self.confirmActionView.frame.size.width, self.contentView.frame.size.height);
   
               self.confirmActionView.frame = CGRectMake(self.btnContainView.originSubViews.lastObject.frame.origin.x,
                                                0,
                                                self.confirmActionView.frame.size.width,
                                                self.contentView.frame.size.height);
              self.confirmActionView.hidden = YES;
   
               [UIView animateWithDuration:0.7 delay:0 usingSpringWithDamping:0.7 initialSpringVelocity:1 options:UIViewAnimationOptionCurveEaseInOut|UIViewAnimationOptionAllowUserInteraction animations:^{
                   self.confirmActionView.frame = frame;
                   _btnContainView.frame = frame;
                   self.confirmActionView.hidden = NO;
                   [_btnContainView.subButtons setValue:@(YES) forKeyPath:@"hidden"];
                   KS_setX(self.contentView, -KS_getW(self.confirmActionView));
                   [self.btnContainView scaleToWidth:self.confirmActionView.frame.size.width];
               } completion:^(BOOL finished) {
                   [_btnContainView.subButtons setValue:@(NO) forKeyPath:@"hidden"];
               }];
                
            }
            
        }
    }
    
    
    if (btn.tag < _actions.count) {
        KSSideslipCellAction *action = _actions[btn.tag];
        if (self.confirmActionView == nil) { // 如果有确认 只执行确认按钮
            if (action.handler) {
                action.handler(action, self.indexPath);
            }
        }
        
    }
    [self hiddenOtherSideslip];
}

- (void)confirmActionBtnClick:(UIButton *)btn{
    if (self.confirmActionView && self.confirmActionView.action.handler) {
        self.confirmActionView.action.handler(self.confirmActionView.action, self.indexPath);
    }
}



#pragma mark - Methods
- (void)hiddenWithBounceAnimation {
    self.state = KSSideslipCellStateAnimating;
    [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        KS_setX(self.contentView, -10);
    } completion:^(BOOL finished) {
        [self hiddenSideslip];
    }];
}

- (void)hiddenOtherSideslip {
    [self.tableView hiddenOtherSideslip:self];
}


- (void)hiddenAllSideslip {
    [self.tableView hiddenAllSideslip];
}

- (void)hiddenSideslip {
    if (self.contentView.frame.origin.x == 0) return;
    self.sideslip = NO;
    self.state = KSSideslipCellStateAnimating;
    
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        KS_setX(self.contentView, 0);
    } completion:^(BOOL finished) {
        [_btnContainView removeFromSuperview];
        _btnContainView = nil;
        self.state = KSSideslipCellStateNormal;
    }];
}

- (void)hiddenSideslipNoAnimation {
    if (self.contentView.frame.origin.x == 0) return;
    self.sideslip = NO;
    self.state = KSSideslipCellStateAnimating;
    KS_setX(self.contentView, 0);
    [_btnContainView removeFromSuperview];
    _btnContainView = nil;
    self.state = KSSideslipCellStateNormal;
}

- (void)showSideslip {
    //尝试添加拦截器
    [self tryBindProxy];
    
    //修改cell以及tableView为侧滑按钮展示状态
    self.sideslip = YES;
    self.tableView.sideslip = YES;
    self.state = KSSideslipCellStateAnimating;
    
    [UIView animateWithDuration:0.7 delay:0 usingSpringWithDamping:0.7 initialSpringVelocity:1 options:UIViewAnimationOptionCurveEaseInOut|UIViewAnimationOptionAllowUserInteraction animations:^{
        KS_setX(self.contentView, -self.btnContainView.totalWidth);
        [self.btnContainView restoration];
    } completion:^(BOOL finished) {
        self.state = KSSideslipCellStateOpen;
    }];
}

//尝试绑定proxy进行滚动的代理拦截
- (void)tryBindProxy {
    UITableView * tableView = [self tableView];
    if ([tableView isKindOfClass:[UITableView class]]) {
        if (![tableView.delegate isKindOfClass:[KSSideslipCellProxy class]]) {
            
            //保证一个tableView只会设置一次proxy
            KSSideslipCellProxy *proxy = [KSSideslipCellProxy alloc];
            proxy.target = tableView; //这里。proxy的target是weak属性，并不会造成循环引用
        }
    }
}


#pragma mark - Setter

- (void)setState:(KSSideslipCellState)state {
    _state = state;
    
    switch (state) {
        case KSSideslipCellStateNormal:
        {
            //这里可以防止循环引用VC，前提cell已经恢复默认状态。
            _actions = nil;
        }
            break;
            
        default:
            break;
    }
}


- (void)setActions:(NSArray <KSSideslipCellAction *>*)actions {
    _actions = actions;
    
    if (_btnContainView) {
        [_btnContainView removeFromSuperview];
        _btnContainView = nil;
    }
    
    _btnContainView = [[KSSideslipContainerView alloc]initWithActions:actions];
    _btnContainView.frame = CGRectMake(self.contentView.frame.size.width, 0, _btnContainView.frame.size.width, self.contentView.frame.size.height);
    _btnContainView.targetCell = self;
    [self insertSubview:_btnContainView belowSubview:self.contentView];
}

#pragma mark - Getter
- (UITableView *)tableView {
    id view = self.superview;
    while (view && [view isKindOfClass:[UITableView class]] == NO) {
        view = [view superview];
    }
    if ([view isKindOfClass:[UITableView class]]) {
        return view;
    }
    else {
        return nil;
    }
}

- (NSIndexPath *)indexPath {
    return [self.tableView indexPathForCell:self];
}

@end



