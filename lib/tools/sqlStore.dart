//Sql
import 'dart:io';

import 'package:external_path/external_path.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import '../Interface.dart';

class SqlStore extends GetxController {
  static SqlStore get to => Get.find();

  Database? db;

  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onClose() async {
    await db!.close();
  }

  Future<void> deleteFile() async {
    File file = File('/storage/emulated/0/Movies/dib/sql/a_download.db');

    try {
      bool exists = await file.exists();
      if (exists) {
        await file.delete();
        print('文件删除成功');
        await openDatabaseConnection();
      } else {
        print('文件不存在');
      }
    } catch (e) {
      print('删除文件时发生错误：$e');
    }
  }

  /// 打开数据库
  Future<void> openDatabaseConnection() async {
    String dibblerPath = await getLocalSQLlPath();


    String databaseName = 'a_download.db';
    String path = join('${dibblerPath}sql', databaseName);

    // 检查数据库文件是否存在
    bool databaseExists = await File(path).exists();

    // 如果数据库文件存在，直接打开
    if (databaseExists) {
      try {
        db = await openDatabase(path);
      } catch (e) {
        deleteFile();
        return;
      }
    } else {
      // 如果数据库不存在，创建数据库
      db = await openDatabase(
        path,
        version: 1,
        onCreate: (database, version) async {
          // 创建 download 表
          await database.execute(
            'CREATE TABLE a_download (id INTEGER PRIMARY KEY, movieId TEXT, url TEXT,'
            ' cover TEXT, title TEXT, status TEXT, localPath TEXT, intro TEXT,synchro INTEGER)',
          );
          // 创建 orders 表
          await database.execute(
            'CREATE TABLE a_orders (id TEXT PRIMARY KEY ,videoId TEXT, title TEXT, nickname TEXT,'
            ' truename TEXT, isplay INTEGER,createTime TEXT)',
          );
        },
      );
    }
  }

  //---------------------下载download sql----------------------
  /// 插入电影Id编号，电影封面图链接，电影下载链接，电影下载状态
  Future<void> insertDownload(
      String movieId,
      String url,
      String cover,
      String title,
      String status,
      String localPath,
      String intro,
      int synchro) async {
    int isSuccess = await db!.insert('a_download', {
      'movieId': movieId,
      'cover': cover,
      'url': url,
      'title': title,
      'status': status,
      'localPath': localPath,
      'intro': intro,
      'synchro': synchro
    });
    print('insertDownload --$isSuccess');
  }

  /// 删除数据
  Future<void> deleteDownload(String movieId) async {
    await db!.delete('a_download', where: 'movieId = ?', whereArgs: [movieId]);
  }

  /// 更新数据
  // Future<void> updateDownload(String movieId, String status) async {
  //   await db.update(
  //       'a_download',
  //       {
  //         'status': status,
  //       },
  //       where: 'movieId = ?',
  //       whereArgs: [movieId]);
  // }

  //根据url 更新数据的Status状态 如果为succeeded 则更新localPath
  Future<void> updateDownloadStatus(String url, String status,
      {String localPath = ''}) async {
    await db!.update('a_download', {'status': status, 'localPath': localPath},
        where: 'url = ?', whereArgs: [url]);
  }

  //根据url 查询数据的synchro状态
  // Future<int> querySynchro(String url) async {
  //   List<Map<String, Object?>> list =
  //       await db.query('a_download', where: 'url = ?', whereArgs: [url]);
  //   if (list.isEmpty) {
  //     return 0;
  //   } else {
  //     return list[0]['synchro'] as int;
  //   }
  // }

  //查询下载状态为0的数据的 返回url 返回类型类型List<String>
  // Future<List<String>> querySynchro() async {
  //   List<Map<String, Object?>> list =
  //       await db.query('a_download', where: 'synchro = ?', whereArgs: [0]);
  //   List<String> urlList = [];
  //   if (list.isEmpty) {
  //     return urlList;
  //   } else {
  //     for (int i = 0; i < list.length; i++) {
  //       urlList.add(list[i]['url'] as String);
  //     }
  //     return urlList;
  //   }
  // }

  // Future<List<Map<String, Object?>>> querySynchro() async {
  //   List<Map<String, Object?>> list =
  //       await db.query('a_download', where: 'synchro = ?', whereArgs: [0]);
  //   return list;
  // }

  //根据url 获取movieId
  Future<String> queryMovieId(String url) async {
    List<Map<String, Object?>> list =
        await db!.query('a_download', where: 'url = ?', whereArgs: [url]);
    if (list.isEmpty) {
      return '';
    } else {
      return list[0]['movieId'] as String;
    }
  }

