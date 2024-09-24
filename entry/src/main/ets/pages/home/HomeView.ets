import { preferences } from '@kit.ArkData'
import { efRcpClientApi } from '@yunkss/ef_rcp'
import { ApiModel, ApiModelClas, ApiModelList } from '../../data/ApiModel'
import { SourceModel } from '../../data/SourceModel'
import { promptAction } from '@kit.ArkUI'
import { DerivedNavPathStack } from '../../common/DerivedNavPathStack'

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
  private derivedStack: DerivedNavPathStack | null = null

  @State current_source: SourceModel|null = null
  @State clasList: ApiModelClas[] = []
  @State vodList: ApiModelList[] = []

  private swiperController: SwiperController = new SwiperController()

  private data: MyDataSource = new MyDataSource([])

  private controller = new VideoController()

  aboutToAppear(): void {
    let list: number[] = []
    for (let i = 1; i <= 5; i++) {
      list.push(i);
    }
    this.data = new MyDataSource(list)
    this.derivedStack = AppStorage.get('derivedStack') as DerivedNavPathStack
  }

  @State isStop: boolean = false

  build() {
    Navigation(){
      Column({space: 0}) {
        // Stack(){

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
        // }
        List(){
          ForEach(this.clasList, (item: ApiModelClas) => {
            ListItem(){
              if (item.type_id == -1){
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
                .height(200)
              }else{
                Column(){
                  Row(){
                    Blank().width(15)
                    Text(item.type_name)
                    Blank()
                  }
                  .width('100%')
                  .height('100%')
                }
                .width('100%')
                .height(44)
              }
            }
            .onClick(() => {
              this.derivedStack?.pushPath({name: 'VodDetailView'})
            })
          }, (item: ApiModelClas) => item.type_id.toString())
        }
        .scrollBar(BarState.Off)
        .divider({ strokeWidth: 1, color: 0xFAFAFA, startMargin: 0, endMargin: 0 }) // 每行之间的分界线
        .edgeEffect(EdgeEffect.Spring) // 边缘效果设置为Spring
        .width('100%')
        .height('100%')
      }
      .width('100%')
      .height('100%')
    }
    .title('首页')
    .onAppear(async () => {
      let data = preferences.getPreferencesSync(getContext(this), { name: 'source.db' })
      this.current_source = data.getSync('current', '') as SourceModel

      let response = await efRcpClientApi.get<ApiModel>({
        url: this.current_source.api
      })
      if (response.error) {
        promptAction.showToast({
          message: response.error.message
        })
        return
      }
      let result = response.data
      let item = new ApiModelClas()
      item.type_id = -1
      result?.class.unshift(item)
      this.clasList = result!.class
      this.vodList = result!.list
    })
  }
}