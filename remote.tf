terraform {
  backend "s3" {
    bucket = "state.hana053.com"
    key    = "micropost"
    region = "ap-northeast-1"
  }
}
