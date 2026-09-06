import 'dart:math';

import 'package:flutter/material.dart';

// === Controller for height scale picker ===
class VerticalScrollController extends ChangeNotifier {
  final double topValue;
  final double bottomValue;
  final double height;
  final double itemGap;

  double _scrollOffset = 0;
  AxisDirection dragDirection = AxisDirection.up;

  double _currentValue;

  VerticalScrollController({
    this.topValue = 250,
    this.bottomValue = 100,
    this.height = 300,
    this.itemGap = 20,
    double? initialValue,
  })  : _currentValue = (initialValue ?? 175).clamp(bottomValue, topValue) {
    _scrollOffset = (topValue - _currentValue) * itemGap;
  }

  int get itemHeight => itemGap.round();

  int get totalLineCount => (topValue - bottomValue).abs().ceil();

  double get scrollOffset => _scrollOffset;

  double get pickValuePrecise {
    double centerOffset = _scrollOffset / itemHeight;
    double value = topValue - centerOffset;
    return value.clamp(bottomValue, topValue);
  }

  int get pickedValue => pickValuePrecise.round();

  double get currentValue => _currentValue;

  void refresh() {
    notifyListeners();
  }

  set currentValue(double val) {
    _currentValue = val.clamp(bottomValue, topValue);
    _scrollOffset = (topValue - _currentValue) * itemHeight;
    notifyListeners();
  }

  void scroll(double pixels) {
    final double maxScroll = totalLineCount * itemHeight.toDouble();
    final double clamped = pixels.clamp(0.0, maxScroll);
    if ((clamped - _scrollOffset).abs() > 0.0001) {
      _scrollOffset = clamped;
      _currentValue = topValue - (_scrollOffset / itemHeight);
      notifyListeners();
    }
  }

  void updateDirection(AxisDirection direction) {
    dragDirection = direction;
  }
}

// === Style class ===
class VerticalScrollPickerStyle {
  final Color? backgroundItemColor;
  final Color? foregroundItemColor;

  const VerticalScrollPickerStyle({
    this.backgroundItemColor,
    this.foregroundItemColor,
  });

  static const VerticalScrollPickerStyle defaultStyle =
      VerticalScrollPickerStyle(
    backgroundItemColor: Color(0xFF9A9A9A),
    foregroundItemColor: Color(0xFF444444),
  );
}

// === VerticalScrollPicker Widget ===
class VerticalScrollPicker extends StatefulWidget {
  final double? height;
  final double? width;
  final double bottomValue;
  final double topValue;
  final double Function() interval;
  final double lineGap;
  final ValueChanged<double>? onChanged;
  final VerticalScrollPickerStyle style;
  final String Function(double value)? onPickedValueFormat;
  final String Function(double value)? onScaleValueFormat;
  final Key nKey;
  final VerticalScrollController controller;

  const VerticalScrollPicker({
    required this.nKey,
    required this.controller,
    this.height,
    this.width,
    required this.bottomValue,
    required this.topValue,
    required this.interval,
    this.onPickedValueFormat,
    this.onScaleValueFormat,
    this.onChanged,
    this.style = VerticalScrollPickerStyle.defaultStyle,
    this.lineGap = 20,
  }) : super(key: nKey);

  @override
  State<VerticalScrollPicker> createState() => _VerticalScrollPickerState();
}

class _VerticalScrollPickerState extends State<VerticalScrollPicker> {
  late VerticalScrollController controller;

  @override
  void initState() {
    super.initState();
    controller = widget.controller;
  }

  @override
  void didUpdateWidget(covariant VerticalScrollPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      controller = widget.controller;
    }
  }

  void _onDragVertically(DragUpdateDetails details) {
    final double delta = details.primaryDelta ?? details.delta.dy;
    bool isUp = delta < 0;
    controller.updateDirection(isUp ? AxisDirection.up : AxisDirection.down);

    double newScrollOffset = controller.scrollOffset - delta;
    controller.scroll(newScrollOffset);
    widget.onChanged?.call(controller.currentValue);
  }

  void _onDragEnd(DragEndDetails details) {
    final double precise = controller.pickValuePrecise;
    final int snappedValue = precise.round();
    controller.currentValue = snappedValue.toDouble();
    widget.onChanged?.call(controller.currentValue);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      width: widget.width,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onVerticalDragEnd: _onDragEnd,
        onVerticalDragUpdate: _onDragVertically,
        child: _RangeSlide(
          key: widget.nKey,
          controller: controller,
          interval: widget.interval,
          style: widget.style,
          onPickedValueFormat: widget.onPickedValueFormat,
          onScaleValueFormat: widget.onScaleValueFormat,
        ),
      ),
    );
  }
}