  //根据movieId 获取LocalPath 和title
  Future<String> queryLocalPath(String movieId) async {
    List<Map<String, Object?>> list = await db!
        .query('a_download', where: 'movieId = ?', whereArgs: [movieId]);
    if (list.isEmpty) {
      return '';
    } else {
      return list[0]['localPath'] as String;
    }
  }

  //根据movieId 更新数据的synchro状态
  Future<void> updateSynchro(String movieId, int synchro) async {
    await db!.update('a_download', {'synchro': synchro},
        where: 'movieId = ?', whereArgs: [movieId]);
  }

  // 根据movieId查询数据库中是否有该电影 返回bool
  Future<bool> queryDownload(String movieId) async {
    List<Map<String, Object?>> list = await db!
        .query('a_download', where: 'movieId = ?', whereArgs: [movieId]);
    if (list.isEmpty) {
      return false;
    } else {
      return true;
    }
  }

  //查询status不为succeeded的电影 不需要localPath synchro字段
  Future<List<Map<String, Object?>>> queryAllDownloadNotSucceeded() async {
    List<Map<String, Object?>> list = await db!
        .query('a_download', where: 'status != ?', whereArgs: ['succeeded']);
    return list;
  }

  //查询状态为succeeded的电影的数量
  Future<int> querySucceeded() async {
    List<Map<String, Object?>> list = await db!
        .query('a_download', where: 'status = ?', whereArgs: ['succeeded']);
    return list.length;
  }

  //查询所有所有数据
  // Future<List<Map<String, Object?>>> queryAllDownload() async {
  //   List<Map<String, Object?>> list = await db.query('a_download');
  //   return list;
  // }

  //查询6个数据 如果不满6个，则返回6个一样的数据
  Future<List<Map<String, Object?>>> querySixDownload() async {
    List<Map<String, Object?>> list = await db!.rawQuery(
        "SELECT * FROM a_download WHERE status = 'succeeded' ORDER BY RANDOM() LIMIT 6");

    return list;
  }

  //随机获取 一条数据 返回Cover
  // Future<String?> queryCoverOne() async {
  //   List<Map<String, Object?>> list = await db.query('a_download',
  //       columns: ['cover'],
  //       where: 'status = ?',
  //       whereArgs: ['succeeded'],
  //       limit: 1,
  //       orderBy: 'RANDOM()');
  //   if (list.isEmpty) {
  //     return null;
  //   } else {
  //     return list[0]['cover'] as String;
  //   }
  // }

//随机查询出一个数据，使用String a = ;String b = title;
//   Future<List<String>> queryUrlTitle() async {
//     List<Map<String, Object?>> list = await db.rawQuery(
//         "SELECT localPath, title FROM a_download WHERE status = 'succeeded' ORDER BY RANDOM() LIMIT 1");
//
//     List<String> urlTitleList = [];
//     if (list.isEmpty) {
//       return urlTitleList;
//     } else {
//       urlTitleList.add(list[0]['localPath'] as String);
//       urlTitleList.add(list[0]['title'] as String);
//       return urlTitleList;
//     }
//   }

//------------------------------------------------------

//--------------------------订单sql----------------------
  //给orders表插入数据 0为未播放 1为正在播放
  Future<void> insertOrders(String id, String videoId, String title,
      String nickname, String truename, String createTime,
      {int isplay = 0}) async {
    int isSuccess = await db!.insert('a_orders', {
      'id': id,
      'videoId': videoId,
      'title': title,
      'nickname': nickname,
      'truename': truename,
      'createTime': createTime,
      'isplay': isplay,
    });
    print('insertOrders --$isSuccess');
  }

  //根据videoId 修改 isplay状态
  Future<void> updateOrders(String id, int isplay) async {
    await db!.update('a_orders', {'isplay': isplay},
        where: 'id = ?', whereArgs: [id]);
  }

  //判断是否有存在isplay = 1的数据
  Future<bool> queryIsPlay() async {
    List<Map<String, Object?>> list =
        await db!.query('a_orders', where: 'isplay = ?', whereArgs: [1]);
    if (list.isEmpty) {
      return false;
    } else {
      return true;
    }
  }

  //根据videoId 删除数据
  Future<void> deleteOrders(String Id) async {
    await db!.delete('a_orders', where: 'id = ?', whereArgs: [Id]);
  }

  //查询所有数据并且根据createTime排序
  Future<List<Map<String, Object?>>> queryAllOrders() async {
    List<Map<String, dynamic>> list = await db!.rawQuery(
        'SELECT * FROM a_orders ORDER BY CAST(createTime AS INTEGER) ASC');
    return list;
  }

//-------------------------------------------------------
}
