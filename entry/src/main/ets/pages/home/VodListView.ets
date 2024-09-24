// https://cj.lziapi.com/api.php/provide/vod/from/lzm3u8/?ac=detail&t=23
import { preferences } from '@kit.ArkData'
import { SourceModel } from '../../data/SourceModel'
import { promptAction } from '@kit.ArkUI'
import { VodDetailModel, VodDetailModelList } from '../../data/VodDetailModel'
import { efRcpClientApi } from '@yunkss/ef_rcp'
import { DerivedNavPathStack } from '../../common/DerivedNavPathStack'
import { ApiModelClas } from '../../data/ApiModel'

@Builder
export function VodListViewBuilder(name: string, param: Object) {
  VodListView()
}

@Preview
@Component
struct VodListView {

  @State page: number = 1

  @State loading: boolean = true
  private derivedStack: DerivedNavPathStack | null = null

  @State t: ApiModelClas|null = null
  @State model: VodDetailModel|null = null

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
            ForEach(this.model?.list, (item: VodDetailModelList) => {
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
                this.derivedStack?.pushPath({name: 'VodDetailView', param: item.vod_id})
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
    .title(this.t?.type_name)
    .onReady((callBack) => {
      this.derivedStack = callBack.pathStack as DerivedNavPathStack
      this.t = callBack.pathInfo.param as ApiModelClas
    })
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
    let count = this.model?.list.length!
    let value = count / 4
    let ext = count % 4
    return ext == 0 ? value : value + 1
  }

  async getList() {
    let data = preferences.getPreferencesSync(getContext(this), { name: 'source.db' })
    let current_source = data.getSync('current', '') as SourceModel

    let response = await efRcpClientApi.get<VodDetailModel>({
      url: `${current_source.api}?ac=detail&t=${this.t?.type_id}&pg=${this.page}`
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
      this.model?.list.push(...response.data?.list ?? [])
    }
  }
}