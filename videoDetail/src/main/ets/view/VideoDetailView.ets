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

import { BreakpointConstants, CommonConstants } from '@ohos/commons';
import { AvPlayerUtil, Logger } from '@ohos/commons';
import { RelatedList } from './RelatedList';
import { CurrentOffsetUtil } from '../utils/CurrentOffsetUtil';
import { DetailConstants } from '../constants/DetailConstants';

@Component
export struct VideoDetailView {
  @StorageLink('currentTime') currentTime: string = CommonConstants.INITIAL_TIME;
  @StorageLink('totalTime') totalTime: string = CommonConstants.INITIAL_TIME;
  @StorageLink('progress') progress: number = 0;
  @StorageLink('currentWidthBreakpoint') currentWidthBreakpoint: string = BreakpointConstants.BREAKPOINT_LG;
  @StorageLink('isHalfFolded') isHalfFolded: boolean = false;
  @Consume('pageInfo') pageInfo: NavPathStack;
  @Link relatedVideoHeight: number;
  @Link videoHeight: number;
  private avPlayerUtil?: AvPlayerUtil;
  private screenHeight: number = 0;
  private scroller: Scroller = new Scroller();
  private xComponentController: XComponentController = new XComponentController();

  aboutToAppear(): void {
    this.avPlayerUtil = AvPlayerUtil.getInstance();
  }

