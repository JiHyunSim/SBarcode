//
//  SBarcodeView.m
//  SBarcode
//
//  Created by INFINAXIS on 2017. 2. 27..
//  Copyright © 2017년 Jihyun Sim. All rights reserved.
//


/*********************************************************************
 
 CODABAR ENCODING TABLE (http://www.barcodeisland.com/codabar.phtml)
 
 0 => space
 1 => bar
 
 -------------------------------------------------------
 |  ASCII           |   WIDTH      |   BARCODE         |
 |  CHARACTER       |   ENCODING   |   ENCODING        |
 -------------------------------------------------------
 |  0               |   0000011    |   101010011       |
 |  1               |   0000110    |   101011001       |
 |  2               |   0001001    |   101001011       |
 |  3               |   1100000    |   110010101       |
 |  4               |   0010010    |   101101001       |
 |  5               |   1000010    |   110101001       |
 |  6               |   0100001    |   100101011       |
 |  7               |   0100100    |   100101101       |
 |  8               |   0110000    |   100110101       |
 |  9               |   1001000    |   110100101       |
 |  - (Dash)        |   0001100    |   101001101       |
 |  $               |   0011000    |   101100101       |
 |  : (Colon)       |   1000101    |   1101011011      |
 |  / (Slash)       |   1010001    |   1101101011      |
 |  . (Point)       |   1010100    |   1101101101      |
 |  + (Plus)        |   0011111    |   101100110011    |
 |  Start/Stop A    |   0011010    |   1011001001      |
 |  Start/Stop B    |	0001011    |   1010010011      |
 |  Start/Stop C    |   0101001    |   1001001011      |
 |  Start/Stop D    |	0001110    |   1010011001      |
 -------------------------------------------------------
 
 *********************************************************************/


#import "SBarcodeView.h"

@interface SBarcodeView()

@property (nonatomic,strong)NSDictionary* barcodeEndcoding;

@end

@implementation SBarcodeView


-(NSDictionary*)barcodeEndcoding
{
    if (_barcodeEndcoding==nil) {
        
        _barcodeEndcoding = @{@"0": @"101010011",
                              @"1": @"101011001",
                              @"2": @"101001011",
                              @"3": @"110010101",
                              @"4": @"101101001",
                              @"5": @"110101001",
                              @"6": @"100101011",
                              @"7": @"100101101",
                              @"8": @"100110101",
                              @"9": @"110100101",
                              @"-": @"101001101",
                              @"$": @"101100101",
                              @":": @"1101011011",
                              @"/": @"1101101011",
                              @".": @"1101101101",
                              @"+": @"101100110011",
                              @"A": @"1011001001",
                              @"B": @"1010010011",
                              @"C": @"1001001011",
                              @"D": @"1010011001"};
    }
    
    return _barcodeEndcoding;
}

-(void)setCode:(NSString *)code
{
    if (![_code isEqualToString:code]) {

        if(code==nil||code.length==0)code=@"";
        _code = [code copy];
        [self setNeedsLayout];

    }
}

-(void)setBarColor:(UIColor *)barColor
{
    if (![_barColor isEqual:barColor]) {
        _barColor = [barColor copy];
        [self setNeedsLayout];
    }
}

-(void)setTextColor:(UIColor *)textColor
{
    if (![_textColor isEqual:textColor]) {
        _textColor = [textColor copy];
        [self setNeedsLayout];
    }
}

-(void)setTextFont:(UIFont *)textFont
{
    if (![_textFont isEqual:textFont]) {
        _textFont = [textFont copy];
        [self setNeedsLayout];
    }
}

-(void)setPadding:(CGFloat)padding
{
    if (_padding!=padding) {
        _padding=padding;
        [self setNeedsLayout];
    }
}

