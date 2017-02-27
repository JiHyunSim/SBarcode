//
//  SBarcodeView.h
//  SBarcode
//
//  Created by INFINAXIS on 2017. 2. 27..
//  Copyright © 2017년 Jihyun Sim. All rights reserved.
//

#import <UIKit/UIKit.h>

IB_DESIGNABLE

@interface SBarcodeView : UIView

@property(nonatomic,strong)IBInspectable NSString* code;
@property(nonatomic,strong)IBInspectable UIColor* barColor;
@property(nonatomic,strong)IBInspectable UIColor* textColor;
@property(nonatomic)IBInspectable CGFloat padding;
@property(nonatomic)IBInspectable BOOL hideCode;
@property(nonatomic,strong)IBInspectable UIFont* textFont;


@end
