import 'dart:convert';

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
  //List _alldata = [];
  //List _filteredalldata = [];
  var data = [];
  //var alldata = [];

  //Icon _searchIcon = new Icon(Icons.search);
  //final TextEditingController _filter = new TextEditingController();
  //String _searchText = "";
  //Widget _appBarTitle = new Text( 'Photographers' );

  final myController = TextEditingController();

  getData() async{
    print('in getData()');
    SharedPreferences getDataPrefs = await SharedPreferences.getInstance();

    // Запрос фотографов
    await http.get('https://jsonplaceholder.typicode.com/users').then((response) {
        debugPrint("user response ${response.statusCode}");
        if(response.statusCode == 200) {
          data = json.decode(response.body.toString());
          getDataPrefs.setString('users', response.body);
          setState(() {
            _array = data;
            //_alldata = data;
          });
        }
      }).catchError((error){
        print("Error: $error");
      });

    // Запрос альбомов
    await http.get('https://jsonplaceholder.typicode.com/albums').then((response) {
      debugPrint("album response ${response.statusCode}");
      if(response.statusCode == 200) {
        //alldata.clear();
        //alldata = json.decode(response.body.toString());
        getDataPrefs.setString('albums', response.body);
        //_alldata.addAll(alldata);
      }
    }).catchError((error){
      print("Error: $error");
    });

    // Запрос фотографий
    await http.get('https://jsonplaceholder.typicode.com/photos').then((response) {
      debugPrint("photo response ${response.statusCode}");
      if(response.statusCode == 200) {
        getDataPrefs.setString('photos', response.body);
        //alldata.clear();
        //alldata = json.decode(response.body.toString());
        //_alldata.addAll(alldata);
        //setState(() {});
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
          //_alldata = data;
        });
        //var cachedJSONalbum = (prefs.getString('albums'));
        //alldata = json.decode(cachedJSON);
        //_alldata.addAll(alldata);
        //var cachedJSONphotos = (prefs.getString('photos'));
        //alldata = json.decode(cachedJSON);
        //_alldata.addAll(alldata);
        //setState(() {});
      }
  }

  onChangeName(int index, String newName) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    data[index]["name"] = newName;
    prefs.setString('users', data.toString());
    getCached();
    print('data: $data');
    print('cache: ${prefs.getString('users')}');
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

  //searching(){
  //  setState(() {
  //    if (this._searchIcon.icon == Icons.search) {
  //      this._searchIcon = new Icon(Icons.close);
  //      this._appBarTitle = new TextField(
  //          controller: _filter,
  //          decoration: new InputDecoration(
  //            prefixIcon: new Icon(Icons.search),
  //            hintText: 'Search...',
  //          ),
  //          onChanged: (value){
  //            List tempList = new List();
  //            _filteredalldata = _alldata;
  //            for (int i = 0; i < _filteredalldata.length; i++) {
  //              if (_filteredalldata[i]['name'].toLowerCase().contains(value.replaceAll(" ", "").toLowerCase()) ||
  //                  _filteredalldata[i]['title'].toLowerCase().contains(value.replaceAll(" ", "").toLowerCase()) ) {
  //                tempList.add(_filteredalldata[i]);
  //              }
  //            }
  //            setState(() {
  //              _filteredalldata = tempList;
  //            });
  //          }
  //      );
  //    } else {
  //      this._searchIcon = new Icon(Icons.search);
  //      this._appBarTitle = new Text('Albums');
  //      _filteredalldata = _array;
  //      _filter.clear();
  //    }
  //  });
//
  //}

  //ExamplePageState() {
  //  _filter.addListener(() {
  //    if (_filter.text.isEmpty) {
  //      setState(() {
  //        _searchText = "";
  //        _filteredalldata = _alldata;
  //      });
  //    } else {
  //      setState(() {
  //        _searchText = _filter.text;
  //      });
  //    }
  //  });
  //}


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

