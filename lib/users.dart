import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'albums.dart';

class MyBody extends StatefulWidget {
  @override
  createState() => new MyBodyState();
}

class MyBodyState extends State<MyBody> {
  List _array = [];
  var data = [];

  String errorMessage = "";
  bool checkError = false;


  final myController = TextEditingController();

  getData() async{
    print('in getData()');
    SharedPreferences getDataPrefs = await SharedPreferences.getInstance();

    // Запрос фотографов
    try {
      Response response = await Dio().get("https://jsonplaceholder.typicode.com/users");
      debugPrint("user response ${response.statusCode}");
      if(response.statusCode == 200) {
        data = response.data;
        getDataPrefs.setString('users', json.encode(data));
        setState(() {
          _array = data;
        });
      }
      if(response.statusCode == 404) {
        setState(() {
          checkError = true;
          errorMessage = "Ресурс был удален";
        });
      }
      if(response.statusCode == 500) {
        setState(() {
          checkError = true;
          errorMessage = "Internal Server Error: ошибка соединения с сервером";
        });
      }
      if(response.statusCode == 503) {
        setState(() {
          checkError = true;
          errorMessage = "Сервер недоступен";
        });
      }
    } catch (e) {
      print(e);
      setState(() {
        checkError = true;
        errorMessage = "Internal Server Error: проверьте подключение";
      });
    }

    // Запрос альбомов
    try {
      Response response = await Dio().get("https://jsonplaceholder.typicode.com/albums");
      debugPrint("album response ${response.statusCode}");
      if(response.statusCode == 200) {
        var albums = response.data;
        getDataPrefs.setString('albums', json.encode(albums));
      }
    } catch (e) {
      print(e);
    }
    // Запрос фотографий
    try {
      Response response = await Dio().get("https://jsonplaceholder.typicode.com/photos");
      debugPrint("photo response ${response.statusCode}");
      if(response.statusCode == 200) {
        var photos = response.data;
        getDataPrefs.setString('photos', json.encode(photos));
      }
    } catch (e) {
      print(e);
    }

  }

  onTapped(String id) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => AlbumsBody( userId: id,
    )));
  }

  getCached() async{

    var inGetData = false;
    SharedPreferences prefs = await SharedPreferences.getInstance();
      var cachedJSON = (prefs.getString('users') ?? {
        getData(),
        inGetData = true
      });
      if (!inGetData){
        print('in getCach()');
        data = json.decode(cachedJSON);
        setState(() {
          _array = data;
        });
      }
  }

  onChangeName(int index, String newName) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    data[index]["name"] = newName;
    prefs.setString('users', json.encode(data));
    getCached();
  }

  void _showChangeDialog(int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Новое имя'),
              content: TextField(
            controller: myController,
        ),
          actions: <Widget>[
            FlatButton(
              onPressed: () {
                myController.text = "";
                Navigator.pop(context);
              },
              child: Text('Close'),
            ),
            FlatButton(
              onPressed: () {
                print(myController.text);
                onChangeName(index, myController.text);
                myController.text = "";
                Navigator.pop(context);
              },
              child: Text('Ok'),
            )
          ],
        );
      }
    );
  }


  deleteCache() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.clear();
    DefaultCacheManager().emptyCache();
    setState(() {
      data.clear();
      _array.clear();
    });
    print('deleted');
    getCached();
  }


  @override
  void initState() {
    getCached();
    super.initState();
  }


  @override
  Widget build(BuildContext context) {

    return new Scaffold(
        backgroundColor: Colors.grey[300],
        appBar: new AppBar(
          title: new Text('Photographers'),
          actions: <Widget>[
            // action button
            IconButton(
              icon: Icon(Icons.refresh),
              onPressed: () {
                deleteCache();
              },
            ),
          ],),
        body:  Container (
        child:
        Column (
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded (
              // Если ошибка покажет алерт диалог
                child: Container (
                  padding: EdgeInsets.only(top: 10),
                  child: checkError? Container(
                    child: AlertDialog(
                            title: Text('$errorMessage'),
                            content: Text(""),
                            actions: <Widget>[
                              FlatButton(
                                onPressed: () {
                                  checkError = false;
                                  getCached();
                                },
                                child: Text('Попробовать снова'),
                              )
                            ],
                          )
                    )
                    : ListView.builder(
                      itemCount: _array.length,
                      itemBuilder: (context, i){
                        return new ListTile(
                          title: Container (
                              color: Colors.white,
                            child: Row(
                                children:[
                                  Expanded(
                                      child: Container(
                                          child: Container(
                                              child: Column (
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Container (
                                                    padding: EdgeInsets.fromLTRB(10, 10, 0, 0),
                                                    child: RichText(
                                                      text: TextSpan(
                                                        style: DefaultTextStyle.of(context).style,
                                                        children: <TextSpan>[
                                                          TextSpan(text: 'Name: ', style: TextStyle(fontWeight: FontWeight.bold)),
                                                          TextSpan(text: "${_array[i]["name"]}"),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  Container (
                                                    padding: EdgeInsets.fromLTRB(10, 2, 0, 2),
                                                    child: RichText(
                                                      text: TextSpan(
                                                        style: DefaultTextStyle.of(context).style,
                                                        children: <TextSpan>[
                                                          TextSpan(text: 'Nickname: ', style: TextStyle(fontWeight: FontWeight.bold)),
                                                          TextSpan(text: "${_array[i]["username"]}"),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  Container (
                                                    padding: EdgeInsets.fromLTRB(10, 0, 0, 10),
                                                    child: RichText(
                                                      text: TextSpan(
                                                        style: DefaultTextStyle.of(context).style,
                                                        children: <TextSpan>[
                                                          TextSpan(text: 'email: ', style: TextStyle(fontWeight: FontWeight.bold)),
                                                          TextSpan(text: "${_array[i]["email"]}"),
                                                        ],
                                                      ),
                                                    ),
                                                  )
                                                ],
                                              ))
                                      ),),
                                ]
                            )),
                          onTap: () =>  onTapped("${_array[i]["id"]}"),
                        onLongPress: () =>  {
                            myController.text = "${_array[i]["name"]}",
                            _showChangeDialog(i)
                        },);
                      }
                  ),
                )
            ),
          ],
        ))
    );
  }
}