// === _RangeSlide ===
class _RangeSlide extends StatefulWidget {
  final String Function(double value)? onPickedValueFormat;
  final String Function(double value)? onScaleValueFormat;
  final double Function() interval;
  final VerticalScrollPickerStyle style;
  final VerticalScrollController controller;

  static double defaultInterval() => 10.0;

  const _RangeSlide({
    super.key,
    required this.controller,
    this.interval = defaultInterval,
    this.onPickedValueFormat,
    this.onScaleValueFormat,
    this.style = VerticalScrollPickerStyle.defaultStyle,
  });

  @override
  State<_RangeSlide> createState() => _RangeSlideState();
}

class _RangeSlideState extends State<_RangeSlide> {
  VerticalScrollController get controller => widget.controller;

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: ListenableBuilder(
        listenable: controller,
        builder: (_, __) => CustomPaint(
          painter: ScalePainter(
            topValue: controller.topValue,
            totalLineCount: controller.totalLineCount,
            pickedValue: controller.pickedValue,
            color: widget.style.backgroundItemColor,
            itemHeight: controller.itemHeight,
            interval: widget.interval,
            scrollOffset: controller.scrollOffset,
            offsetLeft: 18,
            valueFormatter:
                widget.onScaleValueFormat ?? (value) => value.toString(),
            bottomValue: controller.bottomValue,
          ),
          foregroundPainter: MarkPainter(
            interval: widget.interval,
            color: widget.style.foregroundItemColor,
            pickedValue: controller.pickedValue,
            offsetLeft: 18,
            valueFormatter:
                widget.onPickedValueFormat ?? (value) => value.toString(),
          ),
        ),
      ),
    );
  }
}

class ScalePainter extends CustomPainter {
  final Color? color;
  final int totalLineCount;
  final double Function() interval;
  final double topValue;
  final double bottomValue;
  final int pickedValue;
  final double scrollOffset;
  final double offsetLeft;
  final String Function(double value) valueFormatter;
  final int itemHeight;

  ScalePainter({
    required this.totalLineCount,
    required this.pickedValue,
    required this.topValue,
    required this.bottomValue,
    required this.interval,
    required this.scrollOffset,
    required this.valueFormatter,
    this.color,
    this.offsetLeft = 12,
    required this.itemHeight,
  });

  final int extraLines = 40;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color ?? const Color(0xFF717171)
      ..strokeWidth = 2;

    final double startY = size.height / 2 - scrollOffset;

    for (int i = -extraLines; i <= totalLineCount + extraLines; i++) {
      final double y = startY + i * itemHeight;

      if (y < 0 || y > size.height) continue;

      bool isInterval =
          ((topValue - i.toDouble()) % interval()) == 0;

      if (isInterval) {
        canvas.drawLine(
          Offset(offsetLeft * 2, y),
          Offset(offsetLeft * 4, y),
          paint,
        );

        final labelValue = topValue - i;
        if (labelValue.toInt() != pickedValue) {
          _drawText(
            canvas,
            valueFormatter(labelValue),
            Offset(offsetLeft * 4 + 8, y - 7),
            paint.color,
          );
        }
      } else {
        canvas.drawLine(
          Offset(offsetLeft * 2, y),
          Offset(offsetLeft * 2 + offsetLeft, y),
          paint,
        );
      }
    }

    // baseline
    canvas.drawLine(
      Offset(offsetLeft * 2, 0),
      Offset(offsetLeft * 2, size.height),
      paint,
    );
  }

  void _drawText(Canvas canvas, String text, Offset position, Color textColor) {
    final TextSpan span = TextSpan(
      text: text,
      style: TextStyle(
        color: textColor,
        fontSize: 12,
        fontWeight: FontWeight.bold,
      ),
    );
    final TextPainter tp = TextPainter(
      text: span,
      textDirection: TextDirection.ltr,
    );
    tp.layout();
    tp.paint(canvas, position);
  }

  @override
  bool shouldRepaint(covariant ScalePainter oldDelegate) =>
      oldDelegate.scrollOffset != scrollOffset ||
      oldDelegate.pickedValue != pickedValue ||
      oldDelegate.topValue != topValue ||
      oldDelegate.bottomValue != bottomValue ||
      oldDelegate.color != color;
}

