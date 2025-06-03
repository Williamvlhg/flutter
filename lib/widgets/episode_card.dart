import 'package:flutter/material.dart';
import '../models/episode.dart';
import '../utils/theme.dart';

class EpisodeCard extends StatelessWidget {
  final Episode episode;
  final VoidCallback onTap;

  const EpisodeCard({
    super.key,
    required this.episode,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: const BorderSide(color: SimpsonsColors.blue, width: 1),
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
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
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
                      'S${episode.season}E${episode.episodeNumber}',
                      style: const TextStyle(
                        color: SimpsonsColors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Spacer(),
                  const Icon(
                    Icons.play_circle_filled,
                    color: SimpsonsColors.orange,
                    size: 24,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                (episode.titleFr?.isNotEmpty == true) ? episode.titleFr! : episode.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: SimpsonsColors.darkBlue,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if ((episode.titleFr?.isNotEmpty == true) && episode.title != episode.titleFr) ...[
                const SizedBox(height: 4),
                Text(
                  episode.title,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    fontStyle: FontStyle.italic,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 8),
              Text(
                episode.summary ?? 'Aucun résumé disponible',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.black87,
                  height: 1.3,
                ),
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              ),
              const Spacer(),
              Row(
                children: [
                  const Icon(Icons.calendar_today, size: 12, color: SimpsonsColors.blue),
                  const SizedBox(width: 4),
                  Text(
                    episode.airDate != null ? _formatDate(episode.airDate!) : 'Date inconnue',
                    style: const TextStyle(
                      fontSize: 11,
                      color: SimpsonsColors.blue,
                    ),
                  ),
                  const Spacer(),
                  if (episode.characters.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: SimpsonsColors.yellow,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${episode.characters.length} personnages',
                        style: const TextStyle(
                          fontSize: 10,
                          color: SimpsonsColors.darkBlue,
                          fontWeight: FontWeight.w500,
                        ),
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