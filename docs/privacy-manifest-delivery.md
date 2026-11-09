# 隐私清单交付说明

> 适用版本：AppCan iOS 4.7.49｜2026-11-09

`PrivacyInfo.xcprivacy`是随App或SDK打包的机器声明；商店问卷、隐私政策是另外的材料。**4.7.49阶段暂不新增引擎和基础库的清单文件，也未新增自动装配功能，先开展业务测试。** 已有插件/第三方SDK的清单以实际包为准；暂缓不等于免除Apple要求。

引擎侧需核对自身及内置组件的机器声明（如NSUserDefaults访问理由），应用侧按实际功能披露网页存储、推送等数据行为。相机、位置等权限并非接入引擎的必填项，应根据所用插件或业务实际调用补充对应权限及用途说明，不能将本文示例全部照填。

| 您要做什么 | 直接使用 |
| --- | --- |
| 填写商店信息、审核备注或权限文案 | [上架填写模板](app-store-submission-guide.md) |
| 在隐私政策中披露AppCan及插件 | [SDK披露模板](sdk-data-practices.md) |
| Apple提示缺少清单 | 将下方模板交对应SDK或打包维护者；此处没有可复制进工程的机器清单 |

## 缺少清单时的反馈模板

**发送位置：对应SDK、插件或打包服务的支持渠道。** 引擎/插件维护者处理SDK声明，打包维护者核对资源是否进入最终App。

```text
应用版本/构建号：【填写】
引擎版本：4.7.49
插件及第三方SDK版本：【填写】
提交类型：【新App/已有App更新；本次是否新增SDK】
Apple错误码及原文：【粘贴相关段落】
报错中的SDK名称和包内路径：【填写】
```

不要在公开反馈中包含账号密码、Token、密钥或用户数据。收到具体反馈后，再核对相应清单内容与资源装配。

官方依据：[第三方SDK要求](https://developer.apple.com/support/third-party-SDK-requirements/) · [隐私清单文件](https://developer.apple.com/documentation/bundleresources/privacy-manifest-files)。
