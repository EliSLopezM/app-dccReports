import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/content_post.dart';

/// RF-1/RF-2: contenido completo de una publicación.
class ContentDetailScreen extends StatelessWidget {
  const ContentDetailScreen({super.key, required this.post});

  final ContentPost post;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(post.title)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (post.photoUrl != null)
            CachedNetworkImage(
              key: const Key('content-detail-photo'),
              imageUrl: post.photoUrl!,
            ),
          const SizedBox(height: 16),
          Text(post.body, key: const Key('content-detail-body')),
        ],
      ),
    );
  }
}
