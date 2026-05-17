import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/route_post.dart';
import '../theme/app_theme.dart';

class ProfileScreen extends StatefulWidget {
  final bool isDarkMode;
  final ValueChanged<bool> onDarkModeToggle;

  const ProfileScreen({
    super.key,
    required this.isDarkMode,
    required this.onDarkModeToggle,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  final _user = FirebaseAuth.instance.currentUser;
  late TabController _tabController;

  String _displayName = '';
  String _photoUrl = '';
  bool _loadingProfile = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadProfile();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    if (_user == null) return;
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(_user.uid)
        .get();
    final data = doc.data() ?? {};
    setState(() {
      _displayName = data['displayName'] ?? _user.displayName ?? 'User';
      _photoUrl = data['photoUrl'] ?? _user.photoURL ?? '';
      _loadingProfile = false;
    });
  }

  // ── Edit photo URL dialog ─────────────────────────────────────────────────
  void _editPhotoUrl() {
    final ctrl = TextEditingController(text: _photoUrl);
    final cs = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Profile picture URL',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            fontSize: 15,
            color: cs.onSurface,
          ),
        ),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 13,
            color: cs.onSurface,
          ),
          decoration: InputDecoration(
            hintText: 'https://example.com/photo.jpg',
            hintStyle: TextStyle(
              color: cs.onSurface.withOpacity(0.4),
              fontSize: 13,
              fontFamily: 'Poppins',
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel',
                style: TextStyle(
                    color: cs.onSurface.withOpacity(0.5),
                    fontFamily: 'Poppins')),
          ),
          if (_photoUrl.isNotEmpty)
            TextButton(
              onPressed: () async {
                await _savePhotoUrl('');
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text('Remove',
                  style: TextStyle(
                      color: AppTheme.errorRed, fontFamily: 'Poppins')),
            ),
          TextButton(
            onPressed: () async {
              await _savePhotoUrl(ctrl.text.trim());
              if (context.mounted) Navigator.pop(context);
            },
            child: Text('Save',
                style: TextStyle(
                    color: cs.primary,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Future<void> _savePhotoUrl(String url) async {
    if (_user == null) return;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(_user.uid)
        .update({'photoUrl': url});
    setState(() => _photoUrl = url);
  }

  // ── Logout ────────────────────────────────────────────────────────────────
  Future<void> _logout() async {
    final cs = Theme.of(context).colorScheme;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Log out?',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            color: cs.onSurface,
          ),
        ),
        content: Text(
          'You will be returned to the login screen.',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 13,
            color: cs.onSurface.withOpacity(0.6),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel',
                style: TextStyle(
                    color: cs.onSurface.withOpacity(0.5),
                    fontFamily: 'Poppins')),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Log out',
                style: TextStyle(
                    color: AppTheme.errorRed,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await FirebaseAuth.instance.signOut();
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
      }
    }
  }

  // ── Avatar widget ─────────────────────────────────────────────────────────
  Widget _buildAvatar() {
    final cs = Theme.of(context).colorScheme;
    return Stack(
      alignment: Alignment.center,
      children: [
        CircleAvatar(
          radius: 44,
          backgroundColor: cs.surfaceContainerHighest,
          backgroundImage:
              _photoUrl.isNotEmpty ? NetworkImage(_photoUrl) : null,
          child: _photoUrl.isEmpty
              ? Icon(Icons.person_rounded,
                  size: 44, color: cs.onSurface.withOpacity(0.4))
              : null,
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: GestureDetector(
            onTap: _editPhotoUrl,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: cs.primary,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  width: 2,
                ),
              ),
              child: const Icon(Icons.edit_rounded,
                  size: 12, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  // ── Post list ─────────────────────────────────────────────────────────────
  Widget _buildPostList(List<RoutePost> posts) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (posts.isEmpty) {
      return Center(
        child: Text(
          'Nothing here yet.',
          style: TextStyle(
            fontFamily: 'Poppins',
            color: cs.onSurface.withOpacity(0.4),
          ),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
      itemCount: posts.length,
      itemBuilder: (_, i) {
        final post = posts[i];
        final cardColor = isDark ? AppTheme.darkCard : Colors.white;
        final borderColor = cs.outline.withOpacity(isDark ? 0.25 : 0.15);
        final tagBg = isDark ? AppTheme.darkBorder : Colors.grey[100]!;

        return GestureDetector(
          onTap: () =>
              Navigator.pushNamed(context, '/route-detail', arguments: post),
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.location_on_rounded,
                        color: cs.primary, size: 16),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        post.destination,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Poppins',
                          color: cs.onSurface,
                        ),
                      ),
                    ),
                    Text(
                      'P${post.fare}',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Poppins',
                        color: cs.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'From ${post.origin}',
                  style: TextStyle(
                    fontSize: 12,
                    fontFamily: 'Poppins',
                    color: cs.onSurface.withOpacity(0.5),
                  ),
                ),
                if (post.tags.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: post.tags
                        .map((tag) => Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: tagBg,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                tag,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontFamily: 'Poppins',
                                  color: cs.onSurface.withOpacity(0.6),
                                ),
                              ),
                            ))
                        .toList(),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  // ── Saved tab ─────────────────────────────────────────────────────────────
  Widget _buildSavedTab() {
    if (_user == null) return const SizedBox();
    final cs = Theme.of(context).colorScheme;
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(_user.uid)
          .collection('saved')
          .snapshots(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final savedIds = snap.data?.docs.map((d) => d.id).toList() ?? [];
        if (savedIds.isEmpty) {
          return Center(
            child: Text(
              'No saved routes yet.',
              style: TextStyle(
                fontFamily: 'Poppins',
                color: cs.onSurface.withOpacity(0.4),
              ),
            ),
          );
        }
        return FutureBuilder<List<RoutePost>>(
          future: Future.wait(
            savedIds.map((id) => FirebaseFirestore.instance
                .collection('routes')
                .doc(id)
                .get()
                .then((d) => d.exists ? RoutePost.fromDoc(d) : null)),
          ).then((list) => list.whereType<RoutePost>().toList()),
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            return _buildPostList(snap.data ?? []);
          },
        );
      },
    );
  }

  // ── My posts tab ──────────────────────────────────────────────────────────
  Widget _buildMyPostsTab() {
    if (_user == null) return const SizedBox();
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('routes')
          .where('postedBy', isEqualTo: _user.uid)
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final posts =
            snap.data?.docs.map(RoutePost.fromDoc).toList() ?? [];
        return _buildPostList(posts);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Profile',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: cs.onSurface,
            fontFamily: 'Poppins',
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, size: 18, color: cs.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _loadingProfile
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // ── Profile header ────────────────────────────────────────
                Container(
                  // AppBar surface color as background for the header block
                  color: Theme.of(context).appBarTheme.backgroundColor,
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: Column(
                    children: [
                      _buildAvatar(),
                      const SizedBox(height: 12),
                      Text(
                        _displayName,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Poppins',
                          color: cs.onSurface,
                        ),
                      ),
                      Text(
                        _user?.email ?? '',
                        style: TextStyle(
                          fontSize: 12,
                          fontFamily: 'Poppins',
                          color: cs.onSurface.withOpacity(0.5),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // ── Dark mode toggle ────────────────────────────────
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppTheme.darkCard
                              : Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: cs.outline.withOpacity(0.2)),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              isDark
                                  ? Icons.dark_mode_rounded
                                  : Icons.light_mode_rounded,
                              size: 18,
                              color: cs.primary,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Dark mode',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w500,
                                  color: cs.onSurface,
                                ),
                              ),
                            ),
                            Switch(
                              value: widget.isDarkMode,
                              onChanged: widget.onDarkModeToggle,
                              activeColor: cs.primary,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),

                      // ── Log out button ──────────────────────────────────
                      GestureDetector(
                        onTap: _logout,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppTheme.darkCard
                                : Colors.grey[50],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: cs.outline.withOpacity(0.2)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.logout_rounded,
                                  size: 18, color: AppTheme.errorRed),
                              const SizedBox(width: 10),
                              Text(
                                'Log out',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w500,
                                  color: cs.onSurface,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // ── Tab bar ─────────────────────────────────────────
                      TabBar(
                        controller: _tabController,
                        labelColor: cs.primary,
                        unselectedLabelColor: cs.onSurface.withOpacity(0.5),
                        indicatorColor: cs.primary,
                        labelStyle: const TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                        unselectedLabelStyle: const TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w400,
                          fontSize: 13,
                        ),
                        tabs: const [
                          Tab(text: 'Saved'),
                          Tab(text: 'My Posts'),
                        ],
                      ),
                    ],
                  ),
                ),

                // ── Tab views ─────────────────────────────────────────────
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildSavedTab(),
                      _buildMyPostsTab(),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}