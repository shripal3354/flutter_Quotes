import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_quotebook/utils/UtilsImporter.dart';
import 'package:flutter_quotebook/model/QuoteBean.dart';
import 'package:flutter_quotebook/utils/StringConst.dart' as Const;
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:random_color/random_color.dart';
import 'package:flutter_quotebook/screen/QuoteDetailsScreen.dart';
import 'package:flutter_quotebook/model/CategoryBean.dart';

class CategoryDetailScreen extends StatefulWidget {
  final CategoryBean _categoryBean;

  @override
  _CategoryDetailScreenState createState() =>
      _CategoryDetailScreenState(this._categoryBean);

  CategoryDetailScreen(this._categoryBean);
}

class _CategoryDetailScreenState extends State<CategoryDetailScreen>
    with SingleTickerProviderStateMixin {
  CategoryBean _categoryBean;
  List<QuoteBean> _listQuote = [];
  bool isLoading = true;
  AnimationController controller;
  Animation<double> animation;
  RandomColor _randomColor = RandomColor();

  _CategoryDetailScreenState(this._categoryBean);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getQuoteList();
    controller = new AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    animation = CurvedAnimation(parent: controller, curve: Curves.easeIn);
    controller.forward();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: quoteGridList(),
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          _categoryBean.name,
          style: UtilsImporter().styleUtils.loginTextFieldStyle(),
        ),
        leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              color: Colors.black,
            ),
            onPressed: () {
              Navigator.pop(context);
            }),
      ),
    );
  }

  void getQuoteList() {
    if (_listQuote.length > 0) _listQuote.clear();
    UtilsImporter()
        .firebaseDatabaseUtils
        .firbaseCategoryQuoteRefereance
        .child(_categoryBean.name)
        .child('quotes')
        .once()
        .then((DataSnapshot snap) {
      var keys = snap.value.keys;
      var data = snap.value;
      setState(() {
        for (var key in keys) {
          QuoteBean quoteBean = new QuoteBean(
            data[key][Const.StringConst.KEY_Q_QUOTE],
            data[key][Const.StringConst.KEY_Q_AUTHERID],
            data[key][Const.StringConst.KEY_Q_LIKE],
            key,
            data[key][Const.StringConst.KEY_Q_AUTHERNAME],
            data[key][Const.StringConst.KEY_Q_AUTHERPIC],
          );
          _listQuote.add(quoteBean);
        }
        isLoading = false;
      });
    });
  }

  Widget quoteGridList() {
    if (isLoading) {
      return Container(
          child: Center(
        child: CircularProgressIndicator(),
      ));
    } else {
      return StaggeredGridView.countBuilder(
        scrollDirection: Axis.vertical,
        primary: false,
        crossAxisCount: 4,
        mainAxisSpacing: 0.0,
        crossAxisSpacing: 0.0,
        itemCount: _listQuote.length,
        staggeredTileBuilder: (int index) =>
            new StaggeredTile.count(2, index.isEven ? 3 : 2),
        itemBuilder: (BuildContext context, int index) => new Container(
          child: Card(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(16))),
            elevation: 8,
            child: Padding(
              padding: const EdgeInsets.all(26.0),
              child: FadeTransition(
                opacity: animation,
                child: InkWell(
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return QuoteDetailsScreen(_listQuote, index);
                    }));
                  },
                  child: AutoSizeText(
                    _listQuote[index].qoute,
                    style: UtilsImporter()
                        .styleUtils
                        .home2TextFieldStyle(_randomColor.randomColor()),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }
  }
}
