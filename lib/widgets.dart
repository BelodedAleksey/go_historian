import 'package:flutter/material.dart';
import 'package:go_historian/tags_page.dart';
import 'package:provider/provider.dart';
import 'package:go_historian/main_model.dart';
import 'package:file_picker/file_picker.dart';
import 'package:go_historian/main.dart';

//Колонка с полями ввода тэгов
Widget tagsExpanded(BuildContext context) {
  return Expanded(
    child: Consumer<MainModel>(
      builder: (context, mainModel, child) => Container(
        color: Colors.amberAccent,
        child: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(5.0),
              child: SizedBox(
                height: screenModel.height / 2,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: mainModel.ctrlTags.length,
                  itemBuilder: (ctx, i) {
                    return Row(
                      children: <Widget>[
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(),
                          ),
                          width: screenModel.width / 2.5,
                          child: TextField(
                            controller: mainModel.ctrlTags[i],
                            style: TextStyle(fontSize: screenModel.width / 45),
                            textAlign: TextAlign.center,
                            decoration:
                                InputDecoration.collapsed(hintText: "Тэг..."),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.close),
                          onPressed: () {
                            mainModel.delete("tag", i);
                          },
                        )
                      ],
                    );
                  },
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                MaterialButton(
                  color: Colors.green,
                  child: Text("Добавить тэг"),
                  onPressed: () {
                    mainModel.add("tag");
                  },
                ),
                MaterialButton(
                  color: Colors.blue,
                  child: Text("Список тэгов"),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => TagsPage(mainModel),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

//Колонка с полями ввода времени
Widget timesExpanded(BuildContext context) {
  return Expanded(
    child: Consumer<MainModel>(
      builder: (context, mainModel, child) => Container(
        color: Colors.blue,
        child: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(5.0),
              child: SizedBox(
                height: screenModel.height / 2,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: mainModel.ctrlFirstTimes.length,
                  itemBuilder: (ctx, i) {
                    return Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(),
                          ),
                          width: screenModel.width / 5,
                          child: TextField(
                            controller: mainModel.ctrlFirstTimes[i],
                            style: TextStyle(fontSize: screenModel.width / 45),
                            textAlign: TextAlign.center,
                            decoration: InputDecoration.collapsed(
                                hintText: "Начало..."),
                          ),
                        ),
                        Text(" : "),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(),
                          ),
                          width: screenModel.width / 5,
                          child: TextField(
                            controller: mainModel.ctrlLastTimes[i],
                            style: TextStyle(fontSize: screenModel.width / 45),
                            textAlign: TextAlign.center,
                            decoration:
                                InputDecoration.collapsed(hintText: "Конец..."),
                          ),
                        ),
                        IconButton(
                          iconSize: screenModel.width / 35,
                          icon: Icon(Icons.close),
                          onPressed: () {
                            mainModel.delete("time", i);
                          },
                        )
                      ],
                    );
                  },
                ),
              ),
            ),
            MaterialButton(
              color: Colors.green,
              child: Text(
                "Добавить время",
                style: TextStyle(
                  fontSize: screenModel.width / 50,
                ),
              ),
              onPressed: () {
                mainModel.add("time");
              },
            )
          ],
        ),
      ),
    ),
  );
}

//Поле ввода сервера
Widget serverExpanded(BuildContext context) {
  return Expanded(
    child: Consumer<MainModel>(
      builder: (context, mainModel, child) => Container(
        color: Colors.brown,
        child: Row(children: [
          Text(
            "Сервер: ",
            style: TextStyle(
                fontSize: screenModel.width / 15 * screenModel.height / 1100),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(),
            ),
            width: screenModel.width / 4,
            child: DropdownButton<String>(
              items: <String>[
                "ihistorian",
                "srv2-historian",
                "ihistory",
                "a3_tvhist",
                "historyop",
                "histfspo",
                "histnef",
                "histizm3"
              ]
                  .map(
                    (value) => DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        value,
                        style: TextStyle(
                            fontSize: screenModel.width /
                                30 *
                                screenModel.height /
                                900),
                      ),
                    ),
                  )
                  .toList(),
              value: mainModel.selectedServer,
              onChanged: (newValue) {
                mainModel.changeServer(newValue);
              },
            ),
          ),
        ]),
      ),
    ),
  );
}

//Поле ввода интервала
Widget intervalExpanded(BuildContext context, Animation animation) {
  return Expanded(
    child: Consumer<MainModel>(
      builder: (context, mainModel, child) => Container(
        color: Colors.cyanAccent,
        child: Row(
          children: <Widget>[
            Text(
              "Интервал: ",
              style: TextStyle(fontSize: screenModel.width / 25),
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(),
              ),
              width: screenModel.width / 10,
              child: TextField(
                controller: mainModel.ctrlInterval,
                style: TextStyle(fontSize: screenModel.width / 30),
                textAlign: TextAlign.center,
                decoration: InputDecoration.collapsed(hintText: "Интервал..."),
              ),
            ),
            Text(
              "Прогресс: ",
              style: TextStyle(fontSize: screenModel.width / 25),
            ),
            SizedBox(
              height: screenModel.height / 13,
              width: screenModel.width / 2.2,
              child: LinearProgressIndicator(
                backgroundColor: Colors.yellowAccent,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.lightBlue),
                value: animation.value,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

//Кнопка Отправить запрос
Widget fetchBtn(BuildContext context) => Consumer<MainModel>(
      builder: (context, mainModel, child) => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(left: 20, right: 20),
            child: MaterialButton(
              color: Colors.redAccent,
              child: Text("Загрузить конфиг"),
              onPressed: () {
                //Вызываем проводник
                FilePicker.getFilePath().then((_path) {
                  String filename = _path.split('/').last;
                  mainModel.readConfig(filename);
                });
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 20, right: 20),
            child: MaterialButton(
              color: Colors.redAccent,
              child: Text("Сохранить конфиг"),
              onPressed: () {
                FilePicker.getFilePath().then((_path) {
                  String filename = _path.split('/').last;
                  mainModel.saveConfig(filename);
                });
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 20, right: 20),
            child: MaterialButton(
              color: Colors.red,
              child: Text(
                "Сделать запрос",
              ),
              onPressed: () {
                mainModel.fetchData();
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 20, right: 20),
            child: MaterialButton(
              color: Colors.red,
              child: Text(
                "Прервать запрос",
              ),
              onPressed: () {
                mainModel.cancelFetch();
              },
            ),
          ),
        ],
      ),
    );
