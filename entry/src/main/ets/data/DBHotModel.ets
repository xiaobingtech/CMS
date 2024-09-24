export interface DBHotModelSubject {
  episodes_info: string;
  rate: string;
  cover_x: number;
  title: string;
  url: string;
  playable: boolean;
  cover: string;
  id: string;
  cover_y: number;
  is_new: boolean;
}

export interface DBHotModel {
  subjects: DBHotModelSubject[];
}