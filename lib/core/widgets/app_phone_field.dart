import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_barber/core/themes/app_colors.dart';

class Country {
  final String name;
  final String code;
  final String flag;

  Country({required this.name, required this.code, required this.flag});
}

/// Extension to provide utility methods for phone number handling
extension PhoneNumberUtils on AppPhoneField {
  /// Gets the complete phone number with country code in clean format
  /// Example: "+201020304050" (without dashes or spaces)
  static String getCleanPhoneNumber(
    TextEditingController controller,
    Country selectedCountry,
  ) {
    // Remove all dashes and non-digit characters from the phone number
    final cleanNumber = controller.text.replaceAll(RegExp(r'[^\d]'), '');
    // Return country code + clean number
    return '${selectedCountry.code}$cleanNumber';
  }
}

class AppPhoneField extends StatefulWidget {
  const AppPhoneField({
    super.key,
    required this.controller,
    required this.labelText,
    this.hintText = 'Enter your phone number',
    this.validator,
    this.onCountryChanged,
  });

  final TextEditingController controller;
  final String labelText;
  final String hintText;
  final String? Function(String?)? validator;

  /// Callback that returns the selected country whenever it changes
  final void Function(Country)? onCountryChanged;

  @override
  State<AppPhoneField> createState() => _AppPhoneFieldState();
}

class _AppPhoneFieldState extends State<AppPhoneField> {
  final List<Country> countries = [
    Country(name: 'Egypt', code: '+20', flag: '🇪🇬'),
    Country(name: 'Saudi Arabia', code: '+966', flag: '🇸🇦'),
    Country(name: 'UAE', code: '+971', flag: '🇦🇪'),
  ];

  late Country selectedCountry;
  bool isValidFormat = false;

