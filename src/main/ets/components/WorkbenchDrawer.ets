import display from '@ohos.display'
import { clamp, shouldSyncOverlaySize } from '../utils/DrawerMath'
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
  @Prop title: ResourceStr = '任务'
  @Prop contentText: ResourceStr = '请通过 contentBuilder 自定义抽屉内容'
  @Prop @Watch('handleInitialExpandedChange') initialExpanded: boolean = false
  @Prop collapsedHeight: number = DRAWER_DEFAULT_COLLAPSED_HEIGHT
  @Prop expandedHeight: number = DRAWER_DEFAULT_EXPANDED_HEIGHT
  @Prop maxHeightRatio: number = DRAWER_DEFAULT_MAX_HEIGHT_RATIO
  @Prop drawerWidth: Length = DRAWER_DEFAULT_WIDTH
  @Prop animationDuration: number = DRAWER_DEFAULT_ANIMATION_DURATION
  @Prop dragThreshold: number = DRAWER_DEFAULT_DRAG_THRESHOLD
  @Prop snapMode: DrawerSnapMode = DrawerSnapMode.DirectionAndHalf
  @Prop enableDrag: boolean = true
  @Prop enableContentDrag: boolean = false
  @Prop showHandle: boolean = true
  @Prop showMask: boolean = false
  @Prop closeOnMaskClick: boolean = true
  @Prop enableTitleTapToggle: boolean = true
  @Prop drawerBackgroundColor: ResourceColor = '#E8FFFFFF'
  @Prop maskColor: ResourceColor = '#000000'
  @Prop maskOpacity: number = DRAWER_DEFAULT_MASK_OPACITY
  @Prop drawerBorderRadius: number = DRAWER_DEFAULT_BORDER_RADIUS
  @Prop titleHeight: number = DRAWER_DEFAULT_TITLE_HEIGHT
  @Prop contentPadding: number = DRAWER_DEFAULT_CONTENT_PADDING
  @Prop shadowColor: ResourceColor = '#22000000'
  onHeightChange: (height: number) => void = () => {
  }
  onExpandedChange: (isExpanded: boolean) => void = () => {
  }
  @BuilderParam titleBuilder?: () => void
  @BuilderParam contentBuilder?: () => void

  @State private drawerHeight: number = DRAWER_DEFAULT_COLLAPSED_HEIGHT
  @State private containerHeight: number = DRAWER_DEFAULT_EXPANDED_HEIGHT
  @State private isExpanded: boolean = false

  private dragStartHeight: number = DRAWER_DEFAULT_COLLAPSED_HEIGHT
  private lastOffsetY: number = 0
  private isDragging: boolean = false

  aboutToAppear(): void {
    this.updateContainerHeightFromDisplay()
    this.isExpanded = this.initialExpanded
    this.drawerHeight = this.initialExpanded ? this.getSafeExpandedHeight() : this.getSafeCollapsedHeight()
  }

  private updateContainerHeightFromDisplay(): void {
    try {
      const currentDisplay = display.getDefaultDisplaySync()
      const displayHeight = currentDisplay.availableHeight > 0 ? currentDisplay.availableHeight : currentDisplay.height
      this.containerHeight = Math.max(this.getUIContext().px2vp(displayHeight), this.expandedHeight, this.getSafeCollapsedHeight())
    } catch (_error) {
      this.containerHeight = Math.max(this.containerHeight, this.expandedHeight, this.getSafeCollapsedHeight())
    }
  }

  private handleInitialExpandedChange(): void {
    const nextHeight = this.initialExpanded ? this.getSafeExpandedHeight() : this.getSafeCollapsedHeight()
    if (this.isExpanded === this.initialExpanded && this.drawerHeight === nextHeight) {
      return
    }
    this.getUIContext().animateTo({
      duration: this.animationDuration,
      curve: Curve.EaseOut
    }, () => {
      this.isExpanded = this.initialExpanded
      this.updateHeight(nextHeight)
    })
  }

  private getSafeCollapsedHeight(): number {
    const minimumHeaderHeight = (this.showHandle ? DRAWER_DEFAULT_HANDLE_AREA_HEIGHT : 0) + this.titleHeight
    return Math.max(this.collapsedHeight, minimumHeaderHeight, 0)
  }

  private getSafeExpandedHeight(): number {
    const maxHeight = this.containerHeight * this.maxHeightRatio
    const safeExpandedHeight = Math.min(this.expandedHeight, maxHeight)
    return Math.max(safeExpandedHeight, this.getSafeCollapsedHeight())
  }

  private normalizeSizeToNumber(value: Length | undefined): number {
    if (value === undefined) {
      return this.containerHeight
    }
    if (typeof value === 'number') {
      return value
    }
    return this.containerHeight
  }

  private getOverlayHeight(): Length {
    return this.showMask ? '100%' : this.drawerHeight
  }

  private getHeaderHeight(): number {
    return (this.showHandle ? DRAWER_DEFAULT_HANDLE_AREA_HEIGHT : 0) + this.titleHeight
  }

  private shouldRenderContent(): boolean {
    return this.drawerHeight > this.getHeaderHeight() + 1
  }

  private updateHeight(nextHeight: number): void {
    this.drawerHeight = clamp(nextHeight, this.getSafeCollapsedHeight(), this.getSafeExpandedHeight())
    this.onHeightChange(this.drawerHeight)
  }

  private animateToState(nextExpanded: boolean): void {
    this.getUIContext().animateTo({
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

  private syncDrawerHeightWithState(): void {
    this.drawerHeight = this.isExpanded ? this.getSafeExpandedHeight() : this.getSafeCollapsedHeight()
  }

  private beginHeaderPan(): void {
    if (!this.enableDrag) {
      return
    }
    this.dragStartHeight = this.drawerHeight
    this.lastOffsetY = 0
    this.isDragging = true
  }

  private updateHeaderPan(offsetY: number): void {
    if (!this.enableDrag || !this.isDragging) {
      return
    }
    this.lastOffsetY = offsetY
    this.updateHeight(this.dragStartHeight - offsetY)
  }

  private endHeaderPan(offsetY: number): void {
    if (!this.enableDrag || !this.isDragging) {
      this.isDragging = false
      return
    }
    this.lastOffsetY = offsetY
    this.settleDrawer()
    this.isDragging = false
  }

  private handleOverlaySizeChange(newValue: SizeOptions): void {
    if (!shouldSyncOverlaySize(this.showMask, this.isDragging)) {
      return
    }
    const nextContainerHeight = this.normalizeSizeToNumber(newValue.height)
    if (nextContainerHeight > this.getSafeCollapsedHeight()) {
      this.containerHeight = Math.max(nextContainerHeight, this.expandedHeight, this.getSafeCollapsedHeight())
    }
    this.syncDrawerHeightWithState()
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
  HeaderBuilder() {
    Column() {
      this.HandleBuilder()
      this.TitleBuilder()
    }
    .width('100%')
    .height(this.getHeaderHeight())
    .onClick(() => {
      if (this.enableTitleTapToggle && !this.isDragging) {
        this.animateToState(!this.isExpanded)
      }
    })
    .gesture(
      PanGesture({ fingers: 1, direction: PanDirection.Vertical })
        .onActionStart((_event: GestureEvent) => {
          this.beginHeaderPan()
        })
        .onActionUpdate((event: GestureEvent) => {
          this.updateHeaderPan(event.offsetY)
        })
        .onActionEnd((event: GestureEvent) => {
          this.endHeaderPan(event.offsetY)
        })
        .onActionCancel(() => {
          this.isDragging = false
        })
    )
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
  RawContentBuilder() {
    if (this.contentBuilder) {
      this.contentBuilder()
    } else {
      this.DefaultContentBuilder()
    }
  }

  @Builder
  ContentBuilder() {
    if (this.shouldRenderContent()) {
      if (this.enableContentDrag) {
        Column() {
          this.RawContentBuilder()
        }
        .width('100%')
        .layoutWeight(1)
        .gesture(
          PanGesture({ fingers: 1, direction: PanDirection.Vertical })
            .onActionStart((_event: GestureEvent) => {
              this.beginHeaderPan()
            })
            .onActionUpdate((event: GestureEvent) => {
              this.updateHeaderPan(event.offsetY)
            })
            .onActionEnd((event: GestureEvent) => {
              this.endHeaderPan(event.offsetY)
            })
            .onActionCancel(() => {
              this.isDragging = false
            })
        )
      } else {
        this.RawContentBuilder()
      }
    }
  }

  build() {
    Stack({ alignContent: Alignment.Bottom }) {
      if (this.showMask && this.drawerHeight > this.getSafeCollapsedHeight()) {
        Blank()
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

      Column() {
        this.HeaderBuilder()
        this.ContentBuilder()
      }
      .width(this.drawerWidth)
      .height(this.drawerHeight)
      .backgroundColor(this.drawerBackgroundColor)
      .backgroundBlurStyle(BlurStyle.Regular)
      .borderRadius({ topLeft: this.drawerBorderRadius, topRight: this.drawerBorderRadius })
      .border({ width: 1, color: '#8FFFFFFF' })
      .clip(true)
      .shadow({
        radius: DRAWER_DEFAULT_SHADOW_RADIUS,
        color: this.shadowColor,
        offsetX: 0,
        offsetY: DRAWER_DEFAULT_SHADOW_OFFSET_Y
      })
    }
    .width('100%')
    .height(this.getOverlayHeight())
    .onSizeChange((_oldValue: SizeOptions, newValue: SizeOptions) => {
      this.handleOverlaySizeChange(newValue)
    })
  }
}
