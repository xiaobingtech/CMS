import { preferences } from '@kit.ArkData'
import { SourceModel } from '../../data/SourceModel'
import { promptAction } from '@kit.ArkUI'
import { VodDetailModel, VodDetailModelList } from '../../data/VodDetailModel'
import { efRcpClientApi } from '@yunkss/ef_rcp'
import { DerivedNavPathStack } from '../../common/DerivedNavPathStack'
import { ApiModelClas } from '../../data/ApiModel'
import { DBHotModel } from '../../data/DBHotModel'

@Preview
@Component
export struct HotView {

  @State page: number = 1

  @State loading: boolean = true

  @State model: DBHotModel|null = null

  scroller: Scroller = new Scroller()
  build() {
    NavDestination(){
      if (this.loading) {
        LoadingProgress()
          .width(100)
          .height('100%')
      }else{
        Column(){
          Grid(this.scroller){
            ForEach(this.model?.subjects, (item: VodDetailModelList) => {
              GridItem(){
                Column({space: 5}){
                  Image(item.vod_pic)
                    .width('100%')
                    .objectFit(ImageFit.Cover)
                    .height(120)
                    .borderRadius(5)
                  Text(item.vod_name)
                    .fontSize(15)
                    .maxLines(1)
                }
              }
              .onClick(() => {

              })
            })
          }
          .columnsTemplate('1fr 1fr 1fr 1fr')
          .columnsGap(15)
          .width('100%')
          .height('100%')
          .enableScrollInteraction(true)
          .supportAnimation(false)
          .multiSelectable(false)
          .edgeEffect(EdgeEffect.Spring)
          .scrollBar(BarState.On)
          .scrollBarColor(Color.Grey)
          .scrollBarWidth(4)
          .onReachEnd(() => {
            this.footerRefresh()
          })
          // .onScrollBarUpdate((index: number, offset: number) => {
          //   return {totalOffset: (index / this.getRow()) * 165 - offset, totalLength: 150 * this.getRow() + (this.getRow() - 1) * 15}
          // })
        }
      }
    }
    .onAppear(() => {
      this.headerRefresh()
    })
  }

  headerRefresh() {
    this.page = 1
    this.getList()
  }

  footerRefresh() {
    this.page++
    this.getList()
  }

  getRow(): number {
    let count = this.model?.subjects.length!
    let value = count / 4
    let ext = count % 4
    return ext == 0 ? value : value + 1
  }

  async getList() {
    let data = preferences.getPreferencesSync(getContext(this), { name: 'source.db' })
    let current_source = data.getSync('current', '') as SourceModel

    let response = await efRcpClientApi.get<DBHotModel>({
      url: `https://movie.douban.com/j/search_subjects?type=tv&tag=%E7%83%AD%E9%97%A8&page_limit=10&page_start=0`
    })
    if (response.error) {
      promptAction.showToast({
        message: response.error.message
      })
      return
    }
    if (this.page == 1) {
      this.loading = false
      this.model = response.data!
    }else{
      this.model?.subjects.push(...response.data?.subjects ?? [])
    }
  }
}