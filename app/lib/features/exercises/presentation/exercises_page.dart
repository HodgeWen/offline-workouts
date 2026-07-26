import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/db/app_database.dart';
import '../../../core/db/providers.dart';
import '../../../core/theme/app_theme.dart';
import 'exercise_image.dart';

class ExercisesPage extends ConsumerStatefulWidget {
  const ExercisesPage({super.key});

  @override
  ConsumerState<ExercisesPage> createState() => _ExercisesPageState();
}

class _ExercisesPageState extends ConsumerState<ExercisesPage> {
  final _controller = TextEditingController();
  List<Exercise> _items = [];
  bool _loading = true;
  String? _error;
  int _searchSeq = 0;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _search('', immediate: true);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onQueryChanged(String q) {
    // 仅刷新清除按钮可见性，避免整表闪 loading
    setState(() {});
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 220), () {
      _search(q);
    });
  }

  Future<void> _search(String q, {bool immediate = false}) async {
    final seq = ++_searchSeq;
    final showSpinner = immediate || _items.isEmpty;
    if (showSpinner && mounted) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }
    try {
      final db = await ref.read(appDatabaseProvider.future);
      final rows = await db.exerciseDao.search(q);
      if (!mounted || seq != _searchSeq) return;
      setState(() {
        _items = rows;
        _loading = false;
        _error = null;
      });
    } catch (e) {
      if (!mounted || seq != _searchSeq) return;
      setState(() {
        _loading = false;
        _error = '$e';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('搜索失败：$e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text('动作库')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: '搜索动作名 / 部位 / 肌肉',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _controller.text.isEmpty
                    ? null
                    : IconButton(
                        onPressed: () {
                          _debounce?.cancel();
                          _controller.clear();
                          _search('', immediate: true);
                        },
                        icon: const Icon(Icons.clear),
                      ),
              ),
              onChanged: _onQueryChanged,
            ),
          ),
          Expanded(child: _buildBody(text)),
        ],
      ),
    );
  }

  Widget _buildBody(TextTheme text) {
    if (_loading && _items.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null && _items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('加载失败：$_error', textAlign: TextAlign.center),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () => _search(_controller.text, immediate: true),
                child: const Text('重试'),
              ),
            ],
          ),
        ),
      );
    }
    if (_items.isEmpty) {
      return Center(
        child: Text('没有匹配的动作', style: text.bodyLarge),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 24),
      itemCount: _items.length,
      separatorBuilder: (_, _) => Divider(
        height: 1,
        color: AppTheme.primary.withValues(alpha: 0.08),
      ),
      itemBuilder: (context, i) {
        final e = _items[i];
        final hasImage = (e.imagePath ?? '').trim().isNotEmpty;
        return ListTile(
          leading: SizedBox(
            width: 56,
            height: 56,
            child: hasImage
                ? ExerciseImage(
                    imagePath: e.imagePath!,
                    borderRadius: 8,
                    fit: BoxFit.cover,
                    memCacheWidth: 112,
                  )
                : DecoratedBox(
                    decoration: BoxDecoration(
                      color: AppTheme.mist.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.fitness_center,
                      color: AppTheme.slate.withValues(alpha: 0.35),
                    ),
                  ),
          ),
          title: Text(e.name, style: text.titleMedium),
          subtitle: Text(
            [
              if (e.region.isNotEmpty) e.region,
              if (e.anatomyNote != null) e.anatomyNote!,
            ].join(' · '),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: Icon(
            Icons.chevron_right,
            color: AppTheme.slate.withValues(alpha: 0.4),
          ),
          onTap: () => context.push('/exercises/${e.id}'),
        );
      },
    );
  }
}
