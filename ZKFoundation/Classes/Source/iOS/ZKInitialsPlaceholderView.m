//
//  ZKInitialsPlaceholderView.m
//  ZKFoundation
//
//  Created by Kaiser on 2019/4/15.
//

#import "ZKInitialsPlaceholderView.h"

@interface ZKInitialsPlaceholderView ()

@property (strong) UIImage *cachedVisualRepresentation;

- (instancetype)initWithFrame:(CGRect)frame NS_DESIGNATED_INITIALIZER;
- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder NS_DESIGNATED_INITIALIZER;

@end

@implementation ZKInitialsPlaceholderView

@synthesize initials    = _initials;
@synthesize textColor   = _textColor;
@synthesize circleColor = _circleColor;
@synthesize font        = _font;

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self == nil) return nil;
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self == nil) return nil;
    
    return self;
}

- (instancetype)initWithDiameter:(CGFloat)diameter {
    self = [super initWithFrame:CGRectMake(0, 0, diameter, diameter)];
    if (self) {
        self.clipsToBounds          = YES;
        self.userInteractionEnabled = NO;
        self.backgroundColor        = [UIColor clearColor];

        _circleColor = [UIColor lightGrayColor];
        _font        = [UIFont boldSystemFontOfSize:16.0];
        _textColor   = [UIColor whiteColor];
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    if (self.cachedVisualRepresentation) {
        [self.cachedVisualRepresentation drawAtPoint:CGPointZero];
    }
}

#pragma mark - Truncate
- (NSString *)truncatedInitials:(NSString *)initials {
    if ([initials length] > 2) {
        initials = [initials substringToIndex:2];
    }
    return initials;
}

#pragma mark - Setters / Getters
- (void)setInitials:(NSString *)initialialsToDraw {
    initialialsToDraw = [self truncatedInitials:initialialsToDraw];
    if (_initials != initialialsToDraw) {
        _initials = initialialsToDraw;
        [self generateCachedVisualRepresentation];
    }
}

- (NSString *)initials {
    return _initials;
}

- (void)setTextColor:(UIColor *)textColor {
    if (_textColor != textColor) {
        _textColor = textColor;
        [self generateCachedVisualRepresentation];
    }
}

- (UIColor *)textColor {
    return _textColor ? _textColor : [UIColor whiteColor];
}

- (void)setCircleColor:(UIColor *)circleColor {
    if (_circleColor != circleColor) {
        _circleColor = circleColor;
        [self generateCachedVisualRepresentation];
    }
}

- (UIColor *)circleColor {
    return _circleColor ? _circleColor : [UIColor lightGrayColor];
}

- (void)setFont:(UIFont *)font {
    if (_font != font) {
        _font = font;
        [self generateCachedVisualRepresentation];
    }
}

- (UIFont *)font {
    return _font ? _font : [UIFont boldSystemFontOfSize:16.0];
}

- (void)batchUpdateViewWithInitials:(NSString *)initials circleColor:(UIColor *)circleColor textColor:(UIColor *)textColor font:(UIFont *)font {
    //Saves up to 3 wasted draws by not calling our custom setters
    _circleColor = (circleColor != nil ? circleColor : _circleColor);
    _textColor   = (textColor != nil ? textColor : _textColor);
    _font        = (font != nil ? font : _font);
    _initials    = [self truncatedInitials:initials];

    //Finally make a draw call
    [self generateCachedVisualRepresentation];
}

- (void)generateCachedVisualRepresentation {
    if (CGSizeEqualToSize(self.bounds.size, CGSizeZero)) {
        return;
    }
    _cachedVisualRepresentation = nil;

    NSString *fontNameToUse = self.font.fontName;

    UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, [UIScreen mainScreen].scale);

    //Create background circle and add it as a clipping mask.
    UIBezierPath *circleClip = [UIBezierPath bezierPathWithOvalInRect:self.bounds];
    [circleClip addClip];
    UIRectClip(self.bounds);

    [self.circleColor setFill];
    UIRectFill(self.bounds);

    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.alignment                = NSTextAlignmentCenter;

    //Pythagoras!
    //Find the height/width of the largest enscribed square
    CGFloat inscribedSquareHeightWidth = sqrt(pow(self.bounds.size.width, 2.0) / 2);

    //Set default font size so we can work out way down to the right size
    CGFloat fontSize    = self.frame.size.height;
    CGSize boundingSize = CGSizeZero;
    while (fontSize != 0.0) {
        boundingSize = [self.initials boundingRectWithSize:CGSizeMake(inscribedSquareHeightWidth, inscribedSquareHeightWidth) options:0 attributes:@{ NSFontAttributeName: [UIFont fontWithName:fontNameToUse size:fontSize] } context:nil].size;

        //if the bounding size of our text with the given font is inside the enscribed rectangle, return, we have our info.
        if (boundingSize.height <= inscribedSquareHeightWidth && boundingSize.width <= inscribedSquareHeightWidth) break;

        fontSize -= 1.0;
    }

    //setup sizing information for rectangle and centering text
    CGFloat squareOrigin   = (self.bounds.size.width / 2) - (inscribedSquareHeightWidth / 2);
    CGRect enscribedSquare = CGRectMake(squareOrigin, squareOrigin, inscribedSquareHeightWidth, inscribedSquareHeightWidth);

    CGPoint drawingPoint = CGPointMake(enscribedSquare.origin.x + (enscribedSquare.size.width / 2 - boundingSize.width / 2), enscribedSquare.origin.y + (enscribedSquare.size.height / 2 - boundingSize.height / 2));
    [self.initials drawAtPoint:drawingPoint
                withAttributes:@{NSFontAttributeName: [UIFont fontWithName:fontNameToUse size:fontSize],
                                 NSForegroundColorAttributeName: self.textColor,
                                 NSParagraphStyleAttributeName: style}];

    UIImage *outImage = UIGraphicsGetImageFromCurrentImageContext();
    // recyle graphics context, with out this line memory will leak
    UIGraphicsEndImageContext();

    _cachedVisualRepresentation = outImage;
    [self setNeedsDisplay];
}

@end
