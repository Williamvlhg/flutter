import 'package:flutter/material.dart';
import '../models/news.dart';
import '../utils/theme.dart';

class NewsCard extends StatelessWidget {
  final News news;
  final VoidCallback onTap;

  const NewsCard({
    super.key,
    required this.news,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: const BorderSide(color: SimpsonsColors.yellow, width: 1),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            gradient: const LinearGradient(
              colors: [SimpsonsColors.white, SimpsonsColors.lightYellow],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: SimpsonsColors.blue,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _formatDate(news.publishedAt),
                      style: const TextStyle(
                        color: SimpsonsColors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const Spacer(),
                  const Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: SimpsonsColors.blue,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                news.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: SimpsonsColors.darkBlue,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Text(
                news.content,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                  height: 1.4,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const Spacer(),
              Row(
                children: [
                  const Icon(Icons.person, size: 14, color: SimpsonsColors.blue),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      news.author,
                      style: const TextStyle(
                        fontSize: 12,
                        color: SimpsonsColors.blue,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
