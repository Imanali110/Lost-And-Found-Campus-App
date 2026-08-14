// lib/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/items_provider.dart';
import '../utils/constants.dart';
import '../widgets/item_card.dart';
import 'add_item_screen.dart';
import 'item_detail_screen.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchC = TextEditingController();

  @override
  void initState() {
    super.initState();
    // FIX: update the clear-button (suffixIcon) whenever the search text changes
    _searchC.addListener(() => setState(() {}));
  }

  @override
  void dispose() { _searchC.dispose(); super.dispose(); }

  Future<void> _logout() async {
    final ok = await showDialog<bool>(context: context,
      builder: (_) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout', style: TextStyle(color: Colors.red))),
        ],
      ));
    if (ok != true || !mounted) return;
    context.read<ItemsProvider>().stopListening();
    await context.read<AuthProvider>().logout();
    Navigator.pushAndRemoveUntil(context,
      MaterialPageRoute(builder: (_) => const LoginScreen()), (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;

    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppBar(
        backgroundColor: kPrimary,
        foregroundColor: Colors.white,
        title: const Text('Campus Lost & Found',
          style: TextStyle(fontWeight: FontWeight.w600)),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.account_circle_outlined),
            onSelected: (v) { if (v == 'logout') _logout(); },
            itemBuilder: (_) => [
              PopupMenuItem(enabled: false,
                child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(user?.name ?? '',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
                    Text(user?.rollNumber ?? '',
                      style: const TextStyle(fontSize: 12, color: Colors.black45)),
                  ])),
              const PopupMenuDivider(),
              const PopupMenuItem(value: 'logout',
                child: Row(children: [
                  Icon(Icons.logout, color: Colors.red, size: 18),
                  SizedBox(width: 8),
                  Text('Logout', style: TextStyle(color: Colors.red)),
                ])),
            ],
          ),
        ],
      ),

      body: Column(children: [
        // ── Search + filter bar ──
        Container(
          color: kPrimary,
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
          child: Column(children: [
            TextField(
              controller: _searchC,
              onChanged: (q) => context.read<ItemsProvider>().search(q),
              decoration: InputDecoration(
                hintText: 'Search by title, location...',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                // FIX: suffixIcon now reacts correctly because _searchC has a
                //      listener above that calls setState on every keystroke
                suffixIcon: _searchC.text.isNotEmpty
                  ? IconButton(icon: const Icon(Icons.clear, color: Colors.grey),
                      onPressed: () {
                        _searchC.clear();
                        context.read<ItemsProvider>().search('');
                      })
                  : null,
                filled: true, fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 10),
            Consumer<ItemsProvider>(builder: (_, prov, __) =>
              Row(children: [
                _chip('All',   'all',   prov),
                const SizedBox(width: 8),
                _chip('Lost',  'lost',  prov),
                const SizedBox(width: 8),
                _chip('Found', 'found', prov),
              ]),
            ),
          ]),
        ),

        // ── Items list ──
        Expanded(
          child: Consumer<ItemsProvider>(
            builder: (_, prov, __) {
              if (prov.isLoading) {
                return const Center(child: CircularProgressIndicator(color: kPrimary));
              }
              if (prov.items.isEmpty) {
                return Center(child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.inbox_outlined, size: 72, color: Colors.grey.shade300),
                    const SizedBox(height: 12),
                    Text('No items yet', style: TextStyle(fontSize: 17, color: Colors.grey.shade400)),
                    const SizedBox(height: 6),
                    Text('Post a lost or found item using the button below',
                      style: TextStyle(fontSize: 13, color: Colors.grey.shade400),
                      textAlign: TextAlign.center),
                  ],
                ));
              }
              return ListView.builder(
                padding: const EdgeInsets.only(top: 8, bottom: 90),
                itemCount: prov.items.length,
                itemBuilder: (_, i) => ItemCard(
                  item: prov.items[i],
                  onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) =>
                      ItemDetailScreen(item: prov.items[i]))),
                ),
              );
            },
          ),
        ),
      ]),

      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: kPrimary,
        onPressed: () => Navigator.push(context,
          MaterialPageRoute(builder: (_) => const AddItemScreen())),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Post Item',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _chip(String label, String val, ItemsProvider prov) {
    final selected = prov.typeFilter == val;
    final color = val == 'lost' ? kLost : val == 'found' ? kFound : kAccent;
    return GestureDetector(
      onTap: () => prov.setFilter(val),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? color : Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? color : Colors.white38),
        ),
        child: Text(label, style: TextStyle(
          color: selected ? Colors.white : Colors.white70,
          fontWeight: selected ? FontWeight.bold : FontWeight.normal,
          fontSize: 13)),
      ),
    );
  }
}
