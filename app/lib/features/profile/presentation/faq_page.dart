import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/db/app_database.dart';
import '../../../core/db/providers.dart';
import '../../../core/theme/app_theme.dart';

class FaqPage extends ConsumerStatefulWidget {
  const FaqPage({super.key});

  @override
  ConsumerState<FaqPage> createState() => _FaqPageState();
}

class _FaqPageState extends ConsumerState<FaqPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 根 navigator 页需自带氛围背景，否则透明 Scaffold 会透出系统深色窗体
    return AtmosphereBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('常见问题'),
          bottom: TabBar(
            controller: _tabs,
            tabs: const [
              Tab(text: '减脂'),
              Tab(text: '增肌'),
            ],
          ),
        ),
        body: FutureBuilder<AppDatabase>(
          future: ref.read(appDatabaseProvider.future),
          builder: (context, snap) {
            if (!snap.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            return FutureBuilder<List<FaqItem>>(
              future: snap.data!.select(snap.data!.faqItems).get(),
              builder: (context, faqSnap) {
                if (!faqSnap.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final all = faqSnap.data!;
                return TabBarView(
                  controller: _tabs,
                  children: [
                    _FaqList(items: all.where((e) => e.goal == 'cut').toList()),
                    _FaqList(items: all.where((e) => e.goal == 'bulk').toList()),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _FaqList extends StatelessWidget {
  const _FaqList({required this.items});

  final List<FaqItem> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const Center(child: Text('暂无问答'));
    }
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, i) {
        final item = items[i];
        return ExpansionTile(
          title: Text(item.question),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text(item.answer),
            ),
          ],
        );
      },
    );
  }
}
