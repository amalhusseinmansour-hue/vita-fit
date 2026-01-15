import 'package:flutter/foundation.dart';

class FavoritesProvider with ChangeNotifier {
  final Set<String> _favoriteProductIds = {};
  final Set<String> _favoriteClassIds = {};
  final Set<String> _favoriteMealIds = {};

  // المنتجات المفضلة
  Set<String> get favoriteProductIds => {..._favoriteProductIds};

  bool isProductFavorite(String productId) {
    return _favoriteProductIds.contains(productId);
  }

  void toggleProductFavorite(String productId) {
    if (_favoriteProductIds.contains(productId)) {
      _favoriteProductIds.remove(productId);
    } else {
      _favoriteProductIds.add(productId);
    }
    notifyListeners();
  }

  // الحصص المفضلة
  Set<String> get favoriteClassIds => {..._favoriteClassIds};

  bool isClassFavorite(String classId) {
    return _favoriteClassIds.contains(classId);
  }

  void toggleClassFavorite(String classId) {
    if (_favoriteClassIds.contains(classId)) {
      _favoriteClassIds.remove(classId);
    } else {
      _favoriteClassIds.add(classId);
    }
    notifyListeners();
  }

  // الوجبات المفضلة
  Set<String> get favoriteMealIds => {..._favoriteMealIds};

  bool isMealFavorite(String mealId) {
    return _favoriteMealIds.contains(mealId);
  }

  void toggleMealFavorite(String mealId) {
    if (_favoriteMealIds.contains(mealId)) {
      _favoriteMealIds.remove(mealId);
    } else {
      _favoriteMealIds.add(mealId);
    }
    notifyListeners();
  }

  // مسح الكل
  void clearAll() {
    _favoriteProductIds.clear();
    _favoriteClassIds.clear();
    _favoriteMealIds.clear();
    notifyListeners();
  }
}
