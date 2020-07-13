//
//  KSSideslipCellAction.m
//  LYSideslipCellDemo
//
//  Created by edz on 2020/7/13.
//  Copyright © 2020 Louis. All rights reserved.
//

#import "KSSideslipCellAction.h"

 

 
@implementation KSSideslipCellAction

+ (instancetype)rowActionWithStyle:(KSSideslipCellActionStyle)style
                             title:(NSString *)title
                           handler:(void (^)(KSSideslipCellAction *action, NSIndexPath *indexPath))handler {
    
    KSSideslipCellAction *action = [KSSideslipCellAction new];
    action.title = title;
    action.handler = handler;
    action.style = style;
    action.fontSize = 17;
    
    action.titleColor = [UIColor whiteColor];
    
    switch (style) {
        case KSSideslipCellActionStyleDefault: {
            action.backgroundColor = [UIColor redColor];
        }  break;
            
        case KSSideslipCellActionStyleNormal:  {
            action.backgroundColor = [UIColor colorWithRed:200/255.0 green:199/255.0 blue:205/255.0 alpha:1];
        } break;
            
        default:
            break;
    }
    
    return action;
}

- (CGFloat)margin {
    return _margin == 0 ? 15 : _margin;
}


-(CGFloat)actonViewWidth;{
    CGFloat width = [self.title boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT)
                                             options:NSStringDrawingUsesLineFragmentOrigin
                                          attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:self.fontSize]}
                                             context:nil].size.width;
    
    width += (self.image ? self.image.size.width : 0);
    width += self.margin*2;
    return width;
}

@end
