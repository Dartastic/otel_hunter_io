// Licensed under the Apache License, Version 2.0
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:otel_hunter_io/otel_hunter_io.dart';

/// Traces Hunter.io calls with OpenTelemetry.
///
/// `otel_hunter_io` depends on the OpenTelemetry API only, so the application
/// initializes an SDK once at startup. Wrap each Hunter.io call in
/// [tracedHunterIo]; the `invoke` callback makes the real call and reports what
/// came back, which is recorded on the span.
Future<void> main() async {
  await OTel.initialize(serviceName: 'hunter-io-example');

  // Wraps a Hunter.io API call in a CLIENT span.
  final hunterIoId = await tracedHunterIo<String>(
    operation: 'leads.create',
    invoke: () async {
      // Make the Hunter.io call here, then report what it returned.
      const id = 'hunter_io_8f3a2c';
      return const HunterIoCallResult(
          value: id,
          result: HunterIoResult(
              domain: 'example',
              companyName: 'example',
              companyType: 'saas',
              emailPattern: '{first}.{last}@{domain}',
              emailsReturned: 1,
              totalEmailsAvailable: 1,
              verificationResult: 'deliverable',
              score: 1,
              smtpCheck: true,
              disposable: true,
              webmail: true,
              acceptAll: true,
              creditsRequests: 1,
              creditsVerifications: 1,
              creditsRemainingRequests: 1,
              creditsRemainingVerifications: 1,
              statusCode: 201));
    },
  );
  OTelLog.info('tracedHunterIo leads.create returned $hunterIoId');

  // Calls that should not be traced, such as health checks, run inside
  // runWithoutHunterIoInstrumentationAsync.
  await runWithoutHunterIoInstrumentationAsync(
    () => tracedHunterIo<String>(
      operation: 'leads.create',
      invoke: () async {
        const id = 'hunter_io_8f3a2c';
        return const HunterIoCallResult(
            value: id,
            result: HunterIoResult(
                domain: 'example',
                companyName: 'example',
                companyType: 'saas',
                emailPattern: '{first}.{last}@{domain}',
                emailsReturned: 1,
                totalEmailsAvailable: 1,
                verificationResult: 'deliverable',
                score: 1,
                smtpCheck: true,
                disposable: true,
                webmail: true,
                acceptAll: true,
                creditsRequests: 1,
                creditsVerifications: 1,
                creditsRemainingRequests: 1,
                creditsRemainingVerifications: 1,
                statusCode: 201));
      },
    ),
  );

  await OTel.shutdown();
}
