//
//  ZKTableViewSwitchCell.h
//  ZKFoundation
//
//  Created by zhangkai on 2021/7/28.
//  Copyright © 2021 zhangkai. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ZKTableViewAdapterInjectionDelegate;

NS_ASSUME_NONNULL_BEGIN

/**
 *	@brief	<#Description#>
 */
@interface ZKTableViewSwitchCell : UITableViewCell <ZKTableViewAdapterInjectionDelegate> @end

NS_ASSUME_NONNULL_END
