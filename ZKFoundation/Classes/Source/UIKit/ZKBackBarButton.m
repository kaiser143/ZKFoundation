//
//  ZKBackBarButton.m
//  ZKFoundation
//
//  Created by Kaiser on 2026/8/20.
//

#import "ZKBackBarButton.h"
#import "ZKCategoriesImport.h"

@interface UIView (ZKBackBarButton)

/// 用来标志某个 view 是否被设置为某个 UINavigationItem 的 kai_backBarButton
@property (nonatomic, assign) BOOL kaibbb_isViewOfZKBackBarButton;

@end

@interface UINavigationItem (ZKBackBarButtonPrivate)

@property (nonatomic, strong, nullable) UIBarButtonItem *kaibbb_backBarButtonItem;
/// 记录业务真正设置的 hidesBackButton；组件内部因显示自定义返回按钮而修改 hidesBackButton 时不会覆盖该值。
@property (nonatomic, assign) BOOL kaibbb_hidesBackButton;

@property (nonatomic, weak, readonly, nullable) UINavigationBar *kaibbb_navigationBar;
@property (nonatomic, weak, readonly, nullable) UINavigationController *kaibbb_navigationController;
@property (nonatomic, weak, readonly, nullable) UIViewController *kaibbb_viewController;
@property (nonatomic, weak, readonly, nullable) UINavigationItem *kaibbb_previousItem;
@property (nonatomic, weak, readonly, nullable) UINavigationItem *kaibbb_nextItem;

+ (void)kaibbb_updateNavigationItems:(NSArray<UINavigationItem *> *)items;
+ (void)kaibbb_updateNavigationItem:(UINavigationItem *)item;
+ (void)kaibbb_updateNavigationItem:(UINavigationItem *)item
                       previousItem:(UINavigationItem *)prevItem
                           nextItem:(UINavigationItem *)nextItem;
+ (void)kaibbb_ensureInteractivePopGestureEnabledIfNeeded:(UINavigationController *)navigationController;
+ (void)kaibbb_hookInteractivePopGestureDelegateIfNeeded:(UINavigationController *)navigationController;
+ (BOOL)kaibbb_isShowingCustomBackBarButtonInNavigationController:(UINavigationController *)navController;

- (void)kaibbb_setLeftBarButtonItemsAndUpdateSystemBackButton:(NSArray<UIBarButtonItem *> *)items;
- (NSMutableArray<UIBarButtonItem *> *)kaibbb_leftBarButtonItemsWithoutCustom;
- (void)kaibbb_updateHidesBackButton;

@end

@implementation UINavigationItem (ZKBackBarButton)

static void (*kaibbb_orig_setLeftBarButtonItemsAnimated)(id, SEL, NSArray<UIBarButtonItem *> *, BOOL) = NULL;
static void (*kaibbb_orig_setHidesBackButtonAnimated)(id, SEL, BOOL, BOOL) = NULL;

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
#pragma mark - UINavigationItem setLeftBarButtonItems:animated:
        OverrideImplementation([UINavigationItem class], @selector(setLeftBarButtonItems:animated:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^(UINavigationItem *selfObject, NSArray<UIBarButtonItem *> *items, BOOL animated) {
                void (*originSelectorIMP)(id, SEL, NSArray<UIBarButtonItem *> *, BOOL);
                originSelectorIMP = (void (*)(id, SEL, NSArray<UIBarButtonItem *> *, BOOL))originalIMPProvider();
                if (!kaibbb_orig_setLeftBarButtonItemsAnimated) {
                    kaibbb_orig_setLeftBarButtonItemsAnimated = originSelectorIMP;
                }
                originSelectorIMP(selfObject, originCMD, items, animated);

                [UINavigationItem kaibbb_updateNavigationItem:selfObject];
                [selfObject kaibbb_updateHidesBackButton];
            };
        });

#pragma mark - UINavigationItem setHidesBackButton:animated:
        OverrideImplementation([UINavigationItem class], @selector(setHidesBackButton:animated:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^(UINavigationItem *selfObject, BOOL hidesBackButton, BOOL animated) {
                void (*originSelectorIMP)(id, SEL, BOOL, BOOL);
                originSelectorIMP = (void (*)(id, SEL, BOOL, BOOL))originalIMPProvider();
                if (!kaibbb_orig_setHidesBackButtonAnimated) {
                    kaibbb_orig_setHidesBackButtonAnimated = originSelectorIMP;
                }
                originSelectorIMP(selfObject, originCMD, hidesBackButton, animated);

                selfObject.kaibbb_hidesBackButton = hidesBackButton;
                [UINavigationItem kaibbb_updateNavigationItem:selfObject];
            };
        });

