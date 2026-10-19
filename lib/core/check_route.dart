import '../config/routes/path_routing.dart';

import '../const/local_storage/shared_preferences_helper.dart';
import 'dependency_injection.dart';

String checkRouteBasedOnUserJourney() {
  var prefs = sl<SharedPreferencesHelper>();
  var role = prefs.getString(PrefConstKeys.selectedRole);
  var route = role == PrefConstKeys.seekerKey ? Routes.seekerHome : Routes.home;

  prefs.setBoolean('${PrefConstKeys.kyc}Done', true);
  prefs.setBoolean(PrefConstKeys.isHomeOpen, true);

  return route;
}

String checkScreenCompletion() {
  var prefs = sl<SharedPreferencesHelper>();
  var role = prefs.getString(PrefConstKeys.selectedRole);
  if (role == PrefConstKeys.seekerKey) {
    List<String> routes = [PrefConstKeys.roles, PrefConstKeys.focus, PrefConstKeys.category];

    for (String route in routes) {
      bool isDone = prefs.getBoolean('${route}Done');
      if (!isDone) {
        return _getRoutes(route);
      }
    }

    return Routes.seekerHome;
  } else if (role == PrefConstKeys.agentKey) {
    bool isDone = prefs.getBoolean('${PrefConstKeys.kyc}Done');
    if (isDone) {
      return Routes.home;
    }
    return Routes.accessLocationPage;
  } else {
    return Routes.accessLocationPage;
  }
}

String _getRoutes(String route) {
  /*switch (route) {
    case PrefConstKeys.roles:
      //return Routes.chooseRole;
      return Routes.accessLocationPage;
    case PrefConstKeys.focus:
      return Routes.chooseDomain;
    case PrefConstKeys.category:
      return Routes.selectCategory;
    default:
      return Routes.seekerHome; // Return a default screen if needed
  }*/

  switch (route) {
    case PrefConstKeys.roles:
      //return Routes.chooseRole;
      return Routes.accessLocationPage;
    case PrefConstKeys.focus:
      return Routes.accessLocationPage;
    case PrefConstKeys.category:
      return Routes.accessLocationPage;
    default:
      return Routes.seekerHome; // Return a default screen if needed
  }
}
