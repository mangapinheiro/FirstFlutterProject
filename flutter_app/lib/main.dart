//import 'dart:convert';

//import 'package:flutter/material.dart';
//import 'package:http/http.dart' as http;

//void main() => runApp(SampleApp());
//
//class SampleApp extends StatelessWidget {
//  @override
//  Widget build(BuildContext context) {
//    return MaterialApp(
//      title: 'Sample App',
//      theme: ThemeData(
//        primarySwatch: Colors.blue,
//      ),
//      home: SampleAppPage(),
//    );
//  }
//}
//
//class SampleAppPage extends StatefulWidget {
//  SampleAppPage({Key key}) : super(key: key);
//
//  @override
//  _SampleAppPageState createState() => _SampleAppPageState();
//}
//
//class _SampleAppPageState extends State<SampleAppPage> with TickerProviderStateMixin {
//  AnimationController animationController;
//  CurvedAnimation animation;
//
//  List widgets = [];
//
//  @override
//  void initState() {
//    super.initState();
//    animationController = AnimationController(duration: const Duration(milliseconds: 300), vsync: this);
//    animation = CurvedAnimation(parent: animationController, curve: Curves.easeIn);
//    loadData();
//  }
//
//  @override
//  Widget build(BuildContext context) {
//    return Scaffold(
//      appBar: AppBar(
//        title: Text("Sample App"),
//      ),
//      body: ListView.builder(
//        itemCount: widgets.length,
//        itemBuilder: (BuildContext context, int position) {
//          return getRow(position);
//        },
//      ),
//      floatingActionButton: FloatingActionButton(
//        onPressed: () {
////          animationController.reverse().then((value) {
//          _addItem();
////            animationController.forward();
//        },
//        tooltip: 'Increment',
//        child: Icon(Icons.add),
//      ),
//    );
//  }
//
//  Widget getRow(int i) {
//    return FadeTransition(
//      opacity: animation,
//      child: Padding(padding: EdgeInsets.all(10.0), child: Text("Row ${widgets[i]["title"]}")),
//    );
//  }
//
//  loadData() async {
//    String dataURL = "https://jsonplaceholder.typicode.com/posts";
//    http.Response response = await http.get(dataURL);
//    setState(() {
//      widgets = json.decode(response.body);
//      widgets = widgets.sublist(0, 4);
//      animationController.forward(from: 0);
//    });
//  }
//
//  void _addItem() {
//    setState(() {
//      widgets.add({"title": "New Item"});
//      animationController.forward(from: 0);
//    });
//  }
//}

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AnimatedListSample extends StatefulWidget {
  @override
  _AnimatedListSampleState createState() => _AnimatedListSampleState();
}

class _AnimatedListSampleState extends State<AnimatedListSample> {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  ListModel<Item> _list;
  Item _selectedItem;
  Item _nextItem; // The next item inserted when the user presses the '+' button.

  @override
  void initState() {
    super.initState();
    _list = ListModel<Item>(
      listKey: _listKey,
      initialItems: <Item>[Item(description: "Pizza"), Item(description: "Macaroni"), Item(description: "Cheese")],
      removedItemBuilder: _buildRemovedItem,
    );
    _nextItem = Item(description: "New");
  }

  // Used to build list items that haven't been removed.
  Widget _buildItem(BuildContext context, int index, Animation<double> animation) {
    return CardItem(
      animation: animation,
      item: _list[index],
      selected: _selectedItem == _list[index],
      onTap: () {
        setState(() {
          _selectedItem = _selectedItem == _list[index] ? null : _list[index];
        });
      },
    );
  }

  // Used to build an item after it has been removed from the list. This method is
  // needed because a removed item remains visible until its animation has
  // completed (even though it's gone as far this ListModel is concerned).
  // The widget will be used by the [AnimatedListState.removeItem] method's
  // [AnimatedListRemovedItemBuilder] parameter.
  Widget _buildRemovedItem(Item item, BuildContext context, Animation<double> animation) {
    return CardItem(
      animation: animation,
      item: item,
      selected: false,
      // No gesture detector here: we don't want removed items to be interactive.
    );
  }

