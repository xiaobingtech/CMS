import { router } from '@kit.ArkUI';

@Entry
@Component
struct IndexPage {
  @State message: string = 'Hello World';

  build() {
    RelativeContainer() {
      Text(this.message)
        .id('CMS')
        .fontSize(50)
        .fontWeight(FontWeight.Bold)
        .alignRules({
          center: { anchor: '__container__', align: VerticalAlign.Center },
          middle: { anchor: '__container__', align: HorizontalAlign.Center }
        })
    }
    .height('100%')
    .width('100%')
    .onAppear(() => {
      router.replaceUrl({
        url: '/pages/TabPage'
      })
    })
  }
}