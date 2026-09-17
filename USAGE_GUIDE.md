# like-ios 底部抽屉操作说明文档

本文档用于指导开发者在 OpenHarmony/HarmonyOS 项目中接入、验证、调试和发布 `workbench-drawer` like-ios 毛玻璃底部抽屉组件。当前发布包最低兼容 HarmonyOS API 12。

## 1. 目录说明

```text
drawer
├── CHANGELOG.md
├── LICENSE
├── PUBLISH_CHECKLIST.md
├── README.md
├── USAGE_GUIDE.md
├── build-profile.json5
├── example
│   └── WorkbenchDrawerUsage.ets
├── examples
│   └── WorkbenchDrawerUsage.ets
├── Index.ets
├── oh-package.json5
└── src
    └── main
        ├── ets
        │   ├── components
        │   │   └── WorkbenchDrawer.ets
        │   ├── constants
        │   │   └── DrawerConstants.ets
        │   ├── model
        │   │   └── DrawerTypes.ets
        │   └── utils
        │       └── DrawerMath.ets
        └── module.json5
```

说明：

- `Index.ets`：三方库统一导出入口，需与 `oh-package.json5` 的 `main` 保持一致。
- `src/main/ets/components/WorkbenchDrawer.ets`：类 iOS 底部抽屉组件主体。
- `src/main/ets/model/DrawerTypes.ets`：对外枚举类型。
- `src/main/ets/constants/DrawerConstants.ets`：默认尺寸和行为常量。
- `example/WorkbenchDrawerUsage.ets`：三方库平台识别用接入页。
- `examples/WorkbenchDrawerUsage.ets`：本地验证接入页。

## 2. 本地接入

在宿主项目的 `oh-package.json5` 中添加本地依赖：

```json5
{
  "dependencies": {
    "workbench-drawer": "file:../drawer"
  }
}
```

如果 `drawer` 位于宿主项目根目录下，也可以按相对路径调整：

```json5
{
  "dependencies": {
    "workbench-drawer": "file:./drawer"
  }
}
```

安装依赖：

```bash
ohpm install
```

如果本地目录包含中文、空格或括号，建议先复制到纯 ASCII 路径再做 `hvigor` 构建校验；当前 DevEco / hvigor 工具链在这类路径下可能报 `Invalid project path`。

建议的本地构建环境变量：

```bash
export DEVECO_SDK_HOME='/Applications/DevEco-Studio.app/Contents/sdk'
```

## 3. 基础使用

在页面中导入：

```ts
import { WorkbenchDrawer, DrawerSnapMode } from 'workbench-drawer'
```

最小接入方式：

```ts
@Entry
@Component
struct TaskWorkbenchPage {
  build() {
    Stack() {
      Column() {
        Text('宿主页面内容')
      }
      .width('100%')
      .height('100%')

      WorkbenchDrawer({
        title: '任务',
        contentText: '默认内容区域',
        collapsedHeight: 56,
        expandedHeight: 680,
        drawerWidth: '100%',
        snapMode: DrawerSnapMode.DirectionAndHalf
      })
    }
    .width('100%')
    .height('100%')
  }
}
```

注意：

- 推荐将 `WorkbenchDrawer` 放在 `Stack` 的最后一层，确保展示在页面内容上方。
- 外层容器必须有明确高度，例如 `.height('100%')`，否则组件无法计算最大展开高度。

## 4. 自定义标题区域

当默认标题区域无法满足业务需求时，可传入 `titleBuilder`。

```ts
@Builder
function CustomTitleBuilder() {
  Row() {
    Text('任务')
      .fontSize(18)
      .fontWeight(FontWeight.Bold)
      .layoutWeight(1)

    Text('+')
      .fontSize(24)
  }
  .height(48)
  .padding({ left: 16, right: 16 })
  .alignItems(VerticalAlign.Center)
}
```

使用：

```ts
WorkbenchDrawer({
  titleBuilder: CustomTitleBuilder
})
```

## 5. 自定义内容区域

当需要放入列表、Tabs、筛选器或业务卡片时，可传入 `contentBuilder`。

```ts
@Builder
function CustomContentBuilder() {
  Column() {
    Text('我的待办列表')
      .fontSize(16)
  }
  .width('100%')
  .layoutWeight(1)
  .justifyContent(FlexAlign.Center)
  .alignItems(HorizontalAlign.Center)
}
```

使用：

```ts
WorkbenchDrawer({
  contentBuilder: CustomContentBuilder
})
```

## 6. 拖拽配置

### 6.1 默认仅标题/手柄区域拖拽

```ts
WorkbenchDrawer({
  enableDrag: true,
  enableContentDrag: false
})
```

适合内容区域有复杂点击、横向滑动、纵向列表滚动的场景，也是组件默认行为。

### 6.2 允许内容区域拖拽

```ts
WorkbenchDrawer({
  enableDrag: true,
  enableContentDrag: true
})
```

效果：

- 标题区域可拖拽。
- 内容区域也可上下拖拽。

### 6.3 禁止拖拽

