import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:my_app/Service/user_service.dart';

import 'Classes/recipe.dart';
import 'Classes/user.dart';
import 'Styles/Colors.dart';
import 'Widgets/container_recipe_v2_noremove.dart';

class UsersRecipesPage extends StatefulWidget {
  final String username;

  const UsersRecipesPage({super.key, required this.username});

  @override
  State<UsersRecipesPage> createState() => _UsersRecipesPageState();
}

class _UsersRecipesPageState extends State<UsersRecipesPage> {
  List<Recipe> recipes = [];
  bool isLoaded = false;

  void getData() async{
    List<Map<String, dynamic>>? data = await fetchAnotherUsersData(widget.username);

    setState(() {
      recipes = recipeFromJson(json.encode(data));
      isLoaded = true;
    });
  }

  @override
  void initState(){
    super.initState();
    print('before get data');
    getData();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(20, 40, 0, 40),
                child: IconButton(
                    onPressed: (){
                      Navigator.of(context).pop();
                    },
                    icon: Icon(Icons.arrow_back)
                ),
              ),
              Text(
                "${widget.username}'s recipes",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 48),
              ),
            ],
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Wrap(
                spacing: 20,
                direction: Axis.horizontal,
                children: recipes.map((recipe) {
                  String base64Image = recipe.image;
                  String dataUri = "data:image/jpeg;base64,$base64Image";
                  return ContainerRecipeV2Public(
                    recipe: recipe,
                    imageUrl: dataUri,
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
