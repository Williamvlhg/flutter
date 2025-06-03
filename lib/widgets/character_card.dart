import 'package:flutter/material.dart';
import '../models/character.dart';
import '../utils/theme.dart';

class CharacterCard extends StatelessWidget {
  final Character character;
  final VoidCallback onTap;

  const CharacterCard({
    super.key,
    required this.character,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: const BorderSide(color: SimpsonsColors.orange, width: 1),
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
            crossAxisAlignment: CrossAxisAlignment.center,
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
              const SizedBox(height: 12),
              Text(
                character.nameFr.isNotEmpty ? character.nameFr : character.name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: SimpsonsColors.darkBlue,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
              if (character.job.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  character.job,
                  style: const TextStyle(
                    fontSize: 12,
                    color: SimpsonsColors.blue,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: 8),
              Text(
                character.description,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.black87,
                  height: 1.3,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (character.isMajor)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: SimpsonsColors.orange,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        'Principal',
                        style: TextStyle(
                          fontSize: 10,
                          color: SimpsonsColors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  const SizedBox(width: 8),
                  Text(
                    '${character.episodes.length} épisodes',
                    style: const TextStyle(
                      fontSize: 11,
                      color: SimpsonsColors.blue,
                      fontWeight: FontWeight.w500,
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
}