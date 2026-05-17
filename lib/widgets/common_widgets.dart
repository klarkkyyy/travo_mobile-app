import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AppLogo extends StatelessWidget {
  final double size;
  const AppLogo({super.key, this.size = 90});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: Color(0xFF3D5AF1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.directions_bus_rounded,
        color: Colors.white,
        size: size * 0.55,
      ),
    );
  }
}

class OrDivider extends StatelessWidget {
  const OrDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(child: Divider(color: AppTheme.borderGrey)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'or',
            style: TextStyle(
              color: AppTheme.textGrey,
              fontSize: 13,
              fontFamily: 'Poppins',
            ),
          ),
        ),
        Expanded(child: Divider(color: AppTheme.borderGrey)),
      ],
    );
  }
}

class SocialButton extends StatelessWidget {
  final String label;
  final String iconPath;
  final VoidCallback? onTap;

  const SocialButton({
    super.key,
    required this.label,
    required this.iconPath,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap ?? () {},
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _SocialIcon(iconPath: iconPath),
          const SizedBox(width: 10),
          Text(label),
        ],
      ),
    );
  }
}

class _SocialIcon extends StatelessWidget {
  final String iconPath;
  const _SocialIcon({required this.iconPath});

  @override
  Widget build(BuildContext context) {
    if (iconPath == 'google') {
      return Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppTheme.borderGrey),
        ),
        child: const Center(
          child: Text(
            'G',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Color(0xFFEA4335),
            ),
          ),
        ),
      );
    } else {
      return Container(
        width: 20,
        height: 20,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Color(0xFF1877F2),
        ),
        child: const Center(
          child: Text(
            'f',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      );
    }
  }
}

class AppTextField extends StatefulWidget {
  final String hint;
  final bool isPassword;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final Widget? prefixWidget;
  final String? Function(String?)? validator;

  const AppTextField({
    super.key,
    required this.hint,
    this.isPassword = false,
    this.controller,
    this.keyboardType,
    this.prefixWidget,
    this.validator,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      validator: widget.validator,
      obscureText: widget.isPassword ? _obscure : false,
      keyboardType: widget.keyboardType,
      style: const TextStyle(
        fontSize: 14,
        color: AppTheme.textDark,
        fontFamily: 'Poppins',
      ),
      decoration: InputDecoration(
        hintText: widget.hint,
        prefixIcon: widget.prefixWidget,
        suffixIcon: widget.isPassword
            ? IconButton(
                icon: Icon(
                  _obscure
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: AppTheme.textGrey,
                  size: 20,
                ),
                onPressed: () => setState(() => _obscure = !_obscure),
              )
            : null,
      ),
    );
  }
}

class PhoneField extends StatelessWidget {
  final TextEditingController? controller;

  const PhoneField({super.key, this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        border: Border.all(color: AppTheme.borderGrey, width: 1.2),
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
      ),
      child: Row(
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 12, right: 4),
            child: Row(
              children: [
                Text('🇧🇩', style: TextStyle(fontSize: 18)),
                SizedBox(width: 4),
                Icon(Icons.keyboard_arrow_down,
                    size: 16, color: AppTheme.textGrey),
                SizedBox(width: 6),
                Text(
                  '+880',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppTheme.textDark,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 1,
            height: 28,
            color: AppTheme.borderGrey,
            margin: const EdgeInsets.symmetric(horizontal: 8),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.phone,
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.textDark,
                fontFamily: 'Poppins',
              ),
              decoration: const InputDecoration(
                hintText: 'Your mobile number',
                hintStyle: TextStyle(
                  color: AppTheme.textGrey,
                  fontSize: 14,
                  fontFamily: 'Poppins',
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── GenderDropdown ────────────────────────────────────────────────────────────
// Added [value] and [onChanged] so the parent form can own the selected gender.
// The widget still renders identically — only state ownership has moved up.

class GenderDropdown extends StatelessWidget {
  final String? value;
  final ValueChanged<String?> onChanged;

  const GenderDropdown({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        border: Border.all(color: AppTheme.borderGrey, width: 1.2),
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: const Text(
            'Gender',
            style: TextStyle(
              color: AppTheme.textGrey,
              fontSize: 14,
              fontFamily: 'Poppins',
            ),
          ),
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down, color: AppTheme.textGrey),
          items: ['Male', 'Female', 'Other', 'Prefer not to say']
              .map((g) => DropdownMenuItem(
                    value: g,
                    child: Text(
                      g,
                      style: const TextStyle(
                        fontSize: 14,
                        fontFamily: 'Poppins',
                        color: AppTheme.textDark,
                      ),
                    ),
                  ))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}