import { VodDetailModelList } from './VodDetailModel'

export class ApiModelList {
  vod_id: number = 0
  vod_name: string = ''
  type_id: number = 0
  type_name: string = ''
  vod_en: string = ''
  vod_time: string = ''
  vod_remarks: string = ''
  vod_play_from: string = ''
}

export class ApiModelClas {
  type_id: number = 0
  type_pid: number = 0
  type_name: string = ''
  list: VodDetailModelList[] = []
}

export class ApiModel {
  code: number = 0
  msg: string = ''
  page: number = 0
  pagecount: number = 0
  limit: string = ''
  total: number = 0
  list: ApiModelList[] = []
  class: ApiModelClas[] = []
}