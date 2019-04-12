//
//  ZKTableViewHelperInjectionDelegate.h
//  Pods
//
//  Created by Kaiser on 2019/4/10.
//

#ifndef ZKTableViewHelperInjectionDelegate_h
#define ZKTableViewHelperInjectionDelegate_h

@protocol ZKTableViewHelperInjectionDelegate <NSObject>

- (void)bindViewModel:(__kindof NSObject *)viewModel;

@end

#endif /* ZKTableViewHelperInjectionDelegate_h */
