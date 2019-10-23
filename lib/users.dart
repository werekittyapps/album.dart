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

  List _filteredArrayOfUsers = [];
  List _filteredArrayOfAlbums = [];
  List _filteredArrayOfPhotos = [];
  List _partlyFilteredArrayOfPhotos = [];

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
  bool emptySearchCall = false;

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
          //if (categoryFlag == "users") _filteredArray = _arrayOfUsers;
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
        //setState(() {
        //  if (categoryFlag == "albums") _filteredArray = _arrayOfAlbums;
        //});
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
          //if (categoryFlag == "photos") _filteredArray = _arrayOfPhotos;
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
          //if (categoryFlag == "users") _filteredArray = _arrayOfUsers;
          //if (categoryFlag == "albums") _filteredArray = _arrayOfAlbums;
          //if (categoryFlag == "photos") _filteredArray = _arrayOfPhotos;
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
      emptySearchCall = false;
      this._searchIcon = new Icon(Icons.search);
      this._appBarTitle = new Text('Photographers');
      searchFlag = false;
      _filter.clear();
      data.clear();
      _arrayOfUsers.clear();
      _arrayOfAlbums.clear();
      _arrayOfPhotos.clear();
    });
    print('deleted');
    getCached();
  }

  checkInternet() async{
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile) {
      // I am connected to a mobile network.
      print("mobile connection");
      setState(() {
        isConnected = true;
      });
    } else if (connectivityResult == ConnectivityResult.wifi) {
      // I am connected to a wifi network.
      print("wifi connection");
      setState(() {
        isConnected = true;
      });
    }else {
      print("no connection");
      setState(() {
        isConnected = false;
      });
    }
  }

  searching(){
    getCached();
    emptySearchCall = true;
    setState(() {
      if (this._searchIcon.icon == Icons.search) {
        this._searchIcon = new Icon(Icons.close);
        this._appBarTitle = new TextField(
            controller: _filter,
            decoration: new InputDecoration(
              prefixIcon: new Icon(Icons.search),
              hintText: 'Search...',
            ),
            onChanged: (value) {
              var val = value;
              _filteredArrayOfUsers = _arrayOfUsers;
              _filteredArrayOfAlbums = _arrayOfAlbums;
              _filteredArrayOfPhotos = _arrayOfPhotos;
              _partlyFilteredArrayOfPhotos.clear();
              List usersTempList = new List();
              List albumsTempList = new List();
              List photosTempList = new List();
              if(val.length >= 2){
                setState(() {
                  searchFlag = true;
                  emptySearchCall = false;
                });
                for (int i = 0; i < _filteredArrayOfUsers.length; i++) {
                  if (_filteredArrayOfUsers[i]['name'].toLowerCase().contains(
                      val.trim().toLowerCase())) {
                    usersTempList.add(_filteredArrayOfUsers[i]);
                  }
                }
                for (int i = 0; i < _filteredArrayOfAlbums.length; i++) {
                  if (_filteredArrayOfAlbums[i]['title'].toLowerCase().contains(
                      val.trim().toLowerCase())) {
                    albumsTempList.add(_filteredArrayOfAlbums[i]);
                  }
                }
                for (int i = 0; i < _filteredArrayOfPhotos.length; i++) {
                  if (_filteredArrayOfPhotos[i]['title'].toLowerCase().contains(
                      val.trim().toLowerCase())) {
                    photosTempList.add(_filteredArrayOfPhotos[i]);
                  }
                }
              } else {
                searchFlag = false;
                usersTempList.clear();
                albumsTempList.clear();
                photosTempList.clear();
              }
              setState(() {
                searchFlag = searchFlag;
                _filteredArrayOfUsers = usersTempList;
                _filteredArrayOfAlbums = albumsTempList;
                _filteredArrayOfPhotos = photosTempList;
                if(_filteredArrayOfPhotos.length >= 10) {
                  for (var i = 0; i <= 9; i++) {
                    _partlyFilteredArrayOfPhotos.add(_filteredArrayOfPhotos[i]);
                  }
                }
                if(_filteredArrayOfUsers.isNotEmpty && categoryFlag == "users") categoryFlag = "users";
                if(_filteredArrayOfAlbums.isNotEmpty && categoryFlag == "albums") categoryFlag = "albums";
                if(_filteredArrayOfPhotos.isNotEmpty && categoryFlag == "photos") categoryFlag = "photos";
                if(_filteredArrayOfUsers.isEmpty && categoryFlag == "users") categoryFlag = "albums";
                if(_filteredArrayOfAlbums.isEmpty && categoryFlag == "albums") categoryFlag = "users";
                if(_filteredArrayOfUsers.isNotEmpty && _filteredArrayOfAlbums.isEmpty && _filteredArrayOfPhotos.isEmpty) categoryFlag = "users";
                if(_filteredArrayOfUsers.isEmpty && _filteredArrayOfAlbums.isNotEmpty && _filteredArrayOfPhotos.isEmpty) categoryFlag = "albums";
                if(_filteredArrayOfUsers.isEmpty && _filteredArrayOfAlbums.isEmpty && _filteredArrayOfPhotos.isNotEmpty) categoryFlag = "photos";
              });
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

  onMoreBtnTapped(){
    setState(() {
      var dif = _filteredArrayOfPhotos.length - _partlyFilteredArrayOfPhotos.length;
      var filteredLength = _partlyFilteredArrayOfPhotos.length;
      if(dif >= 10) {
        for (var i = filteredLength; i < filteredLength + 10; i++) {
          _partlyFilteredArrayOfPhotos.add(_filteredArrayOfPhotos[i]);
        }
      }
      else {
        for (var i = filteredLength; i < filteredLength + dif; i++) {
          _partlyFilteredArrayOfPhotos.add(_filteredArrayOfPhotos[i]);
        }
      }
    }
    );
    print("All: ${_filteredArrayOfPhotos.length}");
    print("Part: ${_partlyFilteredArrayOfPhotos.length}");
  }

  cachedImageLoader(int i){
    //try{
    //  return CachedNetworkImage(
    //          imageUrl: "${_partlyFilteredArrayOfPhotos[i]["url"]}",
    //          width: 100.0, height: 100.0, fit: BoxFit.cover,
    //          placeholder: (context, url) => CircularProgressIndicator(),
    //          errorWidget: (context, url, error) => Icon(Icons.error),
    //        );
    //} catch(e) {
    //  print("Error: $e");
    //}
    checkInternet();

    if(isConnected){
      return CachedNetworkImage(
        imageUrl: "${_partlyFilteredArrayOfPhotos[i]["url"]}",
        width: 100.0, height: 100.0, fit: BoxFit.cover,
        placeholder: (context, url) => CircularProgressIndicator(),
        errorWidget: (context, url, error) => Icon(Icons.error),
      );
    } else {
      return Image.asset(
        'assets/images/placeholder.png',
        width: 100.0, height: 100.0, fit: BoxFit.cover,
      );
    }
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
              onPressed: _arrayOfUsers.isEmpty && _arrayOfAlbums.isEmpty && _arrayOfPhotos.isEmpty ? null : () {
                checkInternet();
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
              child: Row(
                children: <Widget>[
                  Expanded(
                    child:
                      Container(
                        padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                        child:
                          Row (
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: <Widget>[
                              if (_filteredArrayOfUsers.isNotEmpty)
                              Container(
                                padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
                                child: RaisedButton(
                                    color: categoryFlag == "users" ? Colors.white : Colors.grey,
                                    onPressed: (){
                                      setState(() {
                                        categoryFlag = "users";
                                      });
                                    }, child: Text('Фотографы')),
                              ),
                              if (_filteredArrayOfAlbums.isNotEmpty)
                              Container(
                                padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
                                child: RaisedButton(
                                    color: categoryFlag == "albums" ? Colors.white : Colors.grey,
                                    onPressed: (){
                                      setState(() {
                                        categoryFlag = "albums";
                                      });
                                    }, child: Text('Альбомы')),
                              ),
                              if (_filteredArrayOfPhotos.isNotEmpty)
                              Container(
                                padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
                                child: RaisedButton(
                                    color: categoryFlag == "photos" ? Colors.white : Colors.grey,
                                    onPressed: (){
                                      setState(() {
                                        categoryFlag = "photos";
                                        checkInternet();
                                      });
                                    }, child: Text('Фотографии')),
                              ),
                            ],
                        ),
                      )
                  )
                ],
              ),
            ),
            Expanded (
                child: Container (
                  child:


                  categoryFlag == "albums" ?
                      Container (
                        alignment: Alignment(0.0, -1.0),
                      child: isLoading ? CircularProgressIndicator()
                          :
                      emptySearchCall ? Container()
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

                      )
                      //    : _filteredArray.length == 0 ? Container(
                      //    padding: EdgeInsets.fromLTRB(15, 15, 15, 0),
                      //    child: Row(
                      //        children:[
                      //          Expanded(
                      //              child: Container(
                      //                color: Colors.white,
                      //                padding: EdgeInsets.fromLTRB(10, 20, 10, 20),
                      //                child: Text('Нет данных'),
                      //              ))])
//
                      //)
                          :
                      ListView.builder(
                      //itemCount: _arrayOfAlbums == null ? 0 : _filteredArray.length,
                      itemCount: _filteredArrayOfAlbums.length,
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
                                                            TextSpan(text: "${_filteredArrayOfAlbums[i]["title"]}"),
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
                                                            TextSpan(text: "${_filteredArrayOfAlbums[i]["id"]}"),
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
                      emptySearchCall ? Container()
                          :
                      checkPhotoError ? Container(
                          padding: EdgeInsets.fromLTRB(15, 15, 15, 0),
                          child: Row(
                              children:[
                                Expanded(
                                    child: Container(
                                      color: Colors.white,
                                      padding: EdgeInsets.fromLTRB(10, 20, 10, 20),
                                      child: Text('Что-то пошло не так'),
                                    ))])

                      )
                      //    :
                      //_filteredArray.length == 0 ? Container(
                      //    padding: EdgeInsets.fromLTRB(15, 15, 15, 0),
                      //    child: Row(
                      //        children:[
                      //          Expanded(
                      //              child: Container(
                      //                color: Colors.white,
                      //                padding: EdgeInsets.fromLTRB(10, 20, 10, 20),
                      //                child: Text('Нет данных'),
                      //              ))])
//
                      //)
                          : ListView.builder(
                          itemCount: _partlyFilteredArrayOfPhotos.length,
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
                                                      :
                                                      cachedImageLoader(i),
                                                  //CachedNetworkImage(
                                                  //  imageUrl: "${_partlyFilteredArrayOfPhotos[i]["url"]}",
                                                  //  width: 100.0, height: 100.0, fit: BoxFit.cover,
                                                  //  placeholder: (context, url) => CircularProgressIndicator(),
                                                  //  errorWidget: (context, url, error) => Icon(Icons.error),
                                                  //),
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
                                                            TextSpan(text: "${_partlyFilteredArrayOfPhotos[i]["title"]}"),
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
                                                            TextSpan(text: "${_partlyFilteredArrayOfPhotos[i]["id"]}"),
                                                          ],
                                                        ),
                                                      ),
                                                    )
                                                  ],
                                                ))
                                              ]
                                          )
                                      ),
                                      if (i == _partlyFilteredArrayOfPhotos.length - 1 && _partlyFilteredArrayOfPhotos.length != _filteredArrayOfPhotos.length)
                                        Container(
                                            padding: EdgeInsets.only(top: 10),
                                            child:RaisedButton(
                                                color: Colors.white,
                                                onPressed: (){
                                                  checkInternet();
                                                  onMoreBtnTapped();
                                                }, child: Text('Еще'))),
                                    ]
                                ));
                          }
                      ))


                      : Container (
                    alignment: Alignment(0.0, -1.0),
                    child: isLoading ? CircularProgressIndicator()
                        :
                    emptySearchCall ? Container()
                        :
                    checkError ? Container(
                        padding: EdgeInsets.fromLTRB(15, 15, 15, 0),
                        child: Row(
                            children:[
                              Expanded(
                                  child: Container(
                                    color: Colors.white,
                                    padding: EdgeInsets.fromLTRB(10, 20, 10, 20),
                                    child: Text('Что-то пошло не так'),
                                  ))])

                    )
                    //    :
                    //_filteredArray.length == 0 ? Container(
                    //    padding: EdgeInsets.fromLTRB(15, 15, 15, 0),
                    //    child: Row(
                    //        children:[
                    //          Expanded(
                    //              child: Container(
                    //                color: Colors.white,
                    //                padding: EdgeInsets.fromLTRB(10, 20, 10, 20),
                    //                child: Text('Нет данных'),
                    //              ))])
//
                    //)
                        :
                    ListView.builder(
                        itemCount: _filteredArrayOfUsers.length,
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
                                                            TextSpan(text: "${_filteredArrayOfUsers[i]["name"]}"),
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
                                                            TextSpan(text: "${_filteredArrayOfUsers[i]["username"]}"),
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
                                                            TextSpan(text: "${_filteredArrayOfUsers[i]["email"]}"),
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