  build() {
    Scroll(this.scroller) {
      Column() {
        Stack({ alignContent: Alignment.Bottom }) {
          XComponent({
            id: DetailConstants.VIDEO_DETAIL,
            type: XComponentType.SURFACE,
            controller: this.xComponentController
          })
            .onLoad(() => {
              this.avPlayerUtil?.createAvPlayer(this.xComponentController.getXComponentSurfaceId());
              AppStorage.setOrCreate('detailSurfaceId', this.xComponentController.getXComponentSurfaceId());
            })
            .width(this.videoHeight + DetailConstants.PERCENT_SIGN)
            .height(CommonConstants.FULL_PERCENT)
            .aspectRatio(CommonConstants.VIDEO_ASPECT_RATIO)

          Row() {
            TimeText({ time: $currentTime })
              .margin({
                left: $r('app.float.current_time_text_left'),
                right: $r('app.float.current_time_text_right')
              })

            Slider({
              min: 0,
              max: CommonConstants.PROGRESS_HUNDRED,
              step: 1,
              value: this.progress
            })
              .onChange((value: number, mode: SliderChangeMode) => {
                this.avPlayerUtil?.sliderChange(value, mode);
              })
              .layoutWeight(1)
              .selectedColor($r('app.color.episodes_font'))

            TimeText({ time: $totalTime })
              .margin({
                left: $r('app.float.total_time_text_left'),
                right: $r('app.float.total_time_text_right')
              })

            Image($r('app.media.ic_public_enlarge'))
              .height($r('app.float.enlarge_size'))
              .width($r('app.float.enlarge_size'))
              .margin({ right: $r('app.float.enlarge_margin') })
              .fillColor(Color.White)
              .onClick(() => {
                // Full-screen playback.
                this.pageInfo.pushPath({ name: 'VideoPlayer' });
              })
          }
          .width(CommonConstants.FULL_PERCENT)
          .height($r('app.float.time_row_height'))
          .alignItems(VerticalAlign.Center)

          Image($r('app.media.ic_public_back'))
            .height($r('app.float.back_size'))
            .width($r('app.float.back_size'))
            .position({
              x: $r('app.float.back_position_x'),
              y: $r('app.float.back_position_y')
            })
            .fillColor(Color.White)
            .onClick(() => {
              this.pageInfo.pop();
            })
        }
        .width(CommonConstants.FULL_PERCENT)
        .backgroundColor(Color.Black)
        .onClick(() => {
          this.avPlayerUtil?.playerStateControl();
        })

        RelatedList({
          relatedVideoHeight: $relatedVideoHeight,
          videoHeight: $videoHeight,
          screenHeight: this.screenHeight
        })
      }
      .width(CommonConstants.FULL_PERCENT)
      .justifyContent(FlexAlign.Start)
      .padding({ bottom: $r('app.float.video_col_padding') })
    }
    .scrollable(ScrollDirection.Vertical)
    .scrollBar(BarState.Off)
    .height(CommonConstants.FULL_PERCENT)
    .onScrollFrameBegin((offset: number) => {
      if (this.currentWidthBreakpoint === BreakpointConstants.BREAKPOINT_LG) {
        if ((offset > 0) && (this.videoHeight > DetailConstants.MIN_VIDEO_PERCENT)) {
          // Video zoom-out logic.
          // Percentage of screen height by sliding.
          let offsetPercent = (Math.abs(offset) * DetailConstants.MAX_VIDEO_PERCENT) / this.screenHeight;
          // Video shrinkage percentage.
          let heightOffset = offsetPercent < this.videoHeight - DetailConstants.MIN_VIDEO_PERCENT ? offsetPercent :
            this.videoHeight - DetailConstants.MIN_VIDEO_PERCENT;
          this.videoHeight = this.videoHeight - heightOffset;
        } else if ((offset < 0) && (this.videoHeight < DetailConstants.MAX_VIDEO_PERCENT) &&
          (CurrentOffsetUtil.scrollToTop(JSON.stringify(this.scroller.currentOffset())))) {
          // Video magnification logic.
          let offsetPercent = (Math.abs(offset) * DetailConstants.MAX_VIDEO_PERCENT) / this.screenHeight;
          let heightOffset = offsetPercent < DetailConstants.MAX_VIDEO_PERCENT - this.videoHeight ? offsetPercent :
            DetailConstants.MAX_VIDEO_PERCENT - this.videoHeight;
          this.videoHeight = this.videoHeight + heightOffset;
        } else {
          Logger.info(`No specific function`);
        }
      } else {
        if ((offset > 0) && (this.videoHeight === DetailConstants.MAX_VIDEO_PERCENT) && (this.relatedVideoHeight > 0)) {
          // Related list shrinking logic.
          // Percentage of screen height by sliding.
          let offsetPercent = (Math.abs(offset) * DetailConstants.TEN) / this.screenHeight;
          this.relatedVideoHeight = (this.relatedVideoHeight - offsetPercent * DetailConstants.RELATED_LIST_HEIGHT) <
            0 ? 0 : (this.relatedVideoHeight - offsetPercent * DetailConstants.RELATED_LIST_HEIGHT);
        } else if ((offset > 0) && (this.videoHeight > DetailConstants.MIN_VIDEO_PERCENT) &&
          (this.relatedVideoHeight === 0)) {
          // Video zoom-out logic.
          // Percentage of screen height by sliding.
          let offsetPercent = (Math.abs(offset) * DetailConstants.MAX_VIDEO_PERCENT) / this.screenHeight;
          // Video shrinkage percentage.
          let heightOffset = offsetPercent < this.videoHeight - DetailConstants.MIN_VIDEO_PERCENT ? offsetPercent :
            this.videoHeight - DetailConstants.MIN_VIDEO_PERCENT;
          this.videoHeight = this.videoHeight - heightOffset;
        } else if ((this.videoHeight < DetailConstants.MAX_VIDEO_PERCENT) && (this.relatedVideoHeight === 0)
          && (offset < 0) && (CurrentOffsetUtil.scrollToTop(JSON.stringify(this.scroller.currentOffset())))) {
          // Video magnification logic.
          let offsetPercent = (Math.abs(offset) * DetailConstants.MAX_VIDEO_PERCENT) / this.screenHeight;
          let heightOffset = offsetPercent < DetailConstants.MAX_VIDEO_PERCENT - this.videoHeight ? offsetPercent :
            DetailConstants.MAX_VIDEO_PERCENT - this.videoHeight;
          this.videoHeight = this.videoHeight + heightOffset;
        } else if ((offset < 0) && (this.videoHeight === DetailConstants.MAX_VIDEO_PERCENT) &&
          (this.relatedVideoHeight >= 0)) {
          // Related list enlargement logic.
          // Percentage of screen height by sliding.
          let offsetPercent = (Math.abs(offset) * DetailConstants.TEN) / this.screenHeight;
          this.relatedVideoHeight = (this.relatedVideoHeight + offsetPercent * DetailConstants.RELATED_LIST_HEIGHT) >
            DetailConstants.RELATED_LIST_HEIGHT ? DetailConstants.RELATED_LIST_HEIGHT : (this.relatedVideoHeight +
            offsetPercent * DetailConstants.RELATED_LIST_HEIGHT);
        } else {
          Logger.info(`No specific function`);
        }
      }
      // Returns the actual offset 0.
      return { offsetRemain: 0 };
    })
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