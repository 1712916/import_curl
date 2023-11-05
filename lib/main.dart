import 'package:curl_converter/curl_converter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_json_view/flutter_json_view.dart';
import 'package:super_drag_and_drop/super_drag_and_drop.dart';
import 'dart:convert' as convert;
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a blue toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: MyDraggableWidget(),
    );
  }
}

class MyDraggableWidget extends StatefulWidget {
  @override
  State<MyDraggableWidget> createState() => _MyDraggableWidgetState();
}

class _MyDraggableWidgetState extends State<MyDraggableWidget> {
  String currentText = "";
  @override
  Widget build(BuildContext context) {
    // DragItemWidget provides the content for the drag (DragItem).
    return Scaffold(
      body: Row(
        children: [
          Expanded(
            flex: 1,
            child: ColoredBox(
                color: Colors.grey.shade200,
                child: MyDropRegion(
                  onChanged: (value) {
                    currentText = value;
                    setState(() {});
                  },
                )),
          ),
          Expanded(
            flex: 1,
            child: ResponseView(
              key: ValueKey(currentText),
              curl: currentText,
            ),
          ),
        ],
      ),
    );
  }
}

class MyDropRegion extends StatefulWidget {
  final ValueChanged<String> onChanged;

  const MyDropRegion({super.key, required this.onChanged});
  @override
  State<MyDropRegion> createState() => _MyDropRegionState();
}

class _MyDropRegionState extends State<MyDropRegion> {
  String currentText = "";
  @override
  Widget build(BuildContext context) {
    return DropRegion(
      // Formats this region can accept.
      formats: Formats.standardFormats,
      hitTestBehavior: HitTestBehavior.opaque,
      onDropOver: (event) {
        // You can inspect local data here, as well as formats of each item.
        // However on certain platforms (mobile / web) the actual data is
        // only available when the drop is accepted (onPerformDrop).
        final item = event.session.items.first;
        if (item.localData is Map) {
          // This is a drag within the app and has custom local data set.
        }
        if (item.canProvide(Formats.plainText)) {
          // this item contains plain text.
        }
        // This drop region only supports copy operation.
        if (event.session.allowedOperations.contains(DropOperation.copy)) {
          return DropOperation.copy;
        } else {
          return DropOperation.none;
        }
      },
      onDropEnter: (event) {
        // This is called when region first accepts a drag. You can use this
        // to display a visual indicator that the drop is allowed.
      },
      onDropLeave: (event) {
        // Called when drag leaves the region. Will also be called after
        // drag completion.
        // This is a good place to remove any visual indicators.
      },
      onPerformDrop: (event) async {
        // Called when user dropped the item. You can now request the data.
        // Note that data must be requested before the performDrop callback
        // is over.
        final item = event.session.items.first;

        // data reader is available now
        final reader = item.dataReader!;
        if (reader.canProvide(Formats.plainText)) {
          reader.getValue<String>(Formats.plainText, (value) {
            if (value != null) {
              // You can access values through the `value` property.
              print('Dropped text: ${value}');
              currentText = value;
              setState(() {});
              widget.onChanged(currentText);
            }
          }, onError: (error) {
            print('Error reading value $error');
          });
        }
      },
      child: Container(
        alignment: Alignment.center,
        child: Text("Drop text here: ${currentText}"),
      ),
    );
  }
}

class ResponseView extends StatefulWidget {
  const ResponseView({super.key, required this.curl});

  final String curl;

  @override
  State<ResponseView> createState() => _ResponseViewState();
}

class _ResponseViewState extends State<ResponseView> {
  dynamic text = {};
  @override
  void initState() {
    super.initState();

    init().catchError((err) {
      print('Error: ${err.toString()}');
    });
  }

