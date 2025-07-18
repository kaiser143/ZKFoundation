//
//  ZKFoundation.h
//  ZKFoundation
//
//  Created by Kaiser on 2019/4/8.
//

#ifndef ZKFoundation_h
#define ZKFoundation_h

#if __has_include(<ZKFoundation/ZKFoundation.h>)

    #import <ZKFoundation/ZKApp.h>
    #import <ZKFoundation/ZKFolderMonitor.h>
    #import <ZKFoundation/ZKVersion.h>
    #import <ZKFoundation/ZKAuthContext.h>
    #import <ZKFoundation/UICollectionView+ZKAdapter.h>
    #import <ZKFoundation/UITableView+ZKAdapter.h>
    #import <ZKFoundation/UIView+ZKHelper.h>
    #import <ZKFoundation/UITableViewHeaderFooterView+ZKHelper.h>
    #import <ZKFoundation/ZKCollectionViewAdapter.h>
    #import <ZKFoundation/ZKTableViewAdapter.h>
    #import <ZKFoundation/ZKTableViewAdapterInjectionDelegate.h>
    #import <ZKFoundation/ZKCollectionViewAdapterInjectionDelegate.h>
    #import <ZKFoundation/ZKScrollViewAdapter.h>
    #import <ZKFoundation/ZKHeadingRequest.h>
    #import <ZKFoundation/ZKLocationManager.h>
    #import <ZKFoundation/ZKLocationManager+Internal.h>
    #import <ZKFoundation/ZKLocationRequest.h>
    #import <ZKFoundation/ZKLocationRequestDefines.h>
    #import <ZKFoundation/ZKRequestIDGenerator.h>
    #import <ZKFoundation/ZKButton.h>
    #import <ZKFoundation/ZKAlert.h>
    #import <ZKFoundation/ZKTextField.h>
    #import <ZKFoundation/ZKTextView.h>
    #import <ZKFoundation/ZKPageControl.h>
    #import <ZKFoundation/ZKTintedActionButton.h>
    #import <ZKFoundation/ZKFloatLayoutView.h>
    #import <ZKFoundation/ZKInitialsPlaceholderView.h>
    #import <ZKFoundation/ZKPopupController.h>
    #import <ZKFoundation/ZKLoadingSpinner.h>
    #import <ZKFoundation/ZKSegmentControl.h>
    #import <ZKFoundation/ZKHTTPURLResponse.h>
    #import <ZKFoundation/ZKStretchyHeaderView.h>
    #import <ZKFoundation/ZKPermission.h>
    #import <ZKFoundation/ZKNavigationBarProtocol.h>
    #import <ZKFoundation/ZKNavigationController.h>
    #import <ZKFoundation/ZKNavigationBarTransitionCenter.h>
    #import <ZKFoundation/UIViewController+ZKNavigationBarTransition.h>
    #import <ZKFoundation/ZKStorkInteractiveTransition.h>
    #import <ZKFoundation/ZKTagsControl.h>
    #import <ZKFoundation/ZKURLProtocolLogger.h>
    #import <ZKFoundation/ZKKeyboardManager.h>

#else

    #import "ZKApp.h"
    #import "ZKFolderMonitor.h"
    #import "ZKVersion.h"
    #import "ZKAuthContext.h"
    #import "UICollectionView+ZKAdapter.h"
    #import "UITableView+ZKAdapter.h"
    #import "UIView+ZKHelper.h"
    #import "UITableViewHeaderFooterView+ZKHelper.h"
    #import "ZKCollectionViewAdapter.h"
    #import "ZKTableViewAdapter.h"
    #import "ZKScrollViewAdapter.h"
    #import "ZKTableViewAdapterInjectionDelegate.h"
    #import "ZKCollectionViewAdapterInjectionDelegate.h"
    #import "ZKHeadingRequest.h"
    #import "ZKLocationManager.h"
    #import "ZKLocationManaget+Internal.h"
    #import "ZKLocationRequest.h"
    #import "ZKLocationRequestDefines.h"
    #import "ZKRequestIDGenerator.h"
    #import "ZKButton.h"
    #import "ZKAlert.h"
    #import "ZKTextField.h"
    #import "ZKTextView.h"
    #import "ZKPageControl.h"
    #import "ZKTintedActionButton.h"
    #import "ZKFloatLayoutView.h"
    #import "ZKInitialsPlaceholderView.h"
    #import "ZKPopupController.h"
    #import "ZKLoadingSpinner.h"
    #import "ZKSegmentControl.h"
    #import "ZKHTTPURLResponse.h"
    #import "ZKStretchyHeaderView.h"
    #import "ZKPermission.h"
    #import "ZKNavigationBarProtocol.h"
    #import "ZKNavigationController.h"
    #import "ZKNavigationBarTransitionCenter.h"
    #import "UIViewController+ZKNavigationBarTransition.h"
    #import "ZKStorkInteractiveTransition.h"
    #import "ZKTagsControl.h"
    #import "ZKURLProtocolLogger.h"
    #import "ZKKeyboardManager.h"
#endif /* __has_include*/

#endif /* ZKFoundation_h */
