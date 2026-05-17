import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/route_post.dart';
import '../theme/app_theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _sortBy = 'stars';
  String _searchQuery = '';
  final Set<String> _activeTagFilters = {};
  bool _showSearch = false;
  final _searchCtrl = TextEditingController();

  final Set<String> _availableTags = {};

  Stream<List<RoutePost>> _routesStream() {
    return FirebaseFirestore.instance
        .collection('routes')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(RoutePost.fromDoc).toList());
  }

  List<RoutePost> _applyFilters(List<RoutePost> posts) {
    var filtered = posts;

    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      filtered = filtered
          .where((p) =>
              p.destination.toLowerCase().contains(q) ||
              p.origin.toLowerCase().contains(q))
          .toList();
    }

    if (_activeTagFilters.isNotEmpty) {
      filtered = filtered
          .where((p) => _activeTagFilters.any((t) => p.tags.contains(t)))
          .toList();
    }

    filtered.sort((a, b) {
      switch (_sortBy) {
        case 'stars':
          return b.stars.compareTo(a.stars);
        case 'upvotes':
          return b.upvotes.compareTo(a.upvotes);
        case 'fare':
          return a.fare.compareTo(b.fare);
        case 'createdAt':
        default:
          return b.createdAt.compareTo(a.createdAt);
      }
    });

    return filtered;
  }

  Widget _buildSortChip(String label, String value) {
    final cs = Theme.of(context).colorScheme;
    final active = _sortBy == value;
    return GestureDetector(
      onTap: () => setState(() => _sortBy = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: active ? cs.primary : Colors.transparent,
          border: Border.all(
            color: active ? cs.primary : cs.outline.withOpacity(0.4),
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: active ? FontWeight.w600 : FontWeight.w400,
            color: active ? Colors.white : cs.onSurface.withOpacity(0.6),
            fontFamily: 'Poppins',
          ),
        ),
      ),
    );
  }

  Widget _buildTagChip(String tag) {
    final cs = Theme.of(context).colorScheme;
    final active = _activeTagFilters.contains(tag);
    return GestureDetector(
      onTap: () => setState(() =>
          active ? _activeTagFilters.remove(tag) : _activeTagFilters.add(tag)),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: active ? cs.primary.withOpacity(0.12) : Colors.transparent,
          border: Border.all(
            color: active ? cs.primary : cs.outline.withOpacity(0.4),
          ),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(
          '#$tag',
          style: TextStyle(
            fontSize: 11,
            fontWeight: active ? FontWeight.w600 : FontWeight.w400,
            color: active ? cs.primary : cs.onSurface.withOpacity(0.5),
            fontFamily: 'Poppins',
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: _showSearch
            ? TextField(
                controller: _searchCtrl,
                autofocus: true,
                style: TextStyle(
                    fontSize: 15,
                    fontFamily: 'Poppins',
                    color: cs.onSurface),
                decoration: InputDecoration(
                  hintText: 'Search destination or origin…',
                  hintStyle: TextStyle(
                      fontSize: 14,
                      color: cs.onSurface.withOpacity(0.4),
                      fontFamily: 'Poppins'),
                  border: InputBorder.none,
                ),
                onChanged: (v) => setState(() => _searchQuery = v),
              )
            : Text(
                'Feed',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: cs.onSurface,
                  fontFamily: 'Poppins',
                ),
              ),
        centerTitle: !_showSearch,
        leading: _showSearch
            ? IconButton(
                icon: Icon(Icons.arrow_back_ios,
                    size: 18, color: cs.onSurface),
                onPressed: () => setState(() {
                  _showSearch = false;
                  _searchQuery = '';
                  _searchCtrl.clear();
                }),
              )
            : GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/profile'),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: CircleAvatar(
                    backgroundColor: cs.surfaceContainerHighest,
                    radius: 16,
                    child: Icon(
                      Icons.person_rounded,
                      color: cs.onSurface.withOpacity(0.5),
                      size: 20,
                    ),
                  ),
                ),
              ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: IconButton(
              icon: Icon(
                _showSearch ? Icons.close : Icons.search,
                color: cs.onSurface,
              ),
              onPressed: () {
                if (_showSearch) {
                  setState(() {
                    _showSearch = false;
                    _searchQuery = '';
                    _searchCtrl.clear();
                  });
                } else {
                  setState(() => _showSearch = true);
                }
              },
            ),
          ),
        ],
      ),
      body: StreamBuilder<List<RoutePost>>(
        stream: _routesStream(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text('Error: ${snap.error}'));
          }

          final allPosts = snap.data ?? [];

          for (final p in allPosts) {
            _availableTags.addAll(p.tags);
          }

          final posts = _applyFilters(allPosts);

          return Column(
            children: [
              // ── Sort chips ─────────────────────────────────────────────
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  children: [
                    _buildSortChip('Top rated', 'stars'),
                    const SizedBox(width: 8),
                    _buildSortChip('Most upvoted', 'upvotes'),
                    const SizedBox(width: 8),
                    _buildSortChip('Newest', 'createdAt'),
                    const SizedBox(width: 8),
                    _buildSortChip('Lowest fare', 'fare'),
                  ],
                ),
              ),

              // ── Tag filter chips ───────────────────────────────────────
              if (_availableTags.isNotEmpty)
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                  child: Row(
                    children: _availableTags
                        .toList()
                        .map((t) => Padding(
                              padding: const EdgeInsets.only(right: 6),
                              child: _buildTagChip(t),
                            ))
                        .toList(),
                  ),
                ),

              // ── Post list ──────────────────────────────────────────────
              Expanded(
                child: posts.isEmpty
                    ? Center(
                        child: Text(
                          _searchQuery.isNotEmpty ||
                                  _activeTagFilters.isNotEmpty
                              ? 'No routes match your filters.'
                              : 'No routes yet. Be the first to post!',
                          style: TextStyle(
                              color: cs.onSurface.withOpacity(0.4),
                              fontFamily: 'Poppins'),
                        ),
                      )
                    : ListView.builder(
                        padding:
                            const EdgeInsets.fromLTRB(16, 4, 16, 80),
                        itemCount: posts.length,
                        itemBuilder: (_, i) => RouteCard(
                          key: ValueKey(posts[i].id),
                          post: posts[i],
                        ),
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () => Navigator.pushNamed(context, '/post-route'),
      ),
    );
  }
}

