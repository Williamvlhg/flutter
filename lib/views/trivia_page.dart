import 'package:flutter/material.dart';
import '../utils/theme.dart';

class TriviaPage extends StatefulWidget {
  const TriviaPage({super.key});

  @override
  State<TriviaPage> createState() => _TriviaPageState();
}

class _TriviaPageState extends State<TriviaPage> {
  final List<Map<String, dynamic>> _triviaItems = [
    {
      'title': 'Saviez-vous que...',
      'content': 'Michael Jackson a participé à l\'épisode "Stark Raving Dad" en prêtant sa voix, mais c\'est un sosie qui a chanté les chansons.',
      'category': 'Célébrités',
      'icon': Icons.music_note,
    },
    {
      'title': 'Record mondial',
      'content': 'Les Simpson détiennent le record de la plus longue série d\'animation américaine avec plus de 750 épisodes.',
      'category': 'Records',
      'icon': Icons.emoji_events,
    },
    {
      'title': 'Prédictions réalisées',
      'content': 'La série a prédit l\'élection de Donald Trump en 2000, soit 16 ans avant qu\'elle ne se réalise.',
      'category': 'Prédictions',
      'icon': Icons.cyclone,
    },
    {
      'title': 'Voix française',
      'content': 'Philippe Peythieu est la voix française d\'Homer Simpson depuis le début de la série.',
      'category': 'Doublage',
      'icon': Icons.record_voice_over,
    },
    {
      'title': 'Clins d\'œil',
      'content': 'Itchy et Scratchy sont inspirés de Tom et Jerry, mais en version ultra-violente.',
      'category': 'Références',
      'icon': Icons.visibility,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            _buildTriviaList(),
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
          colors: [SimpsonsColors.orange, SimpsonsColors.yellow],
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
              Icons.quiz,
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
                  'Trivia Simpson',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: SimpsonsColors.darkBlue,
                  ),
                ),
                Text(
                  'Anecdotes et curiosités sur la série',
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

  Widget _buildTriviaList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _triviaItems.length,
      itemBuilder: (context, index) {
        final item = _triviaItems[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            side: const BorderSide(color: SimpsonsColors.yellow, width: 1),
          ),
          child: ExpansionTile(
            leading: CircleAvatar(
              backgroundColor: SimpsonsColors.blue,
              child: Icon(
                item['icon'],
                color: SimpsonsColors.white,
              ),
            ),
            title: Text(
              item['title'],
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: SimpsonsColors.darkBlue,
              ),
            ),
            subtitle: Text(
              item['category'],
              style: const TextStyle(
                color: SimpsonsColors.blue,
                fontSize: 12,
              ),
            ),
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  item['content'],
                  style: const TextStyle(
                    fontSize: 16,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}