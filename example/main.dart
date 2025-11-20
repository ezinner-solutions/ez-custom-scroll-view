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
      title: 'EZ Custom Scroll View Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
        useMaterial3: true,
      ),
      home: const CustomScrollDemoScreen(),
    );
  }
}

class CustomScrollDemoScreen extends StatelessWidget {
  const CustomScrollDemoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('EZ Custom Scroll View Demo'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                '1. Safe in Column (Unbounded Height)',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            // Normally crashes in Column, but safe here
            EzCustomScrollView(
              physics:
                  const NeverScrollableScrollPhysics(), // Let parent scroll
              slivers: [
                SliverToBoxAdapter(
                  child: Container(
                    height: 50,
                    color: Colors.orange[100],
                    alignment: Alignment.center,
                    child: const Text('SliverToBoxAdapter'),
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => ListTile(
                      title: Text('Sliver List Item $index'),
                      tileColor: index.isEven ? Colors.white : Colors.grey[100],
                    ),
                    childCount: 3,
                  ),
                ),
              ],
            ),

            const Divider(height: 32),

            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                '2. Safe in Row (Unbounded Width)',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            // Normally crashes in Row, but safe here
            SizedBox(
              height: 100,
              child: Row(
                children: [
                  const Text('Start'),
                  EzCustomScrollView(
                    scrollDirection: Axis.horizontal,
                    slivers: [
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) => Container(
                            width: 80,
                            color: Colors.amber[100 * (index % 9 + 1)],
                            alignment: Alignment.center,
                            child: Text('H-Item $index'),
                          ),
                          childCount: 5,
                        ),
                      ),
                    ],
                  ),
                  const Text('End'),
                ],
              ),
            ),

            const Divider(height: 32),

            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                '3. Correct Usage (Wrapped in Expanded)',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            SizedBox(
              height: 300, // Constrained parent
              child: Column(
                children: [
                  const Text('Header inside constrained column'),
                  Expanded(
                    child: EzCustomScrollView(
                      slivers: [
                        const SliverAppBar(
                          title: Text('Sliver App Bar'),
                          floating: true,
                          automaticallyImplyLeading: false,
                        ),
                        SliverGrid(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            mainAxisSpacing: 4.0,
                            crossAxisSpacing: 4.0,
                          ),
                          delegate: SliverChildBuilderDelegate(
                            (context, index) => Container(
                              color: Colors.deepOrange[100 * (index % 9 + 1)],
                              alignment: Alignment.center,
                              child: Text('Grid $index'),
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
          ],
        ),
      ),
    );
  }
}
