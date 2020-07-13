//
//  KSSlideslipDefine.h
//  LYSideslipCellDemo
//
//  Created by edz on 2020/7/13.
//  Copyright © 2020 Louis. All rights reserved.
//

#ifndef KSSlideslipDefine_h
#define KSSlideslipDefine_h

typedef NS_ENUM(NSInteger, KSSideslipCellActionStyle) {
    KSSideslipCellActionStyleDefault = 0,
    KSSideslipCellActionStyleDestructive = KSSideslipCellActionStyleDefault, // 删除 红底
    KSSideslipCellActionStyleNormal // 正常 灰底
};


typedef NS_ENUM(NSInteger, KSSideslipCellState) {
    KSSideslipCellStateNormal,
    KSSideslipCellStateAnimating,
    KSSideslipCellStateOpen
};





#endif /* KSSlideslipDefine_h */
