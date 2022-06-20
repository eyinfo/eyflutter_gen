import 'package:eyflutter_gen/data_factory.dart';
import 'package:eyflutter_gen/enums/db_operation_type.dart';
import 'package:eyflutter_gen/events/i_data_factory.dart';
import 'package:eyflutter_gen/sql_where_builder.dart';

/// DataStorage[Item|Entry]对象
class DbUtils {
  factory DbUtils() => _getInstance();

  static DbUtils get instance => _getInstance();
  static DbUtils? _instance;

  static DbUtils _getInstance() {
    return _instance ??= DbUtils._internal();
  }

  DbUtils._internal();

  final IDataFactory _dataFactory = DataFactory();

  /// 插入或替换数据
  /// [data] 数据对象或列表
  /// [builder] 根据条件插入或更新数据
  void insertOrReplace<T>(T data, {required SqlWhereBuilder builder}) {
    _dataFactory.onPrepareData<T>(DbOperationType.insertOrReplace, data, builder: builder);
  }

  /// 删除数据
  /// [schema] 数据表结构
  /// [fields] 数据表字段
  void deleteInTx({required String schema, required String fields, required SqlWhereBuilder builder}) {
    _dataFactory.onHandle(DbOperationType.deleteInTx, schema, fields, builder: builder);
  }

  /// 查询数据(当前执行sql后查询有多条记录时默认返回第一条)
  /// [schema] 数据表结构
  /// [fields] 数据表字段
  /// 返回json数据
  Future<String?> query({required String schema, required String fields, required SqlWhereBuilder builder}) {
    return _dataFactory.onHandle<String>(DbOperationType.query, schema, fields, builder: builder);
  }

  /// 查询数据集
  ///[schema] 数据表结构
  /// [fields] 数据表字段
  /// 返回json数据
  Future<String?> queryList({required String schema, required String fields, required SqlWhereBuilder builder}) {
    return _dataFactory.onHandle<String>(DbOperationType.queryList, schema, fields, builder: builder);
  }

  /// 统计数据
  ///[schema] 数据表结构
  /// [fields] 数据表字段
  Future<int?> count({required String schema, required String fields, required SqlWhereBuilder builder}) {
    return _dataFactory.onHandle<int>(DbOperationType.count, schema, fields, builder: builder);
  }

  /// 是否存在数据
  ///[schema] 数据表结构
  /// [fields] 数据表字段
  Future<bool> exists({required String schema, required String fields, required SqlWhereBuilder builder}) async {
    var _count = (await count(schema: schema, fields: fields, builder: builder)) ?? 0;
    return _count > 0 ? Future.value(true) : Future.value(false);
  }
}
