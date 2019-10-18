import 'dart:convert';

import 'package:album/photos.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:http/http.dart' as http;
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
  List _arrayOfAlbums = [];
  var jsonAlbum = [];
  var albumsData = [];

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
      });
    }
  }

  getAlbumData() async{

    var response = await http.get('https://jsonplaceholder.typicode.com/albums/?userId='
        + "${userId}").then((response) {

      debugPrint("response ${response.statusCode}");
      if(response.statusCode == 200) {
        albumsData = json.decode(response.body);
        setState(() {
          _arrayOfAlbums = albumsData;
        });
      }

    }).catchError((error){
      print("Error: $error");
    });
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
        appBar: new AppBar(title: new Text('Albums')),
        body:  Container (
            child:
            Column (
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded (
                    child: Container (
                      padding: EdgeInsets.only(top: 10),
                      child: ListView.builder(
                          itemCount: _arrayOfAlbums.length,
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
                                                            TextSpan(text: "${_arrayOfAlbums[i]["title"]}"),
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
                                                            TextSpan(text: "${_arrayOfAlbums[i]["id"]}"),
                                                          ],
                                                        ),
                                                      ),
                                                    )
                                                  ],
                                                ))),
                                      ]
                                  )),
                              onTap: () =>  onTapped("${_arrayOfAlbums[i]["id"]}"),);
                          }
                      ),
                    )
                ),
              ],
            ))
    );

  }
}
