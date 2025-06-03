import 'package:flutter/material.dart';
import 'package:projet_flutter/widgets/responsive_grid.dart';
import 'package:provider/provider.dart';
import '../services/database_service.dart';
import '../models/episode.dart';
import '../utils/theme.dart';
import '../widgets/episode_card.dart';

class EpisodesPage extends StatefulWidget {
  const EpisodesPage({super.key});

  @override
  State<EpisodesPage> createState() => _EpisodesPageState();
}

class _EpisodesPageState extends State<EpisodesPage> {
  int? _selectedSeason;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<DatabaseService>(
        builder: (context, dbService, child) {
          if (dbService.isLoading && dbService.episodes.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(color: SimpsonsColors.blue),
            );
          }

          final availableSeasons = dbService.getAvailableSeasons();
          final filteredEpisodes = _getFilteredEpisodes(dbService);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 24),
                _buildSearchAndFilter(availableSeasons),
                const SizedBox(height: 24),
                if (filteredEpisodes.isEmpty)
                  const Center(
                    child: Text(
                      'Aucun épisode trouvé',
                      style: TextStyle(fontSize: 18, color: SimpsonsColors.darkBlue),
                    ),
                  )
                else
                  _buildEpisodesGrid(filteredEpisodes),
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
              Icons.video_library,
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
                  'Épisodes',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: SimpsonsColors.white,
                  ),
                ),
                Text(
                  'Explorez tous les épisodes des Simpson',
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

  Widget _buildSearchAndFilter(List<int> availableSeasons) {
    return Column(
      children: [
        TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Rechercher un épisode...',
            prefixIcon: const Icon(Icons.search, color: SimpsonsColors.blue),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(25),
              borderSide: const BorderSide(color: SimpsonsColors.yellow),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(25),
              borderSide: const BorderSide(color: SimpsonsColors.blue, width: 2),
            ),
            filled: true,
            fillColor: SimpsonsColors.lightYellow,
          ),
          onChanged: (value) {
            setState(() {
              _searchQuery = value;
            });
          },
        ),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              FilterChip(
                label: const Text('Toutes les saisons'),
                selected: _selectedSeason == null,
                onSelected: (selected) {
                  setState(() {
                    _selectedSeason = selected ? null : _selectedSeason;
                  });
                },
                backgroundColor: SimpsonsColors.lightYellow,
                selectedColor: SimpsonsColors.yellow,
                labelStyle: TextStyle(
                  color: _selectedSeason == null ? SimpsonsColors.darkBlue : Colors.black87,
                ),
              ),
              const SizedBox(width: 8),
              ...availableSeasons.map((season) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text('Saison $season'),
                  selected: _selectedSeason == season,
                  onSelected: (selected) {
                    setState(() {
                      _selectedSeason = selected ? season : null;
                    });
                  },
                  backgroundColor: SimpsonsColors.lightYellow,
                  selectedColor: SimpsonsColors.yellow,
                  labelStyle: TextStyle(
                    color: _selectedSeason == season ? SimpsonsColors.darkBlue : Colors.black87,
                  ),
                ),
              )).toList(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEpisodesGrid(List<Episode> episodes) {
    return ResponsiveGrid(
      children: episodes.map((episode) => EpisodeCard(
        episode: episode,
        onTap: () => _showEpisodeDetail(episode),
      )).toList(),
    );
  }

  List<Episode> _getFilteredEpisodes(DatabaseService dbService) {
    List<Episode> episodes = dbService.episodes;

    if (_selectedSeason != null) {
      episodes = dbService.getEpisodesBySeason(_selectedSeason!);
    }

    if (_searchQuery.isNotEmpty) {
      episodes = episodes.where((episode) =>
        episode.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        (episode.titleFr?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false) ||
        (episode.summary?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false)
      ).toList();
    }

    return episodes;
  }

  void _showEpisodeDetail(Episode episode) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(24),
          constraints: const BoxConstraints(maxWidth: 700, maxHeight: 600),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'S${episode.season}E${episode.episodeNumber}',
                            style: const TextStyle(
                              fontSize: 16,
                              color: SimpsonsColors.blue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            episode.titleFr ?? episode.title, 
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: SimpsonsColors.darkBlue,
                            ),
                          ),
                          Text(
                            episode.title,
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.grey,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
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
                    const Icon(Icons.calendar_today, size: 16, color: SimpsonsColors.blue),
                    const SizedBox(width: 4),
                    Text('Diffusé le ${episode.airDate != null ? _formatDate(episode.airDate!) : 'Date inconnue'}'),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'Résumé',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: SimpsonsColors.darkBlue,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  episode.summary ?? 'Aucun résumé disponible',
                  style: const TextStyle(fontSize: 16, height: 1.6),
                ),
                if (episode.characters.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Text(
                    'Personnages principaux',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: SimpsonsColors.darkBlue,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: episode.characters.map((character) => Chip(
                      label: Text(character),
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