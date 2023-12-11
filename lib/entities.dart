//movieId 电影ID,url电影链接,cover电影封面,title电影标题,status 本地下载状态,
// localPath 本地下载路径,synchro与服务器同步下载状态 fromJson方法 tojson方法
import 'package:dibbler_android/Interface.dart';

class DownloadMovie {
  //downLoadStatus localPath 默认值为’‘
  DownloadMovie(this.movieId, this.url, this.cover, this.title, this.synchro,
      {this.downLoadStatus = 'unKnown', this.localPath = ''});

  String movieId;
  String url;
  String cover;
  String title;
  String downLoadStatus;
  String localPath;
  int synchro;

  DownloadMovie.fromJson(Map<String, dynamic> json)
      : movieId = json['id'],
        cover = json['imgpath2'],
        url = json['videopath2'],
        title = json['title'],
        downLoadStatus = 'unKnown',
        localPath = '',
        synchro = json['isDownload'];

  Map<String, dynamic> toJson() => {
        'id': movieId,
        'imgpath': cover,
        'videopath': url,
        'title': title,
        // 'downLoadStatus': downLoadStatus,
        // 'localPath': localPath,
        'isDownload': synchro
      };
}
