import 'package:flutter_test/flutter_test.dart';
import 'package:biodata_mahasiswa/main.dart';

void main() {
  testWidgets('Check if Form Screen loads', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that the title is present.
    expect(find.text('Input Biodata'), findsOneWidget);
    expect(find.text('Informasi Pribadi'), findsOneWidget);
    
    // Verify that the submit button is present.
    expect(find.text('Tampilkan Profil'), findsOneWidget);
  });
}
