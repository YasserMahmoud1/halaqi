import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_barber/core/themes/app_colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_barber/core/router/routes.dart';
import '../../logic/home_providers.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  // String _selectedCategory = 'All';
  // final List<String> _categories = ['All', 'Barbers', 'Services'];

  // String _selectedGeneralCategory = 'Hair Cut';
  // double _ratingBarber = 4.0;
  // double _nearestDistance = 0;
  // double _farthestDistance = 10;

  List<String> _recentSearches = [
    'Haircut near me',
    'Alana Barbershop',
    'Beard trim',
  ];

  @override
  void initState() {
    super.initState();
    // Auto-focus the search field when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchFocusNode.requestFocus();
    });

    _searchController.addListener(() {
      // Trigger search with debounce through the notifier
      // The debounce mechanism handles the delay automatically
      ref.read(searchNotifierProvider.notifier).search(_searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _locationController.dispose();
    _searchFocusNode.dispose();
    // Note: Don't use ref.read in dispose - it's unsafe when widget is unmounting
    // The search will be cleared automatically when the provider is disposed
    super.dispose();
  }

  void _addToRecentSearches(String query) {
    if (query.isEmpty) return;
    setState(() {
      _recentSearches.remove(query);
      _recentSearches.insert(0, query);
      if (_recentSearches.length > 10) {
        _recentSearches = _recentSearches.sublist(0, 10);
      }
    });
  }

  // void _clearRecentSearches() {
  //   setState(() {
  //     _recentSearches.clear();
  //   });
  // }

  // void _showFilterBottomSheet(BuildContext context) {
  //   showModalBottomSheet(
  //     context: context,
  //     isScrollControlled: true,
  //     backgroundColor: Colors.transparent,
  //     builder: (context) => StatefulBuilder(
  //       builder: (context, setModalState) => Container(
  //         height: MediaQuery.of(context).size.height * 0.85,
  //         decoration: BoxDecoration(
  //           color: AppColors.scaffoldBackground(context),
  //           borderRadius: BorderRadius.only(
  //             topLeft: Radius.circular(24.r),
  //             topRight: Radius.circular(24.r),
  //           ),
  //         ),
  //         child: Column(
  //           children: [
  //             SizedBox(height: 12.h),
  //             Container(
  //               width: 40.w,
  //               height: 4.h,
  //               decoration: BoxDecoration(
  //                 color: Colors.grey.withValues(alpha: 0.3),
  //                 borderRadius: BorderRadius.circular(2.r),
  //               ),
  //             ),
  //             SizedBox(height: 20.h),
  //             Padding(
  //               padding: EdgeInsets.symmetric(horizontal: 24.w),
  //               child: Row(
  //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                 children: [
  //                   Row(
  //                     children: [
  //                       Container(
  //                         padding: EdgeInsets.all(8.w),
  //                         decoration: BoxDecoration(
  //                           color: AppColors.primaryColor(context),
  //                           borderRadius: BorderRadius.circular(8.r),
  //                         ),
  //                         child: Icon(
  //                           Icons.tune,
  //                           color: AppColors.scaffoldBackground(context),
  //                           size: 20.sp,
  //                         ),
  //                       ),
  //                       SizedBox(width: 12.w),
  //                       Text(
  //                         'Filter',
  //                         style: TextStyle(
  //                           fontSize: 20.sp,
  //                           fontWeight: FontWeight.bold,
  //                           color: AppColors.inverseScaffoldBackground(context),
  //                         ),
  //                       ),
  //                     ],
  //                   ),
  //                   Container(
  //                     padding: EdgeInsets.all(8.w),
  //                     decoration: BoxDecoration(
  //                       color: AppColors.primaryColor(context),
  //                       borderRadius: BorderRadius.circular(8.r),
  //                     ),
  //                     child: Icon(
  //                       Icons.bookmark_outline,
  //                       color: AppColors.scaffoldBackground(context),
  //                       size: 20.sp,
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             ),
  //             SizedBox(height: 24.h),
  //             Expanded(
  //               child: SingleChildScrollView(
  //                 padding: EdgeInsets.symmetric(horizontal: 24.w),
  //                 child: Column(
  //                   crossAxisAlignment: CrossAxisAlignment.start,
  //                   children: [
  //                     // General Category
  //                     Text(
  //                       'General Category',
  //                       style: TextStyle(
  //                         fontSize: 16.sp,
  //                         fontWeight: FontWeight.bold,
  //                         color: AppColors.inverseScaffoldBackground(context),
  //                       ),
  //                     ),
  //                     SizedBox(height: 12.h),
  //                     Row(
  //                       children: [
  //                         Expanded(
  //                           child: _buildCategoryChip(
  //                             'Hair Cut',
  //                             _selectedGeneralCategory == 'Hair Cut',
  //                             setModalState,
  //                           ),
  //                         ),
  //                         SizedBox(width: 12.w),
  //                         Expanded(
  //                           child: _buildCategoryChip(
  //                             'Beard Cut',
  //                             _selectedGeneralCategory == 'Beard Cut',
  //                             setModalState,
  //                           ),
  //                         ),
  //                       ],
  //                     ),
  //                     SizedBox(height: 24.h),

  //                     // Rating Barber
  //                     Text(
  //                       'Rating Barber',
  //                       style: TextStyle(
  //                         fontSize: 16.sp,
  //                         fontWeight: FontWeight.bold,
  //                         color: AppColors.inverseScaffoldBackground(context),
  //                       ),
  //                     ),
  //                     SizedBox(height: 12.h),
  //                     Row(
  //                       children: [
  //                         ...List.generate(5, (index) {
  //                           return GestureDetector(
  //                             onTap: () {
  //                               setModalState(() {
  //                                 _ratingBarber = (index + 1).toDouble();
  //                               });
  //                             },
  //                             child: Padding(
  //                               padding: EdgeInsets.only(right: 4.w),
  //                               child: Icon(
  //                                 index < _ratingBarber
  //                                     ? Icons.star
  //                                     : Icons.star_border,
  //                                 color: AppColors.primaryColor(context),
  //                                 size: 32.sp,
  //                               ),
  //                             ),
  //                           );
  //                         }),
  //                         SizedBox(width: 8.w),
  //                         Text(
  //                           '${_ratingBarber.toStringAsFixed(1)} (0)',
  //                           style: TextStyle(
  //                             fontSize: 14.sp,
  //                             color: AppColors.textGrey(context),
  //                           ),
  //                         ),
  //                       ],
  //                     ),
  //                     SizedBox(height: 24.h),

  //                     // Distance
  //                     Text(
  //                       'Distance',
  //                       style: TextStyle(
  //                         fontSize: 16.sp,
  //                         fontWeight: FontWeight.bold,
  //                         color: AppColors.inverseScaffoldBackground(context),
  //                       ),
  //                     ),
  //                     SizedBox(height: 12.h),
  //                     Row(
  //                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                       children: [
  //                         Text(
  //                           'Nearest',
  //                           style: TextStyle(
  //                             fontSize: 14.sp,
  //                             color: AppColors.textGrey(context),
  //                           ),
  //                         ),
  //                         Text(
  //                           'Farthest',
  //                           style: TextStyle(
  //                             fontSize: 14.sp,
  //                             color: AppColors.textGrey(context),
  //                           ),
  //                         ),
  //                       ],
  //                     ),
  //                     SizedBox(height: 8.h),
  //                     Row(
  //                       children: [
  //                         Expanded(
  //                           child: Container(
  //                             padding: EdgeInsets.symmetric(
  //                               horizontal: 16.w,
  //                               vertical: 12.h,
  //                             ),
  //                             decoration: BoxDecoration(
  //                               border: Border.all(
  //                                 color: AppColors.primaryColor(context),
  //                                 width: 2,
  //                               ),
  //                               borderRadius: BorderRadius.circular(8.r),
  //                             ),
  //                             child: Row(
  //                               mainAxisAlignment: MainAxisAlignment.center,
  //                               children: [
  //                                 Text(
  //                                   _nearestDistance.toInt().toString(),
  //                                   style: TextStyle(
  //                                     fontSize: 18.sp,
  //                                     fontWeight: FontWeight.bold,
  //                                     color:
  //                                         AppColors.inverseScaffoldBackground(
  //                                           context,
  //                                         ),
  //                                   ),
  //                                 ),
  //                                 SizedBox(width: 4.w),
  //                                 Text(
  //                                   'Km',
  //                                   style: TextStyle(
  //                                     fontSize: 12.sp,
  //                                     color: AppColors.textGrey(context),
  //                                   ),
  //                                 ),
  //                               ],
  //                             ),
  //                           ),
  //                         ),
  //                         Padding(
  //                           padding: EdgeInsets.symmetric(horizontal: 16.w),
  //                           child: Icon(
  //                             Icons.arrow_forward,
  //                             color: AppColors.textGrey(context),
  //                             size: 20.sp,
  //                           ),
  //                         ),
  //                         Expanded(
  //                           child: Container(
  //                             padding: EdgeInsets.symmetric(
  //                               horizontal: 16.w,
  //                               vertical: 12.h,
  //                             ),
  //                             decoration: BoxDecoration(
  //                               border: Border.all(
  //                                 color: AppColors.primaryColor(context),
  //                                 width: 2,
  //                               ),
  //                               borderRadius: BorderRadius.circular(8.r),
  //                             ),
  //                             child: Row(
  //                               mainAxisAlignment: MainAxisAlignment.center,
  //                               children: [
  //                                 Text(
  //                                   _farthestDistance.toInt().toString(),
  //                                   style: TextStyle(
  //                                     fontSize: 18.sp,
  //                                     fontWeight: FontWeight.bold,
  //                                     color:
  //                                         AppColors.inverseScaffoldBackground(
  //                                           context,
  //                                         ),
  //                                   ),
  //                                 ),
  //                                 SizedBox(width: 4.w),
  //                                 Text(
  //                                   'Km',
  //                                   style: TextStyle(
  //                                     fontSize: 12.sp,
  //                                     color: AppColors.textGrey(context),
  //                                   ),
  //                                 ),
  //                               ],
  //                             ),
  //                           ),
  //                         ),
  //                       ],
  //                     ),
  //                     SizedBox(height: 16.h),
  //                     SliderTheme(
  //                       data: SliderThemeData(
  //                         trackHeight: 4.h,
  //                         thumbShape: RoundSliderThumbShape(
  //                           enabledThumbRadius: 8.r,
  //                         ),
  //                         overlayShape: RoundSliderOverlayShape(
  //                           overlayRadius: 16.r,
  //                         ),
  //                         activeTrackColor: AppColors.primaryColor(context),
  //                         inactiveTrackColor: Colors.grey.withValues(alpha: 0.3),
  //                         thumbColor: AppColors.primaryColor(context),
  //                         overlayColor: AppColors.primaryColor(
  //                           context,
  //                         ).withValues(alpha: 0.2),
  //                       ),
  //                       child: Slider(
  //                         value: _farthestDistance,
  //                         min: 0,
  //                         max: 50,
  //                         divisions: 50,
  //                         onChanged: (value) {
  //                           setModalState(() {
  //                             _farthestDistance = value;
  //                           });
  //                         },
  //                       ),
  //                     ),
  //                     SizedBox(height: 40.h),
  //                   ],
  //                 ),
  //               ),
  //             ),
  //             Container(
  //               padding: EdgeInsets.all(24.w),
  //               decoration: BoxDecoration(
  //                 color: AppColors.scaffoldBackground(context),
  //                 boxShadow: [
  //                   BoxShadow(
  //                     color: Colors.black.withValues(alpha: 0.05),
  //                     blurRadius: 10,
  //                     offset: Offset(0, -5),
  //                   ),
  //                 ],
  //               ),
  //               child: SizedBox(
  //                 width: double.infinity,
  //                 height: 50.h,
  //                 child: ElevatedButton(
  //                   onPressed: () {
  //                     Navigator.pop(context);
  //                     setState(() {
  //                       // Apply filters
  //                       // Note: Search is automatically triggered by the text field listener
  //                     });
  //                   },
  //                   style: ElevatedButton.styleFrom(
  //                     backgroundColor: AppColors.primaryColor(context),
  //                     shape: RoundedRectangleBorder(
  //                       borderRadius: BorderRadius.circular(12.r),
  //                     ),
  //                   ),
  //                   child: Text(
  //                     'Apply',
  //                     style: TextStyle(
  //                       fontSize: 16.sp,
  //                       fontWeight: FontWeight.w600,
  //                       color: Colors.white,
  //                     ),
  //                   ),
  //                 ),
  //               ),
  //             ),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }

  // Widget _buildCategoryChip(
  //   String label,
  //   bool isSelected,
  //   StateSetter setModalState,
  // ) {
  //   return GestureDetector(
  //     onTap: () {
  //       setModalState(() {
  //         _selectedGeneralCategory = label;
  //       });
  //     },
  //     child: Container(
  //       padding: EdgeInsets.symmetric(vertical: 12.h),
  //       decoration: BoxDecoration(
  //         color: isSelected
  //             ? AppColors.primaryColor(context)
  //             : AppColors.scaffoldBackground(context),
  //         border: Border.all(
  //           color: isSelected
  //               ? AppColors.primaryColor(context)
  //               : Colors.grey.withValues(alpha: 0.3),
  //           width: 1.5,
  //         ),
  //         borderRadius: BorderRadius.circular(8.r),
  //       ),
  //       child: Center(
  //         child: Text(
  //           label,
  //           style: TextStyle(
  //             fontSize: 14.sp,
  //             fontWeight: FontWeight.w600,
  //             color: isSelected
  //                 ? Colors.white
  //                 : AppColors.inverseScaffoldBackground(context),
  //           ),
  //         ),
  //       ),
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.scaffoldBackground(context),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Container(
          height: 45.h,
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? AppColors.greyDark
                : Colors.grey.shade200,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: TextField(
            controller: _searchController,
            focusNode: _searchFocusNode,
            style: TextStyle(
              fontSize: 16.sp,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
            decoration: InputDecoration(
              hintText: 'Search for barber shops',
              hintStyle: TextStyle(
                fontSize: 16.sp,
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.greyLight
                    : Colors.grey.shade600,
              ),
              prefixIcon: Icon(
                Icons.search,
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.greyLight
                    : Colors.grey.shade500,
                size: 24.sp,
              ),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: Icon(
                        Icons.clear,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? AppColors.greyLight
                            : Colors.grey.shade600,
                        size: 20.sp,
                      ),
                      onPressed: () {
                        _searchController.clear();
                      },
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16.w,
                vertical: 12.h,
              ),
            ),
            onSubmitted: (value) {
              _addToRecentSearches(value);
            },
          ),
        ),
        // Filter button commented out - showing barber shops only
        // actions: [
        //   IconButton(
        //     icon: Icon(Icons.filter_list, size: 24.sp),
        //     onPressed: () {
        //       _showFilterBottomSheet(context);
        //     },
        //   ),
        //   SizedBox(width: 8.w),
        // ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            children: [
          // Category Filter - Commented out (searching barber shops only)
          // Container(
          //   height: 50.h,
          //   padding: EdgeInsets.symmetric(vertical: 8.h),
          //   child: ListView.builder(
          //     scrollDirection: Axis.horizontal,
          //     padding: EdgeInsets.symmetric(horizontal: 24.w),
          //     itemCount: _categories.length,
          //     itemBuilder: (context, index) {
          //       final category = _categories[index];
          //       final isSelected = _selectedCategory == category;
          //       return Padding(
          //         padding: EdgeInsets.only(right: 12.w),
          //         child: GestureDetector(
          //           onTap: () {
          //             setState(() {
          //               _selectedCategory = category;
          //             });
          //           },
          //           child: Container(
          //             padding: EdgeInsets.symmetric(
          //               horizontal: 20.w,
          //               vertical: 8.h,
          //             ),
          //             decoration: BoxDecoration(
          //               color: isSelected
          //                   ? AppColors.primaryColor(context)
          //                   : AppColors.greyDark,
          //               borderRadius: BorderRadius.circular(20.r),
          //             ),
          //             child: Center(
          //               child: Text(
          //                 category,
          //                 style: TextStyle(
          //                   fontSize: 14.sp,
          //                   fontWeight: isSelected
          //                       ? FontWeight.w600
          //                       : FontWeight.normal,
          //                   color: isSelected
          //                       ? AppColors.scaffoldBackground(context)
          //                       : Theme.of(context).textTheme.bodyLarge?.color,
          //                 ),
          //               ),
          //             ),
          //           ),
          //         ),
          //       );
          //     },
          //   ),
          // ),
          //
          // Divider(height: 1.h, color: AppColors.greyDark),

          // Content
          Expanded(
            child: () {
              final searchState = ref.watch(searchNotifierProvider);
              final isSearching = searchState.query.isNotEmpty;

              // Show search results or empty state
              return isSearching
                  ? _buildSearchResults()
                  : Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search,
                            size: 80.sp,
                            color: AppColors.greyLight,
                          ),
                          SizedBox(height: 16.h),
                          Text(
                            'Search for barber shops',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16.sp,
                              color: AppColors.greyLight,
                            ),
                          ),
                        ],
                      ),
                    );
            }(),
          ),
        ],
      ),
    ),
    ),
    );
  }

  // Widget _buildRecentSearches() {
  //   if (_recentSearches.isEmpty) {
  //     return Center(
  //       child: Column(
  //         mainAxisAlignment: MainAxisAlignment.center,
  //         children: [
  //           Icon(Icons.search, size: 80.sp, color: AppColors.greyLight),
  //           SizedBox(height: 16.h),
  //           Text(
  //             'Start searching for barbers\nand services',
  //             textAlign: TextAlign.center,
  //             style: TextStyle(fontSize: 16.sp, color: AppColors.greyLight),
  //           ),
  //         ],
  //       ),
  //     );
  //   }

  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       Padding(
  //         padding: EdgeInsets.all(24.w),
  //         child: Row(
  //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //           children: [
  //             Text(
  //               'Recent Searches',
  //               style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
  //             ),
  //             TextButton(
  //               onPressed: _clearRecentSearches,
  //               child: Text(
  //                 'Clear All',
  //                 style: TextStyle(
  //                   fontSize: 14.sp,
  //                   color: AppColors.primaryColor(context),
  //                 ),
  //               ),
  //             ),
  //           ],
  //         ),
  //       ),
  //       Expanded(
  //         child: ListView.builder(
  //           padding: EdgeInsets.symmetric(horizontal: 24.w),
  //           itemCount: _recentSearches.length,
  //           itemBuilder: (context, index) {
  //             final search = _recentSearches[index];
  //             return ListTile(
  //               contentPadding: EdgeInsets.zero,
  //               leading: Icon(
  //                 Icons.history,
  //                 color: AppColors.greyLight,
  //                 size: 24.sp,
  //               ),
  //               title: Text(search, style: TextStyle(fontSize: 16.sp)),
  //               trailing: IconButton(
  //                 icon: Icon(
  //                   Icons.close,
  //                   color: AppColors.greyLight,
  //                   size: 20.sp,
  //                 ),
  //                 onPressed: () {
  //                   setState(() {
  //                     _recentSearches.removeAt(index);
  //                   });
  //                 },
  //               ),
  //               onTap: () {
  //                 _searchController.text = search;
  //                 _addToRecentSearches(search);
  //               },
  //             );
  //           },
  //         ),
  //       ),
  //     ],
  //   );
  // }

  Widget _buildSearchResults() {
    final searchState = ref.watch(searchNotifierProvider);

    // Show loading indicator
    if (searchState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Show error message
    if (searchState.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 80.sp, color: Colors.red),
            SizedBox(height: 16.h),
            Text(
              'Error',
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 40.w),
              child: Text(
                searchState.error!,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14.sp, color: AppColors.greyLight),
              ),
            ),
          ],
        ),
      );
    }

    // Show empty state
    if (searchState.results.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 80.sp, color: AppColors.greyLight),
            SizedBox(height: 16.h),
            Text(
              'No results found',
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.h),
            Text(
              'Try searching with different keywords',
              style: TextStyle(fontSize: 14.sp, color: AppColors.greyLight),
            ),
          ],
        ),
      );
    }

    // Show search results from the API
    return ListView.builder(
      padding: EdgeInsets.all(24.w),
      itemCount: searchState.results.length,
      itemBuilder: (context, index) {
        final shop = searchState.results[index];
        return _buildShopResultItem(shop);
      },
    );
  }

  // New method to build shop result item from API data
  Widget _buildShopResultItem(shop) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: GestureDetector(
        onTap: () {
          _addToRecentSearches(_searchController.text);
          context.push('${AppRoutes.barberDetails}/${shop.shopId}');
        },
        child: Row(
          children: [
            Container(
              height: 80.h,
              width: 80.w,
              decoration: BoxDecoration(
                color: AppColors.greyDark,
                borderRadius: BorderRadius.circular(12.r),
                image: shop.coverImage != null
                    ? DecorationImage(
                        image: NetworkImage(shop.coverImage!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: shop.coverImage == null
                  ? Center(
                      child: Icon(
                        Icons.store,
                        size: 32.sp,
                        color: AppColors.greyLight,
                      ),
                    )
                  : null,
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    shop.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  // Distance display (first)
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 16.sp,
                        color: AppColors.greyLight,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        shop.distanceKm == null
                            ? 'Distance unavailable'
                            : '${shop.distanceKm.toStringAsFixed(1)} km',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: AppColors.textGrey(context),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  // Rating display (second)
                  Row(
                    children: [
                      Icon(Icons.star, size: 16.sp, color: Colors.amber),
                      SizedBox(width: 4.w),
                      Text(
                        shop.avgRating != null
                            ? shop.avgRating!.toStringAsFixed(1)
                            : 'Not rated',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: AppColors.textGrey(context),
                        ),
                      ),
                    ],
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
