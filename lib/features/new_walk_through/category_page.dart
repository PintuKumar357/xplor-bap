import 'package:flutter/material.dart';
import 'package:xplor/config/routes/path_routing.dart';

class CategoryPage extends StatefulWidget {
  const CategoryPage({super.key});

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  final List<int> _selectedIndices = [];
  final TextEditingController _searchController = TextEditingController();
  List<String> _filteredCategories = [];

  final List<String> categories = [
    'Crop Farming',
    'Crop Advisory',
    'Dairy Farming',
    'Poultry Farming',
    'Fisheries',
    'Sericulture',
    'Apiculture',
    'Agroforestry',
  ];

  @override
  void initState() {
    super.initState();
    _filteredCategories = List.from(categories);
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      final searchText = _searchController.text.trim();
      if (searchText.isEmpty) {
        _filteredCategories = List.from(categories);
      } else {
        _filteredCategories = categories
            .where((category) => category
            .toLowerCase()
            .contains(searchText.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: screenWidth,
              height: 70,
              color: const Color(0xFFFFFFFF),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                      width: 38,
                      height: 38,
                      margin: const EdgeInsets.only(left: 18),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4CAF50).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Image.asset(
                          'assets/images/choose_lang_back_icon.png',
                          width: 18,
                          height: 15,
                        ),
                      ),
                    ),
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        'Category',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF000000),
                          fontFamily: 'Gilroy-Heavy',
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 56),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 24),
                      const Text(
                        'What are you looking for?',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF000000),
                          fontFamily: 'Gilroy-Bold',
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        height: 42,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFFFFF),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: const Color(0xFFEDEDED),
                            width: 0.5,
                          ),
                        ),
                        child: TextField(
                          controller: _searchController,
                          decoration: const InputDecoration(
                            hintText: 'Search',
                            hintStyle: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFF9E9E9E),
                              fontFamily: 'Gilroy-Medium',
                            ),
                            prefixIcon: Icon(
                              Icons.search,
                              color: Color(0xFF9E9E9E),
                              size: 20,
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Recommended Categories',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF000000),
                          fontFamily: 'Gilroy-Bold',
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _filteredCategories.isEmpty
                          ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 40),
                        child: Center(
                          child: Text(
                            'No categories found',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFF9E9E9E),
                              fontFamily: 'Gilroy-Medium',
                            ),
                          ),
                        ),
                      )
                          : GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 158 / 84,
                        ),
                        itemCount: _filteredCategories.length,
                        itemBuilder: (context, index) {
                          final categoryName = _filteredCategories[index];
                          final originalIndex = categories.indexOf(categoryName);
                          return _buildCategoryTile(
                            categoryName,
                            originalIndex,
                          );
                        },
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 20, left: 24, right: 24),
              child: GestureDetector(
                onTap: () {
                  if (_selectedIndices.isNotEmpty) {
                    print('Selected categories: ${_selectedIndices.length}');
                    Navigator.pushNamed(context, Routes.basicInformationPage);
                  }
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 25,
                    vertical: 15,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CAF50),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: const Text(
                    'Next',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      fontFamily: 'Gilroy-Heavy',
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryTile(String name, int index) {
    final isSelected = _selectedIndices.contains(index);

    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) {
            _selectedIndices.remove(index);
          } else {
            _selectedIndices.add(index);
          }
        });
      },
      child: Container(
        height: 84,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFFFF).withOpacity(0.62),
          borderRadius: BorderRadius.circular(16),
          border: isSelected
              ? Border.all(
            color: const Color(0xFF4CAF50),
            width: 1,
          )
              : null,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFBFBFBF).withOpacity(0.16),
              blurRadius: 12,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          children: [
            Center(
              child: Text(
                name,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF64697A),
                  fontFamily: 'Gilroy-Medium',
                ),
              ),
            ),
            if (isSelected)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: const BoxDecoration(
                    color: Color(0xFF4CAF50),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 14,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
