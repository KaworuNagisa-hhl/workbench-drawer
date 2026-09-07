# workbench-drawer

一个面向 OpenHarmony/HarmonyOS ArkUI 的 like-ios 毛玻璃底部抽屉组件，提供类似 iOS 底部面板的上滑展开、下滑收起、吸附回弹与遮罩交互效果；支持默认标题区域、默认内容区域、自定义标题区域、自定义内容区域等能力。当前发布包最低兼容 HarmonyOS API 12。

## 实际运行效果

下面是组件在业务页面中的底部抽屉形态，包含收起、拖拽中、展开三种状态：

![workbench drawer preview](https://cdn.jsdelivr.net/gh/KaworuNagisa-hhl/workbench-drawer@main/docs/workbench-drawer-preview.gif)

## 特性

- 默认可用：只传 `title` 和 `contentText` 即可展示抽屉。
- 可自定义：通过 `titleBuilder` 和 `contentBuilder` 替换标题区域与内容区域。
- like-ios 交互：支持上滑展开、下滑收起、方向吸附、半高吸附与回弹动画。
- 毛玻璃外观：默认支持半透明面板、背景模糊、圆角、细边框和柔和阴影。
- 拖拽配置：默认仅标题/手柄区域拖拽，也支持关闭拖拽。
- 手势更安全：内容区默认不接管拖拽，按钮、列表、横向滑动和主页面滚动都能优先响应。
- 动画更稳定：拖拽期间不会因外层尺寸变化反复重置抽屉高度，减少上拉下拉卡顿与跳动。
- 尺寸配置：支持设置收起高度、展开高度、最大高度比例和抽屉宽度。
- 无业务依赖：不依赖接口、不依赖宿主工程资源、不依赖三方包。
- 适配三方库发布：包含 `oh-package.json5`、`Index.ets`、`README.md`、`CHANGELOG.md`、`LICENSE`。

## 安装

本地源码依赖：

```json5
{
  "dependencies": {
    "workbench-drawer": "file:../drawer"
  }
}
```

发布到 ohpm 后，可通过以下命令安装：

```bash
ohpm install workbench-drawer
```

也可以使用简写命令：

```bash
ohpm i workbench-drawer
```

## 正常使用样式

更完整的接入、调试、发布流程请查看 [USAGE_GUIDE.md](./USAGE_GUIDE.md)。

```ts
import {
  WorkbenchDrawer,
  DrawerSnapMode
} from 'workbench-drawer'
```

```ts
@Entry
@Component
struct TaskWorkbenchPage {
  build() {
    Stack() {
      Column() {
        Text('页面内容')
      }
      .width('100%')
      .height('100%')

      WorkbenchDrawer({
        title: '今日任务',
        contentText: '上滑查看任务详情，点击内容区按钮和列表不会被抽屉抢手势。',
        initialExpanded: false,
        collapsedHeight: 56,
        expandedHeight: 640,
        drawerWidth: '100%',
        snapMode: DrawerSnapMode.DirectionAndHalf
      })
    }
    .width('100%')
    .height('100%')
  }
}
```

## 自定义品牌样式

抽屉默认使用 like-ios 半透明毛玻璃面板。业务方可以覆盖面板宽高、背景色、圆角、内边距、阴影、遮罩和吸附行为。

## 自定义标题区域与内容区域

```ts
@Builder
function CustomTitle() {
  Row() {
    Text('今日任务')
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

@Builder
function CustomContent() {
  Column({ space: 12 }) {
    Text('待处理事项')
      .fontSize(18)
      .fontWeight(FontWeight.Bold)

    Text('完成晚间用药确认，并补充一次血压记录。')
      .fontSize(14)
      .fontColor('#667085')
  }
  .width('100%')
  .layoutWeight(1)
  .justifyContent(FlexAlign.Center)
  .alignItems(HorizontalAlign.Center)
}
```

```ts
WorkbenchDrawer({
  initialExpanded: true,
  collapsedHeight: 56,
  expandedHeight: 700,
  drawerWidth: 360,
  drawerBackgroundColor: '#E8FFFFFF',
  drawerBorderRadius: 18,
  contentPadding: 16,
  shadowColor: '#22000000',
  enableContentDrag: true,
  showMask: true,
  titleBuilder: CustomTitle,
  contentBuilder: CustomContent,
  onExpandedChange: (isExpanded: boolean) => {
    console.info(`drawer expanded: ${isExpanded}`)
  }
})
```

### 关于内容区交互

如果你的 `contentBuilder` 里放的是：
- 横向 `Scroll`
- Tabs
- Banner / Swiper
- 横向卡片列表
- 按钮、表单或纵向列表

当前版本默认只允许标题/手柄区域拖拽，内容区优先交给子组件处理点击、横向滑动和列表滚动，避免抽屉抢手势造成按钮失效或主页面滚动被影响。

## API

| 参数 | 类型 | 默认值 | 说明 |
| --- | --- | --- | --- |
| `title` | `ResourceStr` | `'任务'` | 默认标题文本 |
| `contentText` | `ResourceStr` | 默认提示 | 默认内容文本 |
| `initialExpanded` | `boolean` | `false` | 初始是否展开 |
| `collapsedHeight` | `number` | `56` | 收起高度，单位 vp |
| `expandedHeight` | `number` | `700` | 展开高度，单位 vp |
| `maxHeightRatio` | `number` | `0.92` | 展开高度占父容器最大比例 |
| `drawerWidth` | `Length` | `'100%'` | 抽屉面板宽度，支持 `'100%'`、`'80%'`、`360` 等写法 |
| `animationDuration` | `number` | `180` | 吸附动画时长 |
| `dragThreshold` | `number` | `12` | 拖拽方向判定阈值 |
| `snapMode` | `DrawerSnapMode` | `DirectionAndHalf` | 吸附规则 |
| `enableDrag` | `boolean` | `true` | 是否允许拖拽 |
| `enableContentDrag` | `boolean` | `false` | 是否允许内容区拖拽，默认关闭以保护内容区点击和滚动 |
| `showHandle` | `boolean` | `true` | 是否展示顶部拖拽把手 |
| `showMask` | `boolean` | `false` | 展开时是否展示遮罩 |
| `closeOnMaskClick` | `boolean` | `true` | 点击遮罩是否收起 |
| `drawerBackgroundColor` | `ResourceColor` | `'#E8FFFFFF'` | 毛玻璃抽屉背景色 |
| `maskColor` | `ResourceColor` | `'#000000'` | 遮罩颜色 |
| `maskOpacity` | `number` | `0.35` | 遮罩透明度 |
| `drawerBorderRadius` | `number` | `16` | 顶部圆角 |
| `titleHeight` | `number` | `44` | 默认标题栏高度 |
| `contentPadding` | `number` | `16` | 默认内容内边距 |
| `shadowColor` | `ResourceColor` | `'#22000000'` | 阴影颜色 |
| `onHeightChange` | `(height: number) => void` | 空函数 | 高度变化回调 |
| `onExpandedChange` | `(isExpanded: boolean) => void` | 空函数 | 展开状态变化回调 |
| `titleBuilder` | `() => void` | 无 | 自定义标题区域 |
| `contentBuilder` | `() => void` | 无 | 自定义内容区域 |

## DrawerSnapMode

| 枚举 | 说明 |
| --- | --- |
| `DrawerSnapMode.Direction` | 松手后按拖动方向展开或收起 |
| `DrawerSnapMode.Half` | 松手后超过展开高度一半则展开，否则收起 |
| `DrawerSnapMode.DirectionAndHalf` | 优先响应明显拖动方向，否则按一半高度吸附 |

## 三方库上架前检查

- `oh-package.json5` 中 `name/version/main/license/description` 已配置。
- `README.md`、`CHANGELOG.md`、`LICENSE` 已提供且非空。
- `Index.ets` 统一导出对外 API。
- 源码不依赖宿主工程业务接口、业务资源和私有工具类。
- 发布前建议先生成 HAR 或 tgz 包，再执行 `ohpm prepublish <har_or_tgz_file>` 或平台要求的本地校验命令。

## 兼容性

- Stage 模型。
- 最低兼容 HarmonyOS API 12。
- 当前 HAR 发布元数据 `compatibleSdkVersion` 为 `12`，三方库中心应展示最低 API 为 12。
- 已在 API 12 构建配置下完成 HAR 构建验证。
- 支持 phone、tablet。
