import 'package:material_ui/material_ui.dart';

import '../../theme/app_colors.dart';
import '../../widgets/page_body.dart';
import '../../widgets/ui.dart';

/// Shown for sections whose UI phase has not been built yet.
class ComingSoonPage extends StatelessWidget {
  const ComingSoonPage({super.key, required this.title, required this.phase});

  final String title;
  final String phase;

  @override
  Widget build(BuildContext context) {
    return PageBody(
      children: [
        AppCard(
          padding: 40,
          child: Column(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.brandSoft,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(
                  Icons.construction_rounded,
                  color: AppColors.brand,
                  size: 30,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '$title is coming in $phase',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'The Dashboard is ready to preview now.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
