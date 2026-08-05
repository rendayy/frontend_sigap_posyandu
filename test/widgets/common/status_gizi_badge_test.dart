import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_posyandu/widgets/common/status_gizi_badge.dart';

void main() {
  group('StatusGiziBadge', () {
    for (final entry in [
      ('baik', 'Baik'),
      ('gizi_baik', 'Baik'),
      ('kurang', 'Kurang'),
      ('gizi_kurang', 'Kurang'),
      ('berat_badan_kurang', 'Kurang'),
      ('buruk', 'Buruk'),
      ('stunting', 'Stunting'),
      ('berat_badan_normal', 'Normal'),
      ('berat_badan_berlebih', 'Berlebih'),
      ('obesitas_1', 'Obesitas 1'),
      ('obesitas_2', 'Obesitas 2'),
      ('unknown', 'Tidak Diketahui'),
      (null, 'Tidak Diketahui'),
    ]) {
      testWidgets('shows "${entry.$2}" for status "${entry.$1}"', (tester) async {
        await tester.pumpWidget(MaterialApp(
          home: Scaffold(body: StatusGiziBadge(status: entry.$1)),
        ));
        expect(find.textContaining(entry.$2), findsOneWidget);
      });
    }
  });
}
