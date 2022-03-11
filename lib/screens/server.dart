import 'dart:io';

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

class ListDemo extends StatefulWidget {
  final File imageFile;
  final List<File> fileList;
  ListDemo({required this.imageFile,
    required this.fileList,});

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
    
    BaseOptions options = new BaseOptions(
          baseUrl: "http://103.153.75.195:5000",
          receiveDataWhenStatusError: true,
          connectTimeout: 150*1000, // 150 seconds
          receiveTimeout: 300*1000 // 300 seconds
    );
    
    Dio dio = new Dio(options);

    Response response =
    await dio.post("/api/v2/captionme", data: data);
    
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
          title: Text("Hellooo"),
        ),
        body: new FutureBuilder<dynamic>(
          future: uploadImage(widget.imageFile),

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
