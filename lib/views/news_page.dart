import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/database_service.dart';
import '../models/news.dart';
import '../utils/theme.dart';
import '../widgets/responsive_grid.dart';
import '../widgets/news_card.dart';

class NewsPage extends StatefulWidget {
  const NewsPage({super.key});

  @override
  State<NewsPage> createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<DatabaseService>(
        builder: (context, dbService, child) {
          if (dbService.isLoading && dbService.news.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(color: SimpsonsColors.blue),
            );
          }

          if (dbService.news.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.newspaper,
                    size: 64,
                    color: SimpsonsColors.blue,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Aucune actualité disponible',
                    style: TextStyle(fontSize: 18, color: SimpsonsColors.darkBlue),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 24),
                _buildFeaturedNews(dbService.news.first),
                const SizedBox(height: 32),
                _buildNewsGrid(dbService.news.skip(1).toList()),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [SimpsonsColors.yellow, SimpsonsColors.lightYellow],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: SimpsonsColors.blue, width: 2),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: SimpsonsColors.blue,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.newspaper,
              color: SimpsonsColors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Actualités Simpson',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: SimpsonsColors.darkBlue,
                  ),
                ),
                Text(
                  'Toute l\'actualité de la famille la plus célèbre de Springfield',
                  style: TextStyle(
                    fontSize: 14,
                    color: SimpsonsColors.darkBlue,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedNews(News news) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: SimpsonsColors.yellow, width: 3),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            colors: [SimpsonsColors.white, SimpsonsColors.lightYellow],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: SimpsonsColors.orange,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'À LA UNE',
                      style: TextStyle(
                        color: SimpsonsColors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    _formatDate(news.publishedAt),
                    style: const TextStyle(
                      color: SimpsonsColors.darkBlue,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                news.title,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: SimpsonsColors.darkBlue,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                news.content.length > 200 
                    ? '${news.content.substring(0, 200)}...'
                    : news.content,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(Icons.person, size: 16, color: SimpsonsColors.blue),
                  const SizedBox(width: 4),
                  Text(
                    'Par ${news.author}',
                    style: const TextStyle(
                      color: SimpsonsColors.blue,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: () => _showNewsDetail(news),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: SimpsonsColors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text(
                      'Lire la suite',
                      style: TextStyle(color: SimpsonsColors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNewsGrid(List<News> newsList) {
    return ResponsiveGrid(
      children: newsList.map((news) => NewsCard(
        news: news,
        onTap: () => _showNewsDetail(news),
      )).toList(),
    );
  }

  void _showNewsDetail(News news) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(24),
          constraints: const BoxConstraints(maxWidth: 600, maxHeight: 500),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        news.title,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: SimpsonsColors.darkBlue,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Icon(Icons.person, size: 16, color: SimpsonsColors.blue),
                    const SizedBox(width: 4),
                    Text('Par ${news.author}'),
                    const SizedBox(width: 16),
                    const Icon(Icons.calendar_today, size: 16, color: SimpsonsColors.blue),
                    const SizedBox(width: 4),
                    Text(_formatDate(news.publishedAt)),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  news.content,
                  style: const TextStyle(fontSize: 16, height: 1.6),
                ),
                if (news.tags.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    children: news.tags.map((tag) => Chip(
                      label: Text(tag),
                      backgroundColor: SimpsonsColors.lightYellow,
                      labelStyle: const TextStyle(color: SimpsonsColors.darkBlue),
                    )).toList(),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}