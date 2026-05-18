// Licensed under the Dartastic Pro Software License Agreement.
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:dartastic_opentelemetry/testing.dart';
import 'package:otel_hunter_io/otel_hunter_io.dart';
import 'package:test/test.dart';

void main() {
  late TestHarness harness;
  late InMemorySpanExporter spans;

  setUpAll(() async {
    harness = await maybeInitializeOtelForTest(
      serviceName: 'otel_hunter_io-test',
    );
    spans = harness.spans;
  });

  setUp(() => harness.clear());

  Map<String, Object> attrsOf(Span s) =>
      {for (final a in s.attributes.toList()) a.key: a.value};

  test('domain.search records domain + pattern + emails', () async {
    await tracedHunterIo<String>(
      operation: 'domain.search',
      invoke: () async => const HunterIoCallResult(
        value: 'ok',
        result: HunterIoResult(
          domain: 'example.com',
          companyName: 'Example Inc.',
          companyType: 'saas',
          emailPattern: '{first}.{last}@{domain}',
          emailsReturned: 10,
          totalEmailsAvailable: 87,
          creditsRequests: 1,
          creditsRemainingRequests: 4999,
          statusCode: 200,
        ),
      ),
    );
    final a = attrsOf(spans.findSpanByName('hunter_io domain.search')!);
    expect(a['hunter_io.domain'], 'example.com');
    expect(a['hunter_io.email.pattern'], '{first}.{last}@{domain}');
    expect(a['hunter_io.emails.returned'], 10);
    expect(a['hunter_io.emails.total_available'], 87);
    expect(a['hunter_io.credits.remaining.requests'], 4999);
  });

  test('email.verifier deliverable records score + checks', () async {
    await tracedHunterIo<String>(
      operation: 'email.verifier',
      invoke: () async => const HunterIoCallResult(
        value: 'ok',
        result: HunterIoResult(
          verificationResult: 'deliverable',
          score: 95,
          smtpCheck: true,
          disposable: false,
          webmail: false,
          acceptAll: false,
          creditsVerifications: 1,
          creditsRemainingVerifications: 999,
          statusCode: 200,
        ),
      ),
    );
    final a = attrsOf(spans.findSpanByName('hunter_io email.verifier')!);
    expect(a['hunter_io.verification.result'], 'deliverable');
    expect(a['hunter_io.score'], 95);
    expect(a['hunter_io.smtp_check'], true);
    expect(a['hunter_io.credits.verifications'], 1);
  });

  test('undeliverable sets span error', () async {
    await tracedHunterIo<String>(
      operation: 'email.verifier',
      invoke: () async => const HunterIoCallResult(
        value: 'ok',
        result: HunterIoResult(
          verificationResult: 'undeliverable',
          score: 12,
        ),
      ),
    );
    expect(
      spans.findSpanByName('hunter_io email.verifier')!.status,
      SpanStatusCode.Error,
    );
  });

  test('risky/accept_all does NOT set span error', () async {
    await tracedHunterIo<String>(
      operation: 'email.verifier',
      invoke: () async => const HunterIoCallResult(
        value: 'ok',
        result: HunterIoResult(
          verificationResult: 'risky',
          acceptAll: true,
          score: 65,
        ),
      ),
    );
    expect(
      spans.findSpanByName('hunter_io email.verifier')!.status,
      isNot(SpanStatusCode.Error),
    );
  });

  test('suppression skips spans', () async {
    await runWithoutHunterIoInstrumentationAsync(() async {
      await tracedHunterIo<String>(
        operation: 'account',
        invoke: () async => const HunterIoCallResult(value: 'v'),
      );
    });
    expect(spans.findSpansStartingWith('hunter_io '), isEmpty);
  });
}
