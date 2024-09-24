import { efRcpClientApi } from '@yunkss/ef_rcp'
import { VodDetailModel, VodDetailModelList } from '../../data/VodDetailModel'
import { promptAction } from '@kit.ArkUI'
import { DerivedNavPathStack } from '../../common/DerivedNavPathStack'

@Builder
export function VodDetailViewBuilder(name: string, param: Object) {
  VodDetailView()
}

@Preview
@Component
export struct VodDetailView {
  @State model: VodDetailModelList|undefined = undefined
  @State episodes: Episode[] = []

  private derivedStack: DerivedNavPathStack | null = null

  build() {
    NavDestination(){
      Scroll(){
        Column(){
          Stack(){
            Image(this.model?.vod_pic)
              .width('100%')
              .height(200)
          }
          Text(this.model?.vod_name)
            .fontSize(18)
          Text(this.model?.vod_sub)
            .fontSize(15)
          // Text(this.model?.vod_content)
          //   .fontSize(13)
          Tabs(){
            ForEach(this.model?.vod_play_from.split('$$$'), (item: string) => {
              TabContent(){
                Grid(){
                  ForEach(this.episodes, (item: Episode) => {
                    GridItem(){
                      Text(item.title)
                        .borderWidth(1)
                        .borderRadius(5)
                        .borderColor(Color.Gray)
                        .padding(15)
                        .width('100%')
                        .height('100%')
                    }
                    .onClick(() => {
                      this.derivedStack?.pushPath({name: 'VideoView', param: item.url})
                    })
                  })
                }
                .columnsTemplate('1fr 1fr 1fr 1fr 1fr')
                .rowsTemplate('1fr 1fr 1fr 1fr 1fr')
                .width('100%')
                .backgroundColor(0xFAEEE0)
              }
              .tabBar(item)
            })
          }
          .width('100%')
        }
        .width('100%')
        .height('100%')
      }
      .width('100%')
      .height('100%')
    }
    .title('视频详情')
    .onReady((callBack) => {
      this.derivedStack = callBack.pathStack as DerivedNavPathStack
    })
    .onAppear(() => {
      this.getDetail()
    })
  }

  async getDetail() {
    // https://cj.lziapi.com/api.php/provide/vod/?ac=detail&ids=93988
    let response = await efRcpClientApi.get<VodDetailModel>({
      url: "https://cj.lziapi.com/api.php/provide/vod/?ac=detail&ids=93988"
    })
    if (response.error) {
      promptAction.showToast({
        message: response.error.message
      })
      return
    }
    this.model = response.data?.list[0]

    this.episodes = this.parseStringToJson(this.model?.vod_play_url)
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
        url: part2[1]
      });
    }

    return episodes;
  }
}

interface Episode {
  title: string;
  url: string;
}