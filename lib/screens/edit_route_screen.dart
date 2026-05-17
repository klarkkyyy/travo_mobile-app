import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/route_post.dart';
import '../theme/app_theme.dart';

class EditRouteScreen extends StatefulWidget {
  const EditRouteScreen({super.key});

  @override
  State<EditRouteScreen> createState() => _EditRouteScreenState();
}

class _EditRouteScreenState extends State<EditRouteScreen> {
  final _formKey = GlobalKey<FormState>();

  late RoutePost _post;
  bool _initialized = false;

  final _originCtrl = TextEditingController();
  final _destinationCtrl = TextEditingController();
  final _fareCtrl = TextEditingController();
  final _tipsCtrl = TextEditingController();
  final _customTagCtrl = TextEditingController();

  bool _submitting = false;

  static const _availableTags = [
    '13C', '04B', '62B', 'Ayala', 'SM', 'Carbon',
    'Colon', 'IT Park', 'Bulacao', 'Talisay', 'Mandaue',
  ];
  final Set<String> _selectedTags = {};
  final List<String> _customTags = [];
  final List<_StepEntry> _steps = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _post = ModalRoute.of(context)!.settings.arguments as RoutePost;
      _originCtrl.text = _post.origin;
      _destinationCtrl.text = _post.destination;
      _fareCtrl.text = _post.fare.toString();
      _tipsCtrl.text = _post.tips;

      for (final t in _post.tags) {
        _selectedTags.add(t);
        if (!_availableTags.contains(t)) _customTags.add(t);
      }

      for (final s in _post.steps) {
        final entry = _StepEntry();
        entry.jeepCodeCtrl.text = s.jeepCode;
        entry.stepFareCtrl.text = s.fare.replaceFirst('P', '');
        entry.dropOffCtrl.text = s.dropOff;
        entry.descCtrl.text = s.description;
        _steps.add(entry);
      }
      if (_steps.isEmpty) _steps.add(_StepEntry());

