
@Preview
@Component
export struct VodDetailView {
  build() {
    Column(){
      Stack(){
        Image($r('app.media.vod_1'))
          .blur(50)
          .width('100%')
          .height(300)
      }
    }
    .width('100%')
    .height('100%')
  }
}