#pragma mark - UINavigationBar setItems:animated:
        OverrideImplementation([UINavigationBar class], @selector(setItems:animated:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^(UINavigationBar *selfObject, NSArray<UINavigationItem *> *items, BOOL animated) {
                void (*originSelectorIMP)(id, SEL, NSArray<UINavigationItem *> *, BOOL);
                originSelectorIMP = (void (*)(id, SEL, NSArray<UINavigationItem *> *, BOOL))originalIMPProvider();
                originSelectorIMP(selfObject, originCMD, items, animated);

                [UINavigationItem kaibbb_updateNavigationItems:items];
            };
        });

#pragma mark - UINavigationBar didMoveToSuperview
        ExtendImplementationOfVoidMethodWithoutArguments([UINavigationBar class], @selector(didMoveToSuperview), ^(UINavigationBar *selfObject) {
            [UINavigationItem kaibbb_updateNavigationItems:selfObject.items];
        });

#pragma mark - UINavigationController setNavigationBarHidden:animated:
        OverrideImplementation([UINavigationController class], @selector(setNavigationBarHidden:animated:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^(UINavigationController *selfObject, BOOL hidden, BOOL animated) {
                void (*originSelectorIMP)(id, SEL, BOOL, BOOL);
                originSelectorIMP = (void (*)(id, SEL, BOOL, BOOL))originalIMPProvider();
                originSelectorIMP(selfObject, originCMD, hidden, animated);

                [UINavigationItem kaibbb_updateNavigationItems:selfObject.navigationBar.items];
            };
        });

#pragma mark - UINavigationBar pushNavigationItem:animated:
        OverrideImplementation([UINavigationBar class], @selector(pushNavigationItem:animated:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^(UINavigationBar *selfObject, UINavigationItem *navigationItem, BOOL animated) {
                NSArray<UINavigationItem *> *upcomingItems = selfObject.items ? [selfObject.items arrayByAddingObject:navigationItem] : @[navigationItem];
                [UINavigationItem kaibbb_updateNavigationItems:upcomingItems];

                void (*originSelectorIMP)(id, SEL, UINavigationItem *, BOOL);
                originSelectorIMP = (void (*)(id, SEL, UINavigationItem *, BOOL))originalIMPProvider();
                originSelectorIMP(selfObject, originCMD, navigationItem, animated);
            };
        });

#pragma mark - UINavigationItem setLeftBarButtonItem:animated:
        OverrideImplementation([UINavigationItem class], @selector(setLeftBarButtonItem:animated:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^(UINavigationItem *selfObject, UIBarButtonItem *item, BOOL animated) {
                void (*originSelectorIMP)(id, SEL, UIBarButtonItem *, BOOL);
                originSelectorIMP = (void (*)(id, SEL, UIBarButtonItem *, BOOL))originalIMPProvider();
                originSelectorIMP(selfObject, originCMD, item, animated);

                [UINavigationItem kaibbb_updateNavigationItem:selfObject];
            };
        });

#pragma mark - UINavigationItem setLeftItemsSupplementBackButton:
        OverrideImplementation([UINavigationItem class], @selector(setLeftItemsSupplementBackButton:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^(UINavigationItem *selfObject, BOOL supplementBackButton) {
                void (*originSelectorIMP)(id, SEL, BOOL);
                originSelectorIMP = (void (*)(id, SEL, BOOL))originalIMPProvider();
                originSelectorIMP(selfObject, originCMD, supplementBackButton);

                [UINavigationItem kaibbb_updateNavigationItem:selfObject];
            };
        });

