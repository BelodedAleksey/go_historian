import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_historian/main.dart';
import 'package:go_historian/main_model.dart';
import 'package:go_historian/tags_model.dart';
import 'package:provider/provider.dart';

class TagsPage extends StatefulWidget {
  final mainModel;

  TagsPage(this.mainModel);

  @override
  _TagsPageState createState() => _TagsPageState();
}

class _TagsPageState extends State<TagsPage> {
  static const chan_hist = MethodChannel('hist');

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //Синглтон
    screenModel.width = MediaQuery.of(context).size.width;
    screenModel.height = MediaQuery.of(context).size.height;
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<TagsModel>(
          create: (context) => TagsModel(widget.mainModel.selectedServer),
        ),
        ChangeNotifierProvider<MainModel>.value(
          value: widget.mainModel,
        )
      ],
      child: Center(
        child: Material(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(40.0)),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.green,
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(40.0),
            ),
            width: screenModel.width / 2,
            height: screenModel.height / 1.1,
            child: Padding(
              padding: EdgeInsets.only(top: 20, bottom: 20),
              child: Consumer<TagsModel>(
                builder: (context, tagsModel, child) => Column(
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(Icons.search),
                        Container(
                          color: Colors.white,
                          width: 300,
                          child: TextField(
                            controller: tagsModel.filterCtrl,
                            onChanged: (str) => tagsModel.filter(),
                            decoration: InputDecoration.collapsed(
                                hintText: "Введите фильтр..."),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: screenModel.height / 1.3,
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: (tagsModel.filteredTags == null)
                            ? 0
                            : tagsModel.filteredTags.length,
                        itemBuilder: (context, i) => Card(
                          color: i == tagsModel.selectedTag
                              ? Colors.red
                              : Colors.white,
                          child: ListTile(
                            title: Text(tagsModel.filteredTags[i]["name"]),
                            subtitle:
                                Text(tagsModel.filteredTags[i]["description"]),
                            enabled: true,
                            onTap: () {
                              tagsModel.selectTag(i);
                              Provider.of<MainModel>(context, listen: false)
                                ..add(
                                    "tag",
                                    tagsModel
                                            .filteredTags[tagsModel.selectedTag]
                                        ["name"]);
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
