import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/database_service.dart';
import '../utils/theme.dart';

class SeriesPage extends StatelessWidget {
  const SeriesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<DatabaseService>(
        builder: (context, dbService, child) {
          final seasons = dbService.getAvailableSeasons();
          final stats = dbService.getEpisodesStats();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 24),
                _buildStats(stats),
                const SizedBox(height: 24),
                _buildSeasonsGrid(context, seasons, dbService),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [SimpsonsColors.yellow, SimpsonsColors.orange],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: SimpsonsColors.yellow.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: SimpsonsColors.blue,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Icon(
                  Icons.tv,
                  color: SimpsonsColors.white,
                  size: 40,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Les Simpson',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: SimpsonsColors.darkBlue,
                      ),
                    ),
                    Text(
                      'La plus longue série d\'animation de l\'histoire',
                      style: TextStyle(
                        fontSize: 16,
                        color: SimpsonsColors.darkBlue,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Depuis 1989, la famille Simpson nous fait rire avec les aventures d\'Homer, Marge, Bart, Lisa et Maggie dans la ville fictive de Springfield. Une série culte qui a marqué des générations.',
            style: TextStyle(
              fontSize: 16,
              color: SimpsonsColors.darkBlue,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStats(Map<String, int> stats) {
    return Row(
      children: [
        Expanded(child: _buildStatCard('Épisodes', stats['total'] ?? 0, Icons.video_library)),
        const SizedBox(width: 12),
        Expanded(child: _buildStatCard('Saisons', stats['seasons'] ?? 0, Icons.tv)),
        const SizedBox(width: 12),
        Expanded(child: _buildStatCard('Personnages', stats['characters'] ?? 0, Icons.people)),
      ],
    );
  }

  Widget _buildStatCard(String title, int value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: SimpsonsColors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: SimpsonsColors.blue, width: 2),
        boxShadow: [
          BoxShadow(
            color: SimpsonsColors.blue.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, size: 32, color: SimpsonsColors.blue),
          const SizedBox(height: 8),
          Text(
            value.toString(),
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: SimpsonsColors.darkBlue,
            ),
          ),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              color: SimpsonsColors.darkBlue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeasonsGrid(BuildContext context, List<int> seasons, DatabaseService dbService) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Saisons',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: SimpsonsColors.darkBlue,
          ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: MediaQuery.of(context).size.width < 600 ? 2 : 4,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.2,
          ),
          itemCount: seasons.length,
          itemBuilder: (context, index) {
            final season = seasons[index];
            final episodeCount = dbService.getEpisodesBySeason(season).length;
            
            return Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
                side: const BorderSide(color: SimpsonsColors.yellow, width: 2),
              ),
              child: InkWell(
                onTap: () {
                  // Navigation vers les épisodes de la saison
                },
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
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Saison',
                        style: const TextStyle(
                          fontSize: 14,
                          color: SimpsonsColors.blue,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        season.toString(),
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: SimpsonsColors.darkBlue,
                        ),
                      ),
                      Text(
                        '$episodeCount épisodes',
                        style: const TextStyle(
                          fontSize: 12,
                          color: SimpsonsColors.darkBlue,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}