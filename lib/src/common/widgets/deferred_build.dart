import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

/// İlk kare çizildikten sonra [builder] çalıştırır; açılış ANR riskini azaltır.
class DeferredBuild extends StatefulWidget {
  const DeferredBuild({
    super.key,
    required this.builder,
    this.placeholder = const SizedBox.shrink(),
  });

  final Widget Function(BuildContext context) builder;
  final Widget placeholder;

  @override
  State<DeferredBuild> createState() => _DeferredBuildState();
}

class _DeferredBuildState extends State<DeferredBuild> {
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.scheduleFrameCallback((_) {
      if (!mounted) return;
      setState(() => _ready = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) return widget.placeholder;
    return widget.builder(context);
  }
}
