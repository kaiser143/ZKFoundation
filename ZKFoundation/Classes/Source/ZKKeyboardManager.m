//
//  ZKKeyboardManager.m
//  ZKFoundation
//
//  Created by zhangkai on 2024/9/9.
//

#import "ZKKeyboardManager.h"
#import <ZKCategories/ZKCategories.h>
#import "NSObject+ZKMultipleDelegates.h"

@class _KAIKeyboardViewFrameObserver;
@protocol KAIKeyboardViewFrameObserverDelegate <NSObject>
@required
- (void)keyboardViewFrameDidChange:(UIView *)keyboardView;
@end

@interface ZKKeyboardManager () <KAIKeyboardViewFrameObserverDelegate>

@property(nonatomic, strong) NSMutableArray <NSValue *> *targetResponderValues;

@property(nonatomic, strong) ZKKeyboardUserInfo *lastUserInfo;
@property(nonatomic, assign) CGRect keyboardMoveBeginRect;

@property(nonatomic, weak) UIResponder *currentResponder;
//@property(nonatomic, weak) UIResponder *currentResponderWhenResign;

@property(nonatomic, assign) BOOL debug;

@end


@interface UIView (KeyboardManager)

- (id)kai_findFirstResponder;

@end

@implementation UIView (KeyboardManager)

- (id)kai_findFirstResponder {
    if (self.isFirstResponder) {
        return self;
    }
    for (UIView *subView in self.subviews) {
        id responder = [subView kai_findFirstResponder];
        if (responder) return responder;
    }
    return nil;
}

@end


@interface UIResponder ()

/// 系统自己的isFirstResponder有延迟，这里手动记录UIResponder是否isFirstResponder，ZKKeyboardManager内部自己使用
@property(nonatomic, assign) BOOL keyboardManager_isFirstResponder;
@end


@implementation UIResponder (KeyboardManager)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        OverrideImplementation([UIResponder class], @selector(becomeFirstResponder), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^BOOL(UIResponder *selfObject) {
                selfObject.keyboardManager_isFirstResponder = YES;
                
                // call super
                BOOL (*originSelectorIMP)(id, SEL);
                originSelectorIMP = (BOOL (*)(id, SEL))originalIMPProvider();
                BOOL result = originSelectorIMP(selfObject, originCMD);
                
                return result;
            };
        });
        
        OverrideImplementation([UIResponder class], @selector(resignFirstResponder), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^BOOL(UIResponder *selfObject) {
                selfObject.keyboardManager_isFirstResponder = NO;
                //                if (selfObject.isFirstResponder &&
                //                    selfObject.kai_keyboardManager &&
                //                    [selfObject.kai_keyboardManager.allTargetResponders containsObject:selfObject]) {
                //                    selfObject.kai_keyboardManager.currentResponderWhenResign = selfObject;
                //                }
                // call super
                BOOL (*originSelectorIMP)(id, SEL);
                originSelectorIMP = (BOOL (*)(id, SEL))originalIMPProvider();
                BOOL result = originSelectorIMP(selfObject, originCMD);
                
                return result;
            };
        });
    });
}

#pragma mark - :. getters and setters

- (void)setKai_keyboardManager:(ZKKeyboardManager *)keyboardManager {
    [self setAssociateValue:keyboardManager withKey:@selector(kai_keyboardManager)];
}

- (ZKKeyboardManager *)kai_keyboardManager {
    return [self associatedValueForKey:_cmd];
}

- (void)setKeyboardManager_isFirstResponder:(BOOL)isFirstResponder {
    [self setAssociateValue:@(isFirstResponder) withKey:@selector(keyboardManager_isFirstResponder)];
}

- (BOOL)keyboardManager_isFirstResponder {
    return [[self associatedValueForKey:_cmd] boolValue];
}

@end


@interface _KAIKeyboardViewFrameObserver : NSObject

@property (nonatomic, weak) id <KAIKeyboardViewFrameObserverDelegate> delegate;
- (void)addToKeyboardView:(UIView *)keyboardView;
+ (instancetype)observerForView:(UIView *)keyboardView;

@end

static char kAssociatedObjectKey_KeyboardViewFrameObserver;

@implementation _KAIKeyboardViewFrameObserver {
    __unsafe_unretained UIView *_keyboardView;
}

- (void)addToKeyboardView:(UIView *)keyboardView {
    if (_keyboardView == keyboardView) {
        return;
    }
    if (_keyboardView) {
        [self removeFrameObserver];
        [_keyboardView setAssociateValue:nil withKey:&kAssociatedObjectKey_KeyboardViewFrameObserver];
    }
    _keyboardView = keyboardView;
    if (keyboardView) {
        [self addFrameObserver];
    }
    [keyboardView setAssociateValue:self withKey:&kAssociatedObjectKey_KeyboardViewFrameObserver];
}

- (void)addFrameObserver {
    if (!_keyboardView) {
        return;
    }
    [_keyboardView addObserver:self forKeyPath:@"frame" options:kNilOptions context:NULL];
    [_keyboardView addObserver:self forKeyPath:@"center" options:kNilOptions context:NULL];
    [_keyboardView addObserver:self forKeyPath:@"bounds" options:kNilOptions context:NULL];
    [_keyboardView addObserver:self forKeyPath:@"transform" options:kNilOptions context:NULL];
}

- (void)removeFrameObserver {
    [_keyboardView removeObserver:self forKeyPath:@"frame"];
    [_keyboardView removeObserver:self forKeyPath:@"center"];
    [_keyboardView removeObserver:self forKeyPath:@"bounds"];
    [_keyboardView removeObserver:self forKeyPath:@"transform"];
    _keyboardView = nil;
}

- (void)dealloc {
    [self removeFrameObserver];
}

+ (instancetype)observerForView:(UIView *)keyboardView {
    if (!keyboardView) {
        return nil;
    }
    return [keyboardView associatedValueForKey:&kAssociatedObjectKey_KeyboardViewFrameObserver];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (![keyPath isEqualToString:@"frame"] &&
        ![keyPath isEqualToString:@"center"] &&
        ![keyPath isEqualToString:@"bounds"] &&
        ![keyPath isEqualToString:@"transform"]) {
        return;
    }
    if ([[change objectForKey:NSKeyValueChangeNotificationIsPriorKey] boolValue]) {
        return;
    }
    if ([[change objectForKey:NSKeyValueChangeKindKey] integerValue] != NSKeyValueChangeSetting) {
        return;
    }
    id newValue = [change objectForKey:NSKeyValueChangeNewKey];
    if (newValue == [NSNull null]) { newValue = nil; }
    if (self.delegate) {
        [self.delegate keyboardViewFrameDidChange:_keyboardView];
    }
}

