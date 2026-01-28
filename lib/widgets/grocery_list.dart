import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shopping_list/data/categories.dart';
import 'package:shopping_list/data/dummy_items.dart';
import 'package:shopping_list/models/grocery_item.dart';
import 'package:shopping_list/widgets/new_item.dart';

import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GroceryListScreen extends StatefulWidget {
  const GroceryListScreen({super.key});

  @override
  State<GroceryListScreen> createState() => _GroceryListScreenState();
}

class _GroceryListScreenState extends State<GroceryListScreen> {
  final List<GroceryItem> _groceryItems = [];
  final List<bool> _checkedStates = List.generate(
    groceryItems.length,
    (index) => false,
  );

  late Future<List<GroceryItem>> _loadedItems;

  @override
  void initState() {
    super.initState();
    _loadedItems = _loadItem();
  }

  Future<List<GroceryItem>> _loadItem() async {
    final url = Uri.https(dotenv.env['DB_URL']!, 'shopping-list.json');

    final response = await http.get(url);
    if (response.statusCode >= 400) {
      throw Exception('Failed to fetch grocery items, please try again later');
    }

    if (response.body == 'null') {
      setState(() {});
      return [];
    }

    final Map<String, dynamic> listData = json.decode(response.body);
    final List<GroceryItem> loadedItems = [];
    for (final item in listData.entries) {
      final category = categories.entries
          .firstWhere((catItem) => catItem.value.name == item.value['category'])
          .value;
      loadedItems.add(
        GroceryItem(
          id: item.key,
          name: item.value['name'],
          quantity: item.value['quantity'],
          category: category,
        ),
      );
    }
    setState(() {
      _groceryItems.clear();
      _groceryItems.addAll(loadedItems);
      _checkedStates.clear();
      _checkedStates.addAll(
        List.generate(loadedItems.length, (index) => false),
      );
    });

    return loadedItems;
  }

  void _addItem() async {
    final newItem = await Navigator.of(
      context,
    ).push<GroceryItem>(MaterialPageRoute(builder: (ctx) => NewItemScreen()));

    if (newItem == null) {
      return;
    }

    setState(() {
      _groceryItems.add(newItem);

      _checkedStates.add(false);
    });
  }

  void _removeItem(GroceryItem item) async {
    final index = _groceryItems.indexOf(item);
    setState(() {
      _groceryItems.remove(item);
      _checkedStates.removeAt(index);
    });

    final url = Uri.https(
      'flutter-shopping-list-920f7-default-rtdb.europe-west1.firebasedatabase.app',
      'shopping-list/${item.id}.json',
    );
    final response = await http.delete(url);
    if (response.statusCode >= 400) {
      setState(() {
        _groceryItems.insert(index, item);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Center(child: Text('Your Grocery List'))),
      body: FutureBuilder(
        future: _loadedItems,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          }

          if (_groceryItems.isEmpty) {
            return const Center(
              child: Text(
                'No Items Added Yet',
                style: TextStyle(color: Colors.black),
              ),
            );
          }

          return ListView.builder(
            itemCount: _groceryItems.length,
            itemBuilder: (ctx, index) {
              final item = _groceryItems[index];
              final isChecked = _checkedStates[index];

              return Dismissible(
                key: ValueKey(item.id),
                onDismissed: (direction) {
                  _removeItem(item);
                },
                child: CheckboxListTile(
                  title: Text(item.name),
                  subtitle: Text('${item.quantity}'),
                  value: isChecked,
                  onChanged: (bool? value) {
                    setState(() {
                      _checkedStates[index] = value!;
                    });
                  },
                  controlAffinity: ListTileControlAffinity.leading,
                  checkColor: Colors.black,
                  fillColor: WidgetStateProperty.resolveWith((states) {
                    return isChecked ? item.category.color : null;
                  }),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addItem,
        backgroundColor: const Color.fromARGB(255, 211, 255, 214),
        child: const Icon(Icons.add),
      ),
    );
  }
}
