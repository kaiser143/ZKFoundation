//
//  ZKTintedActionButton.h
//  ZKFoundation
//
//  Created by Kaiser on 2019/4/3.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/*!
 * A generic button that uses the view's tint color for background and highlight colors.
 * @code
    ZKTintedActionButton *action = [ZKTintedActionButton buttonWithType:UIButtonTypeCustom];
    action.tintColor             = UIColor.redColor;
    action.layer.cornerRadius    = <#radius#>;
    [action setTitle:@"<#Title#>" forState:UIControlStateNormal];
    [action addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [<#view#> addSubview:action];
 * @endcode
 */
@interface ZKTintedActionButton : UIButton

@end

NS_ASSUME_NONNULL_END
