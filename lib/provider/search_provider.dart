import 'package:flutter/material.dart';

import '../model/search_model.dart';
import '../repo/search_repo.dart';


class SearchProvider extends ChangeNotifier {
  final SearchRepo repo;

  SearchProvider({required this.repo});

  bool loading = false;
  String? error;
  List<Search> partners = [];

  Future<void> search(String query) async {
    loading = true;
    error = null;
    notifyListeners();

    try {
      partners = await repo.searchPartners(query: query);
    } catch (e) {
      error = e.toString();
    }

    loading = false;
    notifyListeners();
  }
}
