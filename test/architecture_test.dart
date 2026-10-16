@TestOn('vm')
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Guards the two structural rules in BUILD_PLAN.md that are easy to break by
/// accident and expensive to discover late.
///
/// Section 6: `lib/engine/` is pure Dart. It must not import Flutter, Drift or
/// any plugin, so it stays fast to test and cannot reach a database.
///
/// Section 16: `DateTime.now()` appears only in `core/clock.dart`. A forecast
/// that reads the wall clock is not reproducible.
void main() {
  final Directory lib = Directory('lib');

  List<File> dartFilesIn(String path) {
    final Directory dir = Directory(path);
    if (!dir.existsSync()) {
      return <File>[];
    }
    return dir
        .listSync(recursive: true)
        .whereType<File>()
        .where((File f) => f.path.endsWith('.dart'))
        .toList();
  }

  group('engine purity', () {
    const List<String> forbidden = <String>[
      'package:flutter/',
      'package:flutter_test/',
      'package:drift/',
      'package:flutter_riverpod/',
      'package:sqlite3',
      'package:path_provider/',
      'package:fl_chart/',
      'package:flutter_secure_storage/',
      'dart:io',
      'dart:ui',
    ];

    test('no engine file imports Flutter, a plugin or dart:io', () {
      final List<String> offences = <String>[];
      for (final File file in dartFilesIn('lib/engine')) {
        final List<String> lines = file.readAsLinesSync();
        for (int i = 0; i < lines.length; i++) {
          final String line = lines[i].trim();
          if (!line.startsWith('import ') && !line.startsWith('export ')) {
            continue;
          }
          for (final String bad in forbidden) {
            if (line.contains(bad)) {
              offences.add('${file.path}:${i + 1} -> $line');
            }
          }
        }
      }
      expect(
        offences,
        isEmpty,
        reason:
            'lib/engine must stay pure Dart so it runs without a device.\n'
            '${offences.join('\n')}',
      );
    });

    test('engine files only import core, engine or plain dart libraries', () {
      final RegExp importLine = RegExp(r'''^import\s+'([^']+)';''');
      final List<String> offences = <String>[];
      for (final File file in dartFilesIn('lib/engine')) {
        for (final String raw in file.readAsLinesSync()) {
          final RegExpMatch? match = importLine.firstMatch(raw.trim());
          if (match == null) {
            continue;
          }
          final String target = match.group(1)!;
          final bool allowed =
              target.startsWith('dart:math') ||
              target.startsWith('dart:convert') ||
              target.startsWith('dart:collection') ||
              target.startsWith('package:baon/core/') ||
              target.startsWith('package:baon/engine/') ||
              target.startsWith('package:meta/') ||
              !target.contains(':');
          if (!allowed) {
            offences.add('${file.path} -> $target');
          }
        }
      }
      expect(offences, isEmpty, reason: offences.join('\n'));
    });
  });

  group('injected clock', () {
    test('DateTime.now() appears only in core/clock.dart', () {
      final List<String> offences = <String>[];
      for (final File file in dartFilesIn(lib.path)) {
        final String normalised = file.path.replaceAll(r'\', '/');
        if (normalised.endsWith('lib/core/clock.dart')) {
          continue;
        }
        if (normalised.endsWith('.g.dart')) {
          continue;
        }
        final List<String> lines = file.readAsLinesSync();
        for (int i = 0; i < lines.length; i++) {
          if (lines[i].contains('DateTime.now()')) {
            offences.add('$normalised:${i + 1}');
          }
        }
      }
      expect(
        offences,
        isEmpty,
        reason:
            'Inject a Clock instead. See BUILD_PLAN.md Section 16.\n'
            '${offences.join('\n')}',
      );
    });
  });

  group('logging', () {
    test('no balance or amount value is written to a log statement', () {
      final RegExp logCall = RegExp(r'\b(print|debugPrint|log)\s*\(');
      final RegExp moneyish = RegExp(
        r'\b(balance|cents|centavos|amount|spendable|runway)\b',
        caseSensitive: false,
      );
      final List<String> offences = <String>[];
      for (final File file in dartFilesIn(lib.path)) {
        final List<String> lines = file.readAsLinesSync();
        for (int i = 0; i < lines.length; i++) {
          final String line = lines[i];
          if (logCall.hasMatch(line) && moneyish.hasMatch(line)) {
            offences.add('${file.path}:${i + 1} -> ${line.trim()}');
          }
        }
      }
      expect(
        offences,
        isEmpty,
        reason:
            'BUILD_PLAN.md Section 12: never write a balance to a log.\n'
            '${offences.join('\n')}',
      );
    });
  });
}
