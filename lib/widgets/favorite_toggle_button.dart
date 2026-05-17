import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../repositories/favorites_repository.dart';

/// Heart button that toggles favorite state and updates icon color.
class FavoriteToggleButton extends StatefulWidget {
  const FavoriteToggleButton({
    super.key,
    required this.title,
    required this.imageUrl,
  });

  final String title;
  final String imageUrl;

  @override
  State<FavoriteToggleButton> createState() => _FavoriteToggleButtonState();
}

class _FavoriteToggleButtonState extends State<FavoriteToggleButton> {
  bool _isFavorite = false;
  bool _loading = false;
  String? _favoriteId;

  @override
  void initState() {
    super.initState();
    _syncFromServer();
  }

  /// Loads whether this exercise is already in favorites.
  Future<void> _syncFromServer() async {
    try {
      final all = await context.read<FavoritesRepository>().getAll();
      final match = all.where(
        (f) => f.title == widget.title && f.imageUrl == widget.imageUrl,
      );
      if (!mounted) return;
      setState(() {
        _isFavorite = match.isNotEmpty;
        _favoriteId = match.isNotEmpty ? match.first.id : null;
      });
    } catch (_) {}
  }

  /// Adds or removes favorite and updates icon.
  Future<void> _toggle() async {
    setState(() => _loading = true);
    try {
      final repo = context.read<FavoritesRepository>();
      if (_isFavorite && _favoriteId != null) {
        await repo.remove(_favoriteId!);
        if (!mounted) return;
        setState(() {
          _isFavorite = false;
          _favoriteId = null;
        });
        _showSnack('Removed from favorites');
      } else {
        await repo.add(widget.title, widget.imageUrl);
        await _syncFromServer();
        if (!mounted) return;
        _showSnack('${widget.title} added to favorites');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: _loading ? null : _toggle,
      icon: _loading
          ? const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Icon(
              _isFavorite ? Icons.favorite : Icons.favorite_border,
              color: _isFavorite ? Colors.red : Colors.grey.shade600,
            ),
    );
  }
}
