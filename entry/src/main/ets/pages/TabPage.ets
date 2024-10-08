import { preferences } from '@kit.ArkData'
import { router } from '@kit.ArkUI'
import { DerivedNavPathStack } from '../common/DerivedNavPathStack'
import { SourceModel } from '../data/SourceModel'
import { HomeView } from './home/HomeView'
import { VodDetailView } from './home/VodDetailView'
import { HotView } from './hot/HotView'
import { SearchView } from './search/SearchView'
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
    model.api = 'https://www.hongniuzy2.com/api.php/provide/vod/'
    model.name = '红牛资源'
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
          HotView()
        }
        .tabBar(this.tabBarBuilder(1, '热门', 'sys.symbol.discover_fill', 'sys.symbol.discover_fill'))
        TabContent() {
          SearchView()
        }
        .tabBar(this.tabBarBuilder(1, '搜索', 'sys.symbol.magnifyingglass', 'sys.symbol.magnifyingglass'))
        TabContent() {
          SettingView()
        }
        .tabBar(this.tabBarBuilder(2, '设置', 'sys.symbol.person_crop_circle_fill_1', 'sys.symbol.person_crop_circle_fill_1'))
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