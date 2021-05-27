import 'dart:io';

import 'package:moor/ffi.dart';
import 'package:moor/moor.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'database.g.dart';

class Words extends Table {
  TextColumn get strQuestion => text()();

  TextColumn get strAnswer => text()();

  BoolColumn get isMemorized => boolean().withDefault(Constant(false))();

  @override
  // TODO: implement primaryKey
  Set<Column> get primaryKey => {strQuestion};
}

@UseMoor(tables: [Words])
class MyDatabase extends _$MyDatabase {
  MyDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 3;

  // 統合処理
  MigrationStrategy get migration => MigrationStrategy(onCreate: (Migrator m) {
        return m.createAll();
      }, onUpgrade: (Migrator m, int from, int to) async {
        if (from == 1) {
          await m.addColumn(words, words.isMemorized);
        }
      });

  // Create
  Future addWord(Word word) => into(words).insert(word);

  // Read
  Future<List<Word>> get allWords => select(words).get();

  // Read(暗記済みを除外)
  Future<List<Word>> get allWordsExcludeMemorised =>
      (select(words)..where((table) => table.isMemorized.equals(false))).get();

  Future<List<Word>> get allWordsSorted => (select(words)
        ..orderBy([(table) => OrderingTerm(expression: table.isMemorized)]))
      .get();

  // Update
  Future updateWord(Word word) => update(words).replace(word);

  // Delete
  Future deleteWord(Word word) =>
      (delete(words)..where((t) => t.strQuestion.equals(word.strQuestion)))
          .go();
}

LazyDatabase _openConnection() {
  // the LazyDatabase util lets us find the right location for the file async.
  return LazyDatabase(() async {
    // put the database file, called db.sqlite here, into the documents folder
    // for your app.
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'words.db'));
    return VmDatabase(file);
  });
}
