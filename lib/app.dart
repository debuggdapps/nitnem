import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:nitnem/redux/actions/actions.dart';
import 'package:nitnem/redux/selectors/selectors.dart';
import 'package:nitnem/state/appstate.dart';
import 'package:redux/redux.dart';
import 'package:nitnem/navigation/approute.dart';
import 'package:nitnem/pages/options.dart';
import 'package:nitnem/pages/readerscreen.dart';
import 'package:nitnem/pages/splashscreen.dart';
import 'package:nitnem/pages/homescreen.dart';
import 'models/themes.dart';

class NitnemApp extends StatelessWidget {
  final Store<AppState> store;
  NitnemApp(this.store);

  @override
  Widget build(BuildContext context) {
    return StoreProvider<AppState>(
      store: store,
      child: new StoreConnector<AppState, _ViewModel>(
        converter: _ViewModel.fromStore,
        onInit: (store) => store.dispatch(FetchOptionsAction()),
        builder: (context, vm) => MaterialApp (
          title: 'Nitnem App',
          debugShowCheckedModeBanner: false,
          theme: getThemeByName(vm.themeName).data,
          color: Colors.grey,
          home: SplashScreen(),
          routes: _buildRoutes(),
          builder: (BuildContext context, Widget child) {
            return Directionality(
              child: CupertinoTheme (
                // Specifically use a blank Cupertino theme here and do not transfer
                // over the Material primary color etc except the brightness to
                // showcase standard iOS looks.
                data: CupertinoThemeData (
                  brightness: getThemeByName(vm.themeName).data.brightness,
                ),
                child: child
              ),
              textDirection: TextDirection.ltr,
            );
          },
        ),
      )
    );
  }

  Map<String, WidgetBuilder> _buildRoutes() {
    return Map<String, WidgetBuilder>.fromIterable(
      _getRoutes(),
      key: (dynamic route) => '${route.routeName}',
      value: (dynamic route) => route.buildRoute,
    );
  } 

  List<AppRoute> _getRoutes() {
    final List<AppRoute> routes = <AppRoute>[
      // Demos
      AppRoute(
        routeName: '/home',
        buildRoute: (BuildContext context) => HomeScreen(
          optionsPage: OptionsPage(readerMode: false),
        ),
      ),
      AppRoute(
        routeName: '/intro',
        buildRoute: (BuildContext context) => SplashScreen(),
      ),
      AppRoute(
        routeName: '/reader',
        buildRoute: (BuildContext context) => ReaderScreen(),
      ),
    ];
    return routes;
  }
}

class _ViewModel {
  final String themeName;
  _ViewModel({@required this.themeName});

  static _ViewModel fromStore(Store<AppState> store) {
    return _ViewModel(
      themeName: themeSelector(store.state),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _ViewModel &&
          runtimeType == other.runtimeType &&
          themeName == other.themeName;

  @override
  int get hashCode => themeName.hashCode;

  @override
  String toString() {
    return '_ViewModel{themeName: $themeName}';
  }
}