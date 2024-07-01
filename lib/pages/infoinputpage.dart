import 'dart:typed_data';

import 'package:calories_tracker/service/hive_provider.dart';
import 'package:calories_tracker/widget/textFiled.dart';
import 'package:flutter/material.dart';
import 'package:calories_tracker/globaL/const.dart';
import 'package:calories_tracker/widget/button.dart';
import 'package:camera/camera.dart';
import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;

import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePage createState() => _HomePage();
}

TextEditingController _nameController = TextEditingController();
TextEditingController _proteinsController = TextEditingController();
TextEditingController _fatsController = TextEditingController();
TextEditingController _carbohydratesController = TextEditingController();
TextEditingController _caloriesController = TextEditingController();

@override
void dispose() {
  _nameController.dispose();
  _proteinsController.dispose();
  _fatsController.dispose();
  _carbohydratesController.dispose();
  _caloriesController.dispose();
}

class _HomePage extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    Provider.of<DataProvider>(context, listen: false).loadDataFromHive();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: dark1,
        title: Text('История', style: wf24w600),
        centerTitle: true,
      ),
      backgroundColor: dark1,
      body: Center(
        child: Padding(
          padding: a16,
          child: Consumer<DataProvider>(
            builder: (context, provider, child) {
              var groupedData = provider.getWeeklyGroupedData();
              return ListView(
                children: groupedData.entries.map((weekEntry) {
                  return ExpansionTile(
                    iconColor: white,
                    title: Text(
                      'Неделя: ${weekEntry.key}',
                      style: wf14w600,
                    ),
                    children: weekEntry.value.entries.map((dayEntry) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'День: ${dayEntry.key}',
                            style: wf14w600.copyWith(color: Colors.blueAccent),
                          ),
                          Column(
                            children: dayEntry.value.map((data) {
                              return ListTile(
                                title: Text(
                                  'Название: ${data.name} Калории: ${data.caloris}',
                                  style: wf14w400,
                                ),
                                subtitle: Text(
                                  'Белки: ${data.proteins} Жиры: ${data.fats} Углеводу: ${data.carbohydrates}',
                                  style: wf14w400,
                                ),
                                onTap: () {
                                  _showinfoupdatedialog(
                                    context,
                                    data.index,
                                    data.name,
                                    data.proteins.toString(),
                                    data.fats.toString(),
                                    data.carbohydrates.toString(),
                                    data.caloris.toString(),
                                  );
                                },
                              );
                            }).toList(),
                          ),
                        ],
                      );
                    }).toList(),
                  );
                }).toList(),
              );
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CameraPage()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  _CameraPageState createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  Uint8List? _imageData;

  @override
  void initState() {
    super.initState();
    _initializeControllerFuture = _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    final firstCamera = cameras.first;

    _controller = CameraController(
      firstCamera,
      ResolutionPreset.high,
    );

    return await _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<bool> _uploadImage(Uint8List imageData, String url) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse(url));
      request.headers.addAll({
        "Content-Type": "multipart/form-data",
        "Accept": "application/json",
      });
      var file = http.MultipartFile.fromBytes(
        'file',
        imageData,
        filename: 'upload.png',
      );
      request.files.add(file);

      var response = await request.send();

      if (response.statusCode == 200) {
        print("Загрузка успешна!");
        StringBuffer buffer = StringBuffer();
        await for (var chunk in response.stream.transform(utf8.decoder)) {
          buffer.write(chunk);
        }
        final jsonResponse = json.decode(buffer.toString());
        setState(() {
          _nameController.text = jsonResponse['name'];
          _proteinsController.text = jsonResponse['proteins'].toString();
          _fatsController.text = jsonResponse['fats'].toString();
          _carbohydratesController.text =
              jsonResponse['carbohydrates'].toString();
          _caloriesController.text = jsonResponse['calories'].toString();
        });
        return true;
      } else {
        print(
            'Не удалось загрузить изображение. Статус-код: ${response.statusCode}');
        StringBuffer buffer = StringBuffer();
        await for (var chunk in response.stream.transform(utf8.decoder)) {
          buffer.write(chunk);
        }
        print('Ответ с ошибкой: ${buffer.toString()}');
        return false;
      }
    } catch (e, stackTrace) {
      print('Ошибка при загрузке изображения: $e');
      print('Стек ошибок: $stackTrace');
      return false;
    }
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Ошибка'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(message),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('ОК'),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HomePage(),
                  ),
                );
              },
            ),
            TextButton(
              child: const Text('Попробовать еще раз'),
              onPressed: () async {
                if (_imageData != null) {
                  // Показать индикатор загрузки
                  showDialog<void>(
                    context: context,
                    barrierDismissible: false,
                    builder: (BuildContext context) {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    },
                  );

                  try {
                    bool res = await _sendImage();
                    Navigator.of(context).pop();
                    if (res) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HomePage(),
                        ),
                      );
                      _showinfodialog(context);
                    } else {
                      _showErrorDialog(
                          context, 'Не удалось загрузить изображение');
                    }
                  } catch (e) {
                    Navigator.of(context).pop();
                    _showErrorDialog(context, 'Произошла ошибка: $e');
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<bool> _sendImage() async {
    if (_imageData != null) {
      String url = 'http://127.0.0.1:5000/upload';
      return await _uploadImage(_imageData!, url);
    }
    return false;
  }

  Future<void> _takePicture() async {
    try {
      await _initializeControllerFuture;
      final XFile image = await _controller.takePicture();
      final Uint8List imageData = await image.readAsBytes();

      setState(() {
        _imageData = imageData;
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Новый прием пищи'),
      ),
      body: Center(
        child: Column(
          children: [
            Expanded(
              child: _imageData == null
                  ? FutureBuilder<void>(
                      future: _initializeControllerFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.done) {
                          return CameraPreview(_controller);
                        } else {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                      },
                    )
                  : Image.memory(_imageData!),
            ),
            const SizedBox(height: 20),
            _imageData == null
                ? ElevatedButton(
                    onPressed: _takePicture,
                    child: const Text('Сфотографировать'),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () async {
                          if (_imageData != null) {
                            // Показать индикатор загрузки
                            showDialog<void>(
                              context: context,
                              barrierDismissible: false,
                              builder: (BuildContext context) {
                                return Center(
                                  child: CircularProgressIndicator(),
                                );
                              },
                            );

                            try {
                              bool res = await _sendImage();
                              Navigator.of(context)
                                  .pop(); // Закрыть диалог загрузки
                              if (res) {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        HomePage(), // Замените на ваш виджет домашней страницы
                                  ),
                                );
                                _showinfodialog(context);
                              } else {
                                _showErrorDialog(context,
                                    'Не удалось загрузить изображение');
                              }
                            } catch (e) {
                              Navigator.of(context)
                                  .pop(); // Закрыть диалог загрузки в случае ошибки
                              _showErrorDialog(context, 'Произошла ошибка: $e');
                            }
                          }
                        },
                        child: const Text('ОК'),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          await _controller.dispose();
                          setState(() {
                            _imageData = null;
                            _initializeControllerFuture = _initializeCamera();
                          });
                        },
                        child: const Text('Переснять'),
                      ),
                    ],
                  ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

void _showinfodialog(BuildContext context) {
  showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: primary,
          content: SizedBox(
            height: MediaQuery.of(context).size.height * 0.6,
            width: MediaQuery.of(context).size.width * 0.8,
            child: Column(
              mainAxisAlignment: spb,
              children: [
                Column(
                  children: [
                    MyTextField(
                        labelText: 'Название',
                        controller: _nameController,
                        onChanged: (_) {},
                        color: white,
                        textColor: dark2),
                    MyTextField(
                        keyboardType: TextInputType.number,
                        labelText: 'Белки',
                        controller: _proteinsController,
                        onChanged: (_) {},
                        color: white,
                        textColor: dark2),
                    MyTextField(
                        keyboardType: TextInputType.number,
                        labelText: 'Жиры',
                        controller: _fatsController,
                        onChanged: (_) {},
                        color: white,
                        textColor: dark2),
                    MyTextField(
                        keyboardType: TextInputType.number,
                        labelText: 'Углеводы',
                        controller: _carbohydratesController,
                        onChanged: (_) {},
                        color: white,
                        textColor: dark2),
                    MyTextField(
                        keyboardType: TextInputType.number,
                        labelText: 'Калории',
                        controller: _caloriesController,
                        onChanged: (_) {},
                        color: white,
                        textColor: dark2),
                  ],
                ),
                MyButton(
                    text: 'Сохранить',
                    textColor: primary,
                    text_size: 22,
                    text_weight: w600,
                    color: white,
                    borderColor: white,
                    onTap: () {
                      Provider.of<DataProvider>(context, listen: false)
                          .saveDataToHive(
                              _nameController.text,
                              int.parse(_proteinsController.text),
                              int.parse(_fatsController.text),
                              int.parse(_carbohydratesController.text),
                              int.parse(_caloriesController.text));
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HomePage(),
                        ),
                      );
                      _nameController.text = '';
                      _proteinsController.text = '';
                      _fatsController.text = '';
                      _carbohydratesController.text = '';
                      _caloriesController.text = '';
                    })
              ],
            ),
          ),
        );
      });
}

