import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class PhotosBody extends StatefulWidget {
  final String albumId;
  PhotosBody({this.albumId});

  @override
  createState() => new PhotosBodyState(albumId);
}

class PhotosBodyState extends State<PhotosBody> {
  final String albumId;
  PhotosBodyState(this.albumId);
  List _arrayOfPhotos = [];
  var photosDataFull = [];
  var photosData = [];
  var jsonPhoto = [];
  var drawIndex = 0;

  getPhotosData() async{

    await http.get('https://jsonplaceholder.typicode.com/photos?albumId='
        + "${albumId}").then((response) {

      debugPrint("response ${response.statusCode}");
      if(response.statusCode == 200) {
        photosDataFull = json.decode(response.body);
        if(photosDataFull.length >= 10) {
          for (var i = 0; i <= 9; i++) {
            photosData.add(photosDataFull[i]);
          }
        }
        setState(() {
          _arrayOfPhotos = photosData;
        });
      }

    }).catchError((error){
      print("Error: $error");
    });
  }

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
    //getPhotosData();
    getValues();
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: new AppBar(title: new Text('Photos')),
      body: Container (
          child:
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