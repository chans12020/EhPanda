# EhPanda 的 iPhone Duo 适配

本分支实现了响应折叠和窗口尺寸变化的布局，最低运行版本仍为 iOS 26。编译需要 **Xcode 27.1 或更新版本及 iOS 27.1+ SDK**；`ArrangementView` 在 iOS 27.1+ 启用，旧系统使用叠加布局。

## 已修改

- 用当前内容容器的 `onGeometryChange` 测量取代 `UIScreen.main`、全局窗口宽度及设备型号布局判断。弹窗、列表和阅读区域分别测量自己的空间。
- 缩略图网格随宽度调整列数；卡片、预览、搜索历史、分类和设置表单响应尺寸变化。保留已保存的列表模式。
- 统一使用 `NavigationStack` 和绑定 reducer 路由的目的地，详情不再根据设备类型切换为弹窗。设置始终使用原生标签页，调整尺寸不会切换导航方式。
- 全局允许全部方向。历史设置中的 `enablesLandscape` 字段保留以兼容存量数据，界面不再提供强制竖屏开关。
- 阅读器按实际页面容器决定单双页：开启“双页模式”，且宽度至少 640 点、高度至少 300 点时显示双页。该阈值是内容空间要求，不对应某个硬件型号。改变尺寸或封面模式时保留选中的精确页码。
- 阅读器采用 `ArrangementView(.overlay)`：展开/闭合时叠加控制层，半折叠时由系统将页面和控件安置到折叠区域两侧。正文保持适合比例，只有背景延伸至安全区外。手势使用阅读区域的尺寸和原点。
- 阅读控件在窄空间分行，空间高度不足时允许滚动。工具栏采用系统分组和语义位置，为筛选、快速搜索、跳页及更多菜单提供图标和标题。

## 本地检查与构建

从仓库根目录运行：

```sh
./actions-tool/check-duo-layout.sh
```

该检查会实际编译并运行生产代码中的布局与分页逻辑，覆盖空尺寸、窄/宽/方形/矮容器，以及 1–100 页画廊在单双页、封面单页、左右阅读方向下的页码覆盖与切换。它不替代 iOS UI 测试。

在装有 Xcode 27.1+ 的 Mac 上选中对应开发目录，然后运行：

```sh
DEVELOPER_DIR=/Applications/Xcode_27.1.app/Contents/Developer \
  ./actions-tool/build-duo.sh
```

要直接构建可供侧载工具重新签名的 IPA，运行：

```sh
DEVELOPER_DIR=/Applications/Xcode_27.1.app/Contents/Developer \
  ./actions-tool/build-duo-ipa.sh
```

输出为 `build/EhPanda-Duo-unsigned.ipa`。脚本先完成真机归档，再校验 iPhoneOS 平台和 arm64 架构并打包；不会把模拟器程序或源码打包成 IPA。该包未签名，安装时需要侧载工具完成签名。

默认输出未签名归档 `build/EhPanda-Duo.xcarchive`。此归档还不能直接安装到手机；需要在 Xcode 中设置自己的 Team、签名和相应标识符后构建/导出安装包。

测试工作流已切换至 Xcode 27.1，并增加 iPhone Duo / iPhone Air 模拟器矩阵。运行器必须提供 `/Applications/Xcode_27.1.app`，并安装对应 iOS 运行时；可用设备名称可通过 `xcrun simctl list devices available` 确认。

## Device Hub / 真机验收

使用 Xcode 27.1 的 iPhone Duo 模拟器逐项检查：

1. 从首页、收藏、搜索进入详情，再打开评论、预览和设置；反复折叠、展开及旋转，确认返回路径、选中标签和表单输入保留。
2. 阅读第 2、7 页及最后一页，启用双页模式；分别检查封面单页开/关、左右方向和纵向阅读。展开后原页仍在当前跨页中，折回后仍是原页。
3. 半折叠后确认正文和控制面板分处折叠区域两侧；切换竖向与横向姿态，检查控制区预览、滑条、退出、设置及缩放后的拖动。
4. 在外屏和窄窗口中检查竖向工具栏、更多菜单、长标题、大字号、键盘和弹窗；确保内容不被系统栏或摄像头遮挡。
5. 使用 Device Hub 的可调整尺寸模拟器测试极窄、近方形和矮窗口，并回归普通 iPhone、iPad 分屏及 iOS 26 的回退布局。

## 验证状态

当前开发机只有 Command Line Tools，没有完整 Xcode 和 iOS 模拟器。因此本次已完成独立布局/分页检查、Swift 源码语法检查、SwiftUI 测量辅助代码的 macOS 类型检查及项目/plist 校验；**尚未完成整个 iOS 应用编译、模拟器/真机验收或 IPA 导出**。首次在 Xcode 构建时还需解析原项目的 Swift Package 依赖。

## Apple 官方参考

- [Three steps to make your app shine on iPhone Duo](https://developer.apple.com/iphone-duo/prepare/)
- [Preparing your app for iPhone Duo](https://developer.apple.com/documentation/technologyoverviews/preparing-your-app-for-iphone-duo)
- [ArrangementView](https://developer.apple.com/documentation/swiftui/arrangementview)

查阅日期：2026-10-26。

## GitHub Actions 构建 IPA

`Build iPhone Duo IPA` 工作流使用 GitHub 的 `xcode-27` 镜像与 Xcode 27.1，向 `codex/iphone-duo-adaptation` 分支推送时自动构建。成功后下载 `EhPanda-Duo-unsigned` 附件，其中包含 IPA 和 SHA-256 校验文件。IPA 仍需由 Sideloadly 等侧载工具重新签名后安装。构建失败时可下载 `EhPanda-Duo-build-log` 查看编译日志。
