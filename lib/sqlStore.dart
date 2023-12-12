//Sql
import 'dart:io';

import 'package:external_path/external_path.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import 'Interface.dart';

class SqlStore extends GetxController {
  static SqlStore get to => Get.find();

  late Database db;

  @override
  void onInit() {
    openDatabaseConnection();
    super.onInit();
  }

  /// 打开数据库
  Future<void> openDatabaseConnection() async {

    String dibblerPath = await getLocalPath();

   // String databasePath = await getDatabasesPath();
    String databaseName = 'download.db';
    String path = join(dibblerPath, databaseName);

    // 检查数据库文件是否存在
    bool databaseExists = await File(path).exists();

    // 如果数据库文件存在，直接打开
    if (databaseExists) {
      db = await openDatabase(path);
    } else {
      // 如果数据库不存在，创建数据库
      db = await openDatabase(
        path,
        version: 1,
        onCreate: (database, version) async {
          // 创建 download 表
          await database.execute(
            'CREATE TABLE download (id INTEGER PRIMARY KEY, movieId TEXT, url TEXT,'
            ' cover TEXT, title TEXT, status TEXT, localPath TEXT, synchro INTEGER)',
          );
        },
      );
    }
  }

  /// 插入电影Id编号，电影封面图链接，电影下载链接，电影下载状态
  Future<void> insertDownload(String movieId, String url, String cover,
      String title, String status, String localPath, int synchro) async {
    int isSuccess = await db.insert('download', {
      'movieId': movieId,
      'cover': cover,
      'url': url,
      'title': title,
      'status': status,
      'localPath': localPath,
      'synchro': synchro
    });
    print('insertDownload --$isSuccess');
  }

  /// 删除数据
  Future<void> deleteDownload(String movieId) async {
    await db.delete('download', where: 'movieId = ?', whereArgs: [movieId]);
  }

  /// 更新数据
  Future<void> updateDownload(String movieId, String status) async {
    await db.update(
        'download',
        {
          'status': status,
        },
        where: 'movieId = ?',
        whereArgs: [movieId]);
  }

  //根据url 更新数据的Status状态 如果为succeeded 则更新localPath
  Future<void> updateDownloadStatus(String url, String status,
      {String localPath = ''}) async {
    await db.update('download', {'status': status, 'localPath': localPath},
        where: 'url = ?', whereArgs: [url]);
  }

  //根据url 查询数据的synchro状态
  Future<int> querySynchro(String url) async {
    List<Map<String, Object?>> list =
        await db.query('download', where: 'url = ?', whereArgs: [url]);
    if (list.isEmpty) {
      return 0;
    } else {
      return list[0]['synchro'] as int;
    }
  }

  //根据url 获取movieId
  Future<String> queryMovieId(String url) async {
    List<Map<String, Object?>> list =
        await db.query('download', where: 'url = ?', whereArgs: [url]);
    if (list.isEmpty) {
      return '';
    } else {
      return list[0]['movieId'] as String;
    }
  }

  //根据movieId 更新数据的synchro状态
  Future<void> updateSynchro(String movieId, int synchro) async {
    await db.update('download', {'synchro': synchro},
        where: 'movieId = ?', whereArgs: [movieId]);
  }

  // 根据movieId查询数据库中是否有该电影 返回bool
  Future<bool> queryDownload(String movieId) async {
    List<Map<String, Object?>> list =
        await db.query('download', where: 'movieId = ?', whereArgs: [movieId]);
    if (list.isEmpty) {
      return false;
    } else {
      return true;
    }
  }

  //查询status不为succeeded的电影 不需要localPath synchro字段
  Future<List<Map<String, Object?>>> queryAllDownloadNotSucceeded() async {
    List<Map<String, Object?>> list = await db
        .query('download', where: 'status != ?', whereArgs: ['succeeded']);
    return list;
  }

  //查询所有电影数据
  Future<List<Map<String, Object?>>> queryAllDownload() async {
    List<Map<String, Object?>> list = await db.query('download');
    return list;
  }

  //随机获取为succeeded的10条 cover数据，如不满10查询全部, 返回类型List<String> Cover数据
  Future<List<String>> queryCover() async {
    List<Map<String, Object?>> list = await db.query('download',
        where: 'status = ?',
        whereArgs: ['succeeded'],
        columns: ['cover'],
        limit: 10,
        orderBy: 'RANDOM()');
    List<String> coverList = [];
    if (list.isEmpty) {
      return coverList;
    } else {
      for (int i = 0; i < list.length; i++) {
        coverList.add(list[i]['cover'] as String);
      }
      return coverList;
    }
  }

  //随机获取 一条数据 返回Cover
  Future<String?> queryCoverOne() async {
    List<Map<String, Object?>> list = await db.query('download',
        columns: ['cover'],
        where: 'status = ?',
        whereArgs: ['succeeded'],
        limit: 1,
        orderBy: 'RANDOM()');
    if (list.isEmpty) {
      return null;
    } else {
      return list[0]['cover'] as String;
    }
  }

//随机查询出一个数据，使用String a = ;String b = title;
  Future<List<String>> queryUrlTitle() async {
    List<Map<String, Object?>> list = await db.rawQuery(
        "SELECT localPath, title FROM download WHERE status = 'succeeded' ORDER BY RANDOM() LIMIT 1");

    List<String> urlTitleList = [];
    if (list.isEmpty) {
      return urlTitleList;
    } else {
      urlTitleList.add(list[0]['localPath'] as String);
      urlTitleList.add(list[0]['title'] as String);
      return urlTitleList;
    }
  }
}
