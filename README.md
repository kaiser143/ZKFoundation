<h1 align="center">
ZKFoundation
</h1>
<p align="center">
<img src="https://img.shields.io/cocoapods/v/ZKFoundation.svg?style=flat" />
<img src="https://img.shields.io/badge/supporting-objectiveC-yellow.svg" />
<img src="https://img.shields.io/badge/license-MIT-brightgreen.svg" />
<img src="https://img.shields.io/badge/platform- iOS -lightgrey.svg" />
<img src="https://img.shields.io/badge/support-iOS 8.0+ -blue.svg?style=flat" />
</p>

<p align="center">
<strong>一个功能丰富的 iOS 开发基础框架，提供常用工具类和 UI 组件</strong>
</p>

<br>

## 📖 项目介绍

ZKFoundation 是一个专为 iOS 开发设计的基础框架，集成了常用的工具类、UI 组件和功能模块。它旨在简化 iOS 应用开发流程，提供可复用的组件和便捷的开发工具。

### 🎯 主要特性

- **模块化设计**: 支持按需引入不同功能模块
- **现代化 UI**: 提供丰富的自定义 UI 组件
- **位置服务**: 简化的位置管理和权限处理
- **表格适配器**: 强大的 TableView 和 CollectionView 数据绑定
- **导航栏过渡**: 流畅的导航栏动画效果
- **权限管理**: 统一的权限请求和处理
- **网络监控**: URL 协议日志记录功能

## 📱 功能预览

Here's how it looks like:

<p align="left">
<img src="https://github.com/kaiser143/ZKFoundation/raw/master/screenshot/screenshot1.png" width = "120">
<img src="https://github.com/kaiser143/ZKFoundation/raw/master/screenshot/screenshot2.png" width = "120">
<img src="https://github.com/kaiser143/ZKFoundation/raw/master/screenshot/screenshot3.png" width = "120">
<img src="https://github.com/kaiser143/ZKFoundation/raw/master/screenshot/screenshot4.png" width = "120">
<img src="https://github.com/kaiser143/ZKFoundation/raw/master/screenshot/screenshot5.png" width = "120">
</p>

## 🚀 核心模块

### 📍 LocationManager - 位置管理
提供简化的位置服务 API，支持单次定位、持续定位和方向监听：

```objc
// 单次定位
[[ZKLocationManager sharedInstance] requestLocationWithDesiredAccuracy:ZKLocationAccuracyCity
                                                                timeout:10.0
                                                                  block:^(CLLocation *location, ZKLocationAccuracy achievedAccuracy, ZKLocationStatus status) {
    if (status == ZKLocationStatusSuccess) {
        NSLog(@"定位成功: %@", location);
    }
}];

// 持续定位
[[ZKLocationManager sharedInstance] subscribeToLocationUpdatesWithBlock:^(CLLocation *location, ZKLocationAccuracy achievedAccuracy, ZKLocationStatus status) {
    // 处理位置更新
}];
```

### 🎨 UIKit - UI 组件
丰富的自定义 UI 组件集合：

- **ZKAlert**: 自定义弹窗组件
- **ZKButton**: 增强按钮组件
- **ZKTextField/ZKTextView**: 输入框组件
- **ZKPageControl**: 分页控制器
- **ZKSegmentControl**: 分段控制器
- **ZKTagsControl**: 标签控制器
- **ZKLoadingSpinner**: 加载动画
- **ZKPopupController**: 弹窗控制器

### 📋 Adapter - 数据适配器
强大的表格和集合视图数据绑定：

```objc
// TableView 适配器
ZKTableViewAdapter *adapter = [[ZKTableViewAdapter alloc] initWithTableView:tableView];
adapter.dataSource = @[@"Item 1", @"Item 2", @"Item 3"];

// 配置单元格
adapter.cellForRowAtIndexPathBlock = ^UITableViewCell *(UITableView *tableView, NSIndexPath *indexPath, id dataSource) {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    cell.textLabel.text = dataSource;
    return cell;
};

// 处理选择事件
adapter.didSelectRowAtIndexPathBlock = ^(UITableView *tableView, NSIndexPath *indexPath, id dataSource) {
    NSLog(@"选择了: %@", dataSource);
};
```

### 🔐 Permission - 权限管理
统一的权限请求和处理：

```objc
// 请求位置权限
[ZKPermission requestLocationPermissionWithCompletion:^(BOOL granted) {
    if (granted) {
        NSLog(@"位置权限已获取");
    }
}];
```

### 🧭 NavigationBarTransition - 导航栏过渡
流畅的导航栏动画效果：

```objc
// 在 ViewController 中启用导航栏过渡
 - (void)scrollViewDidScroll:(UIScrollView *)scrollView {
         CGFloat headerHeight = CGRectGetHeight(self.headerView.frame);
         if (@available(iOS 11, *)) {
             headerHeight -= self.view.safeAreaInsets.top;
         } else {
             headerHeight -= [self.topLayoutGuide length];
         }

         CGFloat progress         = scrollView.contentOffset.y + scrollView.contentInset.top;
         CGFloat gradientProgress = MIN(1, MAX(0, progress / headerHeight));
         gradientProgress         = gradientProgress * gradientProgress * gradientProgress * gradientProgress;
         if (gradientProgress != _gradientProgress) {
             _gradientProgress         = gradientProgress;
             [self kai_refreshNavigationBarStyle];
         }
}
```