  Future init() async {
    // final curl = Curl.parse(widget.curl.replaceAll('"', ''));
    // print('curl.method: ${curl.method}');

    var response = await http.get(Uri.parse("https://api.thecatapi.com/v1/images/0XYvRd7oD"));
    if (response.statusCode == 200) {
      var convertData = convert.jsonDecode(response.body);
      if (convertData is Map) {
        text = convertData.map((key, value) => MapEntry(key.toString(), value));
      } else if (convertData is List) {
        text = convertData.map((e) {
          if (e is Map) {
            return e.map((key, value) => MapEntry(key.toString(), value));
          } else {
            return e;
          }
        }).toList();
      }

      setState(() {});
    } else {
      print('Request failed with status: ${response.statusCode}.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: text is Map<String, dynamic>
          ? JsonView.map(
              text,
              theme: JsonViewTheme(
                backgroundColor: Colors.white,
                defaultTextStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontSize: 15,
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                        ) ??
                    const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                viewType: JsonViewType.base,
              ),
            )
          : Text("Hello"),
    );
  }
}

class CallHttp {
  final String method;

  CallHttp(this.method);

  dynamic call() {
    switch (method) {
      case 'get':
        {}
    }
  }
}

class Curl {
  void a() {
    String curl = """
    curl --location 'http://gateway-wms-mobile.test.sendo.vn/api/confirm-handover/get-trips' \
--header 'Content-type: application/json; charset=utf-8' \
--header 'Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiIiLCJpYXQiOjE2OTg3MjEyMjUsImV4cCI6MTY5OTYwODEwMCwibmJmIjoxNjk5MDAzMzAwLCJqdGkiOiJZY0N2M1ZRYTlzMU84M3N2Iiwic3ViIjoxNDIsInBydiI6ImE1N2NhNWRjODBhYjMxMjQxZGVjMjQzNmZlNDFmMjZiZGE4OTcwZWUifQ.hODlpG27zG6MW8FiIihY35GtQ2jYzvIXpfQfmvx0cu4' \
--header 'User-Agent: example/1.3.23 (Android 13; sdk_gphone64_arm64; emu64a; arm64-v8a)' \
--header 'Sec-CH-UA-Arch: arm64-v8a' \
--header 'Sec-CH-UA-Model: sdk_gphone64_arm64' \
--header 'Sec-CH-UA-Platform: Android' \
--header 'Sec-CH-UA-Platform-Version: 13' \
--header 'Sec-CH-UA: example; v=1.3.23' \
--header 'Sec-CH-UA-Full-Version: 1.3.23' \
--header 'Sec-CH-UA-Mobile: ?1' \
--header 'content-length: 30' \
--data '{"pageSize":10,"pageNumber":1}'""";
  }
}

// curl --location 'http://gateway-wms-mobile.test.sendo.vn/api/confirm-handover/get-trips' \
// --header 'Content-type: application/json; charset=utf-8' \
// --header 'Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiIiLCJpYXQiOjE2OTg3MjEyMjUsImV4cCI6MTY5OTYwODEwMCwibmJmIjoxNjk5MDAzMzAwLCJqdGkiOiJZY0N2M1ZRYTlzMU84M3N2Iiwic3ViIjoxNDIsInBydiI6ImE1N2NhNWRjODBhYjMxMjQxZGVjMjQzNmZlNDFmMjZiZGE4OTcwZWUifQ.hODlpG27zG6MW8FiIihY35GtQ2jYzvIXpfQfmvx0cu4' \
// --header 'User-Agent: example/1.3.23 (Android 13; sdk_gphone64_arm64; emu64a; arm64-v8a)' \
// --header 'Sec-CH-UA-Arch: arm64-v8a' \
// --header 'Sec-CH-UA-Model: sdk_gphone64_arm64' \
// --header 'Sec-CH-UA-Platform: Android' \
// --header 'Sec-CH-UA-Platform-Version: 13' \
// --header 'Sec-CH-UA: example; v=1.3.23' \
// --header 'Sec-CH-UA-Full-Version: 1.3.23' \
// --header 'Sec-CH-UA-Mobile: ?1' \
// --header 'content-length: 30' \
// --data '{"pageSize":10,"pageNumber":1}'
