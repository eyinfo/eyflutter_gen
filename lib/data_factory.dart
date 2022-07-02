import 'dart:async';
import 'dart:collection';

import 'package:eyflutter_gen/enums/db_operation_type.dart';
import 'package:eyflutter_gen/events/i_data_entry.dart';
import 'package:eyflutter_gen/events/i_data_factory.dart';
import 'package:eyflutter_gen/sql_where_builder.dart';
import 'package:flutter/services.dart';
import 'package:isolate/isolate.dart';

class DataFactory implements IDataFactory {
  final String _dbAction = "cabc4e3d3aca4fd394c0b2d18c1c1d3a";
  final String _dataKey = "data";
  final String _operationTypeKey = "operationType";
  final String _whereKey = "where";

  Future<LoadBalancer> loadBalancer = LoadBalancer.create(8, IsolateRunner.spawn);

  @override
  void onPrepareData<T>(DbOperationType operationType, T data, {required SqlWhereBuilder builder}) {
    if (operationType == DbOperationType.insertOrReplace) {
      _handler<void, T>(operationType, "", "", builder, data: data);
    }
  }

  @override
  Future<T?> onHandle<T>(DbOperationType operationType, String schema, String fields,
      {required SqlWhereBuilder builder}) {
    switch (operationType) {
      case DbOperationType.query:
      case DbOperationType.queryList:
      case DbOperationType.count:
      case DbOperationType.exists:
      case DbOperationType.deleteInTx:
      case DbOperationType.deleteInTxAll:
        return _handler<T, IDataEntry>(operationType, schema, fields, builder);
      default:
        return Future.value();
    }
  }

  Future<R?> _handler<R, T>(DbOperationType operationType, String schema, String fields, SqlWhereBuilder builder,
      {T? data}) async {
    var balancer = await loadBalancer;
    var params = _HandlerParams<T>(operationType, schema, fields, builder, data);
    var retMap = await balancer.run<Map<String, dynamic>, _HandlerParams>(_handlerPrepare, params);
    var _methodChannel = const OptionalMethodChannel("0eff8bd070f64d1890193686196f5a31");
    return _methodChannel.invokeMethod<R>(_dbAction, retMap);
  }

  Map<String, dynamic> _handlerPrepare<T>(_HandlerParams<T> params) {
    Map<String, dynamic> map = HashMap<String, dynamic>();
    map[_operationTypeKey] = params.operationType.name;
    map[_whereKey] = params.builder.build;
    var data = params.data;
    if (data == null) {
      map["schema"] = params.schema;
      map["fields"] = params.fields;
    } else {
      if (data is IDataEntry) {
        map[_dataKey] = data.toJsonMap();
        map["schema"] = data.getSchema();
        map["fields"] = data.getFields();
      } else if (data is List) {
        List<Map<String, dynamic>> lst = [];
        for (IDataEntry entry in data) {
          lst.add(entry.toJsonMap());
        }
        map[_dataKey] = lst;
        if (data.isNotEmpty && data[0] is IDataEntry) {
          IDataEntry entity = data[0] as IDataEntry;
          map["schema"] = entity.getSchema();
          map["fields"] = entity.getFields();
        }
      }
    }
    return map;
  }
}

class _HandlerParams<T> {
  final DbOperationType operationType;
  final String schema;
  final String fields;
  final SqlWhereBuilder builder;
  final T? data;

  _HandlerParams(this.operationType, this.schema, this.fields, this.builder, this.data);
}
