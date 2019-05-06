//
//  ZKFoundation.h
//  Pods
//
//  Created by Kaiser on 2019/4/8.
//

#ifndef ZKFoundation_h
#define ZKFoundation_h

#if __has_include(<ZKCategories/ZKCategories.h>)

#import <ZKFoundation/ZKApp.h>
#import <ZKFoundation/ZKFolderMonitor.h>
#import <ZKFoundation/ZKVersion.h>
#import <ZKFoundation/ZKAuthContext.h>
#import <ZKFoundation/UICollectionView+ZKHelper.h>
#import <ZKFoundation/UITableView+ZKHelper.h>
#import <ZKFoundation/UIView+ZKHelper.h>
#import <ZKFoundation/ZKCollectionViewHelper.h>
#import <ZKFoundation/ZKTableViewHelper.h>
#import <ZKFoundation/ZKTableViewHelperInjectionDelegate.h>
#import <ZKFoundation/ZKHeadingRequest.h>
#import <ZKFoundation/ZKLocationManager.h>
#import <ZKFoundation/ZKLocationManager+Internal.h>
#import <ZKFoundation/ZKLocationRequest.h>
#import <ZKFoundation/ZKLocationRequestDefines.h>
#import <ZKFoundation/ZKRequestIDGenerator.h>
#import <ZKFoundation/ZKButton.h>
#import <ZKFoundation/ZKPageControl.h>
#import <ZKFoundation/ZKTintedActionButton.h>
#import <ZKFoundation/ZKInitialsPlaceholderView.h>
#import <ZKFoundation/ZKPopupController.h>
#import <ZKFoundation/ZKLoadingSpinner.h>
#import <ZKFoundation/ZKSegmentControl.h>

#else

#import "ZKApp.h"
#import "ZKFolderMonitor.h"
#import "ZKVersion.h"
#import "ZKAuthContext.h"
#import "UICollectionView+ZKHelper.h"
#import "UITableView+ZKHelper.h"
#import "UIView+ZKHelper.h"
#import "ZKCollectionViewHelper.h"
#import "ZKTableViewHelper.h"
#import "ZKTableViewHelperInjectionDelegate.h"
#import "ZKHeadingRequest.h"
#import "ZKLocationManager.h"
#import "ZKLocationManaget+Internal.h"
#import "ZKLocationRequest.h"
#import "ZKLocationRequestDefines.h"
#import "ZKRequestIDGenerator.h"
#import "ZKButton.h"
#import "ZKPageControl.h"
#import "ZKTintedActionButton.h"
#import "ZKInitialsPlaceholderView.h"
#import "ZKPopupController.h"
#import "ZKLoadingSpinner.h"
#import "ZKSegmentControl.h"

#endif /* __has_include*/

#endif /* ZKFoundation_h */
