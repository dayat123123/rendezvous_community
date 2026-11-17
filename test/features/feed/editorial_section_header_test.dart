import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:rendezvous_community/rendezvous_community.dart';
import 'package:rendezvous_community/src/features/feed/presentation/widgets/editorial_section.dart';

void main() {
  testWidgets('section header follows the host section title size', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              final theme = Theme.of(context);
              final style = CommunityStyle.fallback(theme);
              return Theme(
                data: theme.copyWith(
                  extensions: [
                    style.copyWith(
                      typography: style.typography.copyWith(
                        sectionTitle: style.typography.sectionTitle.copyWith(fontSize: 12.5),
                      ),
                    ),
                  ],
                ),
                child: EditorialSectionHeader(
                  title: 'Pengguna',
                  icon: Icons.people_outline,
                  actionLabel: 'Lihat semua',
                  onAction: () {},
                ),
              );
            },
          ),
        ),
      ),
    );
    final title = tester.widget<Text>(find.text('Pengguna'));
    expect(title.style?.fontSize, 12.5);
    expect(tester.widget<Icon>(find.byIcon(Icons.people_outline)).size, 16.5);
    expect(tester.widget<Icon>(find.byIcon(Icons.chevron_right)).size, 16.5);
  });
}