### 🌐 URLProtocol - 网络监控
URL 协议日志记录功能：

```objc
// 启用网络日志记录
[ZKURLProtocolLogger enableLogging];
```

## 📦 如何安装

### 系统要求
- iOS 9.0+
- macOS 10.7+
- Xcode 10.0+

### CocoaPods 安装

ZKFoundation is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
# 安装完整版本
pod 'ZKFoundation', :git => 'https://github.com/kaiser143/ZKFoundation.git', :tag => '0.1.17'

# 安装特定提交版本
pod 'ZKFoundation', :git => 'https://github.com/kaiser143/ZKFoundation.git', :commit => 'xxxx'

# 按需安装特定模块
pod 'ZKFoundation/LocationManager'
pod 'ZKFoundation/UIKit'
pod 'ZKFoundation/Adapter'
pod 'ZKFoundation/Permission'
pod 'ZKFoundation/AuthContext'
pod 'ZKFoundation/URLProtocol'
```

### Swift Package Manager 安装

在 Xcode 中选择 **File → Add Package Dependencies...**，填入仓库地址：

```
https://github.com/kaiser143/ZKFoundation.git
```

或在 `Package.swift` 中添加依赖：

```swift
dependencies: [
    .package(url: "https://github.com/kaiser143/ZKFoundation.git", from: "0.1.22"),
],
targets: [
    .target(
        name: "YourTarget",
        dependencies: [
            .product(name: "ZKFoundation", package: "ZKFoundation"),
        ]
    ),
]
```

> ZKFoundation 依赖 [ZKCategories](https://github.com/kaiser143/ZKCategories)，SPM 会自动解析该依赖。

安装完成后在代码中导入：

```objc
#import <ZKFoundation/ZKFoundation.h>
```

### 手动安装

1. 下载项目源码
2. 将 `ZKFoundation/Classes/Source` 目录添加到你的项目中
3. 根据需要导入相应的头文件

## 🛠 快速开始

### 1. 导入框架

```objc
#import <ZKFoundation/ZKFoundation.h>
```

### 2. 使用位置服务

```objc
// 检查位置服务状态
if ([ZKLocationManager locationServicesState] == ZKLocationServicesStateAvailable) {
    // 请求位置
    [[ZKLocationManager sharedInstance] requestLocationWithDesiredAccuracy:ZKLocationAccuracyCity
                                                                    timeout:10.0
                                                                      block:^(CLLocation *location, ZKLocationAccuracy achievedAccuracy, ZKLocationStatus status) {
        // 处理位置结果
    }];
}
```

### 3. 使用自定义弹窗

```objc
ZKAlert *alert = [[ZKAlert alloc] initWithCancelButtonTitle:@"取消"];
[alert addAction:[ZKAlertAction actionWithTitle:@"确定" style:ZKAlertActionStyleDefault handler:^{
    NSLog(@"用户点击了确定");
}]];
[alert present];
```

### 4. 配置表格适配器

```objc
ZKTableViewAdapter *adapter = [[ZKTableViewAdapter alloc] initWithTableView:self.tableView];
adapter.dataSource = self.dataArray;

// 配置单元格
adapter.cellForRowAtIndexPathBlock = ^UITableViewCell *(UITableView *tableView, NSIndexPath *indexPath, id dataSource) {
    // 返回配置好的单元格
    return cell;
};

// 处理选择事件
adapter.didSelectRowAtIndexPathBlock = ^(UITableView *tableView, NSIndexPath *indexPath, id dataSource) {
    // 处理选择逻辑
};
```

## 📚 API 文档

详细的 API 文档请参考各个模块的头文件：

- [LocationManager API](ZKFoundation/Classes/Source/LocationManager/)
- [UIKit API](ZKFoundation/Classes/Source/UIKit/)
- [Adapter API](ZKFoundation/Classes/Source/Adapter/)
- [Permission API](ZKFoundation/Classes/Source/Permission/)

## 🤝 贡献指南

欢迎提交 Issue 和 Pull Request 来帮助改进这个项目。

### 开发环境设置

1. 克隆项目
```bash
git clone https://github.com/kaiser143/ZKFoundation.git
cd ZKFoundation
```

2. 安装依赖
```bash
pod install
```

3. 打开工作空间
```bash
open ZKFoundation.xcworkspace
```

## 📄 许可证

ZKFoundation is available under the MIT license. See the LICENSE file for more info.

## 👨‍💻 作者

**Kaiser** - [deyang143@126.com](mailto:deyang143@126.com)

## 🙏 致谢

感谢所有为这个项目做出贡献的开发者。

---

⭐ 如果这个项目对你有帮助，请给它一个星标！
