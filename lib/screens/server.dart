import 'dart:io';
import 'dart:convert';
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
          baseUrl: "http://192.168.1.5:8088",
          receiveDataWhenStatusError: true,
          connectTimeout: 1000*1000, // 150 seconds
          receiveTimeout: 6000*1000 // 300 seconds
    );
    
    Dio dio = new Dio(options);

    Response response =
        await dio.post("/api/v2/captionme", data: data);
    String k = response.data as String;
    Map<String, dynamic> dataplus = json.decode(k);
    //dataplus.keys.toList();
    final a = dataplus.values.toList()[1].removeAt(0);
    return (dataplus.values.toList()[1]);
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
            title: Text("Results"),
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
                              flex: 2,
                              child: new Container(
                                padding: const EdgeInsets.all(20.0),
                                child: Text(snapshot.data[index].toString()),
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