// ─── Route Card ───────────────────────────────────────────────────────────────

class RouteCard extends StatefulWidget {
  final RoutePost post;
  const RouteCard({super.key, required this.post});

  @override
  State<RouteCard> createState() => _RouteCardState();
}

class _RouteCardState extends State<RouteCard> {
  final _currentUid = FirebaseAuth.instance.currentUser?.uid;

  bool _hasVoted = false;
  bool _isSaved = false;
  bool _voteLoading = false;

  int? _upvoteCount;
  double? _avgStars;
  int? _ratingCount;

  bool get _isMyPost =>
      _currentUid != null && _currentUid == widget.post.postedBy;

  @override
  void initState() {
    super.initState();
    _loadInitialState();
  }

  Future<void> _loadInitialState() async {
    if (_currentUid == null) return;

    final routeRef = FirebaseFirestore.instance
        .collection('routes')
        .doc(widget.post.id);

    final results = await Future.wait([
      routeRef.collection('votes').doc(_currentUid).get(),
      routeRef.collection('votes').get(),
      routeRef.collection('ratings').get(),
      FirebaseFirestore.instance
          .collection('users')
          .doc(_currentUid)
          .collection('saved')
          .doc(widget.post.id)
          .get(),
    ]);

    final voteDoc = results[0] as DocumentSnapshot;
    final votesSnap = results[1] as QuerySnapshot;
    final ratingsSnap = results[2] as QuerySnapshot;
    final saveDoc = results[3] as DocumentSnapshot;

    double avg = 0;
    if (ratingsSnap.docs.isNotEmpty) {
      final total = ratingsSnap.docs.fold<double>(
        0,
        (sum, doc) =>
            sum + ((doc.data() as Map<String, dynamic>)['value'] ?? 0),
      );
      avg = total / ratingsSnap.docs.length;
    }

    if (mounted) {
      setState(() {
        _hasVoted = voteDoc.exists;
        _isSaved = saveDoc.exists;
        _upvoteCount = votesSnap.docs.length;
        _avgStars = avg;
        _ratingCount = ratingsSnap.docs.length;
      });
    }
  }

