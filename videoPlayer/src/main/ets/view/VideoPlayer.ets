/*
 * Copyright (c) 2023 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import { display, window } from '@kit.ArkUI';
import { Callback, deviceInfo } from '@kit.BasicServicesKit';
import { BreakpointConstants, CommonConstants } from '@ohos/commons/';
import { AvPlayerUtil, Logger, WindowUtil } from '@ohos/commons/';
import { PlayerConstants } from '../constants/PlayerConstants';
import { FooterEpisodes } from './FooterEpisodes';
import { SideEpisodes } from './SideEpisodes';

@Component
export struct VideoPlayer {
  @StorageLink('currentWidthBreakpoint') currentWidthBreakpoint: string = BreakpointConstants.BREAKPOINT_LG;
  @StorageLink('currentHeightBreakpoint') currentHeightBreakpoint: string = BreakpointConstants.BREAKPOINT_LG;
  @StorageLink('creaseRegion') creaseRegion: number[] = [];
  @StorageLink('currentTime') currentTime: string = CommonConstants.INITIAL_TIME;
  @StorageLink('totalTime') totalTime: string = CommonConstants.INITIAL_TIME;
  @StorageLink('progress') progress: number = 0;
  @StorageLink('avplayerState') avplayerState: string = '';
  @StorageLink('isHalfFolded') isHalfFolded: boolean = false;
  @State isShowingSideBar: boolean = false;
  @State foldStatus: display.FoldStatus = display.getFoldStatus();
  @Consume('pageInfo') pageInfo: NavPathStack;
  private windowUtil?: WindowUtil;
  private avPlayerUtil?: AvPlayerUtil;
  private xComponentController: XComponentController = new XComponentController();
  private onFoldStatusChange: Callback<display.FoldStatus> = (data: display.FoldStatus) => {
    this.foldStatus = data;
    if (data === display.FoldStatus.FOLD_STATUS_EXPANDED) {
      if (this.windowUtil === undefined) {
        return;
      }
      this.isHalfFolded = false;
      this.windowUtil.setMainWindowOrientation(window.Orientation.AUTO_ROTATION_RESTRICTED);
    } else {
      if (this.windowUtil === undefined) {
        return;
      }
      if (data === display.FoldStatus.FOLD_STATUS_HALF_FOLDED) {
        this.isHalfFolded = true;
      } else {
        this.isHalfFolded = false;
      }
      this.windowUtil.setMainWindowOrientation(window.Orientation.AUTO_ROTATION_LANDSCAPE);
    }
  };

  aboutToAppear() {
    this.avPlayerUtil = AvPlayerUtil.getInstance();
    this.windowUtil = WindowUtil.getInstance();
    if (this.windowUtil !== undefined) {
      /**
       * In any windowSize of 2ini, the systemBar doesn't need to hide.
       * So this logic can't decide by portraitBreakpoint and currentWidthBreakpoint.
       */
      if (deviceInfo.deviceType !== CommonConstants.DEVICE_TYPES[0]) {
        this.windowUtil.disableWindowSystemBar();
      }

      /**
       * The landscape bp "sm" and portrait bp "lg" will show in phone and fold device.
       */
      if (this.currentHeightBreakpoint === 'lg' && this.currentWidthBreakpoint === 'sm') {
        this.windowUtil.setMainWindowOrientation(window.Orientation.AUTO_ROTATION_LANDSCAPE);
      }

      /**
       * The landscape bp "md" and portrait bp "md" will show in fold device.
       */
      if (this.currentHeightBreakpoint === 'md' && this.currentWidthBreakpoint === 'md' && this.isHalfFolded) {
        this.windowUtil.setMainWindowOrientation(window.Orientation.AUTO_ROTATION_LANDSCAPE);
      }
    } else {
      Logger.info(`Full-screen display in portrait mode`);
    }
  }

  async aboutToDisappear() {
    this.avPlayerUtil?.setSurfaceId(AppStorage.get('detailSurfaceId'));
    if (this.windowUtil !== undefined) {
      /**
       * When step out the fullScreen VideoPlay, any device need to show systemBar except 2ini.
       */
      if (deviceInfo.deviceType !== CommonConstants.DEVICE_TYPES[0]) {
        this.windowUtil.enableWindowSystemBar();
      }
      if (this.currentHeightBreakpoint === 'sm' && this.currentWidthBreakpoint === 'md') {
        this.windowUtil.setMainWindowOrientation(window.Orientation.PORTRAIT);
      } else if (this.currentHeightBreakpoint === 'sm' && this.currentWidthBreakpoint === 'lg') {
        this.windowUtil.setMainWindowOrientation(window.Orientation.AUTO_ROTATION_LANDSCAPE);
      } else {
        this.windowUtil.setMainWindowOrientation(window.Orientation.AUTO_ROTATION_RESTRICTED);
      }
    } else {
      Logger.info(`Normal return in portrait mode`);
    }
  }

  build() {
    NavDestination() {
      Row() {
        Column() {
          Stack({ alignContent: Alignment.Center }) {
            Flex({
              direction: FlexDirection.Column,
              justifyContent: this.isHalfFolded ? FlexAlign.Start : FlexAlign.Center,
              alignItems: ItemAlign.Start
            }) {
              Column() {
                XComponent({
                  id: PlayerConstants.X_COMPONENT_ID,
                  type: XComponentType.SURFACE,
                  controller: this.xComponentController
                })
                  .onLoad(() => {
                    this.avPlayerUtil?.setSurfaceId(this.xComponentController.getXComponentSurfaceId());
                  })
                  .aspectRatio(CommonConstants.VIDEO_ASPECT_RATIO)
              }
              .justifyContent(FlexAlign.Center)
              .height(this.isHalfFolded ? this.creaseRegion[0] : CommonConstants.FULL_PERCENT)
              .width(CommonConstants.FULL_PERCENT)
            }
            .width(CommonConstants.FULL_PERCENT)
            .height(CommonConstants.FULL_PERCENT)
            .onClick(() => {
              if (this.isShowingSideBar) {
                this.isShowingSideBar = false;
              }
            })

            Column() {
              Row() {
                TimeText({ time: $currentTime })
                  .margin({
                    left: $r('app.float.current_time_left'),
                    right: $r('app.float.current_time_right')
                  })

                Slider({ min: 0, max: CommonConstants.PROGRESS_HUNDRED, step: 1, value: this.progress })
                  .onChange((value: number, mode: SliderChangeMode) => {
                    this.avPlayerUtil?.sliderChange(value, mode);
                  })
                  .layoutWeight(1)
                  .selectedColor($r('app.color.selected_color'))

                TimeText({ time: $totalTime })
                  .margin({
                    left: $r('app.float.total_time_left'),
                    right: $r('app.float.total_time_right')
                  })
              }
              .width(CommonConstants.FULL_PERCENT)
              .height($r('app.float.time_row_height'))
              .alignItems(VerticalAlign.Center)

              Row() {
                Row() {
                  Image(this.avplayerState === CommonConstants.AV_PLAYER_PLAYING_STATE ? $r('app.media.ic_public_pause')
                    : $r('app.media.ic_public_play'))
                    .height($r('app.float.icon_size'))
                    .width($r('app.float.icon_size'))
                    .margin({ left: $r('app.float.icon_margin') })
                    .onClick(() => {
                      this.avPlayerUtil?.playerStateControl();
                    })
                  ImgIcon({ img: $r('app.media.ic_public_play_next') })
                  ImgIcon({ img: $r('app.media.ic_public_view_list_white') })
                }
                .margin({
                  top: this.currentWidthBreakpoint === BreakpointConstants.BREAKPOINT_SM ? '0' : $r('app.float.icon_row_top'),
                  bottom: this.currentWidthBreakpoint === BreakpointConstants.BREAKPOINT_SM ?
                    $r('app.float.icon_row_bottom_sm') : $r('app.float.icon_row_bottom')
                })

                Blank()

                Row() {
                  TextButton({ content: PlayerConstants.PLAYER_TEXT_LIST[0] })
                    .onClick(() => {
                      this.isShowingSideBar = !this.isShowingSideBar;
                    })
                  TextButton({ content: PlayerConstants.PLAYER_TEXT_LIST[2] })
                  TextButton({ content: PlayerConstants.PLAYER_TEXT_LIST[3] })
                }
                .margin({
                  top: this.currentWidthBreakpoint === BreakpointConstants.BREAKPOINT_SM ? $r('app.float.button_row_top_sm') :
                  $r('app.float.button_row_top'),
                  bottom: this.currentWidthBreakpoint === BreakpointConstants.BREAKPOINT_SM ?
                  $r('app.float.button_row_bottom_sm') : $r('app.float.button_row_bottom')
                })
              }
              .height($r('app.float.icon_button_row_height'))
              .width(CommonConstants.FULL_PERCENT)
            }
            .height(CommonConstants.FULL_PERCENT)
            .width(CommonConstants.FULL_PERCENT)
            .justifyContent(FlexAlign.End)
            .visibility(this.isShowingSideBar ? Visibility.None : Visibility.Visible)

            Image($r('app.media.ic_public_back'))
              .height($r('app.float.icon_size'))
              .width($r('app.float.icon_size'))
              .position({
                x: $r('app.float.back_position_x'),
                y: this.isHalfFolded ? this.creaseRegion[0] + this.creaseRegion[1] : $r('app.float.back_position_y')
              })
              .fillColor(Color.White)
              .onClick(() => {
                this.pageInfo.pop();
              })
              .visibility(!this.isShowingSideBar? Visibility.Visible : Visibility.None)
          }
          .width(CommonConstants.FULL_PERCENT)
          .height(this.isShowingSideBar ? this.creaseRegion[0] : CommonConstants.FULL_PERCENT)
          .layoutWeight(this.isHalfFolded? 0 : 1)

          Blank()
            .height(this.creaseRegion[1])
            .width(CommonConstants.FULL_PERCENT)
            .visibility(this.isHalfFolded && this.isShowingSideBar ? Visibility.Visible : Visibility.None)

          FooterEpisodes({ isShowingSideBar: $isShowingSideBar, foldStatus: this.foldStatus })
        }
        .layoutWeight(3)

        SideEpisodes({ isShowingSideBar: $isShowingSideBar, foldStatus: this.foldStatus })
      }
      .justifyContent(FlexAlign.Start)
      .backgroundColor(Color.Black)
      .height(CommonConstants.FULL_PERCENT)
      .width(CommonConstants.FULL_PERCENT)
    }
    .hideTitleBar(true)
    .onShown(() => {
      if (this.avplayerState !== CommonConstants.AV_PLAYER_PLAYING_STATE) {
        this.avPlayerUtil?.playerStateControl();
      }
      try {
        display.on('foldStatusChange', this.onFoldStatusChange);
      } catch (exception) {
        Logger.error('Failed to register callback. Code: ' + JSON.stringify(exception));
      }
    })
    .onHidden(() => {
      display.off('foldStatusChange');
    })
  }
}

@Component
struct ImgIcon {
  private img?: Resource;

  build() {
    Image(this.img !== undefined ? this.img : '')
      .height($r('app.float.icon_size'))
      .width($r('app.float.icon_size'))
      .margin({ left: $r('app.float.icon_margin') })
  }
}

@Component
struct TextButton {
  private content: ResourceStr = '';

  build() {
    Text(this.content)
      .fontSize($r('app.float.button_text_font'))
      .fontWeight(FontWeight.Normal)
      .fontColor(Color.White)
      .margin({ right: $r('app.float.button_text_margin') })
  }
}

@Component
struct TimeText {
  @Link time: string;

  build() {
    Text(this.time)
      .fontSize($r('app.float.time_font'))
      .fontColor(Color.White)
      .lineHeight($r('app.float.time_text_line'))
      .width($r('app.float.time_text_width'))
  }
}