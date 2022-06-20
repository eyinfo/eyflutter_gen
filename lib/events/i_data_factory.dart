
import 'package:eyflutter_gen/enums/db_operation_type.dart';
import 'package:eyflutter_gen/sql_where_builder.dart';

mixin IDataFactory {
  void onPrepareData<T>(DbOperationType operationType, T data, {required SqlWhereBuilder builder});

  Future<R?> onHandle<R>(DbOperationType operationType, String schema, String fields,
      {required SqlWhereBuilder builder});
}
