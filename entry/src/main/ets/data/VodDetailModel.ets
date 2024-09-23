export interface VodDetailModelList {
  vod_id: number = 0
  type_id: number = 0
  type_id_1: number = 0
  group_id: number = 0
  vod_name: string;
  vod_sub: string;
  vod_en: string;
  vod_status: number = 0
  vod_letter: string;
  vod_color: string;
  vod_tag: string;
  vod_class: string;
  vod_pic: string;
  vod_pic_thumb: string;
  vod_pic_slide: string;
  vod_pic_screenshot: string;
  vod_actor: string;
  vod_director: string;
  vod_writer: string;
  vod_behind: string;
  vod_blurb: string;
  vod_remarks: string;
  vod_pubdate: string;
  vod_total: number = 0
  vod_serial: string;
  vod_tv: string;
  vod_weekday: string;
  vod_area: string;
  vod_lang: string;
  vod_year: string;
  vod_version: string;
  vod_state: string;
  vod_author: string;
  vod_jumpurl: string;
  vod_tpl: string;
  vod_tpl_play: string;
  vod_tpl_down: string;
  vod_isend: number = 0
  vod_lock: number = 0
  vod_level: number = 0
  vod_copyright: number = 0
  vod_points: number = 0
  vod_points_play: number = 0
  vod_points_down: number = 0
  vod_hits: number = 0
  vod_hits_day: number = 0
  vod_hits_week: number = 0
  vod_hits_month: number = 0
  vod_duration: string;
  vod_up: number = 0
  vod_down: number = 0
  vod_score: string;
  vod_score_all: number = 0
  vod_score_num: number = 0
  vod_time: string;
  vod_time_add: number = 0
  vod_time_hits: number = 0
  vod_time_make: number = 0
  vod_trysee: number = 0
  vod_douban_id: number = 0
  vod_douban_score: string;
  vod_reurl: string;
  vod_rel_vod: string;
  vod_rel_art: string;
  vod_pwd: string;
  vod_pwd_url: string;
  vod_pwd_play: string;
  vod_pwd_play_url: string;
  vod_pwd_down: string;
  vod_pwd_down_url: string;
  vod_content: string;
  vod_play_from: string;
  vod_play_server: string;
  vod_play_note: string;
  vod_play_url: string;
  vod_down_from: string;
  vod_down_server: string;
  vod_down_note: string;
  vod_down_url: string;
  vod_plot: number = 0
  vod_plot_name: string;
  vod_plot_detail: string;
  type_name: string;
}

export interface VodDetailModel {
  code: number = 0
  msg: string;
  page: number = 0
  pagecount: number = 0
  limit: string;
  total: number = 0
  list: VodDetailModelList[];
}