      _initialized = true;
    }
  }

  void _addStep() => setState(() => _steps.add(_StepEntry()));
  void _removeStep(int i) {
    if (_steps.length > 1) setState(() => _steps.removeAt(i));
  }

  void _addCustomTag() {
    final tag = _customTagCtrl.text.trim();
    if (tag.isEmpty) return;
    if (_availableTags.contains(tag) || _customTags.contains(tag)) {
      setState(() {
        _selectedTags.add(tag);
        _customTagCtrl.clear();
      });
      return;
    }
    setState(() {
      _customTags.add(tag);
      _selectedTags.add(tag);
      _customTagCtrl.clear();
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    for (int i = 0; i < _steps.length; i++) {
      if (_steps[i].jeepCodeCtrl.text.trim().isEmpty ||
          _steps[i].dropOffCtrl.text.trim().isEmpty) {
        _showError('Complete Ride Taken and Drop Off in Step ${i + 1}.');
        return;
      }
    }

    setState(() => _submitting = true);

    try {
      final steps = _steps
          .map((s) => {
                'jeepCode': s.jeepCodeCtrl.text.trim(),
                'fare': s.stepFareCtrl.text.trim().isNotEmpty
                    ? 'P${s.stepFareCtrl.text.trim()}'
                    : 'P0',
                'dropOff': s.dropOffCtrl.text.trim(),
                'description': s.descCtrl.text.trim(),
              })
          .toList();

      await FirebaseFirestore.instance
          .collection('routes')
          .doc(_post.id)
          .update({
        'origin': _originCtrl.text.trim(),
        'destination': _destinationCtrl.text.trim(),
        'fare': int.tryParse(_fareCtrl.text.trim()) ?? 0,
        'tips': _tipsCtrl.text.trim(),
        'tags': _selectedTags.toList(),
        'steps': steps,
      });

      if (mounted) {
        final cs = Theme.of(context).colorScheme;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Route updated!'),
            backgroundColor: cs.primary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      _showError('Failed to update route. Try again.');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: AppTheme.errorRed,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  InputDecoration _inputDec(BuildContext ctx, String hint, IconData icon) {
    final cs = Theme.of(ctx).colorScheme;
    final isDark = Theme.of(ctx).brightness == Brightness.dark;
    final fillColor = isDark ? AppTheme.darkCard : Colors.white;
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
          fontSize: 14,
          color: cs.onSurface.withOpacity(0.4),
          fontFamily: 'Poppins'),
      prefixIcon: Icon(icon, size: 18, color: cs.primary),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: cs.primary.withOpacity(0.4)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: cs.primary.withOpacity(0.35)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: cs.primary, width: 1.8),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppTheme.errorRed),
      ),
      filled: true,
      fillColor: fillColor,
    );
  }

  InputDecoration _pillDec(BuildContext ctx, String hint) {
    final cs = Theme.of(ctx).colorScheme;
    final isDark = Theme.of(ctx).brightness == Brightness.dark;
    final fillColor = isDark ? AppTheme.darkCard : Colors.white;
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
          fontSize: 12,
          color: cs.onSurface.withOpacity(0.4),
          fontFamily: 'Poppins'),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: cs.primary.withOpacity(0.35)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: cs.primary.withOpacity(0.35)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: cs.primary, width: 1.5),
      ),
      filled: true,
      fillColor: fillColor,
    );
  }

  Widget _buildStepRow(BuildContext ctx, int index) {
    final cs = Theme.of(ctx).colorScheme;
    final step = _steps[index];
    final pillStyle = TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w600,
      fontFamily: 'Poppins',
      color: cs.onSurface,
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 24,
            height: 24,
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: cs.primary,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '${index + 1}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
          ),
          SizedBox(
            width: 76,
            child: TextFormField(
              controller: step.jeepCodeCtrl,
              textAlign: TextAlign.center,
              style: pillStyle,
              decoration: _pillDec(ctx, '13C'),
            ),
          ),
          const SizedBox(width: 6),
          Text('₱',
              style: TextStyle(
                  fontSize: 14,
                  fontFamily: 'Poppins',
                  color: cs.onSurface)),
          const SizedBox(width: 3),
          SizedBox(
            width: 48,
            child: TextFormField(
              controller: step.stepFareCtrl,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: pillStyle,
              decoration: _pillDec(ctx, '0'),
            ),
          ),
          const SizedBox(width: 6),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ...List.generate(
                3,
                (i) => Container(
                  width: 3,
                  height: 3,
                  margin: const EdgeInsets.symmetric(horizontal: 1.5),
                  decoration: BoxDecoration(
                    color: cs.primary.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              const SizedBox(width: 2),
              Icon(Icons.arrow_forward_rounded,
                  size: 13, color: cs.primary),
            ],
          ),
          const SizedBox(width: 6),
          Expanded(
            child: TextFormField(
              controller: step.dropOffCtrl,
              style: pillStyle,
              decoration: _pillDec(ctx, 'Drop off location'),
            ),
          ),
          if (_steps.length > 1) ...[
            const SizedBox(width: 6),
            GestureDetector(
              onTap: () => _removeStep(index),
              child: Icon(Icons.remove_circle_outline_rounded,
                  size: 20, color: cs.onSurface.withOpacity(0.35)),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStepDesc(BuildContext ctx, int index) {
    final cs = Theme.of(ctx).colorScheme;
    final isDark = Theme.of(ctx).brightness == Brightness.dark;
    final fillColor = isDark ? AppTheme.darkCard : Colors.white;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14, left: 32),
      child: TextFormField(
        controller: _steps[index].descCtrl,
        maxLines: 2,
        style: TextStyle(
            fontSize: 13, fontFamily: 'Poppins', color: cs.onSurface),
        decoration: InputDecoration(
          hintText: 'Description (optional)',
          hintStyle: TextStyle(
              fontSize: 12,
              color: cs.onSurface.withOpacity(0.4),
              fontFamily: 'Poppins'),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: cs.primary.withOpacity(0.35)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: cs.primary.withOpacity(0.35)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: cs.primary, width: 1.5),
          ),
          filled: true,
          fillColor: fillColor,
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: cs.onSurface,
          fontFamily: 'Poppins',
        ),
      ),
    );
  }

  @override
  void dispose() {
    _originCtrl.dispose();
    _destinationCtrl.dispose();
    _fareCtrl.dispose();
    _tipsCtrl.dispose();
    _customTagCtrl.dispose();
    for (final s in _steps) {
      s.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fillColor = isDark ? AppTheme.darkCard : Colors.white;
    final allTags = [..._availableTags, ..._customTags];

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Edit Route',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: cs.onSurface,
            fontFamily: 'Poppins',
          ),
        ),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
          children: [
            Text(
              'Update your route details below.',
              style: TextStyle(
                  fontSize: 13,
                  color: cs.onSurface.withOpacity(0.5),
                  fontFamily: 'Poppins'),
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _originCtrl,
              style: TextStyle(
                  fontSize: 14, fontFamily: 'Poppins', color: cs.onSurface),
              decoration:
                  _inputDec(context, 'Start', Icons.radio_button_checked_rounded),
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'Origin is required'
                  : null,
            ),
            const SizedBox(height: 10),

            TextFormField(
              controller: _destinationCtrl,
              style: TextStyle(
                  fontSize: 14, fontFamily: 'Poppins', color: cs.onSurface),
              decoration:
                  _inputDec(context, 'Destination', Icons.location_on_outlined),
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'Destination is required'
                  : null,
            ),
            const SizedBox(height: 20),

            _sectionTitle("What ride/s did you take?"),
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  const SizedBox(width: 32),
                  SizedBox(
                    width: 76,
                    child: Text('Ride Taken',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 11,
                            color: cs.onSurface.withOpacity(0.5),
                            fontFamily: 'Poppins')),
                  ),
                  const SizedBox(width: 6),
                  const SizedBox(width: 10),
                  const SizedBox(width: 3),
                  SizedBox(
                    width: 48,
                    child: Text('Fare',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 11,
                            color: cs.onSurface.withOpacity(0.5),
                            fontFamily: 'Poppins')),
                  ),
                  const SizedBox(width: 6),
                  const SizedBox(width: 26),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text('Drop Off',
                        style: TextStyle(
                            fontSize: 11,
                            color: cs.onSurface.withOpacity(0.5),
                            fontFamily: 'Poppins')),
                  ),
                ],
              ),
            ),
            ...List.generate(
              _steps.length,
              (i) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStepRow(context, i),
                  _buildStepDesc(context, i),
                ],
              ),
            ),

            Center(
              child: GestureDetector(
                onTap: _addStep,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: cs.primary.withOpacity(0.5)),
                    color: fillColor,
                  ),
                  child: Icon(Icons.add, size: 18, color: cs.primary),
                ),
              ),
            ),
            const SizedBox(height: 20),

            _sectionTitle('Tags'),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: allTags.map((tag) {
                final selected = _selectedTags.contains(tag);
                final isCustom = _customTags.contains(tag);
                return GestureDetector(
                  onTap: () => setState(() => selected
                      ? _selectedTags.remove(tag)
                      : _selectedTags.add(tag)),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: selected ? cs.primary : fillColor,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: selected
                            ? cs.primary
                            : isCustom
                                ? cs.primary.withOpacity(0.6)
                                : cs.primary.withOpacity(0.35),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isCustom) ...[
                          Icon(Icons.label_rounded,
                              size: 11,
                              color: selected
                                  ? Colors.white.withOpacity(0.8)
                                  : cs.primary.withOpacity(0.7)),
                          const SizedBox(width: 4),
                        ],
                        Text(
                          tag,
                          style: TextStyle(
                            fontSize: 13,
                            fontFamily: 'Poppins',
                            fontWeight: selected
                                ? FontWeight.w600
                                : FontWeight.w400,
                            color: selected ? Colors.white : cs.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 10),

            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 40,
                    child: TextField(
                      controller: _customTagCtrl,
                      style: TextStyle(
                          fontSize: 13,
                          fontFamily: 'Poppins',
                          color: cs.onSurface),
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _addCustomTag(),
                      decoration: InputDecoration(
                        hintText: 'Add a tag…',
                        hintStyle: TextStyle(
                            fontSize: 12,
                            color: cs.onSurface.withOpacity(0.4),
                            fontFamily: 'Poppins'),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide(
                              color: cs.primary.withOpacity(0.35)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide(
                              color: cs.primary.withOpacity(0.35)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide:
                              BorderSide(color: cs.primary, width: 1.5),
                        ),
                        filled: true,
                        fillColor: fillColor,
                        prefixIcon: Icon(Icons.add,
                            size: 16, color: cs.primary),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _addCustomTag,
                  child: Container(
                    height: 40,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: cs.primary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Center(
                      child: Text('Add',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            fontFamily: 'Poppins',
                          )),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            _sectionTitle('Additional Detail/s:'),
            TextFormField(
              controller: _tipsCtrl,
              maxLines: 4,
              style: TextStyle(
                  fontSize: 13, fontFamily: 'Poppins', color: cs.onSurface),
              decoration: InputDecoration(
                hintText: 'Any tips or notes about this route…',
                hintStyle: TextStyle(
                    fontSize: 13,
                    color: cs.onSurface.withOpacity(0.4),
                    fontFamily: 'Poppins'),
                contentPadding: const EdgeInsets.all(14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: cs.primary.withOpacity(0.35)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: cs.primary.withOpacity(0.35)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: cs.primary, width: 1.5),
                ),
                filled: true,
                fillColor: fillColor,
              ),
            ),
            const SizedBox(height: 16),

            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'How much did it cost you?',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: cs.onSurface,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 100,
                  child: TextFormField(
                    controller: _fareCtrl,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 14,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                        color: cs.primary),
                    decoration: InputDecoration(
                      prefixText: '₱ ',
                      prefixStyle: TextStyle(
                          fontSize: 14,
                          color: cs.primary,
                          fontFamily: 'Poppins'),
                      hintText: '0',
                      hintStyle: TextStyle(
                          fontSize: 14,
                          color: cs.onSurface.withOpacity(0.4)),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide:
                            BorderSide(color: cs.primary.withOpacity(0.35)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide:
                            BorderSide(color: cs.primary.withOpacity(0.35)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide:
                            BorderSide(color: cs.primary, width: 1.5),
                      ),
                      filled: true,
                      fillColor: fillColor,
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Required';
                      if (int.tryParse(v.trim()) == null) return 'Invalid';
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _submitting ? null : _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: cs.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              child: _submitting
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2),
                    )
                  : const Text(
                      'Save Changes',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Poppins',
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StepEntry {
  final jeepCodeCtrl = TextEditingController();
  final stepFareCtrl = TextEditingController();
  final dropOffCtrl = TextEditingController();
  final descCtrl = TextEditingController();

  void dispose() {
    jeepCodeCtrl.dispose();
    stepFareCtrl.dispose();
    dropOffCtrl.dispose();
    descCtrl.dispose();
  }
}