import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../logic/home_providers.dart';

/// Example of how to use the search notifier with debounce
///
/// This widget demonstrates:
/// 1. How to listen to search state
/// 2. How to trigger search on text field changes (with debounce)
/// 3. How to display loading state, results, and errors
///
/// Usage:
/// Simply call `ref.read(searchNotifierProvider.notifier).search(query)`
/// on every TextField onChange event. The debounce mechanism will automatically
/// handle the delay and prevent excessive API calls.
class SearchBarberShopsExample extends ConsumerWidget {
  const SearchBarberShopsExample({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the search state
    final searchState = ref.watch(searchNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Search Barber Shops')),
      body: Column(
        children: [
          // Search TextField
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: (query) {
                // This will be called on every keystroke
                // The debounce mechanism will handle the delay
                ref.read(searchNotifierProvider.notifier).search(query);
              },
              decoration: InputDecoration(
                hintText: 'Search by shop name...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                suffixIcon: searchState.query.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          ref.read(searchNotifierProvider.notifier).clear();
                        },
                      )
                    : null,
              ),
            ),
          ),

          // Loading indicator
          if (searchState.isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            ),

          // Error message
          if (searchState.error != null)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                searchState.error!,
                style: const TextStyle(color: Colors.red),
              ),
            ),

          // Search results
          if (!searchState.isLoading &&
              searchState.error == null &&
              searchState.results.isNotEmpty)
            Expanded(
              child: ListView.builder(
                itemCount: searchState.results.length,
                itemBuilder: (context, index) {
                  final shop = searchState.results[index];
                  return ListTile(
                    leading: shop.coverImage != null
                        ? Image.network(
                            shop.coverImage!,
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          )
                        : const Icon(Icons.store),
                    title: Text(shop.name),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (shop.avgRating != null)
                          Text('Rating: ${shop.avgRating!.toStringAsFixed(1)}'),
                        Text(
                          'Distance: ${shop.distanceKm.toStringAsFixed(2)} km',
                        ),
                      ],
                    ),
                    onTap: () {
                      // Navigate to shop details
                      // Example: context.go('/barber-details', extra: shop.shopId);
                    },
                  );
                },
              ),
            ),

          // Empty state
          if (!searchState.isLoading &&
              searchState.error == null &&
              searchState.query.isNotEmpty &&
              searchState.results.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('No shops found matching your search.'),
            ),

          // Initial state
          if (searchState.query.isEmpty && searchState.results.isEmpty)
            const Expanded(
              child: Center(
                child: Text('Start typing to search for barber shops'),
              ),
            ),
        ],
      ),
    );
  }
}
