import 'package:flutter/material.dart';
import '../controllers/reaction_time_controller.dart';
import 'package:provider/provider.dart';
import '../widgets/reaction_time_widget.dart';

class ReactionTimeScreen extends StatelessWidget {
  const ReactionTimeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ReactionTimeController()..startWaiting(),
      child: Scaffold(
        body: SafeArea(
          child: Consumer<ReactionTimeController>(
            builder: (context, controller, _) {
              return ReactionTimeWidget(controller: controller);
            },
          ),
        ),
      ),
    );
  }
}
