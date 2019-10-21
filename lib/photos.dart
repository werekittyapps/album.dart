import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PhotosBody extends StatefulWidget {
  final String albumId;
  final bool photoError;
  PhotosBody({this.albumId, this.photoError});

  @override
  createState() => new PhotosBodyState(albumId, photoError);
}

class PhotosBodyState extends State<PhotosBody> {
  final String albumId;
  final bool photoError;
  PhotosBodyState(this.albumId, this.photoError);

  List _arrayOfPhotos = [];
  var photosDataFull = [];
  var photosData = [];
  var jsonPhoto = [];
  var drawIndex = 0;

  String errorMessage = "";
  bool checkError = false;

  getValues() async{
    var dataIsEmpty = false;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var cachedJSON = (prefs.getString('photos') ?? {
      print(" Photos data is empty "),
      dataIsEmpty = true
    });
    if (!dataIsEmpty){
      print('in photos getValues()');
      jsonPhoto = json.decode(cachedJSON);
      for(var i = 0; i < jsonPhoto.length; i++) {
        if(jsonPhoto[i]["albumId"].toString() == albumId.toString()){
          photosDataFull.add(jsonPhoto[i]);
        }
      }
      if(photosDataFull.length >= 10) {
        for (var i = 0; i <= 9; i++) {
          photosData.add(photosDataFull[i]);
        }
      }
      setState(() {
        _arrayOfPhotos = photosData;
      });
    }
  }

  //void _showErrorDialog() {
  //  showDialog(
  //      context: context,
  //      builder: (context) {
  //        return AlertDialog(
  //          title: Text('$errorMessage'),
  //          content: Text(""),
  //          actions: <Widget>[
  //            FlatButton(
  //              onPressed: () {
  //                getValues();
  //              },
  //              child: Text('Попробовать снова'),
  //            )
  //          ],
  //        );
  //      }
  //  );
  //}

  onTapped(){
    if (photosDataFull.length - photosData.length >= 10){
      if(photosDataFull.length >= 10) {
        drawIndex++;
        //for (var i = 0; i <= 9; i++) {
        for (var i = drawIndex*10; i <= drawIndex*10 + 9; i++) {
          //photosData.clear();
          photosData.add(photosDataFull[i]);
        }
      }
      setState(() {
        print('array: ' + '${_arrayOfPhotos.length}');
        //drawIndex++;
        _arrayOfPhotos = photosData;
      });
    }
  }

  @override
  void initState() {
    getValues();
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: new AppBar(title: new Text('Photos')),
      body: Container (
        child:photoError ? Container(
            padding: EdgeInsets.fromLTRB(15, 15, 15, 0),
            child: Row(
                children:[
                  Expanded(
                      child: Container(
                        color: Colors.white,
                        padding: EdgeInsets.fromLTRB(10, 20, 10, 20),
                        child: Text('Что-то пошло не так'),
                      ))])

        ) :
          Column (
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded (
                child: Container (
                  padding: EdgeInsets.only(top: 10),
                  child: ListView.builder(
                        itemCount: _arrayOfPhotos.length,
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
                                                child: CachedNetworkImage(
                                                  imageUrl: "${_arrayOfPhotos[i]["url"]}",
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
                                                          TextSpan(text: "${_arrayOfPhotos[i]["title"]}"),
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
                                                          TextSpan(text: "${_arrayOfPhotos[i]["id"]}"),
                                                        ],
                                                      ),
                                                    ),
                                                  )
                                                ],
                              ))
                                            ]
                                        )
                                    ),
                                    if (i == _arrayOfPhotos.length - 1 && _arrayOfPhotos.length != photosDataFull.length)
                                      Container(
                                          padding: EdgeInsets.only(top: 10),
                                          child:RaisedButton(
                                              color: Colors.white,
                                              onPressed: (){
                                            onTapped();
                                            }, child: Text('Еще'))),
                                  ]
                              ));
                        }
                    ),
                )
              ),
            ],
          )
      ),
    );
  }
}