#pragma mark - UINavigationController pushViewController:animated:
        // 在转场开始前就把自定义返回写到目标页的 navigationItem 上，避免等页面显示完才出现
        OverrideImplementation([UINavigationController class], @selector(pushViewController:animated:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^(UINavigationController *selfObject, UIViewController *viewController, BOOL animated) {
                UIViewController *fromViewController = selfObject.topViewController;
                if (fromViewController.navigationItem.kaibbb_backBarButtonItem && viewController) {
                    [UINavigationItem kaibbb_updateNavigationItem:fromViewController.navigationItem
                                                    previousItem:fromViewController.navigationItem.kaibbb_previousItem
                                                        nextItem:viewController.navigationItem];
                }

                void (*originSelectorIMP)(id, SEL, UIViewController *, BOOL);
                originSelectorIMP = (void (*)(id, SEL, UIViewController *, BOOL))originalIMPProvider();
                originSelectorIMP(selfObject, originCMD, viewController, animated);

                [UINavigationItem kaibbb_ensureInteractivePopGestureEnabledIfNeeded:selfObject];
            };
        });

#pragma mark - UINavigationController setViewControllers:animated:
        OverrideImplementation([UINavigationController class], @selector(setViewControllers:animated:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^(UINavigationController *selfObject, NSArray<UIViewController *> *viewControllers, BOOL animated) {
                if (viewControllers.count >= 2) {
                    UIViewController *previous = viewControllers[viewControllers.count - 2];
                    UIViewController *top = viewControllers.lastObject;
                    if (previous.navigationItem.kaibbb_backBarButtonItem) {
                        [UINavigationItem kaibbb_updateNavigationItem:previous.navigationItem
                                                        previousItem:previous.navigationItem.kaibbb_previousItem
                                                            nextItem:top.navigationItem];
                    }
                }

                void (*originSelectorIMP)(id, SEL, NSArray<UIViewController *> *, BOOL);
                originSelectorIMP = (void (*)(id, SEL, NSArray<UIViewController *> *, BOOL))originalIMPProvider();
                originSelectorIMP(selfObject, originCMD, viewControllers, animated);

                [UINavigationItem kaibbb_ensureInteractivePopGestureEnabledIfNeeded:selfObject];
            };
        });
    });
}

static char kAssociatedObjectKey_backBarButton;

- (void)setKai_backBarButton:(__kindof UIView *)kai_backBarButton {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_backBarButton, kai_backBarButton, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    kai_backBarButton.kaibbb_isViewOfZKBackBarButton = YES;
    self.kaibbb_backBarButtonItem = kai_backBarButton ? [[UIBarButtonItem alloc] initWithCustomView:kai_backBarButton] : nil;

    UINavigationController *navigationController = self.kaibbb_navigationController;
    [UINavigationItem kaibbb_updateNavigationItems:self.kaibbb_navigationBar.items];
    [UINavigationItem kaibbb_ensureInteractivePopGestureEnabledIfNeeded:navigationController];
    if (kai_backBarButton) {
        [UINavigationItem kaibbb_hookInteractivePopGestureDelegateIfNeeded:navigationController];
    }
}

- (__kindof UIView *)kai_backBarButton {
    return (UIView *)objc_getAssociatedObject(self, &kAssociatedObjectKey_backBarButton);
}

+ (void)kaibbb_updateNavigationItems:(NSArray<UINavigationItem *> *)items {
    for (NSInteger i = 0, l = items.count; i < l; i++) {
        [UINavigationItem kaibbb_updateNavigationItem:items[i]
                                         previousItem:i > 0 ? items[i - 1] : nil
                                             nextItem:i < l - 1 ? items[i + 1] : nil];
    }
}

/// 由于更新逻辑是「每个 item 更新自己的 nextItem」，这里对 prev / self 各更新一次。
+ (void)kaibbb_updateNavigationItem:(UINavigationItem *)item {
    UINavigationItem *prevItem = item.kaibbb_previousItem;
    UINavigationItem *nextItem = item.kaibbb_nextItem;
    if (prevItem) {
        [UINavigationItem kaibbb_updateNavigationItem:prevItem
                                         previousItem:prevItem.kaibbb_previousItem
                                             nextItem:item];
    }
    [UINavigationItem kaibbb_updateNavigationItem:item previousItem:prevItem nextItem:nextItem];
}

