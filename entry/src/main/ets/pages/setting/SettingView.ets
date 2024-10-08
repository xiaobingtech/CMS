import picker from '@ohos.file.picker';
import fs from '@ohos.file.fs';
import Want from '@ohos.app.ability.Want';
import { URLDialog } from './URLDialog';
import { efRcpClientApi } from '@yunkss/ef_rcp';
import { preferences } from '@kit.ArkData';
import { SourceModel } from '../../data/SourceModel';
import { DerivedNavPathStack } from '../../common/DerivedNavPathStack';

@Preview
@Component
export struct SettingView {

  @State current_source: SourceModel|null = null

  private derivedStack: DerivedNavPathStack | null = null

  aboutToAppear(): void {
    this.derivedStack = AppStorage.get('derivedStack') as DerivedNavPathStack
  }

  onCancel() {
    console.info('Callback when the first button is clicked')
  }

  onAccept() {
    console.info('Callback when the second button is clicked')
    if (this.textValue != '') {
      //下载这个文件
      this.downloadFile(this.textValue)
    }
  }

  async downloadFile(url: string) {
    let dto =
      await efRcpClientApi.downloadFile<string>({
        url: url,
        fileName: url.split('/').pop()
      })
    console.log(dto.data);
  }

  exitApp() {
    console.info('Click the callback in the blank area')
  }

  @State textValue: string = ''
  dialogController: CustomDialogController | null = new CustomDialogController({
    builder: URLDialog({
      cancel: ()=> { this.onCancel() },
      confirm: ()=> { this.onAccept() },
      textValue: $textValue,
    }),
    cancel: this.exitApp,
    autoCancel: true,
    onWillDismiss:(dismissDialogAction: DismissDialogAction)=> {
      console.info("reason=" + JSON.stringify(dismissDialogAction.reason))
      console.log("dialog onWillDismiss")
      if (dismissDialogAction.reason == DismissReason.PRESS_BACK) {
        dismissDialogAction.dismiss()
      }
      if (dismissDialogAction.reason == DismissReason.TOUCH_OUTSIDE) {
        dismissDialogAction.dismiss()
      }
    },
    alignment: DialogAlignment.Bottom,
    offset: { dx: 0, dy: -20 },
    gridCount: 4,
    customStyle: false,
    cornerRadius: 10,
  })

  // 在自定义组件即将析构销毁时将dialogController置空
  aboutToDisappear() {
    this.dialogController = null // 将dialogController置空
  }

  build() {
    Navigation(){
      Scroll(){
        Column(){
          Row(){
            Text('当前源')
            Blank()
            Text(this.current_source?.name)
          }
          .width('100%')
          .height(44)
          .padding(15)
          Divider()
          Row(){
            Text('添加源')
            Blank()
            SymbolGlyph($r('sys.symbol.chevron_right'))
          }
          .width('100%')
          .height(44)
          .padding(15)
          .onClick(() => {
            ActionSheet.show({ // 建议使用 this.getUIContest().showActionSheet()接口
              title: '选择添加源的方式',
              subtitle: '',
              message: '',
              autoCancel: false,
              cancel: () => {

              },
              alignment: DialogAlignment.Bottom,
              offset: { dx: 0, dy: -10 },
              sheets: [
                {
                  title: '从文件中导入',
                  action: () => {
                    this.selectFile()
                  }
                },
                {
                  title: '从URL下载',
                  action: () => {
                    this.dialogController?.open()
                  }
                }
              ]
            })
          })
          Divider()
        }
      }
    }
    .title('设置')
    .onAppear(() => {
      let data = preferences.getPreferencesSync(getContext(this), { name: 'source.db' })
      this.current_source = data.getSync('current', '') as SourceModel
    })
  }

  selectFile() {
    try {
      let DocumentSelectOptions = new picker.DocumentSelectOptions();
      let documentPicker = new picker.DocumentViewPicker();
      documentPicker.select(DocumentSelectOptions, (err, DocumentSelectResult) => {
        if (err) {
          console.error('DocumentViewPicker.select failed with err: ' + err);
          return;
        }
        console.info('DocumentViewPicker.select successfully, DocumentSelectResult uri: ' +
        JSON.stringify(DocumentSelectResult))
      });
    } catch (err) {
      console.error('DocumentViewPicker failed with err: ' + err);
    }
  }
}
