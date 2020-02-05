import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MainModel with ChangeNotifier {
  static const chan_hist = MethodChannel('hist');

  TextEditingController ctrlInterval = TextEditingController(text: "1s");

  List<TextEditingController> ctrlTags = List<TextEditingController>.generate(
      1, (i) => TextEditingController(text: "*CR1_LEVEL.F_CV"));
  List<TextEditingController> ctrlFirstTimes =
      List<TextEditingController>.generate(
          1, (i) => TextEditingController(text: "01-01-20 05:00:00"));
  List<TextEditingController> ctrlLastTimes =
      List<TextEditingController>.generate(
          1, (i) => TextEditingController(text: "01-01-20 06:00:00"));

  String selectedServer = "ihistorian";

  @override
  void dispose() {
    ctrlTags.forEach((_ctrl) {
      _ctrl.dispose();
    });
    ctrlFirstTimes.forEach((_ctrl) {
      _ctrl.dispose();
    });
    ctrlLastTimes.forEach((_ctrl) {
      _ctrl.dispose();
    });

    super.dispose();
  }

  //Загрузить конфиг
  void readConfig() async {
    String filename = 'test.txt';
    var result = await chan_hist.invokeMethod('onReadConfig', filename);
    //server returned with \r
    selectedServer = result['server'].trim();
    ctrlInterval.text = result['interval'].trim();
    for (int i = 0; i < result['tags'].length; i++) {
      if (i == ctrlTags.length) {
        ctrlTags.add(TextEditingController());
      }
      ctrlTags[i].text = result['tags'][i].trim();
    }
    for (int i = 0; i < result['times'].length; i++) {
      if (i == ctrlFirstTimes.length) {
        ctrlFirstTimes.add(TextEditingController());
        ctrlLastTimes.add(TextEditingController());
      }
      ctrlFirstTimes[i].text = result['times'][i][0];
      ctrlLastTimes[i].text = result['times'][i][1].trim();
    }
    notifyListeners();
  }

  //Сохранить конфиг
  void saveConfig() {
    Map<String, dynamic> args = {};
    String filename = 'test.txt';
    args['filename'] = filename;
    args['server'] = selectedServer;
    args['interval'] = ctrlInterval.text;
    List<String> tags = [];
    ctrlTags.forEach((_ctrl) {
      tags.add(_ctrl.text);
    });
    args['tags'] = tags;
    List<List<String>> times = [];
    for (var i = 0; i < ctrlFirstTimes.length; i++) {
      times.add([ctrlFirstTimes[i].text, ctrlLastTimes[i].text]);
    }
    args['times'] = times;
    chan_hist.invokeMethod("onSaveConfig", args);
  }

  //Изменить сервер
  void changeServer(String server) {
    selectedServer = server;
    notifyListeners();
  }

  //Добавить поле ввода
  void add(String type, [String value]) {
    TextEditingController _ctrl = TextEditingController();
    switch (type) {
      case "tag":
        _ctrl.text = value;
        ctrlTags.add(_ctrl);
        break;
      case "time":
        ctrlFirstTimes.add(_ctrl);
        _ctrl = TextEditingController();
        ctrlLastTimes.add(_ctrl);
        break;
      default:
        break;
    }
    notifyListeners();
  }

  //Удалить поле ввода
  void delete(String type, int i) {
    switch (type) {
      case "tag":
        ctrlTags.removeAt(i);
        break;
      case "time":
        ctrlFirstTimes.removeAt(i);
        ctrlLastTimes.removeAt(i);
        break;
      default:
        break;
    }
    notifyListeners();
  }

  //Запросить выборку
  void fetchData() {
    Map<String, dynamic> args = {};
    args['server'] = selectedServer;
    args['interval'] = ctrlInterval.text;
    List<String> tags = [];
    ctrlTags.forEach((_ctrl) {
      tags.add(_ctrl.text);
    });
    args['tags'] = tags;
    List<List<String>> times = [];
    for (var i = 0; i < ctrlFirstTimes.length; i++) {
      times.add([ctrlFirstTimes[i].text, ctrlLastTimes[i].text]);
    }
    args['times'] = times;
    chan_hist.invokeMethod('onFetch', args);
  }
}
