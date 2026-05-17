import 'package:flutter/material.dart';
import '../repositories/favorites_repository.dart';
import '../widgets/async_state_view.dart';
import '../widgets/exercise_network_image.dart';

/// Displays and manages favorite exercises from local storage.
class FavoritesTab extends StatefulWidget {
  const FavoritesTab({super.key, this.favoritesRepository});

  final FavoritesRepository? favoritesRepository;

  @override
  State<FavoritesTab> createState() => _FavoritesTabState();
}

class _FavoritesTabState extends State<FavoritesTab> {
  late final FavoritesRepository _repo;
  List<Map<String, dynamic>> _items = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _repo = widget.favoritesRepository ?? FavoritesRepository();
    _load();
  }

  /// Reloads favorites from repository.
  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await _repo.getAll();
      setState(() {
        _items = data;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AsyncStateView(
      isLoading: _loading,
      error: _error,
      isEmpty: !_loading && _error == null && _items.isEmpty,
      onRetry: _load,
      emptyMessage: 'No favorite exercises saved yet.',
      child: RefreshIndicator(
        onRefresh: _load,
        child: ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: _items.length,
          itemBuilder: (context, index) {
            final item = _items[index];
            return Dismissible(
              key: ValueKey(item['id']),
              direction: DismissDirection.endToStart,
              background: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 20),
                color: Colors.red.shade400,
                child: const Icon(Icons.delete, color: Colors.white),
              ),
              onDismissed: (_) async {
                await _repo.remove(item['id'] as int);
                _load();
              },
              child: Card(
                margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 6),
                child: ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: ExerciseNetworkImage(
                      url: item['imageUrl'] as String,
                      width: 60,
                      height: 60,
                    ),
                  ),
                  title: Text(item['title'] as String, style: const TextStyle(fontWeight: FontWeight.bold)),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                    onPressed: () async {
                      await _repo.remove(item['id'] as int);
                      _load();
                    },
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
