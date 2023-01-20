enum ResultFieldType {
  user_id,
  question,
  createdAt,
}

extension ResultFieldTypeEx on ResultFieldType {
  bool get isDropdown => false;
}

/*
'user_id' snake case
'createdAt' camel case
*/

List<String> getResultFieldList() => ResultFieldType.values.map((x) => x.name).toList();

int getResultFieldIndex({required String name}) => getResultFieldList().indexOf(name);
