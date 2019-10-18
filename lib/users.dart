import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
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

  getData() async{
    print('in getData()');
    SharedPreferences getDataPrefs = await SharedPreferences.getInstance();

    // Запрос фотографов
    var userResponse = await http.get('https://jsonplaceholder.typicode.com/users').then((response) {
        debugPrint("user response ${response.statusCode}");
        if(response.statusCode == 200) {
          data = json.decode(response.body.toString());
          getDataPrefs.setString('users', response.body);
          setState(() {
            _array = data;
          });
        }
      }).catchError((error){
        print("Error: $error");
      });

    // Запрос альбомов
    var albumResponse = await http.get('https://jsonplaceholder.typicode.com/albums').then((response) {
      debugPrint("album response ${response.statusCode}");
      if(response.statusCode == 200) {
        getDataPrefs.setString('albums', response.body);
      }
    }).catchError((error){
      print("Error: $error");
    });

    // Запрос фотографий
    var photoResponse = await http.get('https://jsonplaceholder.typicode.com/photos').then((response) {
      debugPrint("photo response ${response.statusCode}");
      if(response.statusCode == 200) {
        getDataPrefs.setString('photos', response.body);
      }
    }).catchError((error){
      print("Error: $error");
    });

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
                child: Container (
                  padding: EdgeInsets.only(top: 10),
                  child: ListView.builder(
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
                          onTap: () =>  onTapped("${_array[i]["id"]}"),);
                      }
                  ),
                )
            ),
          ],
        ))
    );
  }
}

