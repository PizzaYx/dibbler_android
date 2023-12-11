//下载管理器
import 'package:al_downloader/al_downloader.dart';
import 'package:dibbler_android/Interface.dart';
import 'package:dibbler_android/sqlStore.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class DownLoadStore extends GetxController {
  static DownLoadStore get to => Get.find();

  @override
  void onInit() {
    initialize();
    super.onInit();
  }

  void initialize() {
    ALDownloader.initialize();
    ALDownloader.configurePrint(true, frequentEnabled: false);
  }

  //外部传入数据并下载
  void setMoviesDownload(String url, String status) {
    if (status != 'unKnown') {
      addForeverHandlerInterface(url);
    }
    downloadForUrl(url);
  }

  //下载
  void downloadForUrl(String url) {
    ALDownloader.download(url,
        handlerInterface:
            ALDownloaderHandlerInterface(progressHandler: (progress) {
          debugPrint('ALDownloader | 下载进度 = $progress, url = $url\n');
        }, succeededHandler: () {
          debugPrint('ALDownloader | 下载成功, url = $url\n');
        }, failedHandler: () {
          debugPrint('ALDownloader | 下载失败, url = $url\n');
          SqlStore.to.updateDownloadStatus(url, 'failed');
        }, pausedHandler: () {
          debugPrint('ALDownloader | 下载暂停, url = $url\n');
          SqlStore.to.updateDownloadStatus(url, 'paused');
        }));
  }

  //持久句柄池
  void addForeverHandlerInterface(String url) {
    ALDownloader.addHandlerInterface(
        ALDownloaderHandlerInterface(progressHandler: (progress) {
          debugPrint('ALDownloader | 下载进度 = $progress, url = $url\n');
        }, succeededHandler: () async {
          debugPrint('ALDownloader | 下载成功, url = $url\n');
          successAction(url);
        }, failedHandler: () {
          debugPrint('ALDownloader | 下载失败, url = $url\n');
          SqlStore.to.updateDownloadStatus(url, 'failed');
        }, pausedHandler: () {
          debugPrint('ALDownloader | 下载暂停, url = $url\n');
          SqlStore.to.updateDownloadStatus(url, 'paused');
        }),
        url);
  }

  //下载成功处理
  void successAction(String url) async {
    //获取下载路径
    String? path = await getLocalPath(url);
    if (path != null) {
      SqlStore.to.updateDownloadStatus(url, 'succeeded', localPath: path);
      //同步服务器接口
      String movieId = await SqlStore.to.queryMovieId(url);
      updateVideoIsDownload(movieId);
    }
  }

  //暂停所有下载
  void pauseAllAction() {
    ALDownloader.pauseAll();
  }

  //暂停下载根据url
  void pauseAction(String url) {
    ALDownloader.pause(url);
  }

  //查看下载状态
  void getStatusForUrl(String url) async {
    final status = await ALDownloader.getStatusForUrl(url);
  }

  //移除下载
  void removeAction(String url) {
    ALDownloader.remove(url);
  }

  //
  // void cancelAllAction() {
  //   ALDownloader.cancelAll();
  // }
  //
  // void removeAllAction() {
  //   ALDownloader.removeAll();
  // }

  //获取下载本地路径
  Future<String?> getLocalPath(String url) async {
    final physicalFilePath =
        await ALDownloaderFileManager.getPhysicalFilePathForUrl(url);
    debugPrint(
        'ALDownloader | 获取[url]的物理文件路径, url = $url, path = $physicalFilePath\n');
    return physicalFilePath;
  }

  // /// Manage [ALDownloaderHandlerInterface] by [ALDownloaderHandlerInterfaceId]
  // final _handlerInterfaceIds = <ALDownloaderHandlerInterfaceId>[];
  //
  // /// Manage batch [ALDownloaderHandlerInterface] by [ALDownloaderHandlerInterfaceId]
  // final _handlerInterfaceIdsForBatch = <ALDownloaderHandlerInterfaceId>[];
}