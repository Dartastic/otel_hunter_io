// Licensed under the Apache License, Version 2.0
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry_api/dartastic_opentelemetry_api.dart';

import 'otel_hunter_io_suppression.dart';

const _tracerName = 'dartastic_otel_libs_hunter_io';

APITracer _tracer() => OTelAPI.tracerProvider().getTracer(_tracerName);

class HunterIoResult {
  /// Creates a result.
  const HunterIoResult({
    this.domain,
    this.companyName,
    this.companyType,
    this.emailPattern,
    this.emailsReturned,
    this.totalEmailsAvailable,
    this.verificationResult,
    this.score,
    this.smtpCheck,
    this.disposable,
    this.webmail,
    this.acceptAll,
    this.creditsRequests,
    this.creditsVerifications,
    this.creditsRemainingRequests,
    this.creditsRemainingVerifications,
    this.statusCode,
  });

  /// Target domain for domain/email-finder requests.
  final String? domain;

  /// Resolved company name (Hunter does light enrichment).
  final String? companyName;

  /// `saas` / `ecommerce` / `marketing` / `agency` / `news` / etc.
  final String? companyType;

  /// `{first}.{last}@{domain}` / `{first_initial}{last}@{domain}` /
  /// `{first}@{domain}` etc.
  final String? emailPattern;

  /// How many emails returned this request.
  final int? emailsReturned;

  /// Total Hunter has for the domain (paged).
  final int? totalEmailsAvailable;

  /// `deliverable` / `undeliverable` / `risky` / `unknown` — verifier
  /// outcome.
  final String? verificationResult;

  /// Hunter's confidence score (0-100).
  final int? score;

  /// `true` if Hunter's SMTP probe succeeded.
  final bool? smtpCheck;

  final bool? disposable;
  final bool? webmail;

  /// `true` when the domain accepts every email (verifier can't be
  /// sure if a specific address is real).
  final bool? acceptAll;

  /// Hunter splits credits into two pools: search/find requests and
  /// verification requests.
  final int? creditsRequests;
  final int? creditsVerifications;

  final int? creditsRemainingRequests;
  final int? creditsRemainingVerifications;

  final int? statusCode;
}

/// What a traced call returned: the value for the caller plus fields
/// recorded on the span.
class HunterIoCallResult<T> {
  /// Creates a call result.
  const HunterIoCallResult({required this.value, this.result});

  /// The value returned to the caller.
  final T value;
  final HunterIoResult? result;
}

/// Wraps a Hunter.io API call in a CLIENT span. [operation] is one of
/// `domain.search`, `email.finder`, `email.verifier`,
/// `email_count`, `combined.find`, `account`, `leads.list`,
/// `leads.create`, `leads_lists.list`, `companies.find`.
Future<T> tracedHunterIo<T>({
  required String operation,
  required Future<HunterIoCallResult<T>> Function() invoke,
}) async {
  if (hunterIoInstrumentationSuppressed()) {
    final r = await invoke();
    return r.value;
  }
  final m = <String, Object>{
    'rpc.system': 'hunter_io',
    'rpc.method': operation,
    'hunter_io.operation': operation,
  };

  final span = _tracer().startSpan(
    'hunter_io $operation',
    kind: SpanKind.client,
    attributes: OTelAPI.attributesFromMap(m),
  );
  try {
    final r = await invoke();
    if (r.result != null) {
      final extras = <Attribute<Object>>[];
      if (r.result!.domain != null) {
        extras.add(OTelAPI.attributeString(
          'hunter_io.domain',
          r.result!.domain!,
        ));
      }
      if (r.result!.companyName != null) {
        extras.add(OTelAPI.attributeString(
          'hunter_io.company.name',
          r.result!.companyName!,
        ));
      }
      if (r.result!.companyType != null) {
        extras.add(OTelAPI.attributeString(
          'hunter_io.company.type',
          r.result!.companyType!,
        ));
      }
      if (r.result!.emailPattern != null) {
        extras.add(OTelAPI.attributeString(
          'hunter_io.email.pattern',
          r.result!.emailPattern!,
        ));
      }
      if (r.result!.emailsReturned != null) {
        extras.add(OTelAPI.attributeInt(
          'hunter_io.emails.returned',
          r.result!.emailsReturned!,
        ));
      }
      if (r.result!.totalEmailsAvailable != null) {
        extras.add(OTelAPI.attributeInt(
          'hunter_io.emails.total_available',
          r.result!.totalEmailsAvailable!,
        ));
      }
      if (r.result!.verificationResult != null) {
        extras.add(OTelAPI.attributeString(
          'hunter_io.verification.result',
          r.result!.verificationResult!,
        ));
        if (r.result!.verificationResult == 'undeliverable') {
          span.setStatus(
            SpanStatusCode.Error,
            'Hunter.io verification undeliverable',
          );
        }
      }
      if (r.result!.score != null) {
        extras.add(OTelAPI.attributeInt(
          'hunter_io.score',
          r.result!.score!,
        ));
      }
      if (r.result!.smtpCheck != null) {
        extras.add(OTelAPI.attributeBool(
          'hunter_io.smtp_check',
          r.result!.smtpCheck!,
        ));
      }
      if (r.result!.disposable != null) {
        extras.add(OTelAPI.attributeBool(
          'hunter_io.disposable',
          r.result!.disposable!,
        ));
      }
      if (r.result!.webmail != null) {
        extras.add(OTelAPI.attributeBool(
          'hunter_io.webmail',
          r.result!.webmail!,
        ));
      }
      if (r.result!.acceptAll != null) {
        extras.add(OTelAPI.attributeBool(
          'hunter_io.accept_all',
          r.result!.acceptAll!,
        ));
      }
      if (r.result!.creditsRequests != null) {
        extras.add(OTelAPI.attributeInt(
          'hunter_io.credits.requests',
          r.result!.creditsRequests!,
        ));
      }
      if (r.result!.creditsVerifications != null) {
        extras.add(OTelAPI.attributeInt(
          'hunter_io.credits.verifications',
          r.result!.creditsVerifications!,
        ));
      }
      if (r.result!.creditsRemainingRequests != null) {
        extras.add(OTelAPI.attributeInt(
          'hunter_io.credits.remaining.requests',
          r.result!.creditsRemainingRequests!,
        ));
      }
      if (r.result!.creditsRemainingVerifications != null) {
        extras.add(OTelAPI.attributeInt(
          'hunter_io.credits.remaining.verifications',
          r.result!.creditsRemainingVerifications!,
        ));
      }
      if (r.result!.statusCode != null) {
        extras.add(OTelAPI.attributeInt(
          'http.response.status_code',
          r.result!.statusCode!,
        ));
        if (r.result!.statusCode! >= 400) {
          span.setStatus(
            SpanStatusCode.Error,
            'Hunter.io HTTP ${r.result!.statusCode}',
          );
        }
      }
      if (extras.isNotEmpty) span.addAttributes(OTelAPI.attributes(extras));
    }
    return r.value;
  } catch (e, st) {
    span.addAttributes(OTelAPI.attributes([
      OTelAPI.attributeString(
        ErrorAttributes.errorType.key,
        e.runtimeType.toString(),
      ),
    ]));
    span.recordException(e, stackTrace: st);
    span.setStatus(SpanStatusCode.Error, e.toString());
    rethrow;
  } finally {
    span.end();
  }
}
