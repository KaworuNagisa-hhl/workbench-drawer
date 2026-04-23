import { clamp } from '../utils/DrawerMath'
import { DrawerSnapMode } from '../model/DrawerTypes'
import {
  DRAWER_DEFAULT_ANIMATION_DURATION,
  DRAWER_DEFAULT_BORDER_RADIUS,
  DRAWER_DEFAULT_COLLAPSED_HEIGHT,
  DRAWER_DEFAULT_CONTENT_PADDING,
  DRAWER_DEFAULT_DRAG_THRESHOLD,
  DRAWER_DEFAULT_EXPANDED_HEIGHT,
  DRAWER_DEFAULT_HANDLE_AREA_HEIGHT,
  DRAWER_DEFAULT_HANDLE_HEIGHT,
  DRAWER_DEFAULT_HANDLE_RADIUS,
  DRAWER_DEFAULT_HANDLE_WIDTH,
  DRAWER_DEFAULT_MASK_OPACITY,
  DRAWER_DEFAULT_MAX_HEIGHT_RATIO,
  DRAWER_DEFAULT_SHADOW_OFFSET_Y,
  DRAWER_DEFAULT_SHADOW_RADIUS,
  DRAWER_DEFAULT_TITLE_FONT_SIZE,
  DRAWER_DEFAULT_TITLE_HEIGHT,
  DRAWER_DEFAULT_WIDTH
} from '../constants/DrawerConstants'

@Component
export struct WorkbenchDrawer {
  /** 默认标题文本，自定义标题区域存在时不展示 */
  @Prop title: ResourceStr = '任务'
  /** 默认内容文本，自定义内容区域存在时不展示 */
  @Prop contentText: ResourceStr = '请通过 contentBuilder 自定义抽屉内容'
  /** 初始是否展开 */
  @Prop initialExpanded: boolean = false
  /** 收起高度 */
  @Prop collapsedHeight: number = DRAWER_DEFAULT_COLLAPSED_HEIGHT
  /** 展开高度。若父容器更矮，会自动按父容器高度裁剪 */
  @Prop expandedHeight: number = DRAWER_DEFAULT_EXPANDED_HEIGHT
  /** 展开高度占父容器最大比例 */
  @Prop maxHeightRatio: number = DRAWER_DEFAULT_MAX_HEIGHT_RATIO
  /** 抽屉面板宽度，支持百分比字符串或 vp 数值 */
  @Prop drawerWidth: Length = DRAWER_DEFAULT_WIDTH
  /** 动画时长 */
  @Prop animationDuration: number = DRAWER_DEFAULT_ANIMATION_DURATION
  /** 触发拖拽方向判定的最小距离 */
  @Prop dragThreshold: number = DRAWER_DEFAULT_DRAG_THRESHOLD
  /** 吸附规则 */
  @Prop snapMode: DrawerSnapMode = DrawerSnapMode.DirectionAndHalf
  /** 是否允许拖拽 */
  @Prop enableDrag: boolean = true
  /** 是否允许从内容区拖拽。关闭后只有把手/标题区域可拖拽 */
  @Prop enableContentDrag: boolean = true
  /** 是否展示顶部把手 */
  @Prop showHandle: boolean = true
  /** 是否展示遮罩 */
  @Prop showMask: boolean = false
  /** 点击遮罩是否收起 */
  @Prop closeOnMaskClick: boolean = true
  /** 抽屉整体背景色 */
  @Prop drawerBackgroundColor: ResourceColor = Color.White
  /** 页面遮罩颜色 */
  @Prop maskColor: ResourceColor = '#000000'
  /** 页面遮罩透明度 */
  @Prop maskOpacity: number = DRAWER_DEFAULT_MASK_OPACITY
  /** 顶部圆角 */
  @Prop drawerBorderRadius: number = DRAWER_DEFAULT_BORDER_RADIUS
  /** 标题栏高度 */
  @Prop titleHeight: number = DRAWER_DEFAULT_TITLE_HEIGHT
  /** 内容默认内边距 */
  @Prop contentPadding: number = DRAWER_DEFAULT_CONTENT_PADDING
  /** 抽屉阴影色 */
  @Prop shadowColor: ResourceColor = '#22000000'
  /** 抽屉高度变化回调 */
  onHeightChange: (height: number) => void = () => {
  }
  /** 展开/收起状态变化回调 */
  onExpandedChange: (isExpanded: boolean) => void = () => {
  }
  /** 自定义标题区域。传入后会替换默认标题区域 */
  @BuilderParam titleBuilder?: () => void
  /** 自定义内容区域。传入后会替换默认内容区域 */
  @BuilderParam contentBuilder?: () => void

