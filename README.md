# 丫丫课程表

一个基于 Flutter 的本地课程表应用，包含课表展示、待办事项、课程提醒，以及可扩展的自动导课入口。
四川大学目前可直接导课
目前仅提供 ios 端预览，其他端预览待加入

源码构建不包含学校内容（我们为了防止滥用，你可以自行创建或者直接下载二进制版本）

本项目为非盈利性项目，禁止商用，如果喜欢可以给一颗星星

## 预览（仅 ios 端）

<p align="center">
  <img src="images/Simulator-Screenshot---iPhone-17---2026-03-26-at-12.00.51-iphone-1284x2778.png" alt="首页预览" width="23%" />
  <img src="images/Simulator-Screenshot---iPhone-17---2026-03-26-at-11.59.35-iphone-1284x2778.png" alt="课表预览" width="23%" />
  <img src="images/Simulator-Screenshot---iPhone-17---2026-03-26-at-12.00.42-iphone-1284x2778.png" alt="待办预览" width="23%" />
  <img src="images/Simulator-Screenshot---iPhone-17---2026-03-26-at-11.57.05-iphone-1284x2778.png" alt="设置预览" width="23%" />
</p>

## 开发环境

- Flutter 3.x
- Dart 3.x
- Android Studio / Xcode（按目标平台准备）

## 本地运行

```bash
flutter pub get
flutter run
```

## 从源码构建

这个仓库默认**不包含学校自动导课分析源码**。

出于隐私和适配隔离考虑，`lib/features/import/` 已被加入 Git 忽略规则，因此你从仓库拉取到的源码里，可能不会带有任何学校教务系统的自动分析、页面抓取或解析实现。

这意味着：

- 项目的通用课表、待办、通知等主功能仍然可以继续开发。
- 如果你要从源码直接构建带有“自动导课”能力的版本，需要你自己补充学校适配代码。
- 不同学校的教务系统 HTML 结构、登录流程、字段命名都不同，不能直接复用别的学校规则。
