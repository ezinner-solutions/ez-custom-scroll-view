import 'package:ez_custom_scroll_view/ez_custom_scroll_view.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EzCustomScrollView Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('EzCustomScrollView Demo'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'This is a Column (unbounded height). \n'
                'Normally, putting a CustomScrollView here would crash. \n'
                'EzCustomScrollView handles it safely!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 20),
            
            // --- UNBOUNDED USAGE (Safe with EzCustomScrollView) ---
            const Text('Unbounded (Safe Fix Applied):', style: TextStyle(fontWeight: FontWeight.bold)),
            EzCustomScrollView(
              shrinkWrap: true, // Even with shrinkWrap, it can be tricky in some contexts, but EzCustomScrollView adds extra safety
              slivers: [
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => ListTile(
                      title: Text('Item $index'),
                      tileColor: index.isEven ? Colors.grey[200] : Colors.white,
                    ),
                    childCount: 5,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 40),
            const Divider(),
            const SizedBox(height: 20),

            const Text('Bounded (Standard Usage):', style: TextStyle(fontWeight: FontWeight.bold)),
            // --- BOUNDED USAGE (Standard) ---
            SizedBox(
              height: 200,
              child: EzCustomScrollView(
                slivers: [
                   SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => Container(
                        color: Colors.primaries[index % Colors.primaries.length],
                        child: Center(child: Text('Grid $index', style: const TextStyle(color: Colors.white))),
                      ),
                      childCount: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