  // Insert the "next item" into the list model.
  void _insert() {
    final int index = _selectedItem == null ? _list.length : _list.indexOf(_selectedItem);
    _list.insert(index, _nextItem);
  }

  // Remove the selected item from the list model.
  void _remove() {
    if (_selectedItem != null) {
      _list.removeAt(_list.indexOf(_selectedItem));
      setState(() {
        _selectedItem = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme:  ThemeData(
        primarySwatch: Colors.purple,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('AnimatedList'),
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.add_circle),
              onPressed: _insert,
              tooltip: 'insert a new item',
            ),
            IconButton(
              icon: const Icon(Icons.remove_circle),
              onPressed: _remove,
              tooltip: 'remove the selected item',
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              buildRow(),
              Expanded(
                  child: AnimatedList(
                key: _listKey,
                initialItemCount: _list.length,
                itemBuilder: _buildItem,
              ))
            ],
          ),
        ),
      ),
    );
  }

  Row buildRow() {
    return Row(children: <Widget>[
      Expanded(child: TextField(decoration: InputDecoration(hintText: 'New Item'))),
      SizedBox(
        height: 40,
        width: 40,
        child: RaisedButton(
          shape: CircleBorder(),
          child: Icon(Icons.add),
          padding: EdgeInsets.all(0),
          onPressed: _insert,
        ),
      ),
    ]);
  }
}

class Item {
  String description;
  bool done;

  Item({this.description, this.done = false});
}

/// Keeps a Dart List in sync with an AnimatedList.
///
/// The [insert] and [removeAt] methods apply to both the internal list and the
/// animated list that belongs to [listKey].
///
/// This class only exposes as much of the Dart List API as is needed by the
/// sample app. More list methods are easily added, however methods that mutate the
/// list must make the same changes to the animated list in terms of
/// [AnimatedListState.insertItem] and [AnimatedList.removeItem].
class ListModel<E> {
  ListModel({
    @required this.listKey,
    @required this.removedItemBuilder,
    Iterable<E> initialItems,
  })  : assert(listKey != null),
        assert(removedItemBuilder != null),
        _items = List<E>.from(initialItems ?? <E>[]);

  final GlobalKey<AnimatedListState> listKey;
  final dynamic removedItemBuilder;
  final List<E> _items;

  AnimatedListState get _animatedList => listKey.currentState;

  void insert(int index, E item) {
    _items.insert(index, item);
    _animatedList.insertItem(index);
  }

  E removeAt(int index) {
    final E removedItem = _items.removeAt(index);
    if (removedItem != null) {
      _animatedList.removeItem(index, (BuildContext context, Animation<double> animation) {
        return removedItemBuilder(removedItem, context, animation);
      });
    }
    return removedItem;
  }

  int get length => _items.length;

  E operator [](int index) => _items[index];

  int indexOf(E item) => _items.indexOf(item);
}

/// Displays its integer item as 'item N' on a Card whose color is based on
/// the item's value. The text is displayed in bright green if selected is true.
/// This widget's height is based on the animation parameter, it varies
/// from 0 to 128 as the animation varies from 0.0 to 1.0.
class CardItem extends StatelessWidget {
  const CardItem({Key key, @required this.animation, this.onTap, @required this.item, this.selected = false})
      : assert(animation != null),
        assert(item != null),
        assert(selected != null),
        super(key: key);

  final Animation<double> animation;
  final VoidCallback onTap;
  final Item item;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    TextStyle textStyle = Theme.of(context).textTheme.display1;
    if (selected) textStyle = textStyle.copyWith(color: Colors.lightGreenAccent[700]);
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: SizeTransition(
        axis: Axis.vertical,
        sizeFactor: animation,
        child: FadeTransition(
          opacity: animation,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onTap,
            child: SizedBox(
              height: 128.0,
              child: Card(
                color: Colors.primaries[item.description.length % Colors.primaries.length],
                child: Center(
                  child: Text('${item.description}', style: textStyle),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(AnimatedListSample());
}