+ (void)kaibbb_updateNavigationItem:(UINavigationItem *)item
                       previousItem:(UINavigationItem *)prevItem
                           nextItem:(UINavigationItem *)nextItem {
    if (prevItem && !prevItem.kaibbb_backBarButtonItem && item.leftBarButtonItem.customView.kaibbb_isViewOfZKBackBarButton) {
        NSMutableArray<UIBarButtonItem *> *leftItems = [item kaibbb_leftBarButtonItemsWithoutCustom];
        [item kaibbb_setLeftBarButtonItemsAndUpdateSystemBackButton:leftItems];
    }
    if (item.kaibbb_backBarButtonItem && nextItem) {
        UIBarButtonItem *backBarButtonItem = item.kaibbb_backBarButtonItem;
        NSMutableArray<UIBarButtonItem *> *leftItems = [nextItem kaibbb_leftBarButtonItemsWithoutCustom];
        BOOL shouldShowBackButton = (leftItems.count <= 0 && !nextItem.kaibbb_hidesBackButton) || (leftItems.count > 0 && nextItem.leftItemsSupplementBackButton && !nextItem.kaibbb_hidesBackButton);
        if (shouldShowBackButton) {
            UIViewController *nextViewController = nextItem.kaibbb_viewController;
            if (!nextViewController) {
                UINavigationController *nav = item.kaibbb_navigationController;
                if (nav.kai_isPopping) {
                    nextViewController = [nav.transitionCoordinator viewControllerForKey:UITransitionContextFromViewControllerKey];
                } else {
                    nextViewController = nav.topViewController;
                }
            }
            if ([nextViewController respondsToSelector:@selector(shouldShowBackBarButton:)]) {
                shouldShowBackButton = [((id<ZKBackBarButtonViewControllerSupport>)nextViewController) shouldShowBackBarButton:backBarButtonItem.customView];
            }
            if (shouldShowBackButton) {
                [leftItems insertObject:backBarButtonItem atIndex:0];
            }
        }
        [nextItem kaibbb_setLeftBarButtonItemsAndUpdateSystemBackButton:leftItems];
        UINavigationController *nav = nextItem.kaibbb_navigationController ?: item.kaibbb_navigationController;
        [UINavigationItem kaibbb_ensureInteractivePopGestureEnabledIfNeeded:nav];
    }
}

+ (BOOL)kaibbb_isShowingCustomBackBarButtonInNavigationController:(UINavigationController *)navController {
    if (!navController || navController.navigationBarHidden) {
        return NO;
    }
    UINavigationItem *topItem = navController.navigationBar.topItem;
    UIBarButtonItem *backItem = topItem.kaibbb_previousItem.kaibbb_backBarButtonItem;
    return backItem && topItem.leftBarButtonItem == backItem;
}

+ (void)kaibbb_ensureInteractivePopGestureEnabledIfNeeded:(UINavigationController *)navigationController {
    if (!navigationController || navigationController.viewControllers.count <= 1) {
        return;
    }
    if (![self kaibbb_isShowingCustomBackBarButtonInNavigationController:navigationController]) {
        // push 刚开始时 top 还是 from，用即将显示的 left item 再判断一次
        UINavigationItem *topItem = navigationController.topViewController.navigationItem;
        if (!topItem.leftBarButtonItem.customView.kaibbb_isViewOfZKBackBarButton) {
            return;
        }
    }
    [self kaibbb_hookInteractivePopGestureDelegateIfNeeded:navigationController];
    // 自定义 leftBarButtonItem 后系统可能关掉侧滑返回，这里强制开回来
    navigationController.interactivePopGestureRecognizer.enabled = YES;
    if (@available(iOS 26, *)) {
        SEL sel = NSSelectorFromString(@"interactiveContentPopGestureRecognizer");
        if ([navigationController respondsToSelector:sel]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            UIGestureRecognizer *contentPop = [navigationController performSelector:sel];
#pragma clang diagnostic pop
            contentPop.enabled = YES;
        }
    }
}

