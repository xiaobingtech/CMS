
class MyDataSource implements IDataSource {
  private list: number[] = []

  constructor(list: number[]) {
    this.list = list
  }

  totalCount(): number {
    return this.list.length
  }

  getData(index: number): number {
    return this.list[index]
  }

  registerDataChangeListener(listener: DataChangeListener): void {
  }

  unregisterDataChangeListener() {
  }
}


@Preview
@Component
export struct HomeView {
  private swiperController: SwiperController = new SwiperController()

  private data: MyDataSource = new MyDataSource([])

  private controller = new VideoController()

  aboutToAppear(): void {
    let list: number[] = []
    for (let i = 1; i <= 5; i++) {
      list.push(i);
    }
    this.data = new MyDataSource(list)
  }

  @State isStop: boolean = false

  build() {
    Column() {
      Stack(){
        Swiper(this.swiperController) {
          LazyForEach(this.data, (item: number) => {
            Image("https://image.tmdb.org/t/p/w500/tvwg20zNkqSkQShCqTK1AMimXqQ.jpg")
          }, (item: string) => item)
        }
        .cachedCount(2)
        .index(0)
        .autoPlay(true)
        .interval(4000)
        .loop(true)
        .indicatorInteractive(true)
        .duration(250)
        .itemSpace(0)
        .curve(Curve.EaseInOut)
        .onChange((index: number) => {
          console.info(index.toString())
        })
        .onGestureSwipe((index: number, extraInfo: SwiperAnimationEvent) => {

        })
        .width('100%')
        .height(400)
        // if (!this.isStop) {
        //   Video({
        //     src:"http://temp.dl.xiaobingkj.com/4466f8a2-9cca-428c-9940-70d7436feac2%E3%80%90%E6%8A%96%E9%9F%B3%E7%9F%AD%E8%A7%86%E9%A2%91%E3%80%91%E8%AE%B0%E5%BD%95%E7%BE%8E%E5%A5%BD%E7%94%9F%E6%B4%BB.mp4",
        //     previewUri: "https://image.tmdb.org/t/p/w500/tvwg20zNkqSkQShCqTK1AMimXqQ.jpg",
        //     controller: this.controller
        //   })
        //     .autoPlay(true)
        //     .loop(false)
        //     .objectFit(ImageFit.Cover)
        //     .controls(false)
        //     .width(this.isStop ? 0 : '100%')
        //     .height(this.isStop ? 0 : 400)
        //     .onError(() => {
        //       this.isStop = true
        //       console.log("播放错误")
        //     })
        //     .onStop(() => {
        //       this.isStop = true
        //       console.log("播放完成")
        //     })
        // }
      }
    }.width('100%')
    .height('100%')
  }
}