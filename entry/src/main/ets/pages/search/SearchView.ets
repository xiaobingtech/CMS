
@Component
export struct SearchView {
  controller: SearchController = new SearchController()

  @State q: string = ''

  build() {
    Navigation(){
      Column(){
        Search({
          placeholder: '请输入搜索内容',
          controller: this.controller
        })
          .onSubmit((value) => {
            this.q = value
          })
          .margin(15)
      }
    }
    .title('搜索')
  }
}