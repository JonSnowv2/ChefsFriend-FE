import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:my_app/Service/recipe_service.dart';
import 'package:my_app/Service/user_service.dart';
import 'package:my_app/Styles/Colors.dart';
import 'package:my_app/Styles/Gradients.dart';
import 'package:my_app/Styles/Shadows.dart';
import 'package:flutter_glow/flutter_glow.dart';
import 'package:my_app/Widgets/pop_up_recipe.dart';
import 'package:my_app/users_recipes_page.dart';
import 'dart:html' as html;

import '../Classes/recipe.dart';
import '../Classes/user.dart';

class ContainerRecipeV2Public extends StatefulWidget {
  final Recipe recipe;
  final String? imageUrl;

  ContainerRecipeV2Public({super.key, required this.recipe, required this.imageUrl});

  @override
  State<ContainerRecipeV2Public> createState() => _ContainerRecipeV2StatePublic();
}

class _ContainerRecipeV2StatePublic extends State<ContainerRecipeV2Public> {
  bool clicked = false;
  bool isLoaded = false;
  User? user;

  String? getToken() {
    return html.window.localStorage['token'];
  }

  getData() async{
    final token = getToken();
    User? user2 = await fetchUserData(token!);

    setState(() {
      user = user2;
      clicked = user!.favoriteRecipes.contains(widget.recipe.id);
    });
  }

  void initState(){
    super.initState();
    getData();
    isLoaded = true;
  }

  void _showRecipePopup(BuildContext context, Recipe recipe, String? imageUrl) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return PopUpRecipe(recipe: recipe, imageUrl: imageUrl,);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return isLoaded ? Padding(
      padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: 400,
          maxWidth: 450,
        ),
        child: InkWell(
          onTap: (){
            _showRecipePopup(context, widget.recipe, widget.imageUrl);
          },
          child: Container(
            decoration: BoxDecoration(
              boxShadow: [
                dariusShadow
              ],
              color: Blue,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Center(
                        child: Image(
                          height: 56,
                          image: AssetImage('assets/pin-nobg.png'),
                        )
                    ),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.white, // Border color
                          width: 8.0,           // Border width
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          shadowImage
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: widget.imageUrl != null
                            ? Image.network(widget.imageUrl!)
                            : Container(),
                      ),
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    Text(widget.recipe.title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),),
                    SizedBox(
                      height: 8,
                    ),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          dariusShadow
                        ],
                        color: Bluev2,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  ...widget.recipe.ingredients.take(5).map((item) {
                                    return Text(
                                      '• $item',
                                      softWrap: true,
                                      style: TextStyle(fontSize: 18),
                                    );
                                  }).toList(),
                                  if (widget.recipe.ingredients.length > 5)
                                    Text(
                                      '• ...',
                                      style: TextStyle(fontSize: 18),
                                    ),
                                ],
                              ),
                            ),
                            SizedBox(width: 10,),
                            Flexible(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  ...widget.recipe.instructions.take(5).map((item) {
                                    return Text(
                                      '• $item',
                                      softWrap: true,
                                      style: TextStyle(fontSize: 18),
                                    );
                                  }).toList(),
                                  if (widget.recipe.instructions.length > 5)
                                    Text(
                                      '• ...',
                                      style: TextStyle(fontSize: 18),
                                    ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(widget.recipe.category, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
                              Text('Time taken: ${widget.recipe.timeTaken.toString()} min', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Text('Created by: ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
                                  TextButton(onPressed: (){
                                    Navigator.of(context).push(MaterialPageRoute(builder: (context) => UsersRecipesPage(username: widget.recipe.user_username)));
                                  },
                                    child: Text(widget.recipe.user_username, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Persian_Orange)),)
                                ],
                              ),
                              IconButton(
                                  onPressed: () async{
                                    setState(() {
                                      final token = getToken();
                                      if (clicked == false){
                                        addToFavorites(widget.recipe.id, token!);
                                        clicked = true;
                                      }
                                      else{
                                        removeFromFavorites(widget.recipe.id, token!);
                                        clicked = false;
                                      }
                                    });
                                  },
                                  icon: clicked == false ? Icon(Icons.favorite_border) : Icon(Icons.favorite)
                              ),
                            ],
                          ),
                        ],
                      ),
                    )
                ]
              ),
            ),
          ),
        ),
      ),
    ): Center(child: CircularProgressIndicator(),);
  }
}
