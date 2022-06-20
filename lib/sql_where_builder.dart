import 'package:eyflutter_gen/enums/sql_operator.dart';

class SqlWhereBuilder {
  SqlWhereBuilder._();

  static SqlWhereBuilder get builder {
    return SqlWhereBuilder._();
  }

  final StringBuffer _where = StringBuffer("1=1");

  String _operator(SqlOperator operator) {
    switch (operator) {
      case SqlOperator.eq:
        return "=";
      case SqlOperator.ne:
        return "!=";
      case SqlOperator.gt:
        return ">";
      case SqlOperator.lt:
        return "<";
      case SqlOperator.ge:
        return ">=";
      case SqlOperator.le:
        return "<=";
    }
  }

  /// eg. a='val1' and b='val2'
  SqlWhereBuilder andWhere({required String fieldName, required SqlOperator operator, required String value}) {
    if (fieldName.isEmpty || value.isEmpty) {
      return this;
    }
    _where.write(" and $fieldName ${_operator(operator)} '$value'");
    return this;
  }

  /// or (c='c1' ...)
  /// eg. a='val1' and b='val2' or (c='c1' and ...)
  SqlWhereBuilder orWhere({required SqlWhereBuilder childBuild}) {
    _where.write(" or (${childBuild._where.toString()})");
    return this;
  }

  /// 自定义条件
  SqlWhereBuilder andConditionWhere(String where) {
    if (where.isEmpty) {
      return this;
    }
    _where.write(" and $where");
    return this;
  }

  String get build {
    return _where.toString();
  }
}
