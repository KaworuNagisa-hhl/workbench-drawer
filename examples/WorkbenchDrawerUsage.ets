import { DrawerSnapMode, WorkbenchDrawer } from '../Index'

const DRAWER_PREVIEW_BG: ResourceColor = '#F4F4F5'
const DRAWER_SURFACE: ResourceColor = '#E6111111'
const DRAWER_BORDER: ResourceColor = '#66FFFFFF'
const DRAWER_TEXT_PRIMARY: ResourceColor = '#F8F8F8'
const DRAWER_TEXT_SECONDARY: ResourceColor = '#D6D6D6'
const DRAWER_TEXT_TERTIARY: ResourceColor = '#A8A8A8'
const DRAWER_ACCENT: ResourceColor = '#0B7063'

@Builder
function DrawerTitleBuilder() {
  Row() {
    Column({ space: 2 }) {
      Text('Workbench Drawer')
        .fontSize(17)
        .fontWeight(FontWeight.Bold)
        .fontColor(DRAWER_TEXT_PRIMARY)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })

      Text('like-ios bottom sheet')
        .fontSize(12)
        .fontColor(DRAWER_TEXT_TERTIARY)
    }
    .layoutWeight(1)
    .alignItems(HorizontalAlign.Start)

    Text('H')
      .fontSize(12)
      .fontWeight(FontWeight.Bold)
      .fontColor(DRAWER_TEXT_PRIMARY)
      .width(28)
      .height(28)
      .textAlign(TextAlign.Center)
      .backgroundColor('#1FFFFFFF')
      .borderRadius(8)
      .border({ width: 1, color: DRAWER_BORDER })
  }
  .width('100%')
  .height(54)
  .padding({ left: 18, right: 18 })
  .alignItems(VerticalAlign.Center)
}

@Builder
function DrawerContentBuilder() {
  Column({ space: 12 }) {
    Row({ space: 10 }) {
      Text('C')
        .fontSize(12)
        .fontWeight(FontWeight.Bold)
        .fontColor(DRAWER_TEXT_PRIMARY)
        .width(32)
        .height(32)
        .textAlign(TextAlign.Center)
        .backgroundColor(DRAWER_ACCENT)
        .borderRadius(8)

      Column({ space: 3 }) {
        Text('Collapsed height')
          .fontSize(14)
          .fontWeight(FontWeight.Bold)
          .fontColor(DRAWER_TEXT_PRIMARY)

        Text('78vp title-only state')
          .fontSize(12)
          .fontColor(DRAWER_TEXT_SECONDARY)
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .padding(12)
    .backgroundColor('#1FFFFFFF')
    .borderRadius(8)

    Row({ space: 10 }) {
      Text('E')
        .fontSize(12)
        .fontWeight(FontWeight.Bold)
        .fontColor(DRAWER_TEXT_PRIMARY)
        .width(32)
        .height(32)
        .textAlign(TextAlign.Center)
        .backgroundColor('#1F7A8C')
        .borderRadius(8)

      Column({ space: 3 }) {
        Text('Expanded height')
          .fontSize(14)
          .fontWeight(FontWeight.Bold)
          .fontColor(DRAWER_TEXT_PRIMARY)

        Text('520vp with contentBuilder slot')
          .fontSize(12)
          .fontColor(DRAWER_TEXT_SECONDARY)
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .padding(12)
    .backgroundColor('#1FFFFFFF')
    .borderRadius(8)
  }
  .width('100%')
  .layoutWeight(1)
  .padding({ left: 18, right: 18, top: 8, bottom: 18 })
  .justifyContent(FlexAlign.Start)
  .alignItems(HorizontalAlign.Start)
}

@Entry
@Component
struct WorkbenchDrawerUsage {
  build() {
    Stack() {
      Column({ space: 18 }) {
        Text('07')
          .fontSize(220)
          .fontWeight(FontWeight.Bold)
          .fontColor('#0A000000')
          .height(220)

        Column({ space: 8 }) {
          Text('workbench-drawer')
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontColor('#111827')

          Text('底部抽屉采用同系列黑色毛玻璃展示效果')
            .fontSize(14)
            .fontColor('#667085')
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)
      }
      .width('100%')
      .height('100%')
      .padding({ left: 28, right: 28, top: 64 })
      .alignItems(HorizontalAlign.Start)
      .backgroundColor(DRAWER_PREVIEW_BG)

      WorkbenchDrawer({
        title: 'Workbench Drawer',
        contentText: 'like-ios 毛玻璃底部面板已经映射为 ArkUI 组件',
        initialExpanded: false,
        collapsedHeight: 78,
        expandedHeight: 520,
        drawerWidth: '92%',
        snapMode: DrawerSnapMode.DirectionAndHalf,
        showMask: false,
        drawerBackgroundColor: DRAWER_SURFACE,
        drawerBorderRadius: 18,
        titleHeight: 54,
        contentPadding: 16,
        shadowColor: '#3311181E',
        titleBuilder: DrawerTitleBuilder,
        contentBuilder: DrawerContentBuilder
      })
    }
    .width('100%')
    .height('100%')
  }
}
