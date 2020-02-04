import 'package:flutter/material.dart';
import 'package:go_historian/tags_page.dart';
import 'package:provider/provider.dart';
import 'package:go_historian/main_model.dart';
import 'dart:io';

//Колонка с полями ввода тэгов
Widget tagsExpanded(BuildContext context) => Expanded(
      child: Consumer<MainModel>(
        builder: (context, mainModel, child) => Container(
          color: Colors.amberAccent,
          child: Column(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.all(5.0),
                child: SizedBox(
                  height: 400,
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
                            width: 500,
                            child: TextField(
                              controller: mainModel.ctrlTags[i],
                              style: TextStyle(fontSize: 30.0),
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

//Колонка с полями ввода времени
Widget timesExpanded(BuildContext context) => Expanded(
      child: Consumer<MainModel>(
        builder: (context, mainModel, child) => Container(
          color: Colors.blue,
          child: Column(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.all(5.0),
                child: SizedBox(
                  height: 400,
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
                            width: 250,
                            child: TextField(
                              controller: mainModel.ctrlFirstTimes[i],
                              style: TextStyle(fontSize: 30.0),
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
                            width: 250,
                            child: TextField(
                              controller: mainModel.ctrlLastTimes[i],
                              style: TextStyle(fontSize: 30.0),
                              textAlign: TextAlign.center,
                              decoration: InputDecoration.collapsed(
                                  hintText: "Конец..."),
                            ),
                          ),
                          IconButton(
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
                child: Text("Добавить время"),
                onPressed: () {
                  mainModel.add("time");
                },
              )
            ],
          ),
        ),
      ),
    );

//Поле ввода сервера
Widget serverExpanded(BuildContext context) => Expanded(
      child: Consumer<MainModel>(
        builder: (context, mainModel, child) => Container(
          color: Colors.brown,
          child: Row(children: [
            Text(
              "Сервер: ",
              style: TextStyle(fontSize: 70.0),
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(),
              ),
              width: 300,
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
                          style: TextStyle(fontSize: 40.0),
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

//Поле ввода интервала
Widget intervalExpanded(BuildContext context, Animation animation) => Expanded(
      child: Consumer<MainModel>(
        builder: (context, mainModel, child) => Container(
          color: Colors.cyanAccent,
          child: Row(
            children: <Widget>[
              Text(
                "Интервал: ",
                style: TextStyle(fontSize: 70.0),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(),
                ),
                width: 100,
                child: TextField(
                  controller: mainModel.ctrlInterval,
                  style: TextStyle(fontSize: 30.0),
                  textAlign: TextAlign.center,
                  decoration:
                      InputDecoration.collapsed(hintText: "Интервал..."),
                ),
              ),
              Text(
                "Прогресс: ",
                style: TextStyle(fontSize: 40.0),
              ),
              SizedBox(
                height: 50,
                width: 500,
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
                //Navigator.of(context).pushNamed('/test');
                mainModel.readConfig();
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 20, right: 20),
            child: MaterialButton(
              color: Colors.redAccent,
              child: Text("Сохранить конфиг"),
              onPressed: () {
                mainModel.saveConfig();
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
        ],
      ),
    );