  Future<void> _toggleVote() async {
    if (_currentUid == null || _voteLoading) return;

    final newHasVoted = !_hasVoted;
    final newCount = (_upvoteCount ?? 0) + (newHasVoted ? 1 : -1);

    setState(() {
      _voteLoading = true;
      _hasVoted = newHasVoted;
      _upvoteCount = newCount;
    });

    final ref = FirebaseFirestore.instance
        .collection('routes')
        .doc(widget.post.id);
    final voteRef = ref.collection('votes').doc(_currentUid);

    try {
      if (newHasVoted) {
        await voteRef.set({'votedAt': FieldValue.serverTimestamp()});
        await ref.update({'upvotes': FieldValue.increment(1)});
      } else {
        await voteRef.delete();
        await ref.update({'upvotes': FieldValue.increment(-1)});
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _hasVoted = !newHasVoted;
          _upvoteCount = (_upvoteCount ?? 0) + (newHasVoted ? -1 : 1);
        });
      }
    } finally {
      if (mounted) setState(() => _voteLoading = false);
    }
  }

  Future<void> _toggleSave() async {
    if (_currentUid == null) return;
    setState(() => _isSaved = !_isSaved);
    final saveRef = FirebaseFirestore.instance
        .collection('users')
        .doc(_currentUid)
        .collection('saved')
        .doc(widget.post.id);
    try {
      if (_isSaved) {
        await saveRef.set({'savedAt': FieldValue.serverTimestamp()});
      } else {
        await saveRef.delete();
      }
    } catch (_) {
      if (mounted) setState(() => _isSaved = !_isSaved);
    }
  }

  Future<void> _deletePost() async {
    final cs = Theme.of(context).colorScheme;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Delete route?',
            style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
                color: cs.onSurface)),
        content: Text(
          'This will permanently remove your posted route.',
          style: TextStyle(
              fontFamily: 'Poppins', fontSize: 13, color: cs.onSurface),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel',
                style: TextStyle(
                    color: cs.onSurface.withOpacity(0.6),
                    fontFamily: 'Poppins')),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete',
                style: TextStyle(
                    color: Colors.red,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await FirebaseFirestore.instance
          .collection('routes')
          .doc(widget.post.id)
          .delete();
    }
  }

  void _editPost() {
    Navigator.pushNamed(context, '/edit-route', arguments: widget.post)
        .then((_) {
      if (mounted) _loadInitialState();
    });
  }

  // ── Star row ──────────────────────────────────────────────────────────────
  Widget _buildStars() {
    final cs = Theme.of(context).colorScheme;

    if (_avgStars == null) {
      return Row(
        children: [
          ...List.generate(
            5,
            (_) => Icon(Icons.star_outline_rounded,
                size: 14, color: cs.onSurface.withOpacity(0.3)),
          ),
          const SizedBox(width: 4),
          Text('—',
              style: TextStyle(
                  fontSize: 12, color: cs.onSurface.withOpacity(0.3))),
        ],
      );
    }

    final avg = _avgStars!;
    final count = _ratingCount ?? 0;

    return Row(
      children: [
        ...List.generate(5, (i) {
          if (avg >= i + 1) {
            return const Icon(Icons.star_rounded,
                size: 14, color: Color(0xFFEF9F27));
          } else if (avg >= i + 0.5) {
            return const Icon(Icons.star_half_rounded,
                size: 14, color: Color(0xFFEF9F27));
          } else {
            return const Icon(Icons.star_outline_rounded,
                size: 14, color: Color(0xFFEF9F27));
          }
        }),
        const SizedBox(width: 4),
        Text(
          avg == 0 ? 'No ratings' : '${avg.toStringAsFixed(1)} ($count)',
          style: TextStyle(
              fontSize: 12, color: cs.onSurface.withOpacity(0.5)),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final post = widget.post;

    // Card surface: slightly elevated from the scaffold background
    final cardColor = isDark
        ? AppTheme.darkCard
        : Colors.white;
    final borderColor = _isMyPost
        ? cs.primary.withOpacity(0.3)
        : cs.outline.withOpacity(isDark ? 0.25 : 0.2);
    final tagBg = isDark ? AppTheme.darkBorder : Colors.grey[100]!;
    final tagText = cs.onSurface.withOpacity(0.6);

    return GestureDetector(
      onTap: () async {
        await Navigator.pushNamed(context, '/route-detail', arguments: post);
        if (mounted) _loadInitialState();
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: borderColor,
            width: _isMyPost ? 1.5 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header row ─────────────────────────────────────────────
            Row(
              children: [
                Icon(Icons.location_on_rounded, color: cs.primary, size: 18),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    post.destination,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: cs.onSurface,
                    ),
                  ),
                ),
                if (_isMyPost) ...[
                  PopupMenuButton<String>(
                    onSelected: (v) {
                      if (v == 'edit') _editPost();
                      if (v == 'delete') _deletePost();
                    },
                    icon: Icon(Icons.more_vert_rounded,
                        size: 18, color: cs.onSurface.withOpacity(0.4)),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    itemBuilder: (_) => [
                      PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit_outlined,
                                size: 16, color: cs.primary),
                            const SizedBox(width: 8),
                            const Text('Edit',
                                style: TextStyle(
                                    fontFamily: 'Poppins', fontSize: 13)),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete_outline_rounded,
                                size: 16, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Delete',
                                style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 13,
                                    color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ] else ...[
                  IconButton(
                    icon: Icon(
                      _isSaved
                          ? Icons.bookmark_rounded
                          : Icons.bookmark_outline_rounded,
                      color:
                          _isSaved ? cs.primary : cs.onSurface.withOpacity(0.4),
                    ),
                    iconSize: 20,
                    onPressed: _toggleSave,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ],
            ),

            // ── Posted by row ──────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.only(top: 2, bottom: 6),
              child: Row(
                children: [
                  if (_isMyPost) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: cs.primary,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'You',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),
                  ] else ...[
                    Icon(Icons.person_outline_rounded,
                        size: 13, color: cs.onSurface.withOpacity(0.4)),
                    const SizedBox(width: 3),
                    Text(
                      post.postedByName.isNotEmpty
                          ? post.postedByName
                          : 'Anonymous',
                      style: TextStyle(
                        fontSize: 12,
                        color: cs.onSurface.withOpacity(0.5),
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // ── Tags ───────────────────────────────────────────────────
            if (post.tags.isNotEmpty)
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: post.tags
                    .map((tag) => Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: tagBg,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                                color: cs.outline.withOpacity(0.2)),
                          ),
                          child: Text(tag,
                              style: TextStyle(
                                  fontSize: 12, color: tagText)),
                        ))
                    .toList(),
              ),
            const SizedBox(height: 10),

            // ── Stars | Fare | Upvotes ─────────────────────────────────
            Row(
              children: [
                _buildStars(),
                const Spacer(),
                Text(
                  'P${post.fare}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: cs.primary,
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: _isMyPost ? null : _toggleVote,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _hasVoted ? cs.primary : Colors.transparent,
                      border: Border.all(
                        color: _hasVoted
                            ? cs.primary
                            : cs.outline.withOpacity(0.4),
                      ),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.arrow_upward_rounded,
                          size: 14,
                          color: _hasVoted
                              ? Colors.white
                              : cs.onSurface.withOpacity(0.5),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _upvoteCount == null ? '—' : '$_upvoteCount',
                          style: TextStyle(
                            fontSize: 12,
                            color: _hasVoted
                                ? Colors.white
                                : cs.onSurface.withOpacity(0.6),
                            fontWeight: _hasVoted
                                ? FontWeight.w600
                                : FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}