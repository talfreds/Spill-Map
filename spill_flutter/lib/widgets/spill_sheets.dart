import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../models/spill_models.dart';
import '../state/map_state.dart';
import 'auth_sheet.dart';

Future<void> showSpillDetailSheet({
  required BuildContext context,
  required WidgetRef ref,
  required String spillId,
}) {
  ref.read(selectedSpillIdProvider.notifier).state = spillId;

  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => SpillDetailSheet(spillId: spillId),
  ).whenComplete(() {
    final selectedId = ref.read(selectedSpillIdProvider);
    if (selectedId == spillId) {
      ref.read(selectedSpillIdProvider.notifier).state = null;
    }
  });
}

class NewSpillSheet extends ConsumerStatefulWidget {
  const NewSpillSheet({
    required this.point,
    super.key,
  });

  final LatLng point;

  @override
  ConsumerState<NewSpillSheet> createState() => _NewSpillSheetState();
}

class _NewSpillSheetState extends ConsumerState<NewSpillSheet> {
  final TextEditingController _messageController = TextEditingController();

  String? _imageUrl;
  bool _isUploadingPhoto = false;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    setState(() {
      _isUploadingPhoto = true;
    });

    try {
      final uploadedUrl = await ref.read(spillServiceProvider).pickAndUploadPhoto();
      if (!mounted) {
        return;
      }

      setState(() {
        _imageUrl = uploadedUrl;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Photo upload failed: $error')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isUploadingPhoto = false;
        });
      }
    }
  }

  Future<void> _submitSpill() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Message is required.')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final spill = await ref.read(spillServiceProvider).createSpill(
            lat: widget.point.latitude,
            lng: widget.point.longitude,
            message: message,
            imageUrl: _imageUrl,
          );

      ref.read(localSpillsProvider.notifier).upsert(spill);

      if (!mounted) {
        return;
      }

      final messenger = ScaffoldMessenger.of(context);
      Navigator.of(context).pop();
      messenger.showSnackBar(
        const SnackBar(content: Text('Spill posted.')),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Create spill failed: $error')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final user = ref.watch(authStateProvider).valueOrNull;

    return FractionallySizedBox(
      heightFactor: 0.8,
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(16, 16, 16, bottomInset + 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'New Spill',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              '${widget.point.latitude.toStringAsFixed(5)}, ${widget.point.longitude.toStringAsFixed(5)}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _messageController,
              minLines: 3,
              maxLines: 5,
              enabled: !_isSubmitting,
              decoration: const InputDecoration(
                labelText: 'What happened here?',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            if (user == null) ...[
              Text(
                'This spill will be posted as ${_displayAnonymousIdentityHint()}. Sign in if you want to attach a photo or use your account identity.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: _isSubmitting || _isUploadingPhoto
                      ? null
                      : () => showAuthSheet(context: context, ref: ref),
                  child: const Text('Sign in or register'),
                ),
              ),
            ],
            OutlinedButton.icon(
              onPressed: _isUploadingPhoto || _isSubmitting || user == null
                  ? null
                  : _pickPhoto,
              icon: const Icon(Icons.photo_library_outlined),
              label: Text(
                user == null
                    ? 'Sign in to add a photo'
                    : (_isUploadingPhoto ? 'Uploading photo...' : 'Add photo'),
              ),
            ),
            const SizedBox(height: 12),
            if (_imageUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  _imageUrl!,
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) {
                    return const SizedBox(
                      height: 180,
                      child: Center(child: Text('Photo attached')),
                    );
                  },
                ),
              )
            else
              Text(
                'No photo attached',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _isSubmitting || _isUploadingPhoto ? null : _submitSpill,
                child: Text(_isSubmitting ? 'Posting...' : 'Post Spill'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SpillDetailSheet extends ConsumerStatefulWidget {
  const SpillDetailSheet({
    required this.spillId,
    super.key,
  });

  final String spillId;

  @override
  ConsumerState<SpillDetailSheet> createState() => _SpillDetailSheetState();
}

class _SpillDetailSheetState extends ConsumerState<SpillDetailSheet> {
  final TextEditingController _commentController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitComment() async {
    final message = _commentController.text.trim();
    if (message.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Comment is required.')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      await ref.read(spillServiceProvider).addComment(
            spillId: widget.spillId,
            message: message,
          );

      _commentController.clear();
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Comment failed: $error')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final spill = ref.watch(spillByIdProvider(widget.spillId));
    final comments = ref.watch(spillCommentsProvider(widget.spillId));
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final user = ref.watch(authStateProvider).valueOrNull;

    return FractionallySizedBox(
      heightFactor: 0.92,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 8, 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Spill Detail',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),
          Expanded(
            child: spill == null
                ? const Center(child: Text('This spill is no longer available.'))
                : ListView(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    children: [
                      _SpillHeader(spill: spill),
                      const SizedBox(height: 24),
                      Text(
                        'Comments',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 12),
                      comments.when(
                        data: (items) {
                          if (items.isEmpty) {
                            return const Text('No comments yet. Start the conversation.');
                          }

                          return Column(
                            children: items
                                .map((comment) => Padding(
                                      padding: const EdgeInsets.only(bottom: 12),
                                      child: _CommentCard(comment: comment),
                                    ))
                                .toList(),
                          );
                        },
                        loading: () => const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Center(child: CircularProgressIndicator()),
                        ),
                        error: (error, _) => Text('Could not load comments: $error'),
                      ),
                    ],
                  ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(16, 12, 16, bottomInset + 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      user == null
                          ? 'Commenting as anonymous.'
                          : 'Commenting as ${user.email ?? user.uid}.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                  if (user == null)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton(
                        onPressed: _isSubmitting
                            ? null
                            : () => showAuthSheet(context: context, ref: ref),
                        child: const Text('Sign in or register'),
                      ),
                    ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _commentController,
                          enabled: !_isSubmitting,
                          minLines: 1,
                          maxLines: 4,
                          decoration: const InputDecoration(
                            labelText: 'Write a comment',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      FilledButton(
                        onPressed: _isSubmitting ? null : _submitComment,
                        child: Text(_isSubmitting ? 'Sending...' : 'Comment'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SpillHeader extends StatelessWidget {
  const _SpillHeader({required this.spill});

  final Spill spill;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          spill.message,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        Text(
          'Posted by ${spill.displayUserName} · ${_formatTimestamp(spill.timestamp)}',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 4),
        Text(
          'Location: ${spill.lat.toStringAsFixed(5)}, ${spill.lng.toStringAsFixed(5)}',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        if (spill.imageUrl != null) ...[
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.network(
              spill.imageUrl!,
              height: 220,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) {
                return const SizedBox(
                  height: 220,
                  child: Center(child: Text('Could not load image.')),
                );
              },
            ),
          ),
        ],
      ],
    );
  }
}

class _CommentCard extends StatelessWidget {
  const _CommentCard({required this.comment});

  final SpillComment comment;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              comment.displayUserName,
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 4),
            Text(comment.message),
            const SizedBox(height: 8),
            Text(
              _formatTimestamp(comment.timestamp),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

String _displayAnonymousIdentityHint() {
  return 'an anonymous profile based on your connection';
}

String _formatTimestamp(DateTime timestamp) {
  final local = timestamp.toLocal();
  final month = local.month.toString().padLeft(2, '0');
  final day = local.day.toString().padLeft(2, '0');
  final hour = local.hour.toString().padLeft(2, '0');
  final minute = local.minute.toString().padLeft(2, '0');
  return '$month/$day ${local.year} $hour:$minute';
}
