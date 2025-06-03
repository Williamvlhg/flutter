import 'package:flutter/material.dart';
import '../utils/theme.dart';

class GalleryPage extends StatefulWidget {
  const GalleryPage({super.key});

  @override
  State<GalleryPage> createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage> {
  String _selectedCategory = 'Toutes';
  final List<String> _categories = ['Toutes', 'Personnages', 'Lieux', 'Épisodes', 'Memes'];

  // Images de démonstration
  final List<Map<String, dynamic>> _images = [
    {'url': 'https://via.placeholder.com/300x200?text=Homer', 'category': 'Personnages', 'title': 'Homer Simpson'},
    {'url': 'https://via.placeholder.com/300x200?text=Marge', 'category': 'Personnages', 'title': 'Marge Simpson'},
    {'url': 'https://via.placeholder.com/300x200?text=Springfield', 'category': 'Lieux', 'title': 'Springfield'},
    {'url': 'https://via.placeholder.com/300x200?text=Moes', 'category': 'Lieux', 'title': 'Chez Moe'},
    {'url': 'https://via.placeholder.com/300x200?text=Episode', 'category': 'Épisodes', 'title': 'Épisode classique'},
    {'url': 'https://via.placeholder.com/300x200?text=Meme', 'category': 'Memes', 'title': 'Meme Simpson'},
  ];

  @override
  Widget build(BuildContext context) {
    final filteredImages = _selectedCategory == 'Toutes' 
        ? _images 
        : _images.where((img) => img['category'] == _selectedCategory).toList();

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            _buildCategoryFilter(),
            const SizedBox(height: 24),
            _buildImageGrid(filteredImages),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [SimpsonsColors.blue, SimpsonsColors.darkBlue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: SimpsonsColors.yellow,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.photo_library,
              color: SimpsonsColors.darkBlue,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Galerie',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: SimpsonsColors.white,
                  ),
                ),
                Text(
                  'Images et captures d\'écran des Simpson',
                  style: TextStyle(
                    fontSize: 14,
                    color: SimpsonsColors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _categories.map((category) => Padding(
          padding: const EdgeInsets.only(right: 8),
          child: FilterChip(
            label: Text(category),
            selected: _selectedCategory == category,
            onSelected: (selected) {
              setState(() {
                _selectedCategory = category;
              });
            },
            backgroundColor: SimpsonsColors.lightYellow,
            selectedColor: SimpsonsColors.yellow,
            labelStyle: TextStyle(
              color: _selectedCategory == category ? SimpsonsColors.darkBlue : Colors.black87,
            ),
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildImageGrid(List<Map<String, dynamic>> images) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: MediaQuery.of(context).size.width < 600 ? 2 : 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.2,
      ),
      itemCount: images.length,
      itemBuilder: (context, index) {
        final image = images[index];
        return Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: InkWell(
            onTap: () => _showImageDetail(image),
            borderRadius: BorderRadius.circular(15),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    image['url'],
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: SimpsonsColors.lightYellow,
                      child: const Icon(
                        Icons.image,
                        size: 50,
                        color: SimpsonsColors.blue,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                      child: Text(
                        image['title'],
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showImageDetail(Map<String, dynamic> image) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500, maxHeight: 400),
          child: Column(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                  child: Image.network(
                    image['url'],
                    fit: BoxFit.cover,
                    width: double.infinity,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(
                      image['title'],
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: SimpsonsColors.darkBlue,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Catégorie: ${image['category']}',
                      style: const TextStyle(
                        color: SimpsonsColors.blue,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}