  @State private drawerHeight: number = DRAWER_DEFAULT_COLLAPSED_HEIGHT
  @State private containerHeight: number = DRAWER_DEFAULT_EXPANDED_HEIGHT
  @State private isExpanded: boolean = false

  private touchStartY: number = 0
  private dragStartHeight: number = DRAWER_DEFAULT_COLLAPSED_HEIGHT
  private lastOffsetY: number = 0
  private isDragging: boolean = false

  aboutToAppear(): void {
    this.isExpanded = this.initialExpanded
    this.drawerHeight = this.initialExpanded ? this.getSafeExpandedHeight() : this.getSafeCollapsedHeight()
  }

  private getSafeCollapsedHeight(): number {
    return Math.max(this.collapsedHeight, 0)
  }

  private getSafeExpandedHeight(): number {
    const maxHeight = this.containerHeight * this.maxHeightRatio
    const safeExpandedHeight = Math.min(this.expandedHeight, maxHeight)
    return Math.max(safeExpandedHeight, this.getSafeCollapsedHeight())
  }

  private isTouchInDragHeader(touchY: number): boolean {
    return touchY <= DRAWER_DEFAULT_HANDLE_AREA_HEIGHT + this.titleHeight
  }

  private updateHeight(nextHeight: number): void {
    this.drawerHeight = clamp(nextHeight, this.getSafeCollapsedHeight(), this.getSafeExpandedHeight())
    this.onHeightChange(this.drawerHeight)
  }

  private animateToState(nextExpanded: boolean): void {
    animateTo({
      duration: this.animationDuration,
      curve: Curve.EaseOut
    }, () => {
      this.isExpanded = nextExpanded
      this.updateHeight(nextExpanded ? this.getSafeExpandedHeight() : this.getSafeCollapsedHeight())
    })
    this.onExpandedChange(nextExpanded)
  }

  private shouldExpandByDirection(): boolean {
    if (this.lastOffsetY < -this.dragThreshold) {
      return true
    }
    if (this.lastOffsetY > this.dragThreshold) {
      return false
    }
    return this.isExpanded
  }

  private shouldExpandByHalf(): boolean {
    const middleHeight = (this.getSafeExpandedHeight() + this.getSafeCollapsedHeight()) / 2
    return this.drawerHeight > middleHeight
  }

  private settleDrawer(): void {
    if (this.snapMode === DrawerSnapMode.Direction) {
      this.animateToState(this.shouldExpandByDirection())
      return
    }
    if (this.snapMode === DrawerSnapMode.Half) {
      this.animateToState(this.shouldExpandByHalf())
      return
    }
    if (Math.abs(this.lastOffsetY) > this.dragThreshold) {
      this.animateToState(this.shouldExpandByDirection())
      return
    }
    this.animateToState(this.shouldExpandByHalf())
  }

