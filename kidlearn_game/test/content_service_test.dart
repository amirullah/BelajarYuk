import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kidlearn_game/models/question.dart';
import 'package:kidlearn_game/models/subject.dart';
import 'package:kidlearn_game/services/content_service.dart';

/// Konten dari server (update soal tanpa APK): round-trip JSON + logika refresh.
void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('Question round-trip JSON menjaga semua field penting', () {
    final q = Question.trueFalse(
        statement: 'Langit biru', isTrue: true, emoji: '🌤️', difficulty: 3);
    final back = Question.fromJson(q.toJson());
    expect(back.question, q.question);
    expect(back.type, QuestionType.trueFalse);
    expect(back.correctIndex, q.correctIndex);
    expect(back.difficulty, 3);

    final mc = Question(
        question: '2+2?',
        options: const ['3', '4', '5', '6'],
        correctIndex: 1,
        difficulty: 2);
    final mcBack = Question.fromJson(mc.toJson());
    expect(mcBack.options, mc.options);
    expect(mcBack.correctIndex, 1);
  });

  String doc(int version) =>
      '{"content":$version,"banks":{"1|english":['
      '{"q":"Apple?","o":["a","b","c","d"],"c":0,"t":"multipleChoice","d":1}]}}';

  test('refreshFromServer mengunduh saat server lebih baru & bisa dipakai',
      () async {
    final client = MockClient((req) async {
      if (req.url.path.endsWith('version.json')) {
        return http.Response('{"build":1,"content":5}', 200);
      }
      return http.Response(doc(5), 200);
    });
    final svc = ContentService.test(client);
    expect(await svc.refreshFromServer(), isTrue);
    expect(svc.loadedVersion, 5);
    final bank = svc.forSubject(Subject.english, 1);
    expect(bank, isNotNull);
    expect(bank!.first.question, 'Apple?');
  });

  test('Tidak mengunduh ulang bila versi server tak lebih baru', () async {
    SharedPreferences.setMockInitialValues({
      'content_json': doc(5),
      'content_version': 5,
    });
    final client = MockClient((req) async {
      if (req.url.path.endsWith('version.json')) {
        return http.Response('{"build":1,"content":5}', 200);
      }
      return http.Response('SEHARUSNYA TIDAK DIUNDUH', 200);
    });
    final svc = ContentService.test(client);
    expect(await svc.refreshFromServer(), isFalse);
  });

  test('loadFromCache memakai konten tersimpan tanpa jaringan', () async {
    SharedPreferences.setMockInitialValues({
      'content_json': doc(2),
      'content_version': 2,
    });
    final svc = ContentService.test(MockClient((_) async {
      throw Exception('jaringan tak boleh dipakai');
    }));
    await svc.loadFromCache();
    expect(svc.hasContent, isTrue);
    expect(svc.forSubject(Subject.english, 1)!.first.question, 'Apple?');
  });
}
