import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TagsModel with ChangeNotifier {
  static const chan_hist = MethodChannel('hist');
  List<dynamic> tags;
  List<dynamic> filteredTags;
  int selectedTag;
  TextEditingController filterCtrl = TextEditingController();

  TagsModel(String server) {
    fetchTags(server);
  }

  @override
  void dispose() {
    filterCtrl.dispose();
    super.dispose();
  }

  //Фильтр по тэгам
  void filter() {
    filteredTags = tags.where((tag) {
      if (tag["name"].toLowerCase().contains(filterCtrl.text.toLowerCase())) {
        return true;
      }
      return false;
    }).toList();
    notifyListeners();
  }

  //Делаем запрос на тэги
  void fetchTags(String server) async {
    tags = await chan_hist.invokeMethod("onFetchTags", server);
    filteredTags = tags;
    notifyListeners();
  }

  //Выбираем тэг
  void selectTag(int i) {
    selectedTag = i;
    notifyListeners();
  }
}
