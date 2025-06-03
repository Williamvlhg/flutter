import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../models/episode.dart';
import '../models/character.dart';
import '../models/news.dart';
import '../utils/theme.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthService>(
      builder: (context, authService, child) {
        if (!authService.isAuthenticated || !authService.isAdmin) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.lock,
                    size: 64,
                    color: SimpsonsColors.blue,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Accès refusé',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: SimpsonsColors.darkBlue,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Vous devez être administrateur pour accéder à cette page',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: SimpsonsColors.darkBlue,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Retour'),
                  ),
                ],
              ),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Administration'),
            backgroundColor: SimpsonsColors.orange,
            bottom: TabBar(
              controller: _tabController,
              labelColor: SimpsonsColors.darkBlue,
              tabs: const [
                Tab(icon: Icon(Icons.dashboard), text: 'Tableau de bord'),
                Tab(icon: Icon(Icons.newspaper), text: 'Actualités'),
                Tab(icon: Icon(Icons.video_library), text: 'Épisodes'),
                Tab(icon: Icon(Icons.people), text: 'Personnages'),
              ],
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: const [
              AdminDashboard(),
              NewsManagement(),
              EpisodesManagement(),
              CharactersManagement(),
            ],
          ),
        );
      },
    );
  }
}

// Tableau de bord administrateur
class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DatabaseService>(
      builder: (context, dbService, child) {
        final stats = dbService.getEpisodesStats();
        
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWelcomeCard(),
              const SizedBox(height: 24),
              _buildStatsGrid(stats),
              const SizedBox(height: 24),
              _buildQuickActions(context),
              const SizedBox(height: 24),
              _buildRecentActivity(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWelcomeCard() {
    return Consumer<AuthService>(
      builder: (context, authService, child) {
        return Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            side: const BorderSide(color: SimpsonsColors.orange, width: 2),
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              gradient: const LinearGradient(
                colors: [SimpsonsColors.yellow, SimpsonsColors.lightYellow],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: SimpsonsColors.blue,
                  child: const Icon(
                    Icons.admin_panel_settings,
                    size: 30,
                    color: SimpsonsColors.white,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Bienvenue ${authService.currentUser?.username ?? "Administrateur"}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: SimpsonsColors.darkBlue,
                        ),
                      ),
                      const Text(
                        'Panneau d\'administration Simpsons Park',
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
          ),
        );
      },
    );
  }

  Widget _buildStatsGrid(Map<String, int> stats) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _buildStatCard('Épisodes', stats['total'] ?? 0, Icons.video_library, SimpsonsColors.blue),
        _buildStatCard('Saisons', stats['seasons'] ?? 0, Icons.tv, SimpsonsColors.orange),
        _buildStatCard('Personnages', stats['characters'] ?? 0, Icons.people, SimpsonsColors.yellow),
        _buildStatCard('Actualités', stats['news'] ?? 0, Icons.newspaper, SimpsonsColors.darkBlue),
      ],
    );
  }

  Widget _buildStatCard(String title, int value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(color: color, width: 2),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          gradient: LinearGradient(
            colors: [Colors.white, color.withOpacity(0.1)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value.toString(),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Actions rapides',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: SimpsonsColors.darkBlue,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _buildActionButton(
                  'Nouvel épisode',
                  Icons.add_circle,
                  SimpsonsColors.blue,
                  () => _showAddEpisodeDialog(context),
                ),
                _buildActionButton(
                  'Nouveau personnage',
                  Icons.person_add,
                  SimpsonsColors.orange,
                  () => _showAddCharacterDialog(context),
                ),
                _buildActionButton(
                  'Nouvelle actualité',
                  Icons.article,
                  SimpsonsColors.yellow,
                  () => _showAddNewsDialog(context),
                ),
                _buildActionButton(
                  'Statistiques',
                  Icons.analytics,
                  SimpsonsColors.darkBlue,
                  () => _showStatsDialog(context),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(String label, IconData icon, Color color, VoidCallback onPressed) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: Colors.white),
      label: Text(label, style: const TextStyle(color: Colors.white)),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }

  Widget _buildRecentActivity() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Activité récente',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: SimpsonsColors.darkBlue,
              ),
            ),
            const SizedBox(height: 16),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 3,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                final activities = [
                  {'action': 'Nouvel épisode ajouté', 'time': 'Il y a 2 heures', 'icon': Icons.video_library},
                  {'action': 'Personnage mis à jour', 'time': 'Il y a 5 heures', 'icon': Icons.person},
                  {'action': 'Actualité publiée', 'time': 'Il y a 1 jour', 'icon': Icons.article},
                ];
                final activity = activities[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: SimpsonsColors.lightYellow,
                    child: Icon(activity['icon'] as IconData, color: SimpsonsColors.blue),
                  ),
                  title: Text(activity['action'] as String),
                  subtitle: Text(activity['time'] as String),
                  contentPadding: EdgeInsets.zero,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAddEpisodeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const AddEpisodeDialog(),
    );
  }

  void _showAddCharacterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const AddCharacterDialog(),
    );
  }

  void _showAddNewsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const AddNewsDialog(),
    );
  }

  void _showStatsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Statistiques détaillées'),
        content: const Text('Fonctionnalité en cours de développement...'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }
}

