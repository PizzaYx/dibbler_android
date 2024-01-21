//movieId 电影ID,url电影链接,cover电影封面,title电影标题,status 本地下载状态,
// localPath 本地下载路径,synchro与服务器同步下载状态 fromJson方法 tojson方法
import 'package:dibbler_android/Interface.dart';

class MovieData {
  //downLoadStatus localPath 默认值为’‘
  MovieData(
      this.movieId, this.url, this.cover, this.title, this.intro, this.synchro,
      {this.downLoadStatus = 'unKnown', this.localPath = ''});

  String movieId;
  String url;
  String cover;
  String title;
  String downLoadStatus;
  String localPath;
  String intro;
  int synchro;

  MovieData.fromJson(Map<String, dynamic> json)
      : movieId = json['id'],
        cover = json['imgpath2'],
        url = json['videopath2'],
        title = json['title'],
        downLoadStatus = 'unKnown',
        localPath = '',
        intro = json['intro'],
        synchro = json['isDownload'];

  Map<String, dynamic> toJson() => {
        'id': movieId,
        'imgpath': cover,
        'videopath': url,
        'title': title,
        'intro': intro,
        'isDownload': synchro
      };
}

//videoID ,id 播放视频列表
class PlayVideo {
  String videoId;
  String id;
  String title;
  String nickname;
  String truename;
  String createTime;
  int isplay;

  PlayVideo(this.videoId, this.id, this.title, this.nickname, this.truename,
      this.createTime,
      {this.isplay = 0});

  PlayVideo.fromJson(Map<String, dynamic> json)
      : videoId = json['videoId'],
        id = json['id'],
        title = json['title'],
        nickname = json['nickname'],
        truename = json['truename'],
        createTime = json['createTime'].toString(),
        isplay = 0;

  Map<String, dynamic> toJson() => {
        'videoId': videoId,
        'id': id,
        'title': title,
        'nickname': nickname,
        'truename': truename,
        'createTime': createTime,
      };
}

//随机播放信息
class CoverTitle {
  String cover;
  String title;
  String introduction;
  String localPath;
  CoverTitle(this.cover, this.title, this.introduction, this.localPath); //构造函数
}
