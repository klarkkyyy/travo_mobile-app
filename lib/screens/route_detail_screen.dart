import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/route_post.dart';
import '../theme/app_theme.dart';

class RouteDetailScreen extends StatefulWidget {
  const RouteDetailScreen({super.key});

  @override
  State<RouteDetailScreen> createState() => _RouteDetailScreenState();
}

class _RouteDetailScreenState extends State<RouteDetailScreen> {
  final uid = FirebaseAuth.instance.currentUser?.uid;

  int _selectedStars = 0;
  int _submittedStars = 0;
  bool _isSubmitting = false;
  double _avgStars = 0;
  int _ratingCount = 0;
  bool _ratingsLoaded = false;
  String? _posterName;

  Future<void> _loadPosterName(String postedByUid) async {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(postedByUid)
        .get();
    if (mounted && doc.exists) {
      setState(() => _posterName = doc.data()?['name'] ?? 'Unknown');
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final post = ModalRoute.of(context)!.settings.arguments as RoutePost;
    _loadRatings(post.id);
    _loadPosterName(post.postedBy);
  }

  Future<void> _loadRatings(String routeId) async {
    if (uid == null) return;

    final ratingsSnap = await FirebaseFirestore.instance
        .collection('routes')
        .doc(routeId)
        .collection('ratings')
        .get();

    double avg = 0;
    if (ratingsSnap.docs.isNotEmpty) {
      final total = ratingsSnap.docs.fold<double>(
        0,
        (sum, doc) => sum + ((doc.data())['value'] ?? 0),
      );
      avg = total / ratingsSnap.docs.length;
    }

    final myRating = ratingsSnap.docs
        .where((doc) => doc.id == uid)
        .firstOrNull;

    if (mounted) {
      setState(() {
        _avgStars = avg;
        _ratingCount = ratingsSnap.docs.length;
        _submittedStars = myRating != null
            ? ((myRating.data()['value'] as num?) ?? 0).toInt()
            : 0;
        _selectedStars = _submittedStars;
        _ratingsLoaded = true;
      });
    }
  }

  Future<void> _submitRating(RoutePost post) async {
    if (uid == null || _selectedStars == 0 || _isSubmitting) return;

    setState(() => _isSubmitting = true);

    final routeRef =
        FirebaseFirestore.instance.collection('routes').doc(post.id);

    try {
      await routeRef.collection('ratings').doc(uid).set({
        'value': _selectedStars,
        'ratedAt': FieldValue.serverTimestamp(),
      });

      final ratingsSnap = await routeRef.collection('ratings').get();
      final total = ratingsSnap.docs.fold<double>(
        0,
        (sum, doc) =>
            sum + ((doc.data())['value'] as num? ?? 0).toDouble(),
      );
      final newAvg = total / ratingsSnap.docs.length;
      await routeRef.update({
        'stars': newAvg.toDouble(),
        'ratingCount': ratingsSnap.docs.length,
      });

      await routeRef.update({'stars': newAvg.toDouble()});

      if (mounted) {
        final cs = Theme.of(context).colorScheme;
        setState(() {
          _submittedStars = _selectedStars;
          _avgStars = newAvg;
          _ratingCount = ratingsSnap.docs.length;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _submittedStars > 0 ? 'Rating updated!' : 'Rating submitted!',
            ),
            backgroundColor: cs.primary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to submit rating. Try again.'),
            backgroundColor: AppTheme.errorRed,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  // ── Widgets ────────────────────────────────────────────────────────────────

  Widget _buildTag(String label) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: cs.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: cs.primary.withOpacity(0.2)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: cs.primary,
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: cs.primary),
          const SizedBox(width: 10),
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: cs.onSurface,
              fontFamily: 'Poppins',
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13,
                color: cs.onSurface.withOpacity(0.5),
                fontFamily: 'Poppins',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepCard(RouteStep step, int index) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : Colors.grey[50],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: cs.outline.withOpacity(0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: cs.primary,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '${index + 1}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: cs.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        step.jeepCode,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: cs.primary,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      step.fare,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: cs.onSurface,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  step.description,
                  style: TextStyle(
                    fontSize: 13,
                    color: cs.onSurface.withOpacity(0.5),
                    fontFamily: 'Poppins',
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingSection(RoutePost post) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.outline.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Rate this route',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: cs.onSurface,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 4),

          if (_ratingsLoaded)
            Text(
              _ratingCount == 0
                  ? 'No ratings yet — be the first!'
                  : 'Average: ${_avgStars.toStringAsFixed(1)} ($_ratingCount ${_ratingCount == 1 ? 'rating' : 'ratings'})',
              style: TextStyle(
                fontSize: 12,
                color: cs.onSurface.withOpacity(0.4),
                fontFamily: 'Poppins',
              ),
            ),
          const SizedBox(height: 12),

          Row(
            children: List.generate(5, (i) {
              final starValue = i + 1;
              return GestureDetector(
                onTap: () => setState(() => _selectedStars = starValue),
                child: Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: Icon(
                    _selectedStars >= starValue
                        ? Icons.star_rounded
                        : Icons.star_outline_rounded,
                    size: 32,
                    color: _selectedStars >= starValue
                        ? const Color(0xFFEF9F27)
                        : cs.onSurface.withOpacity(0.2),
                  ),
                ),
              );
            }),
          ),
          if (_selectedStars > 0) ...[
            const SizedBox(height: 6),
            Text(
              ['', 'Poor', 'Fair', 'Good', 'Very Good', 'Excellent']
                  [_selectedStars],
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFFEF9F27),
                fontWeight: FontWeight.w500,
                fontFamily: 'Poppins',
              ),
            ),
          ],
          const SizedBox(height: 14),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _selectedStars == 0 || _isSubmitting
                  ? null
                  : () => _submitRating(post),
              child: _isSubmitting
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2),
                    )
                  : Text(
                      _submittedStars > 0 ? 'Update Rating' : 'Submit Rating',
                    ),
            ),
          ),

          if (_submittedStars > 0) ...[
            const SizedBox(height: 8),
            Center(
              child: Text(
                'Your current rating: $_submittedStars★',
                style: TextStyle(
                  fontSize: 12,
                  color: cs.onSurface.withOpacity(0.4),
                  fontFamily: 'Poppins',
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final post = ModalRoute.of(context)!.settings.arguments as RoutePost;

    final cardColor = isDark ? AppTheme.darkCard : Colors.white;
    final cardBorder = cs.outline.withOpacity(0.2);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Route Details'),
        titleSpacing: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Route header card ────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: cardBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoRow(
                      Icons.location_on_rounded, 'From', post.origin),
                  _buildInfoRow(Icons.flag_rounded, 'To', post.destination),
                  _buildInfoRow(
                    Icons.payments_outlined,
                    'Total fare',
                    'P${post.fare}',
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: post.tags.map(_buildTag).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // ── Steps ────────────────────────────────────────────────────
            if (post.steps.isNotEmpty) ...[
              Text(
                'How to get there',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: cs.onSurface,
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 10),
              ...post.steps.asMap().entries.map(
                    (e) => _buildStepCard(e.value, e.key),
                  ),
              const SizedBox(height: 4),
            ],

            // ── Tips ─────────────────────────────────────────────────────
            if (post.tips.isNotEmpty) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF2A2210)
                      : const Color(0xFFFFFBEB),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isDark
                        ? const Color(0xFF5C4A00)
                        : const Color(0xFFFDE68A),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('💡', style: TextStyle(fontSize: 16)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        post.tips,
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark
                              ? const Color(0xFFE5C97A)
                              : const Color(0xFF92400E),
                          fontFamily: 'Poppins',
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],

            // ── Posted by ─────────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: cardBorder),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: cs.surfaceContainerHighest,
                    radius: 18,
                    child: Icon(Icons.person_rounded,
                        color: cs.onSurface.withOpacity(0.4), size: 20),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _posterName ?? post.postedByName,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: cs.onSurface,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      Text(
                        'Posted ${_formatDate(post.createdAt)}',
                        style: TextStyle(
                          fontSize: 11,
                          color: cs.onSurface.withOpacity(0.35),
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // ── Rating section ─────────────────────────────────────────────
            _buildRatingSection(post),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays == 0) return 'today';
    if (diff.inDays == 1) return 'yesterday';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    if (diff.inDays < 30) return '${(diff.inDays / 7).floor()} weeks ago';
    if (diff.inDays < 365) return '${(diff.inDays / 30).floor()} months ago';
    return '${(diff.inDays / 365).floor()} years ago';
  }
}