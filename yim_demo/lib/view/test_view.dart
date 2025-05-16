import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../provider/common_data_provider.dart';

class TestView extends StatelessWidget {
  const TestView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Test Viewer')),
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Consumer<CommonDataProvider>(
                builder: (context, data, child) {
                  return Column(
                    children: [
                      data.storageData.backgroundImage ??
                          const Text('No Image'),
                      const SizedBox(height: 10),
                      Text(data.httpConnection.isLocalhost.toString()),
                      const SizedBox(height: 10),
                      Text(data.httpConnection.url),
                      const SizedBox(height: 10),
                      Text(data.httpConnection.port),
                      const SizedBox(height: 10),
                      Text(data.storageData.storageItems.toString()),
                      const SizedBox(height: 10),
                      Text(data.storageData.tempItems.toString()),
                    ],
                  );
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  context.read<CommonDataProvider>().refreshData();
                },
                child: const Text("새로고침"),
              ),
              ElevatedButton(
                onPressed: () {
                  context.read<CommonDataProvider>().changeHttpConnection(
                    false,
                    '10.0.2.2',
                    '5000',
                  );
                },
                child: const Text("Android"),
              ),
              ElevatedButton(
                onPressed: () {
                  context.read<CommonDataProvider>().changeHttpConnection(
                    true,
                    '192.168.0.1',
                    '5000',
                  );
                },
                child: const Text("Windows/localhostTrue"),
              ),
              ElevatedButton(
                onPressed: () {
                  context.read<CommonDataProvider>().changeHttpConnection(
                    false,
                    '127.0.0.1',
                    '5000',
                  );
                },
                child: const Text("Windows/localhostFalse"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
