import { efRcpClientApi } from '@yunkss/ef_rcp'
import { VodDetailModel, VodDetailModelList } from '../../data/VodDetailModel'
import { promptAction } from '@kit.ArkUI'
import { DerivedNavPathStack } from '../../common/DerivedNavPathStack'
import { preferences } from '@kit.ArkData'
import { SourceModel } from '../../data/SourceModel'

@Builder
export function VodDetailViewBuilder(name: string, param: Object) {
  VodDetailView()
}

@Preview
@Component
export struct VodDetailView {
  @Builder
  fromMenu() {
    Menu() {
      ForEach(this.play_from, (item: string) => {
        MenuItem({ content: item })
          .onChange((selected) => {
            if (selected) {
              this.playFromIndex = this.play_from.indexOf(item, 0)
            }
          })
      })
    }
  }

  @State play_from: string[] = []

  @State playFromIndex: number = 0

  @State model: VodDetailModelList|undefined = undefined
  @State episodes: Episode[] = []
  @State vod_id: string|null = null

  private derivedStack: DerivedNavPathStack | null = null

  scroller: Scroller = new Scroller()

  @State loading: boolean = true

  build() {
    NavDestination(){
      if (this.loading) {
        LoadingProgress()
          .width(100)
          .height('100%')
      }else{
        Scroll(){
          Column(){
            Image(this.model?.vod_pic)
              .width('100%')
              .height(300)
            Row({space: 15}){
              Text('切换线路')
                .fontSize(15)
              Text(this.play_from[this.playFromIndex])
                .bindMenu(this.fromMenu())
                .fontSize(15)
            }
            .height(44)
            Grid(this.scroller){
              ForEach(this.episodes, (item: Episode) => {
                GridItem(){
                  Text(item.title)
                    .borderWidth(1)
                    .borderRadius(5)
                    .borderColor(Color.Gray)
                    .padding(15)
                    .width('100%')
                    .height('100%')
                    .textAlign(TextAlign.Center)
                }
                .width('100%')
                .height(44)
                .onClick(() => {
                  this.derivedStack?.pushPath({name: 'VideoView', param: this.playFromIndex == 0 ? item.url1 : item.url2})
                })
              })
            }
            .columnsTemplate('1fr 1fr 1fr')
            .columnsGap(15)
            .rowsGap(15)
            .width('100%')
            .height(this.loading ? 0 : this.getEpHeight())
            .backgroundColor(0xFAEEE0)
            .enableScrollInteraction(true)
            .supportAnimation(false)
            .multiSelectable(false)
            .edgeEffect(EdgeEffect.Spring)
            .scrollBar(BarState.On)
            .scrollBarColor(Color.Grey)
            .scrollBarWidth(4)
          }
          .width('100%')
          .height('100%')
        }
        .width('100%')
        .height('100%')
      }
    }
    .title(this.model?.vod_name)
    .onReady((callBack) => {
      this.derivedStack = callBack.pathStack as DerivedNavPathStack
      this.vod_id = callBack.pathInfo.param as string
    })
    .onAppear(() => {
      this.getDetail()
    })
  }

  getEpHeight(): number {
    let value = this.episodes.length / 3
    let ext = this.episodes.length % 3
    let row = ext == 0 ? value : (value + 1)
    return Math.min(row * 44 + (row - 1) * 15, 300)
  }

  async getDetail() {
    let data = preferences.getPreferencesSync(getContext(this), { name: 'source.db' })
    let current_source = data.getSync('current', '') as SourceModel

    let response = await efRcpClientApi.get<VodDetailModel>({
      url: `${current_source.api}?ac=detail&ids=${this.vod_id}`
    })
    if (response.error) {
      promptAction.showToast({
        message: response.error.message
      })
      return
    }
    this.model = response.data?.list[0]

    this.episodes = this.parseStringToJson(this.model?.vod_play_url)

    this.play_from = this.model?.vod_play_from.split('$$$')!

    this.loading = false
  }

  parseStringToJson(input: string|undefined): Episode[] {
    const parts = input!.split('$$$');

    if (parts.length !== 2) {
      throw new Error("Input string format is incorrect");
    }

    const urls1 = parts[0].split('#');
    const urls2 = parts[1].split('#');

    if (urls1.length !== urls2.length) {
      throw new Error("Input string format is incorrect");
    }

    const episodes: Episode[] = [];

    for (let i = 0; i < urls1.length; i++) {
      const part1 = urls1[i].split('$');
      const part2 = urls2[i].split('$');

      if (part1.length !== 2 || part2.length !== 2) {
        throw new Error("Input string format is incorrect");
      }

      episodes.push({
        title: part1[0],
        url1: part1[1],
        url2: part2[1]
      });
    }

    return episodes;
  }
}

interface Episode {
  title: string;
  url1: string;
  url2: string;
}