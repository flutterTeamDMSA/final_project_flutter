import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:contrast_shower_app/models/dataModel.dart';

class DataProvider extends ChangeNotifier {
  late List<DataModel> _dataList = [];

  List<DataModel> get dataList => _dataList;

  Future<void> loadDataFromHive() async {
    var box = await Hive.openBox('history');
    List<dynamic> dataListFromBox = box.get('dataList', defaultValue: []);
    
    _dataList = dataListFromBox.map((data) => DataModel(
      index: data['index'] ?? 0,
      name: data['name'] ?? '',
      proteins: data['proteins'] ?? 0,
      fats: data['fats'] ?? 0,
      carbohydrates: data['carbohydrates'] ?? 0,
      caloris: data['caloris'] ?? 0,
      date: data['date'] != null ? DateTime.parse(data['date']) : DateTime.now(),
    )).toList();

    _dataList.sort((a, b) => b.date.compareTo(a.date));
    
    notifyListeners();
  }

  Map<String, Map<String, List<DataModel>>> getWeeklyGroupedData() {
    Map<String, Map<String, List<DataModel>>> groupedData = {};

    for (var data in _dataList) {
      String weekKey = _getWeekKey(data.date);
      String dayKey = _getDayKey(data.date);

      if (!groupedData.containsKey(weekKey)) {
        groupedData[weekKey] = {};
      }
      if (!groupedData[weekKey]!.containsKey(dayKey)) {
        groupedData[weekKey]![dayKey] = [];
      }
      groupedData[weekKey]![dayKey]!.add(data);
    }

    return groupedData;
  }

  String _getWeekKey(DateTime date) {
    var firstDayOfWeek = date.subtract(Duration(days: date.weekday - 1));
    var lastDayOfWeek = firstDayOfWeek.add(const Duration(days: 6));
    return '${firstDayOfWeek.toIso8601String().split('T').first} - ${lastDayOfWeek.toIso8601String().split('T').first}';
  }

  String _getDayKey(DateTime date) {
    return date.toIso8601String().split('T').first;
  }

  Future<void> saveDataToHive(String name, int proteins,int fats, int carbohydrates, int caloris) async {
    var box = await Hive.openBox('history');
    
    List<dynamic> dataListFromBox = box.get('dataList', defaultValue: []);
    
    int newIndex = _dataList.isNotEmpty ? _dataList.last.index + 1 : 0;
    DateTime currentDate = DateTime.now();

    dataListFromBox.add({
      'index': newIndex,
      'name': name,
      'proteins': proteins,
      'fats': fats,
      'carbohydrates': carbohydrates,
      'caloris': caloris,
      'date': currentDate.toIso8601String(),
    });

    await box.put('dataList', dataListFromBox);

    await box.close();

    await loadDataFromHive(); 
  }

  Future<void> updateDataInHive(int index, String name, int proteins, int fats, int carbohydrates, int caloris) async {
    var box = await Hive.openBox('history');
    
    List<dynamic> dataListFromBox = box.get('dataList', defaultValue: []);
    
    for (int i = 0; i < dataListFromBox.length; i++) {
      if (dataListFromBox[i]['index'] == index) {
        dataListFromBox[i] = {
          'index': index,
          'name': name,
          'proteins': proteins,
          'fats': fats,
          'carbohydrates': carbohydrates,
          'caloris': caloris,
          'date': dataListFromBox[i]['date'],
        };
        break;
      }
    }

    await box.put('dataList', dataListFromBox);

    await box.close();

    await loadDataFromHive();
  }
}
