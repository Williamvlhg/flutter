import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/database_service.dart';
import '../models/character.dart';
import '../utils/theme.dart';
import '../widgets/character_card.dart';
import '../widgets/responsive_grid.dart';

class CharactersPage extends StatefulWidget {
  const CharactersPage({super.key});

  @override
  State<CharactersPage> createState() => _CharactersPageState();
}

class _CharactersPageState extends State<CharactersPage> {
  String _searchQuery = '';
  bool _showOnlyMajor = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<DatabaseService>(
        builder: (context, dbService, child) {
          if (dbService.isLoading && dbService.characters.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(color: SimpsonsColors.blue),
            );
          }

          final filteredCharacters = _getFilteredCharacters(dbService);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 24),
                _buildSearchAndFilter(),
                const SizedBox(height: 24),
                if (filteredCharacters.isEmpty)
                  const Center(
                    child: Text(
                      'Aucun personnage trouvé',
                      style: TextStyle(fontSize: 18, color: SimpsonsColors.darkBlue),
                    ),
                  )
                else
                  _buildCharactersGrid(filteredCharacters),
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
              Icons.people,
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
                  'Personnages',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: SimpsonsColors.darkBlue,
                  ),
                ),
                Text(
                  'Découvrez les habitants de Springfield',
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

  Widget _buildSearchAndFilter() {
    return Column(
      children: [
        TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Rechercher un personnage...',
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
        Row(
          children: [
            FilterChip(
              label: const Text('Personnages principaux'),
              selected: _showOnlyMajor,
              onSelected: (selected) {
                setState(() {
                  _showOnlyMajor = selected;
                });
              },
              backgroundColor: SimpsonsColors.lightYellow,
              selectedColor: SimpsonsColors.yellow,
              labelStyle: TextStyle(
                color: _showOnlyMajor ? SimpsonsColors.darkBlue : Colors.black87,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCharactersGrid(List<Character> characters) {
    return ResponsiveGrid(
      children: characters.map((character) => CharacterCard(
        character: character,
        onTap: () => _showCharacterDetail(character),
      )).toList(),
    );
  }

  List<Character> _getFilteredCharacters(DatabaseService dbService) {
    List<Character> characters = dbService.characters;

    if (_showOnlyMajor) {
      characters = dbService.getMajorCharacters();
    }

    if (_searchQuery.isNotEmpty) {
      characters = characters.where((character) =>
        character.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        character.nameFr.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        character.description.toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();
    }

    return characters;
  }

  void _showCharacterDetail(Character character) {
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
                    if (character.imageUrl != null)
                      CircleAvatar(
                        radius: 40,
                        backgroundImage: NetworkImage(character.imageUrl!),
                        backgroundColor: SimpsonsColors.lightYellow,
                      )
                    else
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: SimpsonsColors.yellow,
                        child: Text(
                          character.nameFr.isNotEmpty ? character.nameFr[0] : character.name[0],
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: SimpsonsColors.darkBlue,
                          ),
                        ),
                      ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            character.nameFr.isNotEmpty ? character.nameFr : character.name,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: SimpsonsColors.darkBlue,
                            ),
                          ),
                          if (character.nameFr.isNotEmpty && character.name != character.nameFr)
                            Text(
                              character.name,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          if (character.job.isNotEmpty)
                            Text(
                              character.job,
                              style: const TextStyle(
                                fontSize: 14,
                                color: SimpsonsColors.blue,
                                fontWeight: FontWeight.w500,
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
                const SizedBox(height: 20),
                if (character.family.isNotEmpty) ...[
                  Row(
                    children: [
                      const Icon(Icons.family_restroom, size: 20, color: SimpsonsColors.blue),
                      const SizedBox(width: 8),
                      Text(
                        'Famille: ${character.family}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: SimpsonsColors.darkBlue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],
                const Text(
                  'Description',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: SimpsonsColors.darkBlue,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  character.description,
                  style: const TextStyle(fontSize: 16, height: 1.6),
                ),
                if (character.episodes.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  Text(
                    'Apparitions (${character.episodes.length} épisodes)',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: SimpsonsColors.darkBlue,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 100,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: character.episodes.length > 10 ? 10 : character.episodes.length,
                      itemBuilder: (context, index) {
                        return Container(
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: SimpsonsColors.lightYellow,
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(color: SimpsonsColors.yellow),
                          ),
                          child: Text(
                           character.episodes[index].titleFr.isNotEmpty 
                              ? character.episodes[index].titleFr 
                              : character.episodes[index].title,
                            style: const TextStyle(
                              color: SimpsonsColors.darkBlue,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  if (character.episodes.length > 10)
                    Text(
                      '... et ${character.episodes.length - 10} autres épisodes',
                      style: const TextStyle(
                        color: SimpsonsColors.blue,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}