```ts
WorkbenchDrawer({
  enableDrag: false
})
```

适合只通过外部状态控制展示的场景。

## 7. 吸附规则

组件提供三种吸附规则：

```ts
DrawerSnapMode.Direction
DrawerSnapMode.Half
DrawerSnapMode.DirectionAndHalf
```

接入方式：

```ts
WorkbenchDrawer({
  snapMode: DrawerSnapMode.DirectionAndHalf
})
```

说明：

- `Direction`：松手后根据上滑/下滑方向决定展开或收起。
- `Half`：松手时超过中间高度则展开，否则收起。
- `DirectionAndHalf`：如果拖拽方向明显则按方向，否则按一半高度判断。

## 8. 遮罩配置

开启遮罩：

```ts
WorkbenchDrawer({
  showMask: true,
  closeOnMaskClick: true,
  maskColor: '#000000',
  maskOpacity: 0.35
})
```

说明：

- `showMask` 为 `true` 时，抽屉展开后展示遮罩。
- `closeOnMaskClick` 为 `true` 时，点击遮罩会收起抽屉。

## 9. 尺寸配置

### 9.1 高度配置

```ts
WorkbenchDrawer({
  collapsedHeight: 56,
  expandedHeight: 700,
  maxHeightRatio: 0.92
})
```

说明：

- `collapsedHeight`：收起时露出的高度。
- `expandedHeight`：期望展开高度。
- `maxHeightRatio`：最大高度占父容器高度比例，防止超出屏幕。

### 9.2 宽度配置

```ts
WorkbenchDrawer({
  drawerWidth: '100%'
})
```

也可以设置为固定 vp 宽度：

```ts
WorkbenchDrawer({
  drawerWidth: 360
})
```

说明：

- `drawerWidth` 默认值为 `'100%'`，即占满父容器宽度。
- 当设置为固定数值时，抽屉会保持底部居中展示。
- 建议移动端使用 `'100%'`，平板或桌面化场景可使用固定宽度。

## 10. 回调监听

监听高度变化：

```ts
WorkbenchDrawer({
  onHeightChange: (height: number) => {
    console.info(`drawer height: ${height}`)
  }
})
```

监听展开状态：

```ts
WorkbenchDrawer({
  onExpandedChange: (isExpanded: boolean) => {
    console.info(`drawer expanded: ${isExpanded}`)
  }
})
```

## 11. 本地验证步骤

1. 将 `drawer` 目录放在宿主项目根目录或同级目录。
2. 在宿主项目 `oh-package.json5` 中添加 `file:` 依赖。
3. 执行 `ohpm install`。
4. 在页面中导入 `WorkbenchDrawer`。
5. 将组件放入 `Stack` 最后一层。
6. 运行项目，验证以下场景：

- 默认标题和默认内容是否展示。
- 自定义标题是否替换默认标题。
- 自定义内容是否替换默认内容。
- 上滑是否展开。
- 下滑是否收起。
- 超过一半高度松手是否吸附正确。
- 内容区域点击是否正常。
- `enableContentDrag=false` 时内容区域是否不再触发抽屉拖拽。
- `showMask=true` 时遮罩是否展示，点击是否收起。

## 12. 打包与发布

发布前确认：

```bash
ohpm install
```

执行本地校验或构建命令，具体以当前 DevEco Studio / OpenHarmony SDK 版本为准。

建议发布前先生成 HAR 或 tgz 包，再执行发布前检查：

```bash
ohpm prepublish <har_or_tgz_file>
```

如果当前 ohpm 版本或平台要求不同，请以 DevEco Studio / OpenHarmony SDK 提供的校验命令为准。

## 13. 常见问题

### 13.1 抽屉不显示

检查外层是否为 `Stack`，并且是否设置了宽高：

```ts
Stack() {
  WorkbenchDrawer()
}
.width('100%')
.height('100%')
```

### 13.2 抽屉展开高度不对

检查：

- 父容器是否有明确高度。
- `expandedHeight` 是否大于 `collapsedHeight`。
- `maxHeightRatio` 是否过小。

### 13.3 内容区域点击和拖拽冲突

如果内容区域有复杂列表、Tabs 或横向滚动，建议：

```ts
WorkbenchDrawer({
  enableContentDrag: false
})
```

这样只有标题区域和把手区域会触发抽屉拖拽。

### 13.4 自定义内容没有撑满

自定义内容建议设置：

```ts
.width('100%')
.layoutWeight(1)
```

## 14. 上架前最终检查

- `README.md` 是否说明安装、导入、基础用法、自定义用法、API。
- `USAGE_GUIDE.md` 是否说明接入、验证、发布流程。
- `CHANGELOG.md` 是否记录版本变化。
- `LICENSE` 是否存在。
- `oh-package.json5` 的 `name/version/main/license` 是否正确。
- `Index.ets` 是否导出所有公开 API。
- 发布包兼容说明是否与三方库中心展示一致：当前为 HarmonyOS API 12。
- 代码中是否存在宿主工程业务依赖。
- 是否在独立验证工程中完成验证。
