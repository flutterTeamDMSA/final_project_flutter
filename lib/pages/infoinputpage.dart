import 'package:contrast_shower_app/service/hive_provider.dart';
import 'package:contrast_shower_app/widget/textFiled.dart';
import 'package:flutter/material.dart';
import 'package:contrast_shower_app/globaL/const.dart';
import 'package:contrast_shower_app/widget/button.dart';
import 'package:camera/camera.dart';
import 'dart:async';
import 'dart:io';

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
                                title: Text('Название: ${data.name} Калории: ${data.caloris}',style: wf14w400,),
                                subtitle: Text('Белки: ${data.proteins} Жиры: ${data.fats} Углеводу: ${data.carbohydrates}',style: wf14w400,),
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
  String? _imagePath;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    final firstCamera = cameras.first;

    _controller = CameraController(
      firstCamera,
      ResolutionPreset.high,
    );

    _initializeControllerFuture = _controller.initialize();
    setState(() {});
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Новый прием пищи',style: wf14w400),
        backgroundColor: primary,
      ),
      backgroundColor: primary,
      body: Center(
        child: Column(
          children: [
            Expanded(
              child: _imagePath == null
                  ? FutureBuilder<void>(
                      future: _initializeControllerFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.done) {
                          return CameraPreview(_controller);
                        } else {
                          return const Center(child: CircularProgressIndicator());
                        }
                      },
                    )
                  : Image.file(File(_imagePath!)),
            ),
            const SizedBox(height: 20),
            _imagePath == null
                ? ElevatedButton(
                    onPressed: () async {
                      try {
                        await _initializeControllerFuture;
                        final image = await _controller.takePicture();
                        setState(() {
                          _imagePath = image.path;
                        });
                      } catch (e) {
                        print(e);
                      }
                    },
                    child: const Text('Сфотографировать'),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          if (_imagePath != null) {
                            Navigator.of(context).pop();  
                            _showinfodialog(context);
                          }
                        },
                        child: const Text('ОК'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _imagePath = null;
                            _initializeCamera();
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

void _showinfodialog(BuildContext context){
  showDialog(
    context: context, 
    builder: (BuildContext context){
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
                    labelText:'Название', 
                    controller: _nameController, 
                    onChanged: (_){}, 
                    color: white, 
                    textColor: dark2
                  ),
                  MyTextField(
                    keyboardType: TextInputType.number,
                    labelText:'Белки', 
                    controller: _proteinsController, 
                    onChanged: (_){}, 
                    color: white, 
                    textColor: dark2
                  ),
                  MyTextField(
                    keyboardType: TextInputType.number,
                    labelText:'Жиры', 
                    controller: _fatsController, 
                    onChanged: (_){}, 
                    color: white, 
                    textColor: dark2
                  ),
                  MyTextField(
                    keyboardType: TextInputType.number,
                    labelText:'Углеводы', 
                    controller: _carbohydratesController, 
                    onChanged: (_){}, 
                    color: white, 
                    textColor: dark2
                  ),
                  MyTextField(
                    keyboardType: TextInputType.number,
                    labelText:'Калории', 
                    controller: _caloriesController, 
                    onChanged: (_){}, 
                    color: white, 
                    textColor: dark2
                  ),
                ],
              ),
              MyButton(
                text: 'Сохранить', 
                textColor: primary,
                text_size: 22, 
                text_weight: w600, 
                color: white, 
                borderColor: white, 
                onTap: (){
                  Provider.of<DataProvider>(context, listen: false).saveDataToHive(
                    _nameController.text,
                    int.parse(_proteinsController.text),
                    int.parse(_fatsController.text),
                    int.parse(_carbohydratesController.text),
                    int.parse(_caloriesController.text));
                  Navigator.pop(context);
                }
              )
            ],
          ),
        ),
      );
    }
  );
}
void _showinfoupdatedialog(BuildContext context, int index, String name, String proteins,String fats, String carbohydrates, String caloris) {
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
                  Provider.of<DataProvider>(context, listen: false).updateDataInHive(
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
 