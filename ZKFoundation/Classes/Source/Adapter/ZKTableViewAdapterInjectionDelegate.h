//
//  ZKTableViewHelperInjectionDelegate.h
//  Pods
//
//  Created by Kaiser on 2019/4/10.
//

#ifndef ZKTableViewAdapterInjectionDelegate_h
#define ZKTableViewAdapterInjectionDelegate_h

@protocol ZKTableViewAdapterInjectionDelegate <NSObject>

@optional
- (void)bindViewModel:(__kindof NSObject *)viewModel forIndexPath:(NSIndexPath *)indexPath;

@end

#endif /* ZKTableViewAdapterInjectionDelegate_h */
