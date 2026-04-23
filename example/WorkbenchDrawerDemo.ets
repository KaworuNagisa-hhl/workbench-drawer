import { DrawerSnapMode, WorkbenchDrawer } from '../Index'

@Builder
function DemoTitleBuilder() {
  Row() {
    Text('任务')
      .fontSize(18)
      .fontWeight(FontWeight.Bold)
      .fontColor('#101828')
      .layoutWeight(1)

    Text('刷新')
      .fontSize(14)
      .fontColor('#007DFF')
  }
  .width('100%')
  .height(48)
  .padding({ left: 16, right: 16 })
  .alignItems(VerticalAlign.Center)
}

@Builder
function DemoContentBuilder() {
  Column({ space: 12 }) {
    Text('我的待办')
      .fontSize(16)
      .fontWeight(FontWeight.Medium)
      .fontColor('#101828')

    Text('这里替换成你的业务列表、Tabs 或其它内容。')
      .fontSize(14)
      .fontColor('#667085')
  }
  .width('100%')
  .layoutWeight(1)
  .padding(16)
  .justifyContent(FlexAlign.Center)
  .alignItems(HorizontalAlign.Center)
}

@Entry
@Component
struct WorkbenchDrawerDemo {
  build() {
    Stack() {
      Column() {
        Text('宿主页面内容')
          .fontSize(20)
          .fontColor('#101828')
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.Center)
      .backgroundColor('#F2F4F7')

      WorkbenchDrawer({
        title: '默认标题',
        contentText: '默认内容区域',
        initialExpanded: false,
        collapsedHeight: 56,
        expandedHeight: 680,
        drawerWidth: '100%',
        snapMode: DrawerSnapMode.DirectionAndHalf,
        showMask: false,
        titleBuilder: DemoTitleBuilder,
        contentBuilder: DemoContentBuilder
      })
    }
    .width('100%')
    .height('100%')
  }
}
