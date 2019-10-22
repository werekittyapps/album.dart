import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity/connectivity.dart';
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
  List _arrayOfUsers = [];
  List _arrayOfAlbums = [];
  List _arrayOfPhotos = [];

  List _filteredArray = [];

  var data = [];

  String errorMessage = "";
  bool checkError = false;
  bool checkAlbumError = false;
  bool checkPhotoError = false;

  final myController = TextEditingController();

  Icon _searchIcon = new Icon(Icons.search);
  final TextEditingController _filter = new TextEditingController();
  Widget _appBarTitle = new Text( 'Photographers' );

  var categoryFlag = "users";
  var searchFlag = false;
  bool isConnected = false;
  bool isLoading = false;

  getData() async{
    setState(() {
      isLoading = true;
    });
    print('in getData()');
    SharedPreferences getDataPrefs = await SharedPreferences.getInstance();

    // Запрос фотографов
    try {
      Response response = await Dio().get("https://jsonplaceholder.typicode.com/users");
      debugPrint("user response ${response.statusCode}");
      if(response.statusCode == 200) {
        checkError = false;
        data = response.data;
        getDataPrefs.setString('users', json.encode(data));
        setState(() {
          _arrayOfUsers = data;
          if (categoryFlag == "users") _filteredArray = _arrayOfUsers;
        });
      }
      if(response.statusCode == 400) {
        setState(() {
          checkError = true;
          errorMessage = "Некорректный запрос";
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
      //print(e);
      setState(() {
        checkError = true;
        errorMessage = "Ошибка запроса: проверьте подключение";
      });
    }

    // Запрос альбомов
    try {
      Response response = await Dio().get("https://jsonplaceholder.typicode.com/albums");
      debugPrint("album response ${response.statusCode}");
      if(response.statusCode == 200) {
        checkAlbumError = false;
        var albums = response.data;
        getDataPrefs.setString('albums', json.encode(albums));
        _arrayOfAlbums = albums;
        setState(() {
          if (categoryFlag == "albums") _filteredArray = _arrayOfAlbums;
        });
      }
      if(response.statusCode == 400) {
        setState(() {
          checkError = true;
          checkAlbumError = true;
          errorMessage = "Некорректный запрос";
        });
      }
      if(response.statusCode == 404) {
        setState(() {
          checkError = true;
          checkAlbumError = true;
          errorMessage = "Ресурс был удален";
        });
      }
      if(response.statusCode == 500) {
        setState(() {
          checkError = true;
          checkAlbumError = true;
          errorMessage = "Internal Server Error: ошибка соединения с сервером";
        });
      }
      if(response.statusCode == 503) {
        setState(() {
          checkError = true;
          checkAlbumError = true;
          errorMessage = "Сервер недоступен";
        });
      }
    } catch (e) {
      //print(e);
      setState(() {
        checkError = true;
        checkAlbumError = true;
        errorMessage = "Ошибка запроса: проверьте подключение";
      });
    }
    // Запрос фотографий
    try {
      Response response = await Dio().get("https://jsonplaceholder.typicode.com/photos");
      debugPrint("photo response ${response.statusCode}");
      if(response.statusCode == 200) {
        checkPhotoError = false;
        var photos = response.data;
        getDataPrefs.setString('photos', json.encode(photos));
        _arrayOfPhotos = photos;
        setState(() {
          if (categoryFlag == "photos") _filteredArray = _arrayOfPhotos;
          isLoading = false;
        });
      }
      if(response.statusCode == 400) {
        setState(() {
          checkError = true;
          checkPhotoError = true;
          errorMessage = "Некорректный запрос";
          setState(() {
            isLoading = false;
          });
        });
      }
      if(response.statusCode == 404) {
        setState(() {
          checkError = true;
          checkPhotoError = true;
          errorMessage = "Ресурс был удален";
          setState(() {
            isLoading = false;
          });
        });
      }
      if(response.statusCode == 500) {
        setState(() {
          checkError = true;
          checkPhotoError = true;
          errorMessage = "Internal Server Error: ошибка соединения с сервером";
          setState(() {
            isLoading = false;
          });
        });
      }
      if(response.statusCode == 503) {
        setState(() {
          checkError = true;
          checkPhotoError = true;
          errorMessage = "Сервер недоступен";
          setState(() {
            isLoading = false;
          });
        });
      }
    } catch (e) {
      //print(e);
      setState(() {
        checkError = true;
        checkPhotoError = true;
        errorMessage = "Ошибка запроса: проверьте подключение";
        setState(() {
          isLoading = false;
        });
      });
    }

  }

  onTapped(String id) {
    Navigator.push(context, MaterialPageRoute(
        builder: (context) => AlbumsBody( userId: id,
          albumError: checkAlbumError, photoError: checkPhotoError,
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

        var cachedAlbumJSON = (prefs.getString('albums'));
        var albumData = json.decode(cachedAlbumJSON);
        var cachedPhotoJSON = (prefs.getString('photos'));
        var photoData = json.decode(cachedPhotoJSON);
            setState(() {
          _arrayOfUsers = data;
          _arrayOfAlbums = albumData;
          _arrayOfPhotos = photoData;
          if (categoryFlag == "users") _filteredArray = _arrayOfUsers;
          if (categoryFlag == "albums") _filteredArray = _arrayOfAlbums;
          if (categoryFlag == "photos") _filteredArray = _arrayOfPhotos;
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
      _arrayOfUsers.clear();
      _arrayOfAlbums.clear();
      _arrayOfPhotos.clear();
    });
    print('deleted');
    getCached();
  }

  checkInternet() async{
    print('here');
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile) {
      // I am connected to a mobile network.
      print("mobile");
      setState(() {
        isConnected = true;
      });
    } else if (connectivityResult == ConnectivityResult.wifi) {
      // I am connected to a wifi network.
      print("wifi");
      setState(() {
        isConnected = true;
      });
    }else {
      print("no");
      setState(() {
        isConnected = false;
      });
    }
  }

  searching(){
    getCached();
    setState(() {
      if (this._searchIcon.icon == Icons.search) {
        searchFlag = true;
        if (categoryFlag == "users") _filteredArray = _arrayOfUsers;
        if (categoryFlag == "albums") _filteredArray = _arrayOfAlbums;
        if (categoryFlag == "photos") _filteredArray = _arrayOfPhotos;
        this._searchIcon = new Icon(Icons.close);
        this._appBarTitle = new TextField(
            controller: _filter,
            decoration: new InputDecoration(
              prefixIcon: new Icon(Icons.search),
              hintText: 'Search...',
            ),
            onChanged: (value) {
              //if (value.length >= 2) {
                if (categoryFlag == "albums") {
                  List tempList = new List();
                  _filteredArray = _arrayOfAlbums;
                  if (value.length >= 2) {
                    for (int i = 0; i < _filteredArray.length; i++) {
                      if (_filteredArray[i]['title'].toLowerCase().contains(
                          value.trim().toLowerCase())) {
                        tempList.add(_filteredArray[i]);
                      }
                    }
                  } else {
                    tempList = _arrayOfAlbums;
                  }
                  setState(() {
                    _filteredArray = tempList;
                  });
                }
                if (categoryFlag == "photos") {
                  List tempList = new List();
                  _filteredArray = _arrayOfPhotos;
                  if (value.length >= 2) {
                    for (int i = 0; i < _filteredArray.length; i++) {
                      if (_filteredArray[i]['title'].toLowerCase().contains(
                          value.trim().toLowerCase())) {
                        tempList.add(_filteredArray[i]);
                      }
                    }
                  } else {
                    tempList = _arrayOfPhotos;
                  }
                  setState(() {
                    _filteredArray = tempList;
                  });
                }
                if (categoryFlag == "users") {
                  List tempList = new List();
                  _filteredArray = _arrayOfUsers;
                  if (value.length >= 2) {
                    for (int i = 0; i < _filteredArray.length; i++) {
                      if (_filteredArray[i]['name'].toLowerCase().contains(
                          value.trim().toLowerCase())) {
                        tempList.add(_filteredArray[i]);
                      }
                    }
                  } else {
                    tempList = _arrayOfUsers;
                  }
                  setState(() {
                    _filteredArray = tempList;
                  });
                }
              //}
            }
        );
      } else {
        this._searchIcon = new Icon(Icons.search);
        this._appBarTitle = new Text('Photographers');
        searchFlag = false;
        _filter.clear();
      }
    });

  }


  @override
  void initState() {
    checkInternet();
    getCached();
    super.initState();
  }


  @override
  Widget build(BuildContext context) {

    return new Scaffold(
        backgroundColor: Colors.grey[300],
        appBar: new AppBar(
          title: _appBarTitle,
          actions: <Widget>[
            // action button
            IconButton(
              icon: _searchIcon,
              onPressed: () {
                searching();
              },
            ),
            IconButton(
              icon: Icon(Icons.refresh),
              onPressed: () {
                deleteCache();
              },
            ),
          ],),
        body:  Container (
        child: searchFlag ?
        Column (
          children: [
            Container(
              child: ButtonBar(
          mainAxisSize: MainAxisSize.min, // this will take space as minimum as posible(to center)
          children: <Widget>[
            new RaisedButton(
                color: categoryFlag == "users" ? Colors.white : Colors.grey,
                onPressed: (){
                  setState(() {
                    categoryFlag = "users";
                    _filteredArray = _arrayOfUsers;
                  });
                }, child: Text('Фотографы')),
            new RaisedButton(
                color: categoryFlag == "albums" ? Colors.white : Colors.grey,
                onPressed: (){
                  setState(() {
                    categoryFlag = "albums";
                    _filteredArray = _arrayOfAlbums;
                  });
                }, child: Text('Альбомы')),
            new RaisedButton(
                color: categoryFlag == "photos" ? Colors.white : Colors.grey,
                onPressed: (){
                  setState(() {
                    categoryFlag = "photos";
                    checkInternet();
                    _filteredArray = _arrayOfPhotos;
                  });
                }, child: Text('Фотографии')),
          ],
        ),
            ),
            Expanded (
                child: Container (
                  child: categoryFlag == "albums" ?


                      Container (
                        alignment: Alignment(0.0, -1.0),
                      child: isLoading ? CircularProgressIndicator()
                          :
                      checkAlbumError ? Container(
                          padding: EdgeInsets.fromLTRB(15, 15, 15, 0),
                          child: Row(
                              children:[
                                Expanded(
                                    child: Container(
                                      color: Colors.white,
                                      padding: EdgeInsets.fromLTRB(10, 20, 10, 20),
                                      child: Text('Что-то пошло не так'),
                                    ))])

                      ) : _filteredArray.length == 0 ? Container(
                          padding: EdgeInsets.fromLTRB(15, 15, 15, 0),
                          child: Row(
                              children:[
                                Expanded(
                                    child: Container(
                                      color: Colors.white,
                                      padding: EdgeInsets.fromLTRB(10, 20, 10, 20),
                                      child: Text('Нет данных'),
                                    ))])

                      ) :
                      ListView.builder(
                      itemCount: _arrayOfAlbums == null ? 0 : _filteredArray.length,
                          itemBuilder: (context, i){
                            return new ListTile(
                              title: Container (
                                  color: Colors.white,
                                  child: Row(
                                      children:[
                                        Expanded(
                                            child: Container(
                                                child: Column (
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Container (
                                                      padding: EdgeInsets.fromLTRB(10, 10, 0, 2),
                                                      child: RichText(
                                                        text: TextSpan(
                                                          style: DefaultTextStyle.of(context).style,
                                                          children: <TextSpan>[
                                                            TextSpan(text: 'Title: ', style: TextStyle(fontWeight: FontWeight.bold)),
                                                            TextSpan(text: "${_filteredArray[i]["title"]}"),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                    Container (
                                                      padding: EdgeInsets.fromLTRB(10, 2, 0, 10),
                                                      child: RichText(
                                                        text: TextSpan(
                                                          style: DefaultTextStyle.of(context).style,
                                                          children: <TextSpan>[
                                                            TextSpan(text: 'ID: ', style: TextStyle(fontWeight: FontWeight.bold)),
                                                            TextSpan(text: "${_filteredArray[i]["id"]}"),
                                                          ],
                                                        ),
                                                      ),
                                                    )
                                                  ],
                                                ))),
                                      ]
                                  )),
                            );
                          }
                      ),)


                      : categoryFlag == "photos" ?
                  Container (
                      alignment: Alignment(0.0, -1.0),
                      child: isLoading ? CircularProgressIndicator()
                          :
                      _filteredArray.length == 0 ? Container(
                          padding: EdgeInsets.fromLTRB(15, 15, 15, 0),
                          child: Row(
                              children:[
                                Expanded(
                                    child: Container(
                                      color: Colors.white,
                                      padding: EdgeInsets.fromLTRB(10, 20, 10, 20),
                                      child: Text('Нет данных'),
                                    ))])

                      ) : ListView.builder(
                          itemCount: _filteredArray.length,
                          itemBuilder: (context, i){
                            return new Container(
                                padding: EdgeInsets.only(bottom: 10),
                                child: Column(
                                    children:[
                                      Container (
                                          color: Colors.white,
                                          child: Row (
                                              children: [
                                                Container (
                                                  width: 120.0,
                                                  height: 120.0,
                                                  padding: EdgeInsets.all(10),
                                                  child: !isConnected ? Image.asset(
                                                    'assets/images/placeholder.png',
                                                    width: 100.0, height: 100.0, fit: BoxFit.cover,
                                                  )
                                                      : CachedNetworkImage(
                                                    imageUrl: "${_filteredArray[i]["url"]}",
                                                    width: 100.0, height: 100.0, fit: BoxFit.cover,
                                                    placeholder: (context, url) => CircularProgressIndicator(),
                                                    errorWidget: (context, url, error) => Icon(Icons.error),
                                                  ),
                                                ),
                                                Expanded(child: Column (
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Container (
                                                      padding: EdgeInsets.all(10),
                                                      child: RichText(
                                                        text: TextSpan(
                                                          style: DefaultTextStyle.of(context).style,
                                                          children: <TextSpan>[
                                                            TextSpan(text: 'Title: ', style: TextStyle(fontWeight: FontWeight.bold)),
                                                            TextSpan(text: "${_filteredArray[i]["title"]}"),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                    Container (
                                                      padding: EdgeInsets.all(10),
                                                      child: RichText(
                                                        text: TextSpan(
                                                          style: DefaultTextStyle.of(context).style,
                                                          children: <TextSpan>[
                                                            TextSpan(text: 'ID: ', style: TextStyle(fontWeight: FontWeight.bold)),
                                                            TextSpan(text: "${_filteredArray[i]["id"]}"),
                                                          ],
                                                        ),
                                                      ),
                                                    )
                                                  ],
                                                ))
                                              ]
                                          )
                                      ),
                                    ]
                                ));
                          }
                      ))


                      : Container (
                    alignment: Alignment(0.0, -1.0),
                    child: isLoading ? CircularProgressIndicator()
                        :
                    _filteredArray.length == 0 ? Container(
                        padding: EdgeInsets.fromLTRB(15, 15, 15, 0),
                        child: Row(
                            children:[
                              Expanded(
                                  child: Container(
                                    color: Colors.white,
                                    padding: EdgeInsets.fromLTRB(10, 20, 10, 20),
                                    child: Text('Нет данных'),
                                  ))])

                    ) :
                    ListView.builder(
                        itemCount: _filteredArray.length,
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
                                                            TextSpan(text: "${_filteredArray[i]["name"]}"),
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
                                                            TextSpan(text: "${_filteredArray[i]["username"]}"),
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
                                                            TextSpan(text: "${_filteredArray[i]["email"]}"),
                                                          ],
                                                        ),
                                                      ),
                                                    )
                                                  ],
                                                ))
                                        ),),
                                    ]
                                )),
                          );
                        }
                    ),
                  ),

                )
            ),
          ],
        )
            :
        isLoading ? Container(
          alignment: Alignment(0.0, 0.0),
          child: CircularProgressIndicator(),
        )
            :
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
                      itemCount: _arrayOfUsers.length,
                      itemBuilder: (context, i){
                        return new ListTile(
                          title: Container (
                              color: Colors.white,
                            child: Row(
                                children:[
                                  Expanded(
                                      child: Container(
                                          child:
                                          Container(
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
                                                          TextSpan(text: "${_arrayOfUsers[i]["name"]}"),
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
                                                          TextSpan(text: "${_arrayOfUsers[i]["username"]}"),
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
                                                          TextSpan(text: "${_arrayOfUsers[i]["email"]}"),
                                                        ],
                                                      ),
                                                    ),
                                                  )
                                                ],
                                              ))
                                      ),),
                                ]
                            )),
                          onTap: () =>  onTapped("${_arrayOfUsers[i]["id"]}"),
                        onLongPress: () =>  {
                            myController.text = "${_arrayOfUsers[i]["name"]}",
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