  private handleDrawerTouch(event: TouchEvent): void {
    if (!this.enableDrag || !event.touches || event.touches.length === 0) {
      return
    }
    const touchY = event.touches[0].y
    if (event.type === TouchType.Down) {
      if (!this.enableContentDrag && !this.isTouchInDragHeader(touchY)) {
        return
      }
      this.touchStartY = touchY
      this.dragStartHeight = this.drawerHeight
      this.lastOffsetY = 0
      this.isDragging = false
      event.stopPropagation()
      return
    }
    if (event.type === TouchType.Move) {
      const offsetY = touchY - this.touchStartY
      this.lastOffsetY = offsetY
      if (Math.abs(offsetY) > this.dragThreshold) {
        this.isDragging = true
      }
      this.updateHeight(this.dragStartHeight - offsetY)
      event.stopPropagation()
      return
    }
    if (event.type === TouchType.Up || event.type === TouchType.Cancel) {
      if (this.isDragging) {
        this.settleDrawer()
      }
      this.isDragging = false
      event.stopPropagation()
    }
  }

  @Builder
  HandleBuilder() {
    if (this.showHandle) {
      Row() {
        Row()
          .width(DRAWER_DEFAULT_HANDLE_WIDTH)
          .height(DRAWER_DEFAULT_HANDLE_HEIGHT)
          .borderRadius(DRAWER_DEFAULT_HANDLE_RADIUS)
          .backgroundColor('#D0D5DD')
      }
      .width('100%')
      .height(DRAWER_DEFAULT_HANDLE_AREA_HEIGHT)
      .justifyContent(FlexAlign.Center)
      .alignItems(VerticalAlign.Center)
    }
  }

  @Builder
  DefaultTitleBuilder() {
    Row() {
      Text(this.title)
        .fontSize(DRAWER_DEFAULT_TITLE_FONT_SIZE)
        .fontWeight(FontWeight.Medium)
        .fontColor('#101828')
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
    }
    .width('100%')
    .height(this.titleHeight)
    .padding({ left: this.contentPadding, right: this.contentPadding })
    .alignItems(VerticalAlign.Center)
  }

  @Builder
  TitleBuilder() {
    if (this.titleBuilder) {
      this.titleBuilder()
    } else {
      this.DefaultTitleBuilder()
    }
  }

  @Builder
  DefaultContentBuilder() {
    Column() {
      Text(this.contentText)
        .fontSize(14)
        .fontColor('#667085')
        .textAlign(TextAlign.Center)
    }
    .width('100%')
    .layoutWeight(1)
    .padding(this.contentPadding)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  ContentBuilder() {
    if (this.contentBuilder) {
      this.contentBuilder()
    } else {
      this.DefaultContentBuilder()
    }
  }

  @Builder
  DrawerPanelBuilder() {
    Column() {
      this.HandleBuilder()
      this.TitleBuilder()
      this.ContentBuilder()
    }
    .width(this.drawerWidth)
    .height(this.drawerHeight)
    .backgroundColor(this.drawerBackgroundColor)
    .borderRadius({ topLeft: this.drawerBorderRadius, topRight: this.drawerBorderRadius })
    .shadow({
      radius: DRAWER_DEFAULT_SHADOW_RADIUS,
      color: this.shadowColor,
      offsetX: 0,
      offsetY: DRAWER_DEFAULT_SHADOW_OFFSET_Y
    })
    .clip(true)
    .onTouch((event: TouchEvent) => {
      this.handleDrawerTouch(event)
    })
  }

  build() {
    Stack({ alignContent: Alignment.Bottom }) {
      if (this.showMask && this.isExpanded) {
        Row()
          .width('100%')
          .height('100%')
          .backgroundColor(this.maskColor)
          .opacity(this.maskOpacity)
          .onClick(() => {
            if (this.closeOnMaskClick) {
              this.animateToState(false)
            }
          })
      }
      this.DrawerPanelBuilder()
    }
    .width('100%')
    .height('100%')
    .onAreaChange((_oldArea: Area, newArea: Area) => {
      this.containerHeight = Number(newArea.height)
      this.updateHeight(this.isExpanded ? this.getSafeExpandedHeight() : this.getSafeCollapsedHeight())
    })
  }
}
