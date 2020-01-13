//
//  ZKCollectionViewHelperInjectionDelegate.h
//  Pods
//
//  Created by Kaiser on 2019/5/23.
//

#ifndef ZKCollectionViewHelperInjectionDelegate_h
#define ZKCollectionViewHelperInjectionDelegate_h

@protocol ZKCollectionViewHelperInjectionDelegate<NSObject>

@optional
- (void)bindViewModel:(__kindof NSObject *)viewModel forItemAtIndexPath:(NSIndexPath *)indexPath;

@end

#endif /* ZKCollectionViewHelperInjectionDelegate_h */
