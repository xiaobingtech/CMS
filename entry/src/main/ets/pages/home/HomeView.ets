import { preferences } from '@kit.ArkData'
import { efRcpClientApi } from '@yunkss/ef_rcp'
import { ApiModel, ApiModelClas, ApiModelList } from '../../data/ApiModel'
import { SourceModel } from '../../data/SourceModel'
import { promptAction, router } from '@kit.ArkUI'
import { DerivedNavPathStack } from '../../common/DerivedNavPathStack'
import { VodDetailModel, VodDetailModelList } from '../../data/VodDetailModel'

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

  @State count: number = 0

  private swiperController: SwiperController = new SwiperController()

  private data: MyDataSource = new MyDataSource([])

  private controller = new VideoController()

  @State loading: boolean = true

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
      if (this.loading) {
        LoadingProgress()
          .width(100)
          .height('100%')
      }else{
        Column({space: 0}) {
          List(){
            ForEach(this.clasList, (item: ApiModelClas) => {
              ListItem(){
                Column(){
                  Row(){
                    Blank().width(15)
                    Text(item.type_name)
                    Blank()
                    Text('更多')
                    SymbolGlyph($r('sys.symbol.chevron_right'))
                    Blank().width(15)
                  }
                  .width('100%')
                  .height(44)
                  .onClick(() => {
                    this.derivedStack?.pushPath({name: 'VodListView', param: item})
                  })
                  Grid(){
                    ForEach(this.clasList.filter(key => key.type_id == item.type_id)[0].list, (item2: VodDetailModelList) => {
                      GridItem(){
                        Column({space: 5}){
                          Image(item2.vod_pic)
                            .width('100%')
                            .objectFit(ImageFit.Cover)
                            .height(120)
                            .borderRadius(5)
                          Text(item2.vod_name)
                            .fontSize(15)
                            .maxLines(1)
                        }
                      }
                      .onClick(() => {
                        this.derivedStack?.pushPath({name: 'VodDetailView', param: item2.vod_id})
                      })
                    })
                  }
                  .columnsTemplate('1fr 1fr 1fr 1fr')
                  .rowsTemplate('1fr')
                  .columnsGap(15)
                  .width('100%')
                  .height(this.loading ? 0 : 150)
                }
                .width('100%')
                .height(194)
              }
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
    }
    .title(this.current_source?.name)
    .onAppear(async () => {
      let data = preferences.getPreferencesSync(getContext(this), { name: 'source.db' })
      let current_source = data.getSync('current', '') as SourceModel
      this.current_source = current_source
      let response = await efRcpClientApi.get<ApiModel>({
        url: this.current_source.api + '/api.php/provide/vod/?ac=list'
      })
      if (response.error) {
        promptAction.showToast({
          message: response.error.message
        })
        return
      }
      let result = response.data

      this.clasList = result!.class

      this.vodList = result!.list

      this.clasList.forEach(async (item, index) => {
        let response2 = await efRcpClientApi.get<VodDetailModel>({
          url: current_source.api + `/api.php/provide/vod/?ac=detail&t=${item.type_id}`
        })
        this.count ++
        if (this.count == result!.class.length) {
          this.loading = false
        }
        if (response2.error) {
          promptAction.showToast({
            message: response2.error.message
          })
          return
        }
        let result2 = response2.data
        this.clasList.filter(key => key.type_id == item.type_id)[0].list = result2?.list ?? []
      })
    })
  }
}