// === MarkPainter ===
class MarkPainter extends CustomPainter {
  final double Function() interval;
  final int pickedValue;
  final double offsetLeft;
  final Color? color;
  final String Function(double) valueFormatter;

  MarkPainter({
    required this.interval,
    required this.pickedValue,
    required this.valueFormatter,
    this.offsetLeft = 12,
    this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint arrowPaint = Paint()
      ..color = color ?? Colors.black
      ..strokeWidth = 3
      ..style = PaintingStyle.fill;

    double arrowHandle = 80;
    double arrowHeadSize = 6;
    double gap = 50;

    Offset center = Offset(size.width / 2, size.height / 2);

    // UP Arrow
    Offset upStart = Offset(6, center.dy - gap / 2);
    Offset upEnd = Offset(6, upStart.dy - arrowHandle);
    canvas.drawLine(upStart, upEnd, arrowPaint);

    Path upArrowHead = Path();
    upArrowHead.moveTo(upEnd.dx, upEnd.dy - 2);
    upArrowHead.lineTo(upEnd.dx - arrowHeadSize, upEnd.dy + arrowHeadSize);
    upArrowHead.lineTo(upEnd.dx + arrowHeadSize, upEnd.dy + arrowHeadSize);
    upArrowHead.close();
    canvas.drawPath(upArrowHead, arrowPaint);

    // DOWN Arrow
    Offset downStart = Offset(6, center.dy + gap / 2);
    Offset downEnd = Offset(6, downStart.dy + arrowHandle);
    canvas.drawLine(downStart, downEnd, arrowPaint);

    Path downArrowHead = Path();
    downArrowHead.moveTo(downEnd.dx, downEnd.dy + 2);
    downArrowHead.lineTo(
      downEnd.dx - arrowHeadSize,
      downEnd.dy - arrowHeadSize,
    );
    downArrowHead.lineTo(
      downEnd.dx + arrowHeadSize,
      downEnd.dy - arrowHeadSize,
    );
    downArrowHead.close();
    canvas.drawPath(downArrowHead, arrowPaint);

    // Horizontal Arrow
    drawStaticMid(canvas, arrowPaint, center, arrowHeadSize);
  }

  void drawStaticMid(
    Canvas canvas,
    Paint arrowPaint,
    Offset center,
    double arrowHeadSize,
  ) {
    Offset horStart = Offset(offsetLeft * 2, center.dy);
    Offset horEnd = Offset(6 + offsetLeft * 4, horStart.dy);
    canvas.drawLine(horStart, horEnd, arrowPaint);

    Path horizontalArrowHead = Path();
    horizontalArrowHead.moveTo(horStart.dx, horStart.dy - arrowHeadSize);
    horizontalArrowHead.lineTo(horStart.dx, horStart.dy + arrowHeadSize);
    horizontalArrowHead.lineTo(horStart.dx + arrowHeadSize, horStart.dy);
    horizontalArrowHead.close();
    canvas.drawPath(horizontalArrowHead, arrowPaint);

    double finalValue = double.parse(pickedValue.toStringAsFixed(1));
    final TextSpan textSpan = TextSpan(
      text: valueFormatter(max(finalValue, 0)),
      style: TextStyle(
        color: color ?? Colors.black,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );

    final TextPainter textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();

    Offset textOffset = Offset(
      horEnd.dx + 10,
      horEnd.dy - textPainter.height / 2,
    );
    textPainter.paint(canvas, textOffset);
  }

  @override
  bool shouldRepaint(covariant MarkPainter oldDelegate) =>
      oldDelegate.pickedValue != pickedValue ||
      oldDelegate.color != color ||
      oldDelegate.offsetLeft != offsetLeft;
}

// === Helper functions ===
String inchToFeetInch(double inchValue) {
  int feet = inchValue ~/ 12;
  int inch = (inchValue % 12).round();
  return "$feet'$inch\"";
}

String inchToFeet(double inchValue) {
  int feet = inchValue ~/ 12;
  return "$feet ft";
}

