import 'package:flutter/material.dart';
import '../utils/theme.dart';

class AnalysisPage extends StatelessWidget {
  const AnalysisPage({super.key});

  final List<Map<String, dynamic>> _analyses = const [
    {
      'title': 'L\'image de la France dans les Simpson',
      'description': 'Une analyse approfondie de la représentation française dans la série.',
      'content': 'Les Simpson ont abordé la France à plusieurs reprises, souvent avec des stéréotypes mais aussi avec une certaine affection. De l\'épisode "The Crepes of Wrath" où Bart est échangé avec un étudiant français, aux références culinaires et culturelles récurrentes.',
      'icon': Icons.flag,
      'color': SimpsonsColors.blue,
    },
    {
      'title': 'Itchy & Scratchy : Violence et Censure',
      'description': 'L\'évolution du cartoon dans le cartoon et ses messages.',
      'content': 'Itchy & Scratchy serve de métaphore sur la violence télévisuelle et la censure. À travers ces segments, les créateurs critiquent l\'hypocrisie de la société concernant la violence dans les médias pour enfants.',
      'icon': Icons.tv,
      'color': SimpsonsColors.orange,
    },
    {
      'title': 'Springfield : Miroir de l\'Amérique',
      'description': 'Comment Springfield représente l\'Amérique moyenne.',
      'content': 'Springfield n\'est pas située dans un état spécifique volontairement. Cette ville représente l\'Amérique moyenne avec ses problèmes sociaux, économiques et politiques typiques.',
      'icon': Icons.location_city,
      'color': SimpsonsColors.yellow,
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
            _buildAnalysesList(),
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
          colors: [SimpsonsColors.darkBlue, SimpsonsColors.blue],
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
              Icons.analytics,
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
                  'Analyses',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: SimpsonsColors.white,
                  ),
                ),
                Text(
                  'Analyses thématiques de l\'univers Simpson',
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

  Widget _buildAnalysesList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _analyses.length,
      itemBuilder: (context, index) {
        final analysis = _analyses[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          elevation: 6,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            side: BorderSide(color: analysis['color'], width: 2),
          ),
          child: InkWell(
            onTap: () => _showAnalysisDetail(analysis),
            borderRadius: BorderRadius.circular(15),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                gradient: LinearGradient(
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
                      CircleAvatar(
                        backgroundColor: analysis['color'],
                        child: Icon(
                          analysis['icon'],
                          color: SimpsonsColors.white,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          analysis['title'],
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: SimpsonsColors.darkBlue,
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward_ios,
                        color: SimpsonsColors.blue,
                        size: 16,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    analysis['description'],
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                      height: 1.4,
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

  void _showAnalysisDetail(Map<String, dynamic> analysis) {
    // Cette méthode sera appelée par le context depuis le widget
    // Pour l'instant, on ne peut pas naviguer sans context
  }
}