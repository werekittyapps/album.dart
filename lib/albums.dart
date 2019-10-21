import 'dart:convert';

import 'package:album/photos.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AlbumsBody extends StatefulWidget {
  final String userId;
  AlbumsBody({this.userId});

  @override
  createState() => new AlbumsBodyState(userId);
}

class AlbumsBodyState extends State<AlbumsBody> {
  final String userId;
  AlbumsBodyState(this.userId);

  final myController = TextEditingController();

  List _arrayOfAlbums = [];

  List _filteredArrayOfAlbums = [];
  var jsonAlbum = [];

  var albumsData = [];

  Icon _searchIcon = new Icon(Icons.search);
  final TextEditingController _filter = new TextEditingController();
  Widget _appBarTitle = new Text( 'Albums' );

  getValues() async{
    var dataIsEmpty = false;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var cachedJSON = (prefs.getString('albums') ?? {
      print(" Albums data is empty "),
      dataIsEmpty = true
    });
    if (!dataIsEmpty){
      jsonAlbum = json.decode(cachedJSON);
      for(var i = 0; i < jsonAlbum.length; i++) {
        if(jsonAlbum[i]["userId"].toString() == userId.toString()){
          albumsData.add(jsonAlbum[i]);
        }
      }
      setState(() {
        _arrayOfAlbums = albumsData;
        _filteredArrayOfAlbums = _arrayOfAlbums;
      });
    }
  }

  searching(){
    setState(() {
        if (this._searchIcon.icon == Icons.search) {
          this._searchIcon = new Icon(Icons.close);
          this._appBarTitle = new TextField(
            controller: _filter,
            decoration: new InputDecoration(
                prefixIcon: new Icon(Icons.search),
                hintText: 'Search...',
            ),
            onChanged: (value){
                List tempList = new List();
                _filteredArrayOfAlbums = _arrayOfAlbums;
                for (int i = 0; i < _filteredArrayOfAlbums.length; i++) {
                  if (_filteredArrayOfAlbums[i]['title'].toLowerCase().contains(value.replaceAll(" ", "").toLowerCase())) {
                    tempList.add(_filteredArrayOfAlbums[i]);
                  }
                }
                setState(() {
                _filteredArrayOfAlbums = tempList;
                });
            }
          );
        } else {
          this._searchIcon = new Icon(Icons.search);
          this._appBarTitle = new Text('Albums');
          _filteredArrayOfAlbums = _arrayOfAlbums;
          _filter.clear();
        }
    });

  }

  onChangeTitle(int index, String newTitle) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    jsonAlbum[index]["title"] = newTitle;
    prefs.setString('albums', json.encode(jsonAlbum));
    getValues();
  }

  void _showChangeDialog(int index) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Новое название'),
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
                  onChangeTitle(index, myController.text);
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

  onTapped(String id){
    Navigator.push(context, MaterialPageRoute(builder: (context) => PhotosBody( albumId: id,
    )));
  }

  @override
  void initState() {
    //getAlbumData();
    getValues();
    super.initState();
  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(
        backgroundColor: Colors.grey[300],
        //appBar: new AppBar(title: new Text('Albums')),
        appBar: new AppBar(title: _appBarTitle,
          actions: <Widget>[
            // action button
            IconButton(
              icon: _searchIcon,
              onPressed: () {
                searching();
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
                          //itemCount: _arrayOfAlbums.length,
                          itemCount: _arrayOfAlbums == null ? 0 : _filteredArrayOfAlbums.length,
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
                                                            //TextSpan(text: "${_arrayOfAlbums[i]["title"]}"),
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
                                                            //TextSpan(text: "${_arrayOfAlbums[i]["id"]}"),
                                                            TextSpan(text: "${_filteredArrayOfAlbums[i]["id"]}"),
                                                          ],
                                                        ),
                                                      ),
                                                    )
                                                  ],
                                                ))),
                                      ]
                                  )),
                              onTap: () =>  onTapped("${_filteredArrayOfAlbums[i]["id"]}"),
                              onLongPress: () =>  {
                                myController.text = "${_filteredArrayOfAlbums[i]["title"]}",
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