void _showinfoupdatedialog(BuildContext context, int index, String name,
    String proteins, String fats, String carbohydrates, String caloris) {
  TextEditingController nameController = TextEditingController();
  TextEditingController proteinsController = TextEditingController();
  TextEditingController fatsController = TextEditingController();
  TextEditingController carbohydratesController = TextEditingController();
  TextEditingController caloriesController = TextEditingController();
  nameController.text = name;
  proteinsController.text = proteins;
  fatsController.text = fats;
  carbohydratesController.text = carbohydrates;
  caloriesController.text = caloris;
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: primary,
        content: SizedBox(
          height: MediaQuery.of(context).size.height * 0.6,
          width: MediaQuery.of(context).size.width * 0.8,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              MyTextField(
                labelText: 'Название',
                controller: nameController,
                onChanged: (_) {},
                color: Colors.white,
                textColor: dark2,
              ),
              MyTextField(
                keyboardType: TextInputType.number,
                labelText: 'Белки',
                controller: proteinsController,
                onChanged: (_) {},
                color: Colors.white,
                textColor: dark2,
              ),
              MyTextField(
                keyboardType: TextInputType.number,
                labelText: 'Жиры',
                controller: fatsController,
                onChanged: (_) {},
                color: Colors.white,
                textColor: dark2,
              ),
              MyTextField(
                keyboardType: TextInputType.number,
                labelText: 'Углеводы',
                controller: carbohydratesController,
                onChanged: (_) {},
                color: Colors.white,
                textColor: dark2,
              ),
              MyTextField(
                keyboardType: TextInputType.number,
                labelText: 'Калории',
                controller: caloriesController,
                onChanged: (_) {},
                color: Colors.white,
                textColor: dark2,
              ),
              MyButton(
                text: 'Сохранить',
                textColor: primary,
                text_size: 22,
                text_weight: FontWeight.w600,
                color: Colors.white,
                borderColor: Colors.white,
                onTap: () {
                  Provider.of<DataProvider>(context, listen: false)
                      .updateDataInHive(
                    index,
                    nameController.text,
                    int.parse(proteinsController.text),
                    int.parse(fatsController.text),
                    int.parse(caloriesController.text),
                    int.parse(caloriesController.text),
                  );
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      );
    },
  );
}