// Gestion des actualités
class NewsManagement extends StatelessWidget {
  const NewsManagement({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DatabaseService>(
      builder: (context, dbService, child) {
        return Scaffold(
          body: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: dbService.news.length,
            itemBuilder: (context, index) {
              final news = dbService.news[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  title: Text(news.title),
                  subtitle: Text('Par ${news.author} - ${_formatDate(news.publishedAt)}'),
                  trailing: PopupMenuButton(
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: 'edit', child: Text('Modifier')),
                      const PopupMenuItem(value: 'delete', child: Text('Supprimer')),
                    ],
                    onSelected: (value) {
                      if (value == 'delete') {
                        _showDeleteConfirmation(context, news.id, 'actualité');
                      }
                    },
                  ),
                ),
              );
            },
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _showAddNewsDialog(context),
            backgroundColor: SimpsonsColors.blue,
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }

  void _showAddNewsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const AddNewsDialog(),
    );
  }

  void _showDeleteConfirmation(BuildContext context, String id, String type) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Supprimer $type'),
        content: Text('Êtes-vous sûr de vouloir supprimer cette $type ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

// Gestion des épisodes
class EpisodesManagement extends StatelessWidget {
  const EpisodesManagement({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DatabaseService>(
      builder: (context, dbService, child) {
        return Scaffold(
          body: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: dbService.episodes.length,
            itemBuilder: (context, index) {
              final episode = dbService.episodes[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  title: Text((episode.titleFr?.isNotEmpty == true) ? episode.titleFr! : episode.title),
                  subtitle: Text('S${episode.season}E${episode.episodeNumber}'),
                  trailing: PopupMenuButton(
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: 'edit', child: Text('Modifier')),
                      const PopupMenuItem(value: 'delete', child: Text('Supprimer')),
                    ],
                  ),
                ),
              );
            },
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _showAddEpisodeDialog(context),
            backgroundColor: SimpsonsColors.blue,
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }

  void _showAddEpisodeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const AddEpisodeDialog(),
    );
  }
}

// Gestion des personnages
class CharactersManagement extends StatelessWidget {
  const CharactersManagement({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DatabaseService>(
      builder: (context, dbService, child) {
        return Scaffold(
          body: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: dbService.characters.length,
            itemBuilder: (context, index) {
              final character = dbService.characters[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: SimpsonsColors.yellow,
                    child: Text(
                      character.nameFr.isNotEmpty ? character.nameFr[0] : character.name[0],
                      style: const TextStyle(color: SimpsonsColors.darkBlue),
                    ),
                  ),
                  title: Text(character.nameFr.isNotEmpty ? character.nameFr : character.name),
                  subtitle: Text(character.job),
                  trailing: PopupMenuButton(
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: 'edit', child: Text('Modifier')),
                      const PopupMenuItem(value: 'delete', child: Text('Supprimer')),
                    ],
                  ),
                ),
              );
            },
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _showAddCharacterDialog(context),
            backgroundColor: SimpsonsColors.blue,
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }

  void _showAddCharacterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const AddCharacterDialog(),
    );
  }
}

// Dialogues d'ajout
class AddNewsDialog extends StatefulWidget {
  const AddNewsDialog({super.key});

  @override
  State<AddNewsDialog> createState() => _AddNewsDialogState();
}

class _AddNewsDialogState extends State<AddNewsDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _authorController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Nouvelle actualité'),
      content: SizedBox(
        width: 400,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Titre'),
                validator: (value) => value?.isEmpty == true ? 'Titre requis' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _authorController,
                decoration: const InputDecoration(labelText: 'Auteur'),
                validator: (value) => value?.isEmpty == true ? 'Auteur requis' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _contentController,
                decoration: const InputDecoration(labelText: 'Contenu'),
                maxLines: 4,
                validator: (value) => value?.isEmpty == true ? 'Contenu requis' : null,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: _saveNews,
          child: const Text('Enregistrer'),
        ),
      ],
    );
  }

  void _saveNews() async {
    if (_formKey.currentState!.validate()) {
      final authService = Provider.of<AuthService>(context, listen: false);
      final dbService = Provider.of<DatabaseService>(context, listen: false);
      
      final news = News(
        id: '',
        title: _titleController.text,
        content: _contentController.text,
        author: _authorController.text,
        publishedAt: DateTime.now(),
        tags: [],
      );

      final success = await dbService.createNews(news, authService.token!);
      
      if (success) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Actualité créée avec succès')),
        );
      }
    }
  }
}

