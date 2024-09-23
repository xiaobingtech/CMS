import { preferences } from '@kit.ArkData'
import { router } from '@kit.ArkUI'
import { DerivedNavPathStack } from '../common/DerivedNavPathStack'
import { SourceModel } from '../data/SourceModel'
import { HomeView } from './home/HomeView'
import { SettingView } from './setting/SettingView'

@Entry
@Component
struct TabPage {
  @StorageProp('currentBreakpoint') currentBreakpoint: string = '';

  @State selectIndex : number = 0

  derivedStack: DerivedNavPathStack = new DerivedNavPathStack();

  aboutToAppear(): void {
    AppStorage.setOrCreate('derivedStack', this.derivedStack)

    let data = preferences.getPreferencesSync(getContext(this), { name: 'source.db' })

    let model = new SourceModel()
    model.api = 'https://cj.lziapi.com/api.php/provide/vod/from/lzm3u8/'
    model.name = '量子资源'
    data.putSync('current', model)
  }

  @Builder
  tabBarBuilder(index: number, title: string, img: string, sel_img: string) {
    if (this.currentBreakpoint !== 'md' ) {
      Column({space: 5}){
        SymbolGlyph(index == this.selectIndex ? $r(sel_img) : $r(img))
          .fontSize(30)
          .fontColor(index == this.selectIndex ? [$r('app.color.accent')] : [Color.Gray])
        Text(title).fontColor(index == this.selectIndex ? $r('app.color.accent') : Color.Gray)
      }
    }else{
      Row({space: 5}){
        SymbolGlyph(index == this.selectIndex ? $r(sel_img) : $r(img))
          .fontSize(30)
          .fontColor(index == this.selectIndex ? [$r('app.color.accent')] : [Color.Gray])
        Text(title).fontColor(index == this.selectIndex ? $r('app.color.accent') : Color.Gray)
      }
    }
  }

  build() {
    Navigation(this.derivedStack){
      Tabs({ barPosition: this.currentBreakpoint === "lg" ? BarPosition.Start : BarPosition.End }) {
        TabContent() {
          HomeView()
        }
        .tabBar(this.tabBarBuilder(0, '首页', 'sys.symbol.square_grid_2x2', 'sys.symbol.square_fill_grid_2x2'))

        TabContent() {
          SettingView()
        }
        .tabBar(this.tabBarBuilder(4, '设置', 'sys.symbol.person_crop_circle_fill_1', 'sys.symbol.person_crop_circle_fill_1'))
      }
      .onChange((index: number) => {
        this.selectIndex = index
      })
      .scrollable(false)
      .animationDuration(0)
      .width('100%')
      .barWidth(this.currentBreakpoint === "lg" ? 96 : '100%')
      .barHeight(this.currentBreakpoint === "lg" ? '60%' : 56)
      .vertical(this.currentBreakpoint === "lg")
    }
    .hideTitleBar(true)
  }
}