+ (void)kaibbb_hookInteractivePopGestureDelegateIfNeeded:(UINavigationController *)navigationController {
    NSObject *delegate = navigationController.interactivePopGestureRecognizer.delegate;
    if (!delegate) {
        return;
    }
    Class delegateClass = delegate.class;
    [ZKHelper executeBlock:^{
        SEL selector1 = NSSelectorFromString(@"_gestureRecognizer:shouldReceiveEvent:");
        SEL selector2 = @selector(gestureRecognizer:shouldReceiveTouch:);

        BOOL (^isShowingZKBackBarButtonBlock)(UIView *) = ^BOOL(UIView *view) {
            UIViewController *viewController = view.viewController;
            if ([viewController isKindOfClass:UINavigationController.class]) {
                return [UINavigationItem kaibbb_isShowingCustomBackBarButtonInNavigationController:(UINavigationController *)viewController];
            }
            return NO;
        };

        if ([delegate respondsToSelector:selector1]) {
            OverrideImplementation(delegateClass, selector1, ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
                return ^BOOL(NSObject *selfObject, UIGestureRecognizer *firstArgv, UIEvent *secondArgv) {
                    if (isShowingZKBackBarButtonBlock(firstArgv.view)) {
                        return YES;
                    }
                    BOOL (*originSelectorIMP)(id, SEL, UIGestureRecognizer *, UIEvent *);
                    originSelectorIMP = (BOOL (*)(id, SEL, UIGestureRecognizer *, UIEvent *))originalIMPProvider();
                    return originSelectorIMP(selfObject, originCMD, firstArgv, secondArgv);
                };
            });
        }

        if ([delegate respondsToSelector:selector2]) {
            OverrideImplementation(delegateClass, selector2, ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
                return ^BOOL(NSObject *selfObject, UIGestureRecognizer *firstArgv, UITouch *secondArgv) {
                    if (isShowingZKBackBarButtonBlock(firstArgv.view)) {
                        return YES;
                    }
                    BOOL (*originSelectorIMP)(id, SEL, UIGestureRecognizer *, UITouch *);
                    originSelectorIMP = (BOOL (*)(id, SEL, UIGestureRecognizer *, UITouch *))originalIMPProvider();
                    return originSelectorIMP(selfObject, originCMD, firstArgv, secondArgv);
                };
            });
        }

        SEL shouldBegin = @selector(gestureRecognizerShouldBegin:);
        if ([delegate respondsToSelector:shouldBegin]) {
            OverrideImplementation(delegateClass, shouldBegin, ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
                return ^BOOL(NSObject *selfObject, UIGestureRecognizer *gestureRecognizer) {
                    UINavigationController *nav = nil;
                    if ([selfObject isKindOfClass:UINavigationController.class]) {
                        nav = (UINavigationController *)selfObject;
                    } else if ([selfObject respondsToSelector:@selector(navigationController)]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                        id value = [selfObject performSelector:@selector(navigationController)];
#pragma clang diagnostic pop
                        if ([value isKindOfClass:UINavigationController.class]) {
                            nav = value;
                        }
                    }
                    if (nav && gestureRecognizer == nav.interactivePopGestureRecognizer &&
                        [UINavigationItem kaibbb_isShowingCustomBackBarButtonInNavigationController:nav]) {
                        return nav.viewControllers.count > 1;
                    }
                    BOOL (*originSelectorIMP)(id, SEL, UIGestureRecognizer *);
                    originSelectorIMP = (BOOL (*)(id, SEL, UIGestureRecognizer *))originalIMPProvider();
                    return originSelectorIMP(selfObject, originCMD, gestureRecognizer);
                };
            });
        }
    } oncePerIdentifier:[NSString stringWithFormat:@"ZKBackBarButton %@", NSStringFromClass(delegateClass)]];
}

- (void)kaibbb_setLeftBarButtonItemsAndUpdateSystemBackButton:(NSArray<UIBarButtonItem *> *)items {
    if (kaibbb_orig_setLeftBarButtonItemsAnimated) {
        kaibbb_orig_setLeftBarButtonItemsAnimated(self, @selector(setLeftBarButtonItems:animated:), items, NO);
    } else {
        [self setLeftBarButtonItems:items animated:NO];
    }
    [self kaibbb_updateHidesBackButton];
}

/// 清理当前 leftBarButtonItems 里的所有自定义返回按钮，避免前一个界面的自定义返回按钮指针变了却没刷新当前界面的旧返回按钮。
- (NSMutableArray<UIBarButtonItem *> *)kaibbb_leftBarButtonItemsWithoutCustom {
    NSArray<UIBarButtonItem *> *filtered = [self.leftBarButtonItems filter:^BOOL(UIBarButtonItem *object) {
        return !object.customView.kaibbb_isViewOfZKBackBarButton;
    }];
    return filtered ? filtered.mutableCopy : [NSMutableArray array];
}

