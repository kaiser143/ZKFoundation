//
//  ZKTableViewHelperInjectionDelegate.h
//  Pods
//
//  Created by Kaiser on 2019/4/10.
//

#ifndef ZKTableViewHelperInjectionDelegate_h
#define ZKTableViewHelperInjectionDelegate_h

@protocol ZKTableViewHelperInjectionDelegate <NSObject>

@optional
- (void)bindViewModel:(__kindof NSObject *)viewModel forIndexPath:(NSIndexPath *)indexPath;

@end

#endif /* ZKTableViewHelperInjectionDelegate_h */