@end


@interface ZKKeyboardUserInfo ()

@property(nonatomic, weak, readwrite) ZKKeyboardManager *keyboardManager;
@property(nonatomic, strong, readwrite) NSNotification *notification;
@property(nonatomic, weak, readwrite) UIResponder *targetResponder;
@property(nonatomic, assign) BOOL isTargetResponderFocused;

@property(nonatomic, assign, readwrite) CGFloat width;
@property(nonatomic, assign, readwrite) CGFloat height;

@property(nonatomic, assign, readwrite) CGRect beginFrame;
@property(nonatomic, assign, readwrite) CGRect endFrame;

@property(nonatomic, assign, readwrite) NSTimeInterval animationDuration;
@property(nonatomic, assign, readwrite) UIViewAnimationCurve animationCurve;
@property(nonatomic, assign, readwrite) UIViewAnimationOptions animationOptions;

@property(nonatomic, assign, readwrite) BOOL isFloatingKeyboard;

@end

@implementation ZKKeyboardUserInfo

- (void)setNotification:(NSNotification *)notification {
    _notification = notification;
    if (self.originUserInfo) {
        
        _animationDuration = [[self.originUserInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
        
        _animationCurve = (UIViewAnimationCurve)[[self.originUserInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];
        
        _animationOptions = self.animationCurve<<16;
        
        CGRect beginFrame = [[self.originUserInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
        CGRect endFrame = [[self.originUserInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
        
        // iOS 13 分屏键盘 x 不是 0，不知道是系统 BUG 还是故意这样，先这样保护，再观察一下后面的 beta 版本
        BOOL condition = [UIDevice currentDevice].isPad && [UIApplication applicationSize].width != ZKScreenSize().width;
        if (condition && beginFrame.origin.x > 0) {
            beginFrame.origin.x = 0;
        }
        if (condition && endFrame.origin.x > 0) {
            endFrame.origin.x = 0;
        }
        
        _beginFrame = beginFrame;
        _endFrame = endFrame;
    }
}

- (void)setTargetResponder:(UIResponder *)targetResponder {
    _targetResponder = targetResponder;
    self.isTargetResponderFocused = targetResponder && targetResponder.keyboardManager_isFirstResponder;
}

- (NSDictionary *)originUserInfo {
    return self.notification ? self.notification.userInfo : nil;
}

- (CGFloat)width {
    CGRect keyboardRect = [ZKKeyboardManager convertKeyboardRect:_endFrame toView:nil];
    return keyboardRect.size.width;
}

- (CGFloat)height {
    CGRect keyboardRect = [ZKKeyboardManager convertKeyboardRect:_endFrame toView:nil];
    return keyboardRect.size.height;
}

- (CGFloat)heightInView:(UIView *)view {
    if (!view) {
        return [self height];
    }
    CGRect keyboardRect = [ZKKeyboardManager convertKeyboardRect:_endFrame toView:view];
    CGRect visibleRect = CGRectIntersection(CGRectPixelFloor(view.bounds), CGRectPixelFloor(keyboardRect));
    if (!CGRectIsValidated(visibleRect)) {
        return 0;
    }
    return visibleRect.size.height;
}

- (CGRect)beginFrame {
    return _beginFrame;
}

- (CGRect)endFrame {
    return _endFrame;
}

- (NSTimeInterval)animationDuration {
    return _animationDuration;
}

- (UIViewAnimationCurve)animationCurve {
    return _animationCurve;
}

- (UIViewAnimationOptions)animationOptions {
    return _animationOptions;
}

@end


/**
 1. 系统键盘app启动第一次使用键盘的时候，会调用两轮键盘通知事件，之后就只会调用一次。而搜狗等第三方输入法的键盘，目前发现每次都会调用三次键盘通知事件。总之，键盘的通知事件是不确定的。
 
 2. 搜狗键盘可以修改键盘的高度，在修改键盘高度之后，会调用键盘的keyboardWillChangeFrameNotification和keyboardWillShowNotification通知。
 
 3. 如果从一个聚焦的输入框直接聚焦到另一个输入框，会调用前一个输入框的keyboardWillChangeFrameNotification，在调用后一个输入框的keyboardWillChangeFrameNotification，最后调用后一个输入框的keyboardWillShowNotification（如果此时是浮动键盘，那么后一个输入框的keyboardWillShowNotification不会被调用；）。
 
 4. iPad可以变成浮动键盘，固定->浮动：会调用keyboardWillChangeFrameNotification和keyboardWillHideNotification；浮动->固定：会调用keyboardWillChangeFrameNotification和keyboardWillShowNotification；浮动键盘在移动的时候只会调用keyboardWillChangeFrameNotification通知，并且endFrame为zero，fromFrame不为zero，而是移动前键盘的frame。浮动键盘在聚焦和失焦的时候只会调用keyboardWillChangeFrameNotification，不会调用show和hide的notification。
 
 5. iPad可以拆分为左右的小键盘，小键盘的通知具体基本跟浮动键盘一样。
 
 6. iPad可以外接键盘，外接键盘之后屏幕上就没有虚拟键盘了，但是当我们输入文字的时候，发现底部还是有一条灰色的候选词，条东西也是键盘，它也会触发跟虚拟键盘一样的通知事件。如果点击这条候选词右边的向下箭头，则可以完全隐藏虚拟键盘，这个时候如果失焦再聚焦发现还是没有这条候选词，也就是键盘完全不出来了，如果输入文字，候选词才会重新出来。总结来说就是这条候选词是可以关闭的，关闭之后只有当下次输入才会重新出现。（聚焦和失焦都只调用keyboardWillChangeFrameNotification和keyboardWillHideNotification通知，而且frame始终不变，都是在屏幕下面）
 
 7. iOS8 hide 之后高度变成0了，keyboardWillHideNotification还是正常的，所以建议不要使用键盘高度来做动画，而是用键盘的y值；在show和hide的时候endFrame会出现一些奇怪的中间值，但最终值是对的；两个输入框切换聚焦，iOS8不会触发任何键盘通知；iOS8的浮动切换正常；
 
 8. iOS8在 固定->浮动 的过程中，后面的keyboardWillChangeFrameNotification和keyboardWillHideNotification里面的endFrame是正确的，而iOS10和iOS9是错的，iOS9的y值是键盘的MaxY，而iOS10的y值是隐藏状态下的y，也就是屏幕高度。所以iOS9和iOS10需要在keyboardDidChangeFrameNotification里面重新刷新一下。
 */
@implementation ZKKeyboardManager

- (instancetype)init {
    NSAssert(NO, @"请使用initWithDelegate:初始化");
    return [self initWithDelegate:nil];
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    NSAssert(NO, @"请使用initWithDelegate:初始化");
    return [self initWithDelegate:nil];
}

- (instancetype)initWithDelegate:(id <ZKKeyboardManagerDelegate>)delegate {
    if (self = [super init]) {
        _delegate = delegate;
        _delegateEnabled = YES;
        _targetResponderValues = [[NSMutableArray alloc] init];
        [self addKeyboardNotification];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (BOOL)addTargetResponder:(UIResponder *)targetResponder {
    if (!targetResponder || ![targetResponder isKindOfClass:[UIResponder class]]) {
        return NO;
    }
    targetResponder.kai_keyboardManager = self;
    [self.targetResponderValues addObject:[self packageTargetResponder:targetResponder]];
    return YES;
}

- (NSArray<UIResponder *> *)allTargetResponders {
    NSMutableArray *targetResponders = nil;
    for (int i = 0; i < self.targetResponderValues.count; i++) {
        if (!targetResponders) {
            targetResponders = [[NSMutableArray alloc] init];
        }
        id unPackageValue = [self unPackageTargetResponder:self.targetResponderValues[i]];
        if (unPackageValue && [unPackageValue isKindOfClass:[UIResponder class]]) {
            [targetResponders addObject:(UIResponder *)unPackageValue];
        }
    }
    return [targetResponders copy];
}

- (BOOL)removeTargetResponder:(UIResponder *)targetResponder {
    if (targetResponder && [self.targetResponderValues containsObject:[self packageTargetResponder:targetResponder]]) {
        [self.targetResponderValues removeObject:[self packageTargetResponder:targetResponder]];
        return YES;
    }
    return NO;
}

- (NSValue *)packageTargetResponder:(UIResponder *)targetResponder {
    if (![targetResponder isKindOfClass:[UIResponder class]]) {
        return nil;
    }
    return [NSValue valueWithNonretainedObject:targetResponder];
}

- (UIResponder *)unPackageTargetResponder:(NSValue *)value {
    if (!value) {
        return nil;
    }
    id unPackageValue = [value nonretainedObjectValue];
    if (![unPackageValue isKindOfClass:[UIResponder class]]) {
        return nil;
    }
    return (UIResponder *)unPackageValue;
}

- (UIResponder *)firstResponderInWindows {
    UIResponder *responder = [UIApplication.sharedApplication.keyWindow kai_findFirstResponder];
    if (!responder) {
        for (UIWindow *window in UIApplication.sharedApplication.windows) {
            if (window != UIApplication.sharedApplication.keyWindow) {
                responder = [window kai_findFirstResponder];
                if (responder) {
                    return responder;
                }
            }
        }
    }
    return responder;
}

#pragma mark - Notification

- (void)addKeyboardNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShowNotification:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShowNotification:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHideNotification:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHideNotification:) name:UIKeyboardDidHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrameNotification:) name:UIKeyboardWillChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidChangeFrameNotification:) name:UIKeyboardDidChangeFrameNotification object:nil];
}

- (BOOL)isAppActive {
    if (self.ignoreApplicationState) {
        return YES;
    }
    if (UIApplication.sharedApplication.applicationState == UIApplicationStateActive) {
        return YES;
    }
    return NO;
}

- (BOOL)isLocalKeyboard:(NSNotification *)notification {
    if ([[notification.userInfo valueForKey:UIKeyboardIsLocalUserInfoKey] boolValue]) {
        return YES;
    }
    if ([UIDevice currentDevice].isPad && [UIApplication applicationSize].width != ZKScreenSize().width) {
        return YES;
    }
    return NO;
}

- (void)keyboardWillShowNotification:(NSNotification *)notification {
    if (![self isAppActive] || ![self isLocalKeyboard:notification]) {
        ZKLog(@"app is not active");
        return;
    }
    
    if (![self shouldReceiveShowNotification]) {
        return;
    }
    
    ZKKeyboardUserInfo *userInfo = [self newUserInfoWithNotification:notification];
    self.lastUserInfo = userInfo;
    userInfo.targetResponder = self.currentResponder ?: nil;
    
    if (self.delegateEnabled && [self.delegate respondsToSelector:@selector(keyboardWillShowWithUserInfo:)]) {
        [self.delegate keyboardWillShowWithUserInfo:userInfo];
    }
    
    // 额外处理iPad浮动键盘
    if ([UIDevice currentDevice].isPad) {
        [self keyboardDidChangedFrame:[self.class keyboardView]];
    }
}

- (void)keyboardDidShowNotification:(NSNotification *)notification {
    
    if (self.debug) {
        ZKLog(@"keyboardDidShowNotification - %@", self);
    }
    
    if (![self isAppActive] || ![self isLocalKeyboard:notification]) {
        ZKLog(@"app is not active");
        return;
    }
    
    ZKKeyboardUserInfo *userInfo = [self newUserInfoWithNotification:notification];
    self.lastUserInfo = userInfo;
    userInfo.targetResponder = self.currentResponder ?: nil;
    
    id firstResponder = [self firstResponderInWindows];
    BOOL shouldReceiveDidShowNotification = self.targetResponderValues.count <= 0 || (firstResponder && firstResponder == self.currentResponder);
    
    if (shouldReceiveDidShowNotification) {
        if (self.delegateEnabled && [self.delegate respondsToSelector:@selector(keyboardDidShowWithUserInfo:)]) {
            [self.delegate keyboardDidShowWithUserInfo:userInfo];
        }
        // 额外处理iPad浮动键盘
        if ([UIDevice currentDevice].isPad) {
            [self keyboardDidChangedFrame:[self.class keyboardView]];
        }
    }
}

- (void)keyboardWillHideNotification:(NSNotification *)notification {
    
    if (self.debug) {
        ZKLog(@"keyboardWillHideNotification - %@", self);
    }
    
    if (![self isAppActive] || ![self isLocalKeyboard:notification]) {
        ZKLog(@"app is not active");
        return;
    }
    
    if (![self shouldReceiveHideNotification]) {
        return;
    }
    
    ZKKeyboardUserInfo *userInfo = [self newUserInfoWithNotification:notification];
    self.lastUserInfo = userInfo;
    userInfo.targetResponder = self.currentResponder ?: nil;
    
    if (self.delegateEnabled && [self.delegate respondsToSelector:@selector(keyboardWillHideWithUserInfo:)]) {
        [self.delegate keyboardWillHideWithUserInfo:userInfo];
    }
    
    // 额外处理iPad浮动键盘
    if ([UIDevice currentDevice].isPad) {
        [self keyboardDidChangedFrame:[self.class keyboardView]];
    }
}

- (void)keyboardDidHideNotification:(NSNotification *)notification {
    
    if (self.debug) {
        ZKLog(@"keyboardDidHideNotification - %@", self);
    }
    
    if (![self isAppActive] || ![self isLocalKeyboard:notification]) {
        ZKLog(@"app is not active");
        return;
    }
    
    ZKKeyboardUserInfo *userInfo = [self newUserInfoWithNotification:notification];
    self.lastUserInfo = userInfo;
    userInfo.targetResponder = self.currentResponder ?: nil;
    
    if ([self shouldReceiveHideNotification]) {
        if (self.delegateEnabled && [self.delegate respondsToSelector:@selector(keyboardDidHideWithUserInfo:)]) {
            [self.delegate keyboardDidHideWithUserInfo:userInfo];
        }
    }
    
    if (self.currentResponder && !self.currentResponder.keyboardManager_isFirstResponder && ![UIDevice currentDevice].isPad) {
        // 时机最晚，设置为 nil
        self.currentResponder = nil;
    }
    
    // 额外处理iPad浮动键盘
    if ([UIDevice currentDevice].isPad) {
        if (self.targetResponderValues.count <= 0 || self.currentResponder) {
            [self keyboardDidChangedFrame:[self.class keyboardView]];
        }
    }
}

- (void)keyboardWillChangeFrameNotification:(NSNotification *)notification {
    
    if (self.debug) {
        ZKLog(@"keyboardWillChangeFrameNotification - %@", self);
    }
    
    if (![self isAppActive] || ![self isLocalKeyboard:notification]) {
        ZKLog(@"app is not active");
        return;
    }
    
    ZKKeyboardUserInfo *userInfo = [self newUserInfoWithNotification:notification];
    self.lastUserInfo = userInfo;
    
    if ([self shouldReceiveShowNotification] || [self shouldReceiveHideNotification]) {
        userInfo.targetResponder = self.currentResponder ?: nil;
    } else {
        return;
    }
    
    if (self.delegateEnabled && [self.delegate respondsToSelector:@selector(keyboardWillChangeFrameWithUserInfo:)]) {
        [self.delegate keyboardWillChangeFrameWithUserInfo:userInfo];
    }
    
    // 额外处理iPad浮动键盘
    if ([UIDevice currentDevice].isPad) {
        [self addFrameObserverIfNeeded];
    }
}

- (void)keyboardDidChangeFrameNotification:(NSNotification *)notification {
    
    if (self.debug) {
        ZKLog(@"keyboardDidChangeFrameNotification - %@", self);
    }
    
    if (![self isAppActive] || ![self isLocalKeyboard:notification]) {
        ZKLog(@"app is not active");
        return;
    }
    
    ZKKeyboardUserInfo *userInfo = [self newUserInfoWithNotification:notification];
    self.lastUserInfo = userInfo;
    
    if ([self shouldReceiveShowNotification] || [self shouldReceiveHideNotification]) {
        userInfo.targetResponder = self.currentResponder ?: nil;
    } else {
        return;
    }
    
    if (self.delegateEnabled && [self.delegate respondsToSelector:@selector(keyboardDidChangeFrameWithUserInfo:)]) {
        [self.delegate keyboardDidChangeFrameWithUserInfo:userInfo];
    }
    
    // 额外处理iPad浮动键盘
    if ([UIDevice currentDevice].isPad) {
        [self keyboardDidChangedFrame:[self.class keyboardView]];
    }
}

- (ZKKeyboardUserInfo *)newUserInfoWithNotification:(NSNotification *)notification {
    ZKKeyboardUserInfo *userInfo = [[ZKKeyboardUserInfo alloc] init];
    userInfo.keyboardManager = self;
    userInfo.notification = notification;
    return userInfo;
}

- (BOOL)shouldReceiveShowNotification {
    UIResponder *firstResponder = [self firstResponderInWindows];
    // 如果点击了 webview 导致键盘下降，这个时候运行 shouldReceiveHideNotification 就会判断错误，所以如果发现是 nil 或是 WKContentView 则值不变
    // WKContentView
    if (!self.currentResponder || (firstResponder && ![firstResponder isKindOfClass:NSClassFromString([NSString stringWithFormat:@"%@%@", @"WK", @"ContentView"])])) {
        self.currentResponder = firstResponder;
    }
    
    if (self.targetResponderValues.count <= 0) {
        return YES;
    } else {
        return self.currentResponder && [self.targetResponderValues containsObject:[self packageTargetResponder:self.currentResponder]];
    }
}

- (BOOL)shouldReceiveHideNotification {
    if (self.targetResponderValues.count <= 0) {
        return YES;
    } else {
        if (self.currentResponder) {
            return [self.targetResponderValues containsObject:[self packageTargetResponder:self.currentResponder]];
        } else {
            return NO;
        }
    }
}

#pragma mark - iPad浮动键盘

- (void)addFrameObserverIfNeeded {
    if (![self.class keyboardView]) {
        return;
    }
    UIView *keyboardView = [self.class keyboardView];
    _KAIKeyboardViewFrameObserver *observer = [_KAIKeyboardViewFrameObserver observerForView:keyboardView];
    if (!observer) {
        observer = [[_KAIKeyboardViewFrameObserver alloc] init];
        observer.kai_multipleDelegatesEnabled = YES;
        [observer addToKeyboardView:keyboardView];
    }
    observer.delegate = self;
    [self keyboardDidChangedFrame:keyboardView]; // 手动调用第一次
}

- (void)keyboardDidChangedFrame:(UIView *)keyboardView {
    
    if (keyboardView != [self.class keyboardView]) {
        return;
    }
    
    // 也需要判断targetResponder
    if (![self shouldReceiveShowNotification] && ![self shouldReceiveHideNotification]) {
        return;
    }
    
    if (self.delegateEnabled && [self.delegate respondsToSelector:@selector(keyboardWillChangeFrameWithUserInfo:)]) {
        
        UIWindow *keyboardWindow = keyboardView.window;
        
        if (self.keyboardMoveBeginRect.size.width == 0 && self.keyboardMoveBeginRect.size.height == 0) {
            // 第一次需要初始化
            self.keyboardMoveBeginRect = CGRectMake(0, keyboardWindow.bounds.size.height, keyboardWindow.bounds.size.width, 0);
        }
        
        CGRect endFrame = CGRectZero;
        if (keyboardWindow) {
            endFrame = [keyboardWindow convertRect:keyboardView.frame toWindow:nil];
        } else {
            endFrame = keyboardView.frame;
        }
        
        // 自己构造一个ZKKeyboardUserInfo，一些属性使用之前最后一个keyboardUserInfo的值
        ZKKeyboardUserInfo *keyboardMoveUserInfo = [[ZKKeyboardUserInfo alloc] init];
        keyboardMoveUserInfo.keyboardManager = self;
        keyboardMoveUserInfo.targetResponder = self.lastUserInfo ? self.lastUserInfo.targetResponder : nil;
        keyboardMoveUserInfo.animationDuration = self.lastUserInfo ? self.lastUserInfo.animationDuration : 0.25;
        keyboardMoveUserInfo.animationCurve = self.lastUserInfo ? self.lastUserInfo.animationCurve : 7;
        keyboardMoveUserInfo.animationOptions = self.lastUserInfo ? self.lastUserInfo.animationOptions : keyboardMoveUserInfo.animationCurve<<16;
        keyboardMoveUserInfo.beginFrame = self.keyboardMoveBeginRect;
        keyboardMoveUserInfo.endFrame = endFrame;
        keyboardMoveUserInfo.isFloatingKeyboard = keyboardView ? CGRectGetWidth(keyboardView.bounds) < CGRectGetWidth(UIApplication.sharedApplication.delegate.window.bounds) : NO;
        
        if (self.debug) {
            NSLog(@"keyboardDidMoveNotification - %@\n", self);
        }
        
        [self.delegate keyboardWillChangeFrameWithUserInfo:keyboardMoveUserInfo];
        
        self.keyboardMoveBeginRect = endFrame;
        
        if (self.currentResponder) {
            UIWindow *mainWindow = UIApplication.sharedApplication.keyWindow ?: UIApplication.sharedApplication.delegate.window;
            if (mainWindow) {
                CGRect keyboardRect = keyboardMoveUserInfo.endFrame;
                CGFloat distanceFromBottom = [ZKKeyboardManager distanceFromMinYToBottomInView:mainWindow keyboardRect:keyboardRect];
                if (distanceFromBottom < keyboardRect.size.height) {
                    if (!self.currentResponder.keyboardManager_isFirstResponder) {
                        // willHide
                        self.currentResponder = nil;
                    }
                } else if (distanceFromBottom > keyboardRect.size.height && !self.currentResponder.isFirstResponder) {
                    if (!self.currentResponder.keyboardManager_isFirstResponder) {
                        // 浮动
                        self.currentResponder = nil;
                    }
                }
            }
        }
        
    }
}

#pragma mark - <KAIKeyboardViewFrameObserverDelegate>

- (void)keyboardViewFrameDidChange:(UIView *)keyboardView {
    [self keyboardDidChangedFrame:keyboardView];
}

#pragma mark - 工具方法

+ (void)animateWithAnimated:(BOOL)animated keyboardUserInfo:(ZKKeyboardUserInfo *)keyboardUserInfo animations:(void (^)(void))animations completion:(void (^)(BOOL finished))completion {
    if (animated) {
        [UIView animateWithDuration:keyboardUserInfo.animationDuration delay:0 options:keyboardUserInfo.animationOptions|UIViewAnimationOptionBeginFromCurrentState animations:^{
            if (animations) {
                animations();
            }
        } completion:^(BOOL finished) {
            if (completion) {
                completion(finished);
            }
        }];
    } else {
        if (animations) {
            animations();
        }
        if (completion) {
            completion(YES);
        }
    }
}

+ (void)handleKeyboardNotificationWithUserInfo:(ZKKeyboardUserInfo *)keyboardUserInfo showBlock:(void (^)(ZKKeyboardUserInfo *keyboardUserInfo))showBlock hideBlock:(void (^)(ZKKeyboardUserInfo *keyboardUserInfo))hideBlock {
    // 专门处理 iPad Pro 在键盘完全不显示的情况（不会调用willShow，所以通过是否focus来判断）
    // iPhoneX Max 这里键盘高度不是0，而是一个很小的值
    if (!keyboardUserInfo.isTargetResponderFocused) {
        // 先判断 focus，避免 frame 变化但是此时 visibleKeyboardHeight 还不是 0 导致调用了 showBlock
        if ([ZKKeyboardManager visibleKeyboardHeight] <= 0) {
            if (hideBlock) {
                hideBlock(keyboardUserInfo);
            }
        }
    } else {
        if (showBlock) {
            showBlock(keyboardUserInfo);
        }
    }
}

+ (CGRect)convertKeyboardRect:(CGRect)rect toView:(UIView *)view {
    
    if (CGRectIsNull(rect) || CGRectIsInfinite(rect)) {
        return rect;
    }
    
    UIWindow *mainWindow = UIApplication.sharedApplication.keyWindow ?: UIApplication.sharedApplication.delegate.window;
    if (!mainWindow) {
        if (view) {
            [view convertRect:rect fromView:nil];
        } else {
            return rect;
        }
    }
    
    rect = [mainWindow convertRect:rect fromWindow:nil];
    if (!view) {
        return [mainWindow convertRect:rect toWindow:nil];
    }
    if (view == mainWindow) {
        return rect;
    }
    
    UIWindow *toWindow = [view isKindOfClass:[UIWindow class]] ? (id)view : view.window;
    if (!mainWindow || !toWindow) {
        return [mainWindow convertRect:rect toView:view];
    }
    if (mainWindow == toWindow) {
        return [mainWindow convertRect:rect toView:view];
    }
    
    rect = [mainWindow convertRect:rect toView:mainWindow];
    rect = [toWindow convertRect:rect fromWindow:mainWindow];
    rect = [view convertRect:rect fromView:toWindow];
    
    return rect;
}

+ (CGFloat)distanceFromMinYToBottomInView:(UIView *)view keyboardRect:(CGRect)rect {
    rect = [self convertKeyboardRect:rect toView:view];
    CGFloat distance = CGRectGetHeight(CGRectPixelFloor(view.bounds)) - CGRectGetMinY(rect);
    return distance;
}

+ (UIWindow *)keyboardWindow {
    for (UIWindow *window in UIApplication.sharedApplication.windows) {
        if ([self positionedKeyboardViewInWindow:window]) {
            return window;
        }
    }
    
    UIWindow *window = [UIApplication.sharedApplication.windows objectPassingTest:^BOOL(__kindof UIWindow * _Nonnull item) {
        return [NSStringFromClass(item.class) isEqualToString:@"UIRemoteKeyboardWindow"];
    }];
    if (window) {
        return window;
    }
    
    window = [UIApplication.sharedApplication.windows objectPassingTest:^BOOL(__kindof UIWindow * _Nonnull item) {
        return [NSStringFromClass(item.class) isEqualToString:@"UITextEffectsWindow"];
    }];
    return window;
}

+ (UIView *)keyboardView {
    for (UIWindow *window in UIApplication.sharedApplication.windows) {
        UIView *view = [self positionedKeyboardViewInWindow:window];
        if (view) {
            return view;
        }
    }
    return nil;
}

/**
 从给定的 window 里寻找代表键盘当前布局位置的 view。
 iOS 15 及以前（包括用 Xcode 13 编译的 App 运行在 iOS 16 上的场景），键盘的 UI 层级是：
 |- UIApplication.windows
 |- UIRemoteKeyboardWindow
 |- UIInputSetContainerView
 |- UIInputSetHostView - 键盘及 webView 里的输入工具栏（上下键、Done键）
 |- _UIKBCompatInputView - 键盘主体按键
 |- TUISystemInputAssistantView - 键盘顶部的候选词栏、emoji 键盘顶部的搜索框
 |- _UIRemoteKeyboardPlaceholderView - webView 里的输入工具栏的占位（实际的 view 在 UITextEffectsWindow 里）
 
 iOS 16 及以后（仅限用 Xcode 14 及以上版本编译的 App），UIApplication.windows 里已经不存在 UIRemoteKeyboardWindow 了，所以退而求其次，我们通过 UITextEffectsWindow 里的 UIInputSetHostView 来获取键盘的位置——这两个 window 在布局层面可以理解为镜像关系。
 |- UIApplication.windows
 |- UITextEffectsWindow
 |- UIInputSetContainerView
 |- UIInputSetHostView - 键盘及 webView 里的输入工具栏（上下键、Done键）
 |- _UIRemoteKeyboardPlaceholderView - 整个键盘区域，包含顶部候选词栏、emoji 键盘顶部搜索栏（有时候不一定存在）
 |- UIWebFormAccessory - webView 里的输入工具栏的占位
 |- TUIInputAssistantHostView - 外接键盘时可能存在，此时不一定有 placeholder
 |- UIInputSetHostView - 可能存在多个，但只有一个里面有 _UIRemoteKeyboardPlaceholderView
 
 所以只要找到 UIInputSetHostView 即可，优先从 UIRemoteKeyboardWindow 找，不存在的话则从 UITextEffectsWindow 找。
 */
+ (UIView *)positionedKeyboardViewInWindow:(UIWindow *)window {
    
    if (!window) return nil;
    
    NSString *windowName = NSStringFromClass(window.class);
    if ([windowName isEqualToString:@"UIRemoteKeyboardWindow"]) {
        UIView *result = [[window.subviews objectPassingTest:^BOOL(__kindof UIView * _Nonnull subview) {
            return [NSStringFromClass(subview.class) isEqualToString:@"UIInputSetContainerView"];
        }].subviews objectPassingTest:^BOOL(__kindof UIView * _Nonnull subview) {
            return [NSStringFromClass(subview.class) isEqualToString:@"UIInputSetHostView"];
        }];
        return result;
    }
    if ([windowName isEqualToString:@"UITextEffectsWindow"]) {
        UIView *result = [[window.subviews objectPassingTest:^BOOL(__kindof UIView * _Nonnull subview) {
            return [NSStringFromClass(subview.class) isEqualToString:@"UIInputSetContainerView"];
        }].subviews objectPassingTest:^BOOL(__kindof UIView * _Nonnull subview) {
            return [NSStringFromClass(subview.class) isEqualToString:@"UIInputSetHostView"] && subview.subviews.count;
        }];
        return result;
    }
    return nil;
}

+ (BOOL)isKeyboardVisible {
    UIView *keyboardView = self.keyboardView;
    UIWindow *keyboardWindow = keyboardView.window;
    if (!keyboardView || !keyboardWindow) {
        return NO;
    }
    CGRect rect = CGRectIntersection(CGRectPixelFloor(keyboardWindow.bounds), CGRectPixelFloor(keyboardView.frame));
    if (CGRectIsValidated(rect) && !CGRectIsEmpty(rect)) {
        return YES;
    }
    return NO;
}

+ (CGRect)currentKeyboardFrame {
    UIView *keyboardView = [self keyboardView];
    if (!keyboardView) {
        return CGRectNull;
    }
    UIWindow *keyboardWindow = keyboardView.window;
    if (keyboardWindow) {
        return [keyboardWindow convertRect:CGRectPixelFloor(keyboardView.frame) toWindow:nil];
    } else {
        return CGRectPixelFloor(keyboardView.frame);
    }
}

+ (CGFloat)visibleKeyboardHeight {
    UIView *keyboardView = [self keyboardView];
    // iPad“侧拉”模式打开的 App，App Window 和键盘 Window 尺寸不同，如果以键盘 Window 为准则会认为键盘一直在屏幕上，从而出现误判，所以这里改为用 App Window。
    // iPhone、iPad 全屏/分屏/台前调度，都没这个问题
    //    UIWindow *keyboardWindow = keyboardView.window;
    UIWindow *keyboardWindow = UIApplication.sharedApplication.delegate.window;
    if (!keyboardView || !keyboardWindow) {
        return 0;
    } else {
        // 开启了系统的“设置→辅助功能→动态效果→减弱动态效果→首选交叉淡出过渡效果”后，键盘动画不再是 slide，而是 fade，此时应该用 alpha 来判断
        // https://github.com/Tencent/QMUI_iOS/issues/1173
        if (keyboardView.alpha <= 0) {
            return 0;
        }
        
        CGRect keyboardFrame = [keyboardWindow convertRect:keyboardView.bounds fromView:keyboardView];
        CGRect visibleRect = CGRectIntersection(keyboardWindow.bounds, keyboardFrame);
        if (CGRectIsValidated(visibleRect)) {
            return CGRectGetHeight(visibleRect);
        }
        return 0;
    }
}

@end

#pragma mark - UITextField

@interface UITextField () <ZKKeyboardManagerDelegate>

@end

@implementation UITextField (ZKKeyboardManager)

- (void)setKai_keyboardWillShowNotificationBlock:(void (^)(ZKKeyboardUserInfo *))keyboardWillShowNotificationBlock {
    [self setAssociateCopyValue:keyboardWillShowNotificationBlock withKey:@selector(kai_keyboardWillShowNotificationBlock)];
    if (keyboardWillShowNotificationBlock) {
        [self initKeyboardManagerIfNeeded];
    }
}

- (void (^)(ZKKeyboardUserInfo *))kai_keyboardWillShowNotificationBlock {
    return [self associatedValueForKey:_cmd];
}

static char kAssociatedObjectKey_keyboardDidShowNotificationBlock;
- (void)setKai_keyboardDidShowNotificationBlock:(void (^)(ZKKeyboardUserInfo *))keyboardDidShowNotificationBlock {
    [self setAssociateCopyValue:keyboardDidShowNotificationBlock withKey:@selector(kai_keyboardDidShowNotificationBlock)];
    if (keyboardDidShowNotificationBlock) {
        [self initKeyboardManagerIfNeeded];
    }
}

- (void (^)(ZKKeyboardUserInfo *))kai_keyboardDidShowNotificationBlock {
    return [self associatedValueForKey:_cmd];
}

- (void)setKai_keyboardWillHideNotificationBlock:(void (^)(ZKKeyboardUserInfo *))keyboardWillHideNotificationBlock {
    [self setAssociateCopyValue:keyboardWillHideNotificationBlock withKey:@selector(kai_keyboardWillHideNotificationBlock)];
    if (keyboardWillHideNotificationBlock) {
        [self initKeyboardManagerIfNeeded];
    }
}

- (void (^)(ZKKeyboardUserInfo *))kai_keyboardWillHideNotificationBlock {
    return [self associatedValueForKey:_cmd];
}

- (void)setKai_keyboardDidHideNotificationBlock:(void (^)(ZKKeyboardUserInfo *))keyboardDidHideNotificationBlock {
    [self setAssociateCopyValue:keyboardDidHideNotificationBlock withKey:@selector(kai_keyboardDidHideNotificationBlock)];
    if (keyboardDidHideNotificationBlock) {
        [self initKeyboardManagerIfNeeded];
    }
}

- (void (^)(ZKKeyboardUserInfo *))kai_keyboardDidHideNotificationBlock {
    return [self associatedValueForKey:_cmd];
}

- (void)setKai_keyboardWillChangeFrameNotificationBlock:(void (^)(ZKKeyboardUserInfo *))keyboardWillChangeFrameNotificationBlock {
    [self setAssociateCopyValue:keyboardWillChangeFrameNotificationBlock withKey:@selector(kai_keyboardWillChangeFrameNotificationBlock)];
    if (keyboardWillChangeFrameNotificationBlock) {
        [self initKeyboardManagerIfNeeded];
    }
}

- (void (^)(ZKKeyboardUserInfo *))kai_keyboardWillChangeFrameNotificationBlock {
    return [self associatedValueForKey:_cmd];
}

- (void)setKai_keyboardDidChangeFrameNotificationBlock:(void (^)(ZKKeyboardUserInfo *))keyboardDidChangeFrameNotificationBlock {
    [self setAssociateCopyValue:keyboardDidChangeFrameNotificationBlock withKey:@selector(kai_keyboardDidChangeFrameNotificationBlock)];
    if (keyboardDidChangeFrameNotificationBlock) {
        [self initKeyboardManagerIfNeeded];
    }
}

- (void (^)(ZKKeyboardUserInfo *))kai_keyboardDidChangeFrameNotificationBlock {
    return [self associatedValueForKey:_cmd];
}

- (void)initKeyboardManagerIfNeeded {
    if (!self.kai_keyboardManager) {
        self.kai_keyboardManager = [[ZKKeyboardManager alloc] initWithDelegate:self];
        [self.kai_keyboardManager addTargetResponder:self];
    }
}

#pragma mark - <ZKKeyboardManagerDelegate>

- (void)keyboardWillShowWithUserInfo:(ZKKeyboardUserInfo *)keyboardUserInfo {
    if (self.kai_keyboardWillShowNotificationBlock) {
        self.kai_keyboardWillShowNotificationBlock(keyboardUserInfo);
    }
}

- (void)keyboardWillHideWithUserInfo:(ZKKeyboardUserInfo *)keyboardUserInfo {
    if (self.kai_keyboardWillHideNotificationBlock) {
        self.kai_keyboardWillHideNotificationBlock(keyboardUserInfo);
    }
}

- (void)keyboardWillChangeFrameWithUserInfo:(ZKKeyboardUserInfo *)keyboardUserInfo {
    if (self.kai_keyboardWillChangeFrameNotificationBlock) {
        self.kai_keyboardWillChangeFrameNotificationBlock(keyboardUserInfo);
    }
}

- (void)keyboardDidShowWithUserInfo:(ZKKeyboardUserInfo *)keyboardUserInfo {
    if (self.kai_keyboardDidShowNotificationBlock) {
        self.kai_keyboardDidShowNotificationBlock(keyboardUserInfo);
    }
}

- (void)keyboardDidHideWithUserInfo:(ZKKeyboardUserInfo *)keyboardUserInfo {
    if (self.kai_keyboardDidHideNotificationBlock) {
        self.kai_keyboardDidHideNotificationBlock(keyboardUserInfo);
    }
}

- (void)keyboardDidChangeFrameWithUserInfo:(ZKKeyboardUserInfo *)keyboardUserInfo {
    if (self.kai_keyboardDidChangeFrameNotificationBlock) {
        self.kai_keyboardDidChangeFrameNotificationBlock(keyboardUserInfo);
    }
}

@end

#pragma mark - UITextView

@interface UITextView () <ZKKeyboardManagerDelegate>

@end

@implementation UITextView (ZKKeyboardManager)

static char kAssociatedObjectKey_keyboardWillShowNotificationBlock;
- (void)setKai_keyboardWillShowNotificationBlock:(void (^)(ZKKeyboardUserInfo *))keyboardWillShowNotificationBlock {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_keyboardWillShowNotificationBlock, keyboardWillShowNotificationBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
    if (keyboardWillShowNotificationBlock) {
        [self initKeyboardManagerIfNeeded];
    }
}

- (void (^)(ZKKeyboardUserInfo *))kai_keyboardWillShowNotificationBlock {
    return (void (^)(ZKKeyboardUserInfo *))objc_getAssociatedObject(self, &kAssociatedObjectKey_keyboardWillShowNotificationBlock);
}

static char kAssociatedObjectKey_keyboardDidShowNotificationBlock;
- (void)setKai_keyboardDidShowNotificationBlock:(void (^)(ZKKeyboardUserInfo *))keyboardDidShowNotificationBlock {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_keyboardDidShowNotificationBlock, keyboardDidShowNotificationBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
    if (keyboardDidShowNotificationBlock) {
        [self initKeyboardManagerIfNeeded];
    }
}

- (void (^)(ZKKeyboardUserInfo *))kai_keyboardDidShowNotificationBlock {
    return (void (^)(ZKKeyboardUserInfo *))objc_getAssociatedObject(self, &kAssociatedObjectKey_keyboardDidShowNotificationBlock);
}

static char kAssociatedObjectKey_keyboardWillHideNotificationBlock;
- (void)setKai_keyboardWillHideNotificationBlock:(void (^)(ZKKeyboardUserInfo *))keyboardWillHideNotificationBlock {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_keyboardWillHideNotificationBlock, keyboardWillHideNotificationBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
    if (keyboardWillHideNotificationBlock) {
        [self initKeyboardManagerIfNeeded];
    }
}

- (void (^)(ZKKeyboardUserInfo *))kai_keyboardWillHideNotificationBlock {
    return (void (^)(ZKKeyboardUserInfo *))objc_getAssociatedObject(self, &kAssociatedObjectKey_keyboardWillHideNotificationBlock);
}

static char kAssociatedObjectKey_keyboardDidHideNotificationBlock;
- (void)setKai_keyboardDidHideNotificationBlock:(void (^)(ZKKeyboardUserInfo *))keyboardDidHideNotificationBlock {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_keyboardDidHideNotificationBlock, keyboardDidHideNotificationBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
    if (keyboardDidHideNotificationBlock) {
        [self initKeyboardManagerIfNeeded];
    }
}

- (void (^)(ZKKeyboardUserInfo *))kai_keyboardDidHideNotificationBlock {
    return (void (^)(ZKKeyboardUserInfo *))objc_getAssociatedObject(self, &kAssociatedObjectKey_keyboardDidHideNotificationBlock);
}

static char kAssociatedObjectKey_keyboardWillChangeFrameNotificationBlock;
- (void)setKai_keyboardWillChangeFrameNotificationBlock:(void (^)(ZKKeyboardUserInfo *))keyboardWillChangeFrameNotificationBlock {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_keyboardWillChangeFrameNotificationBlock, keyboardWillChangeFrameNotificationBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
    if (keyboardWillChangeFrameNotificationBlock) {
        [self initKeyboardManagerIfNeeded];
    }
}

- (void (^)(ZKKeyboardUserInfo *))kai_keyboardWillChangeFrameNotificationBlock {
    return (void (^)(ZKKeyboardUserInfo *))objc_getAssociatedObject(self, &kAssociatedObjectKey_keyboardWillChangeFrameNotificationBlock);
}

static char kAssociatedObjectKey_keyboardDidChagneFrameNotificationBlock;
- (void)setKai_keyboardDidChangeFrameNotificationBlock:(void (^)(ZKKeyboardUserInfo *))keyboardDidChangeFrameNotificationBlock {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_keyboardDidChagneFrameNotificationBlock, keyboardDidChangeFrameNotificationBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
    if (keyboardDidChangeFrameNotificationBlock) {
        [self initKeyboardManagerIfNeeded];
    }
}

- (void (^)(ZKKeyboardUserInfo *))kai_keyboardDidChangeFrameNotificationBlock {
    return (void (^)(ZKKeyboardUserInfo *))objc_getAssociatedObject(self, &kAssociatedObjectKey_keyboardDidChagneFrameNotificationBlock);
}

- (void)initKeyboardManagerIfNeeded {
    if (!self.kai_keyboardManager) {
        self.kai_keyboardManager = [[ZKKeyboardManager alloc] initWithDelegate:self];
        [self.kai_keyboardManager addTargetResponder:self];
    }
}

#pragma mark - <ZKKeyboardManagerDelegate>

- (void)keyboardWillShowWithUserInfo:(ZKKeyboardUserInfo *)keyboardUserInfo {
    if (self.kai_keyboardWillShowNotificationBlock) {
        self.kai_keyboardWillShowNotificationBlock(keyboardUserInfo);
    }
}

- (void)keyboardWillHideWithUserInfo:(ZKKeyboardUserInfo *)keyboardUserInfo {
    if (self.kai_keyboardWillHideNotificationBlock) {
        self.kai_keyboardWillHideNotificationBlock(keyboardUserInfo);
    }
}

- (void)keyboardWillChangeFrameWithUserInfo:(ZKKeyboardUserInfo *)keyboardUserInfo {
    if (self.kai_keyboardWillChangeFrameNotificationBlock) {
        self.kai_keyboardWillChangeFrameNotificationBlock(keyboardUserInfo);
    }
}

- (void)keyboardDidShowWithUserInfo:(ZKKeyboardUserInfo *)keyboardUserInfo {
    if (self.kai_keyboardDidShowNotificationBlock) {
        self.kai_keyboardDidShowNotificationBlock(keyboardUserInfo);
    }
}

- (void)keyboardDidHideWithUserInfo:(ZKKeyboardUserInfo *)keyboardUserInfo {
    if (self.kai_keyboardDidHideNotificationBlock) {
        self.kai_keyboardDidHideNotificationBlock(keyboardUserInfo);
    }
}

- (void)keyboardDidChangeFrameWithUserInfo:(ZKKeyboardUserInfo *)keyboardUserInfo {
    if (self.kai_keyboardDidChangeFrameNotificationBlock) {
        self.kai_keyboardDidChangeFrameNotificationBlock(keyboardUserInfo);
    }
}

@end
