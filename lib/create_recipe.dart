import 'dart:convert';
import 'dart:html' as html;
import 'dart:typed_data';
import 'package:my_app/Widgets/input_text_create.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:universal_html/html.dart' as html;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'Classes/recipe.dart';
import 'Service/recipe_service.dart';
import 'Service/user_service.dart';
import 'Styles/Colors.dart';
import 'Widgets/input_text_create_v2expanded.dart';
import 'Widgets/message_complete.dart';

class CreateActivityPage extends StatefulWidget {

  const CreateActivityPage({super.key});

  @override
  State<CreateActivityPage> createState() => _CreateActivityPageState();
}

class _CreateActivityPageState extends State<CreateActivityPage> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _instructionsController = TextEditingController();
  final _ingredientsController = TextEditingController();
  final _timeTakenController = TextEditingController();
  Image? _selectedImage;
  String? _selectedImageBase64;
  bool isSwitched = false;

  List<String> ingredients = [];
  List<String> instructions = [];

  void _updateIngredients(String ingredient){
    setState(() {
      ingredients.add(ingredient);
      _ingredientsController.clear();
    });
  }

  void _updateInstructions(String instruction){
    setState(() {
      instructions.add(instruction);
      _instructionsController.clear();
    });
  }

  Future<String?> selectAndConvertImage() async {
    final fileInput = html.FileUploadInputElement()
      ..accept = 'image/*';

    fileInput.click();

    await fileInput.onChange.first;

    final selectedFile = fileInput.files?.first;

    if (selectedFile != null) {
      final reader = html.FileReader();

      reader.readAsDataUrl(selectedFile);

      await reader.onLoad.first;

      final base64String = reader.result as String;

      return base64String;
    } else {
      return null;
    }
  }

  Future<String?> convertImageToBase64(html.File selectedFile) async {
    final reader = html.FileReader();
    reader.readAsDataUrl(selectedFile);
    await reader.onLoad.first;
    final base64String = reader.result as String;
    return base64String;
  }

  void _updateSelectedImage(String imageString) {
    final base64Image = imageString.split(',').last;

    setState(() {
      _selectedImage = Image.memory(
        base64Decode(base64Image),
        fit: BoxFit.cover,
        width: 640,
        height: 360,
      );
    });

    _selectedImageBase64 = base64Image;
  }

  void _onSubmit(String? token) {
      int public = isSwitched ? 1 : 0;
      String chefFriend = "Chef'sFriend";
      createRecipe(
        _titleController.text,
        _descriptionController.text,
        ingredients,
        instructions,
        _selectedCategory!,
        _selectedImageBase64! != null ? _selectedImageBase64 : chefFriend,
        token!,
        public,
        int.parse(_timeTakenController.text),
      );
      showOverlayNotification((context) {
        return CompleteMessage(
          message: 'Recipe created successfully',
        );
      });
  }

  String? getToken() {
    return html.window.localStorage['token'];
  }

  String? _selectedCategory = 'Main Course';

  List<DropdownMenuItem<String>> categories = [
    DropdownMenuItem<String>(child: Text('Main Course'), value: 'Main Course'),
    DropdownMenuItem<String>(child: Text('Breakfast'), value: 'Breakfast'),
    DropdownMenuItem<String>(child: Text('Appetizer'), value: 'Appetizer'),
    DropdownMenuItem<String>(child: Text('Snack'), value: 'Snack'),
    DropdownMenuItem<String>(child: Text('Salad'), value: 'Salad'),
    DropdownMenuItem<String>(child: Text('Soup'), value: 'Soup'),
    DropdownMenuItem<String>(child: Text('Dessert'), value: 'Dessert'),
  ];

  void _updateSelectedCategory(String? newCategory) {
    setState(() {
      _selectedCategory = newCategory;
    });
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
                    child: Column(
                      children: [
                        Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                              "Add a Recipe",
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 48),
                          ),
                        ),
                        Row(
                          children: [
                            Text('Make this recipe public?'),
                            Switch(
                                value: isSwitched,
                                onChanged: (value){
                                    setState(() {
                                      isSwitched=value;
                                    });
                                }
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                  TextButton(
                      onPressed: (){
                        final token = getToken();
                        if (token != null) {
                          _onSubmit(token);
                        }
                        },
                      child: Icon(Icons.add)
                  )
                ],
              ),
              Padding(
                  padding: EdgeInsets.symmetric(horizontal: 80, vertical: 20),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          flex:3,
                          child: CoolTextBar(
                            Controller: _titleController,
                            type: "Title",
                            validator: (value){
                              if(value!.isEmpty){
                                return "Please Enter a title";
                              }
                            },
                          )
                        ),
                        SizedBox(
                          width: 50,
                        ),Expanded(
                            flex: 1,
                            child: CoolTextBar(
                              Controller: _timeTakenController,
                              type: "Time taken (minutes)",
                              validator: (value){
                                if (value!.isEmpty) {
                                  return 'Please enter a value';
                                }
                                try {
                                  int.parse(value);
                                  return null;
                                } catch (e) {
                                  return 'Please enter a valid integer';
                                }
                              },
                            )
                        ),
                        SizedBox(
                          width: 25,
                        ),
                        Expanded(
                        flex: 1,
                            child: DropdownButton<String>(
                              items: categories,
                              value: _selectedCategory,
                              onChanged: (String? newValue) {
                                _updateSelectedCategory(newValue);
                              },
                              iconSize: 42,
                              iconEnabledColor: Persian_Orange,
                            ),
                        ),
                      ],
                    ),
                    SizedBox(height: 50,),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 2,
                          child: Column(
                            children: [
                              Container(
                                height: 360,
                                width: 640,
                                color: Color(0xffefefef),
                                child: _selectedImage != null
                                    ? _selectedImage
                                    : Placeholder(),
                              ),
                              TextButton(
                                  onPressed: () async {
                                    final imageString = await selectAndConvertImage();
                                    if (imageString != null) {
                                      _updateSelectedImage(imageString);
                                    }
                                  },
                                  child: Text("Add Image")
                              )
                            ],
                          ),
                        ),
                        SizedBox(
                          width: 50,
                        ),
                        Expanded(
                          flex: 2,
                          child: Container(
                            height: 300,
                            child: CoolTextBarv2(
                              Controller: _descriptionController,
                              type: "Description",
                              validator: (value) {
                                if (value!.length < 60) {
                                  return "Must be at least 60 characters!";
                                }
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  SizedBox(height: 50,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 2,
                        child: Column(
                          children: [
                            CoolTextBar(
                              Controller: _ingredientsController,
                              type: "Ingredients",
                              validator: (value){

                              },
                            ),
                            Align(
                              alignment: Alignment.topLeft,
                              child: TextButton(
                                onPressed: () {
                                  _updateIngredients(_ingredientsController.text);
                                },
                                child: Text("Submit ingredient"),
                              ),
                            ),
                            Align(
                              alignment: Alignment.topLeft,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: ingredients.map((ingredient) {
                                  return Text(
                                    "- $ingredient",
                                    style: TextStyle(fontSize: 18),
                                  );
                                }).toList(),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: 50,
                      ),
                      Expanded(
                        flex: 3,
                        child: Column(
                          children: [
                            CoolTextBar(
                              Controller: _instructionsController,
                              type: "Instructions",
                              validator: (value){

                              },
                            ),
                            Align(
                              alignment: Alignment.topLeft,
                              child: TextButton(
                                onPressed: () {
                                  _updateInstructions(_instructionsController.text);
                                },
                                child: Text("Submit instruction"),
                              ),
                            ),
                            Align(
                              alignment: Alignment.topLeft,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: instructions.map((instructions) {
                                  return Text(
                                    "- $instructions",
                                    style: TextStyle(fontSize: 18),
                                  );
                                }).toList(),
                              ),
                            )
                          ],
                        ),
                      ),
                      ],
                  ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}


