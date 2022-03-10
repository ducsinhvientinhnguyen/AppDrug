import 'dart:io';

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

class ListDemo extends StatefulWidget {
  final File image;

  ListDemo({required this.image});

  @override
  _ListDemoState createState() {
    return _ListDemoState();
  }
}

class _ListDemoState extends State<ListDemo> {

  uploadImage(File file) async {
    String fileName = file.path.split('/').last;

    FormData data = FormData.fromMap({
      "file": await MultipartFile.fromFile(
        file.path,
        filename: fileName,
      ),
    });

    Dio dio = new Dio();

    Response response =
    await dio.post("http://192.168.xx.xx:8000/predict/image", data: data);

    return (response.data as List);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: true,
          leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () => Navigator.of(context).pop()),
          title: Text("Result"),
        ),
        body: new FutureBuilder<dynamic>(
          future: uploadImage(widget.image),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
              case ConnectionState.waiting:
                return Center(child: CircularProgressIndicator());
              default:
                if (snapshot.hasError)
                  return Container(child: Text(snapshot.error.toString()));

                return new ListView.builder(
                  scrollDirection: Axis.vertical,
                  itemCount: snapshot.data.length,
                  itemBuilder: (BuildContext context, int index) {
                    return new Card(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Expanded(
                            flex: 1,
                            child: new Container(
                              padding: const EdgeInsets.all(20.0),
                              child: Text(snapshot.data[index][0].toString()),
                            ),
                          ),
                          Expanded(
                            flex: 4,
                            child: new Container(
                              padding: const EdgeInsets.all(20.0),
                              child: Text(snapshot.data[index][1].toString()),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
            }
          },
        ),
      ),
    );
  }
}