  @override
  void initState() {
    super.initState();
    selectedCountry = countries[0];
    widget.controller.addListener(_validatePhoneNumber);
    // Notify parent of initial country
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onCountryChanged?.call(selectedCountry);
    });
  }

  @override
  void dispose() {
    widget.controller.removeListener(_validatePhoneNumber);
    super.dispose();
  }

  void _validatePhoneNumber() {
    final text = widget.controller.text.replaceAll('-', '');
    setState(() {
      // Validate based on selected country
      if (selectedCountry.code == '+20') {
        // Egypt: 10 digits
        isValidFormat = text.length == 10;
      } else if (selectedCountry.code == '+966') {
        // Saudi Arabia: 9 digits
        isValidFormat = text.length == 9;
      } else if (selectedCountry.code == '+971') {
        // UAE: 9 digits
        isValidFormat = text.length == 9;
      }
    });
  }

  String _formatPhoneNumber(String value) {
    final digits = value.replaceAll(RegExp(r'\D'), '');
    final buffer = StringBuffer();

    if (selectedCountry.code == '+20') {
      // Egypt format: XXX-XXX-XXXX
      for (int i = 0; i < digits.length && i < 10; i++) {
        if (i == 3 || i == 6) buffer.write('-');
        buffer.write(digits[i]);
      }
    } else if (selectedCountry.code == '+966' ||
        selectedCountry.code == '+971') {
      // KSA/UAE format: XX-XXX-XXXX
      for (int i = 0; i < digits.length && i < 9; i++) {
        if (i == 2 || i == 5) buffer.write('-');
        buffer.write(digits[i]);
      }
    }

    return buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8.h,
      children: [
        Text(
          widget.labelText,
          style: TextStyle(color: AppColors.textGrey(context), fontSize: 16.sp),
        ),
        Theme(
          data: Theme.of(context).copyWith(
            textSelectionTheme: TextSelectionThemeData(
              cursorColor: AppColors.primaryColor(context),
              selectionColor: AppColors.primaryColor(
                context,
              ).withValues(alpha: 0.3),
              selectionHandleColor: AppColors.primaryColor(context),
            ),
          ),
          child: TextFormField(
            validator: widget.validator,
            controller: widget.controller,
            keyboardType: TextInputType.phone,
            inputFormatters: [
              _PhoneNumberFormatter(_formatPhoneNumber, selectedCountry.code),
            ],
            decoration: InputDecoration(
              prefixIcon: SizedBox(
                width: 100.w,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(width: 8.w),
                    PopupMenuButton<Country>(
                      color: AppColors.scaffoldBackground(context),
                      initialValue: selectedCountry,
                      onSelected: (Country country) {
                        setState(() {
                          selectedCountry = country;
                          widget.controller.clear();
                          isValidFormat = false;
                        });
                        // Notify parent of country change
                        widget.onCountryChanged?.call(country);
                      },
                      itemBuilder: (BuildContext context) {
                        return countries.map((Country country) {
                          return PopupMenuItem<Country>(
                            value: country,
                            child: Row(
                              spacing: 8.w,
                              children: [
                                Text(
                                  country.flag,
                                  style: TextStyle(fontSize: 20.sp),
                                ),
                                Text(
                                  country.code,
                                  style: TextStyle(
                                    color: AppColors.inverseScaffoldBackground(
                                      context,
                                    ),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14.sp,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList();
                      },
                      child: Row(
                        spacing: 4.w,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            selectedCountry.flag,
                            style: TextStyle(fontSize: 20.sp),
                          ),
                          Text(
                            selectedCountry.code,
                            style: TextStyle(
                              color: AppColors.primaryColor(context),
                              fontWeight: FontWeight.w600,
                              fontSize: 14.sp,
                            ),
                          ),
                          Icon(
                            Icons.arrow_drop_down,
                            color: AppColors.primaryColor(context),
                            size: 20.sp,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 1.w,
                      height: 24.h,
                      color: AppColors.textGrey(context),
                      margin: EdgeInsets.only(left: 4.w),
                    ),
                  ],
                ),
              ),
              suffixIcon: isValidFormat
                  ? Icon(Icons.check_circle, color: Colors.green, size: 24.sp)
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide: BorderSide(color: AppColors.primaryColor(context)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide: BorderSide(color: AppColors.primaryColor(context)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide: BorderSide(
                  color: AppColors.tffBorderColor(context),
                ),
              ),
              hintText: widget.hintText,
              hintStyle: TextStyle(
                color: AppColors.textGrey(context),
                fontSize: 14.sp,
              ),
            ),
            cursorColor: AppColors.primaryColor(context),
            style: TextStyle(
              color: AppColors.inverseScaffoldBackground(context),
              fontSize: 16.sp,
            ),
          ),
        ),
      ],
    );
  }
}

class _PhoneNumberFormatter extends TextInputFormatter {
  final String Function(String) formatter;
  final String countryCode;

  _PhoneNumberFormatter(this.formatter, this.countryCode);

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // 1. Calculate how many digits are before the cursor originally
    int digitsBeforeCursor = 0;
    for (int i = 0; i < newValue.selection.end; i++) {
      if (RegExp(r'\d').hasMatch(newValue.text[i])) {
        digitsBeforeCursor++;
      }
    }

    // 2. Extract all digits from newValue
    String text = newValue.text.replaceAll(RegExp(r'\D'), '');

    int strippedDigits = 0;
    int maxLength = countryCode == '+20' ? 10 : 9;

    // 3. Handle pasted country code (e.g., pasting "+20 102..." directly)
    String codeDigits = countryCode.replaceAll('+', '');
    if (text.length > maxLength && text.startsWith(codeDigits)) {
      text = text.substring(codeDigits.length);
      strippedDigits += codeDigits.length;
    }

    // 4. Remove leading zeros smoothly
    while (text.startsWith('0')) {
      text = text.substring(1);
      strippedDigits++;
    }

    // 5. Truncate to max length
    if (text.length > maxLength) {
      text = text.substring(0, maxLength);
    }

    // Adjust the internal cursor calculation by the digits we removed
    digitsBeforeCursor -= strippedDigits;
    if (digitsBeforeCursor < 0) digitsBeforeCursor = 0;
    if (digitsBeforeCursor > maxLength) digitsBeforeCursor = maxLength;

    final formatted = formatter(text);

    // Track cursor position avoiding jumps to the end of text
    int formattedCursor = -1;
    int digitsCount = 0;
    for (int i = 0; i < formatted.length; i++) {
      if (digitsCount == digitsBeforeCursor) {
        formattedCursor = i;
        break;
      }
      if (RegExp(r'\d').hasMatch(formatted[i])) {
        digitsCount++;
      }
    }
    
    // If we didn't land exactly on an internal digit cut-off, place it at the end
    if (formattedCursor == -1) {
      formattedCursor = formatted.length;
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formattedCursor),
    );
  }
}