class AddEpisodeDialog extends StatefulWidget {
  const AddEpisodeDialog({super.key});

  @override
  State<AddEpisodeDialog> createState() => _AddEpisodeDialogState();
}

class _AddEpisodeDialogState extends State<AddEpisodeDialog> {
  final _titleController = TextEditingController();
  final _titleFrController = TextEditingController();
  final _summaryController = TextEditingController();
  final _seasonController = TextEditingController();
  final _episodeNumberController = TextEditingController();
  final _durationController = TextEditingController(text: '22'); // Valeur par défaut
  
  @override
  void dispose() {
    _titleController.dispose();
    _titleFrController.dispose();
    _summaryController.dispose();
    _seasonController.dispose();
    _episodeNumberController.dispose(); 
    _durationController.dispose(); 
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Ajouter un épisode'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Titre'),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _titleFrController,
              decoration: InputDecoration(labelText: 'Titre français (optionnel)'),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _summaryController,
              decoration: InputDecoration(labelText: 'Résumé (optionnel)'),
              maxLines: 3,
            ),
            SizedBox(height: 16),
            TextField(
              controller: _seasonController,
              decoration: InputDecoration(labelText: 'Saison'),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 16),
            TextField(
              controller: _episodeNumberController,
              decoration: InputDecoration(
                labelText: 'Numéro d\'épisode',
                hintText: 'Ex: 1, 2, 3...',
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 16),
            TextField(
              controller: _durationController,
              decoration: InputDecoration(
                labelText: 'Durée (minutes)',
                hintText: 'Ex: 22',
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: _addEpisode,
          child: Text('Ajouter'),
        ),
      ],
    );
  }

  void _addEpisode() {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Le titre est requis')),
      );
      return;
    }

    if (_seasonController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('La saison est requise')),
      );
      return;
    }

    if (_episodeNumberController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Le numéro d\'épisode est requis')),
      );
      return;
    }

    final episode = Episode(
      id: '', 
      season: int.tryParse(_seasonController.text) ?? 1,
      episodeNumber: int.tryParse(_episodeNumberController.text) ?? 1,
      title: _titleController.text.trim(),
      titleFr: _titleFrController.text.trim().isEmpty ? null : _titleFrController.text.trim(),
      summary: _summaryController.text.trim().isEmpty ? null : _summaryController.text.trim(),
      characters: [], 
      mainCharacters: [], 
      duration: int.tryParse(_durationController.text) ?? 22,
      views: 0,
      tags: [],
      isSpecial: false,
      trivia: [],
      guestStars: [],
      culturalReferences: [],
      quotes: [],
      airDate: null,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    Navigator.of(context).pop(episode);
  }
}

class AddCharacterDialog extends StatefulWidget {
  const AddCharacterDialog({super.key});

  @override
  State<AddCharacterDialog> createState() => _AddCharacterDialogState();
}

class _AddCharacterDialogState extends State<AddCharacterDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _nameFrController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _jobController = TextEditingController();
  final _familyController = TextEditingController();
  bool _isMajor = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Nouveau personnage'),
      content: SizedBox(
        width: 400,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Nom original'),
                  validator: (value) => value?.isEmpty == true ? 'Nom requis' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nameFrController,
                  decoration: const InputDecoration(labelText: 'Nom français'),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _jobController,
                  decoration: const InputDecoration(labelText: 'Métier'),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _familyController,
                  decoration: const InputDecoration(labelText: 'Famille'),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                  maxLines: 3,
                  validator: (value) => value?.isEmpty == true ? 'Description requise' : null,
                ),
                const SizedBox(height: 16),
                CheckboxListTile(
                  title: const Text('Personnage principal'),
                  value: _isMajor,
                  onChanged: (value) => setState(() => _isMajor = value ?? false),
                  contentPadding: EdgeInsets.zero,
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: _saveCharacter,
          child: const Text('Enregistrer'),
        ),
      ],
    );
  }

  void _saveCharacter() async {
    if (_formKey.currentState!.validate()) {
      final authService = Provider.of<AuthService>(context, listen: false);
      final dbService = Provider.of<DatabaseService>(context, listen: false);
      
      final character = Character(
        id: '',
        name: _nameController.text,
        nameFr: _nameFrController.text,
        description: _descriptionController.text,
        episodes: [],
        family: _familyController.text,
        job: _jobController.text,
        isMajor: _isMajor,
      );

      final success = await dbService.createCharacter(character, authService.token!);
      
      if (success) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Personnage créé avec succès')),
        );
      }
    }
  }
}