- (void)kaibbb_updateHidesBackButton {
    // 当需要显示自定义的返回按钮时，必须把系统的返回按钮隐藏掉，否则会看到两个返回按钮同时存在
    BOOL shouldShowCustomBackButton = self.leftBarButtonItems.firstObject.customView.kaibbb_isViewOfZKBackBarButton && (self.leftBarButtonItems.count == 1 || (self.leftBarButtonItems.count > 1 && self.leftItemsSupplementBackButton)) && !self.kaibbb_hidesBackButton;
    if (kaibbb_orig_setHidesBackButtonAnimated) {
        if (shouldShowCustomBackButton) {
            kaibbb_orig_setHidesBackButtonAnimated(self, @selector(setHidesBackButton:animated:), YES, NO);
        } else {
            kaibbb_orig_setHidesBackButtonAnimated(self, @selector(setHidesBackButton:animated:), self.kaibbb_hidesBackButton, NO);
        }
    } else if (shouldShowCustomBackButton) {
        [self setHidesBackButton:YES animated:NO];
    } else {
        [self setHidesBackButton:self.kaibbb_hidesBackButton animated:NO];
    }
}

#pragma mark - Associated

static char kAssociatedObjectKey_backBarButtonItem;
static char kAssociatedObjectKey_hidesBackButton;

- (void)setKaibbb_backBarButtonItem:(UIBarButtonItem *)kaibbb_backBarButtonItem {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_backBarButtonItem, kaibbb_backBarButtonItem, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIBarButtonItem *)kaibbb_backBarButtonItem {
    return (UIBarButtonItem *)objc_getAssociatedObject(self, &kAssociatedObjectKey_backBarButtonItem);
}

- (void)setKaibbb_hidesBackButton:(BOOL)kaibbb_hidesBackButton {
    [self setAssociateValue:@(kaibbb_hidesBackButton) withKey:&kAssociatedObjectKey_hidesBackButton];
}

- (BOOL)kaibbb_hidesBackButton {
    return [[self associatedValueForKey:&kAssociatedObjectKey_hidesBackButton] boolValue];
}

#pragma mark - Navigation Item Helpers

- (UINavigationBar *)kaibbb_navigationBar {
    if ([self respondsToSelector:@selector(navigationBar)]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        return [self performSelector:@selector(navigationBar)];
#pragma clang diagnostic pop
    }
    return nil;
}

- (UINavigationController *)kaibbb_navigationController {
    UINavigationBar *navigationBar = self.kaibbb_navigationBar;
    UINavigationController *navigationController = (UINavigationController *)navigationBar.superview.viewController;
    if ([navigationController isKindOfClass:UINavigationController.class]) {
        return navigationController;
    }
    return nil;
}

- (UIViewController *)kaibbb_viewController {
    UINavigationBar *navigationBar = self.kaibbb_navigationBar;
    UINavigationController *navigationController = self.kaibbb_navigationController;
    if (!navigationBar || !navigationController) return nil;

    NSInteger index = [navigationBar.items indexOfObject:self];
    if (index != NSNotFound && index < (NSInteger)navigationController.viewControllers.count) {
        return navigationController.viewControllers[index];
    }
    return nil;
}

- (UINavigationItem *)kaibbb_previousItem {
    NSArray<UINavigationItem *> *items = self.kaibbb_navigationBar.items;
    if (!items.count) return nil;
    NSInteger index = [items indexOfObject:self];
    if (index != NSNotFound && index > 0) return items[index - 1];
    return nil;
}

- (UINavigationItem *)kaibbb_nextItem {
    NSArray<UINavigationItem *> *items = self.kaibbb_navigationBar.items;
    if (!items.count) return nil;
    NSInteger index = [items indexOfObject:self];
    if (index != NSNotFound && index < (NSInteger)items.count - 1) return items[index + 1];
    return nil;
}

@end

@implementation UIView (ZKBackBarButton)

static char kAssociatedObjectKey_isViewOfZKBackBarButton;

- (void)setKaibbb_isViewOfZKBackBarButton:(BOOL)kaibbb_isViewOfZKBackBarButton {
    [self setAssociateValue:@(kaibbb_isViewOfZKBackBarButton) withKey:&kAssociatedObjectKey_isViewOfZKBackBarButton];
}

- (BOOL)kaibbb_isViewOfZKBackBarButton {
    return [[self associatedValueForKey:&kAssociatedObjectKey_isViewOfZKBackBarButton] boolValue];
}

@end
