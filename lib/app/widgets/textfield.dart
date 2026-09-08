import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../res/assets/asset.dart';
import '../res/colors/colors.dart';

class InputTextWidget extends StatefulWidget {
  const InputTextWidget({
    super.key,
    this.hintText = '',
    this.backicontap2,
    this.backicontap,
    required this.onChanged,
    this.onTap,
    this.validator,
    this.obscureText = false,
    this.readOnly = false,
    this.leading = false,
    this.backIcon = false,
    this.backIcon2 = false,
    this.leadingIcon = ImageAssets.email,
    this.imageIcon = '',
    this.backimage = '',
    this.backimagetap,
    this.backimageadd = false,
    this.contentPadding = true,
    this.clock = false,
    this.scan = false,
    this.passwordIcon = ImageAssets.obsecure,
    this.borderRadius = 10.0,
    this.borderColor = AppColor.customDodgerBlue,
    this.hintTextColor = AppColor.customDodgerBlue,
    this.textColor = AppColor.customDodgerBlue,
    this.height = 50.0,
    this.imageHeight = 22.0,
    this.imageWeight = 22.0,
    this.obscureWidth = 24.0,
    this.obscureHeigth = 24.0,
    this.width = double.infinity,
    this.hintfontFamily = 'Montserrat',
    this.hintfontSize = 14.0,
    this.hintfontWeight = FontWeight.w300,
    this.fontSize = 16.0,
    this.fontWeight = FontWeight.w500,
    this.fontFamily = 'Urbanist',
    this.vertical = 10.0,
    this.horizontal = 15.0,
    this.leadingright = 0.0,
    this.leadingtop = 0.0,
    this.leadingleft = 0.0,
    this.backimagewidht = 24.0,
    this.backimageheight = 24.0,
    this.backgroundColor = AppColor.customDodgerBlue,
    this.maxLines = 1,
    this.controller,
  });

  final String hintText, hintfontFamily, fontFamily;
  final double borderRadius,
      fontSize,
      hintfontSize,
      imageHeight,
      imageWeight,
      leadingright,
      leadingtop,
      leadingleft,
      obscureHeigth,
      obscureWidth;
  final Color borderColor, textColor, hintTextColor, backgroundColor;
  final double height,
      width,
      horizontal,
      vertical,
      backimagewidht,
      backimageheight;
  final bool obscureText,
      readOnly,
      contentPadding,
      leading,
      clock,
      scan,
      backIcon,
      backIcon2,
      backimageadd;
  final String passwordIcon, leadingIcon, imageIcon, backimage;
  final ValueChanged<String> onChanged;
  final VoidCallback? onTap, backicontap, backicontap2, backimagetap;
  final String? Function(String?)? validator;
  final FontWeight fontWeight, hintfontWeight;
  final int maxLines;
  final TextEditingController? controller;

  @override
  State<InputTextWidget> createState() => _InputTextWidgetState();
}

class _InputTextWidgetState extends State<InputTextWidget> {
  late bool _isObscured;

  @override
  void initState() {
    super.initState();
    _isObscured = widget.obscureText;
  }

  void _toggleObscure() {
    setState(() {
      _isObscured = !_isObscured;
    });
  }

  Widget _buildIcon(
    String path, {
    double? width,
    double? height,
    Color? color,
  }) {
    if (path.endsWith('.svg')) {
      return Padding(
        padding: EdgeInsetsGeometry.only(left: 10.w),
        child: SvgPicture.asset(
          path,
          width: width?.w,
          height: height?.h,
          color: color,
        ),
      );
    } else {
      return Image.asset(
        path,
        width: width?.w,
        height: height?.h,
        color: color,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      width: widget.width.w,
      decoration: BoxDecoration(
        color: widget.backgroundColor,
        border: Border.all(color: widget.borderColor),
        borderRadius: BorderRadius.circular(widget.borderRadius.r),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 5.w),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (widget.leading)
              Padding(
                padding: EdgeInsets.only(
                  right: widget.leadingright.w,
                  top: widget.leadingtop.h,
                  left: widget.leadingleft.w,
                ),
                child: _buildIcon(
                  widget.leadingIcon,
                  width: widget.imageWeight,
                  height: widget.imageHeight,
                ),
              ),
            Expanded(
              child: TextField(
                controller: widget.controller,
                onChanged: widget.onChanged,
                onTap: widget.onTap,
                readOnly: widget.readOnly,
                maxLines: widget.maxLines,
                obscureText: _isObscured,
                decoration: InputDecoration(
                  isDense: true,
                  hintText: widget.hintText,
                  hintStyle: TextStyle(
                    color: widget.hintTextColor,
                    fontSize: widget.hintfontSize.spMax,
                    fontWeight: widget.hintfontWeight,
                    fontFamily: widget.hintfontFamily,
                  ),
                  border: InputBorder.none,
                  contentPadding: widget.contentPadding
                      ? EdgeInsets.symmetric(
                          horizontal: widget.horizontal.w,
                          vertical: widget.vertical.h,
                        )
                      : null,
                ),
                style: TextStyle(
                  fontSize: widget.fontSize.spMax,
                  fontWeight: widget.fontWeight,
                  fontFamily: widget.fontFamily,
                  color: widget.textColor,
                ),
              ),
            ),
            if (widget.obscureText)
              Padding(
                padding: EdgeInsets.only(right: 10.w),
                child: GestureDetector(
                  onTap: _toggleObscure,
                  child: _buildIcon(
                    _isObscured ? ImageAssets.eyes : widget.passwordIcon,
                    width: widget.obscureWidth,
                    height: widget.obscureHeigth,
                    color: AppColor.greyLight,
                  ),
                ),
              ),
            if (widget.backIcon)
              Padding(
                padding: EdgeInsets.only(left: 10.w),
                child: GestureDetector(
                  onTap: widget.backicontap,
                  child: _buildIcon(widget.imageIcon),
                ),
              ),
            if (widget.backIcon2)
              Padding(
                padding: EdgeInsets.only(left: 10.w),
                child: GestureDetector(
                  onTap: widget.backicontap2,
                  child: _buildIcon(widget.imageIcon),
                ),
              ),
            if (widget.backimageadd)
              Padding(
                padding: EdgeInsets.only(right: 10.w),
                child: GestureDetector(
                  onTap: widget.backimagetap,
                  child: _buildIcon(
                    widget.backimage,
                    width: widget.backimagewidht,
                    height: widget.backimageheight,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