-(void)setHideCode:(BOOL)hideCode
{
    if (_hideCode!=hideCode) {
        _hideCode=hideCode;
        [self setNeedsLayout];
    }
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code

    NSMutableParagraphStyle* style = [[NSMutableParagraphStyle alloc] init];
    [style setAlignment:NSTextAlignmentCenter];
    
    NSDictionary* attributes=@{NSFontAttributeName: self.textFont,
                               NSForegroundColorAttributeName: self.textColor,
                               NSParagraphStyleAttributeName: style};
    
    if (![self isValidCode]) {
        
        NSString* text=@"Invalid Code";
        CGRect sizeLabel = [text boundingRectWithSize:CGSizeMake(self.frame.size.width, CGFLOAT_MAX)
                                         options:NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesLineFragmentOrigin
                                      attributes:@{NSFontAttributeName:self.textFont} context:nil];
        
        
        [text drawAtPoint:CGPointMake(self.frame.size.width/2-sizeLabel.size.width/2, self.frame.size.height/2-sizeLabel.size.height/2) withAttributes:attributes];
        return;
    }
    
    [self.barColor setFill];
    
    CGFloat multiplier =  1.25f;
    CGRect sizeLabel = [self.code boundingRectWithSize:CGSizeMake(self.frame.size.width, CGFLOAT_MAX)
                                          options:NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesLineFragmentOrigin
                                       attributes:@{NSFontAttributeName:self.textFont} context:nil];
    
    CGFloat labelHeight = ceil(sizeLabel.size.height);
    
    
    CGFloat barHeight = self.frame.size.height- (self.hideCode ? 0:labelHeight+self.padding);
    NSString* sequence = [self barcodeSequence];
    
    int narrow,wide=0;
    
    for (uint i=0; i<sequence.length; i++) {
        
        unichar ch = [sequence characterAtIndex:i];
        
        if (ch=='0') {
            narrow+=1;
        }else
        {
            if (i<sequence.length-1) {
                if ([sequence characterAtIndex:i+1]=='1') {
                    wide+=1;
                }else
                {
                    narrow+=1;
                }
            }else
            {
                narrow+=1;
            }
        }
        
    }
    
    CGFloat barWidth=self.frame.size.width/(narrow+multiplier*wide);
    
    CGFloat x=0.0;
    
    for (uint i=0; i<sequence.length; i++) {
        unichar ch = [sequence characterAtIndex:i];
        if (ch=='0') {
            x+=barWidth;
        }else
        {
            CGFloat customBarWidth = barWidth;
            if (i <sequence.length-1) {
                if ([sequence characterAtIndex:i+1]=='1') {
                    customBarWidth*=multiplier;
                }
            }
            
            UIRectFill(CGRectMake(x,0, customBarWidth, barHeight));
            x+=customBarWidth;
        }
    }
    
    if (!self.hideCode) {
        [self.code drawInRect:CGRectMake(0, barHeight+self.padding, x, labelHeight) withAttributes:attributes];
    }
    
    
}



-(instancetype)initWithFrame:(CGRect)frame
{
    if (self=[super initWithFrame:frame]) {
        
        [self commonInit];
        
    }
    return self;
}

-(instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self=[super initWithCoder:aDecoder]) {
        [self commonInit];
        
    }
    
    return self;
}

-(void)commonInit
{
    self.textFont = [UIFont fontWithName:@"HelveticaNeue-Medium" size:15.0f];
    self.barColor = [UIColor blackColor];
    self.textColor = [UIColor blackColor];
    self.padding = 2.0f;
    self.hideCode = NO;
    [self setNeedsLayout];
}

-(void)prepareForInterfaceBuilder
{
    [self commonInit];
}

-(NSString*)barcodeSequence
{
    NSMutableString* seq=[NSMutableString string];
    
    
    for (NSUInteger i =0 ; i < self.code.length; i++) {
        unichar ch= [self.code characterAtIndex:i];
        NSString* key=[NSString stringWithCharacters:&ch length:1];
        [seq appendString:self.barcodeEndcoding[key]];
        if (i<self.code.length-1) {
            [seq appendString:@"0"];
        }
        
    }
    
    return seq;
}

-(BOOL)isValidCode
{
    if(self.code.length < 3 && self.code.length > 16 ) return NO;
    unichar schar = [[[self.code substringWithRange:NSMakeRange(0, 1)] uppercaseString] characterAtIndex:0];
    unichar echar = [[[self.code substringWithRange:NSMakeRange(self.code.length-1, 1)] uppercaseString] characterAtIndex:0];
    NSString* mstring = [self.code substringWithRange:NSMakeRange(1, self.code.length-2)];
    
    BOOL isValidStart = schar >= 'A' && schar <= 'D';
    BOOL isValidEnd = echar >='A' && echar <='D';
    BOOL isValidMiddle = YES;
    
    for (uint i =0 ; i< mstring.length ;i++) {
        unichar ch = [mstring characterAtIndex:i];
        if (![self.barcodeEndcoding objectForKey:[NSString stringWithCharacters:&ch length:1]]) {
            isValidMiddle = NO;
            break;
        }
    }
    
    return isValidStart && isValidEnd && isValidMiddle;
}

@end


















