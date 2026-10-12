// Date: 15/2/2025
// By: Fouad
// Last update: 15/2/2025
// Objectives: Implementation of column model
class ColumnModel {
  String? title;
  String? hint;
  bool? isRequired;
  String? alignment;
  String? fieldType;
  String? maxSelection; //checkbox
  String? arrangement; //radio
  List<String?>? options; //radio
  int? limitation; //image,description
  String? locationType; //location
  //title
  String? textSize;
  bool? isBold;
  bool? isItalic;
  bool? isUnderLine;
  String? color;
  String? response;

  ColumnModel({
    required this.fieldType,
    required this.textSize,
    required this.isBold,
    required this.isItalic,
    required this.isUnderLine,
    required this.color,
    required this.locationType,
    required this.limitation,
    required this.arrangement,
    required this.isRequired,
    required this.hint,
    required this.options,
    required this.title,
    required this.alignment,
    required this.maxSelection,
    this.response,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'Location_Type': locationType,
      'Limitation': limitation,
      'Text_Size': textSize,
      'Is_Bold': isBold,
      'Is_Italic': isItalic,
      'Is_Underline': isUnderLine,
      'Color': color,
      'Arrangement': arrangement,
      'Hint': hint,
      'Options': options,
      'Title': title,
      'Alignment': alignment,
      'Max_Selection': maxSelection,
      'Field_Type': fieldType,
      'Is_Required': isRequired,
      'Response': response
    };
  }

  factory ColumnModel.fromMap(Map<String, dynamic> map) {
    ColumnModel columnModel= ColumnModel(
      locationType: map['Location_Type'],
      limitation: map['Limitation'],
      textSize: map['Text_Size'],
      isBold: map['Is_Bold'],
      isItalic: map['Is_Italic'],
      isUnderLine: map['Is_Underline'],
      color: map['Color'],
      arrangement: map['Arrangement'],
      hint: map['Hint'],
      options: (map['Options'] as List<dynamic>?)?.cast<String>(),
      title: map['Title'],
      alignment: map['Alignment'],
      maxSelection: map['Max_Selection'],
      fieldType: map['Field_Type'],
      isRequired: map['Is_Required'],
      response: map['Response'],
    );
    return columnModel;
  }
}
