# Kin Capital Rails API Client
# Single point of truth for the backend contract. Every call maps 1:1 to
# an endpoint in the FastAPI backend (app.py).
# Base URL overridable via --dart-define=API_BASE_URL (Google Antigravity / emulator friendly)

import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/api_models.dart';

class ApiService {
  ApiService({String? baseUrl})
      : baseUrl = baseUrl ?? _defaultBaseUrl();

  final String baseUrl;

  /// Emulator: 10.0.2.2 maps to host localhost.
  /// Physical device / Antigravity: pass the host LAN IP via --dart-define.
  static String _defaultBaseUrl() {
    const fromEnv = String.fromEnvironment('API_BASE_URL');
    if (fromEnv.isNotEmpty) return fromEnv;
    if (!kIsWeb && Platform.isAndroid) return 'http://10.0.2.2:8000';
    return 'http://localhost:8000';
  }

  static const _timeout = Duration(seconds: 15);

  Future<Map<String, dynamic>> _get(String path) async {
    final uri = Uri.parse('$baseUrl$path');
    final resp = await http.get(uri).timeout(_timeout);
    return _decode(resp, uri);
  }

  Future<Map<String, dynamic>> _post(String path, Map<String, dynamic> body) async {
    final uri = Uri.parse('$baseUrl$path');
    final resp = await http
        .post(uri, headers: {'Content-Type': 'application/json'}, body: jsonEncode(body))
        .timeout(_timeout);
    return _decode(resp, uri);
  }

  Map<String, dynamic> _decode(http.Response resp, Uri uri) {
    if (resp.statusCode >= 400) {
      throw ApiException('${resp.statusCode}: ${resp.body}', uri: uri);
    }
    final data = jsonDecode(resp.body) as Map<String, dynamic>;
    return data;
  }

  // ── Endpoints ──────────────────────────────────────────────────────────

  /// GET /health — mode, model, service status
  Future<HealthStatus> health() async {
    final d = await _get('/health');
    return HealthStatus.fromJson(d);
  }

  /// POST /ingest — unify one cash-flow event into the entity ledger
  Future<LedgerEntry> ingest({
    required String entityId,
    required String eventType,
    required double amount,
    String currency = 'USD',
    String? timestamp,
    String counterparty = '',
    Map<String, dynamic>? meta,
  }) async {
    final d = await _post('/ingest', {
      'entity_id': entityId,
      'event_type': eventType,
      'amount': amount,
      'currency': currency,
      'timestamp': timestamp ?? DateTime.now().toIso8601String(),
      'counterparty': counterparty,
      'meta': meta ?? {},
    });
    return LedgerEntry.fromJson(d);
  }

  /// GET /ledger/{entity_id}
  Future<LedgerResponse> ledger(String entityId) async {
    final d = await _get('/ledger/$entityId');
    return LedgerResponse.fromJson(d);
  }

  /// POST /credit-offer — explainable credit decision
  Future<CreditOffer> creditOffer(String entityId, {double requestedAmount = 0}) async {
    final d = await _post('/credit-offer', {
      'entity_id': entityId,
      'requested_amount': requestedAmount,
    });
    return CreditOffer.fromJson(d);
  }

  /// POST /risk-score
  Future<RiskScore> riskScore(String entityId) async {
    final d = await _post('/risk-score', {'entity_id': entityId});
    return RiskScore.fromJson(d);
  }

  /// POST /route-transfer — cheapest remittance routing
  Future<RouteResult> routeTransfer({
    required String fromEntity,
    required String toEntity,
    required double amount,
    String currency = 'USD',
  }) async {
    final d = await _post('/route-transfer', {
      'from_entity': fromEntity,
      'to_entity': toEntity,
      'amount': amount,
      'currency': currency,
    });
    return RouteResult.fromJson(d);
  }

  /// GET /audit/{entity_id}
  Future<AuditResponse> audit(String entityId) async {
    final d = await _get('/audit/$entityId');
    return AuditResponse.fromJson(d);
  }

  /// POST /orchestrate — full agentic loop (perceive → reason → plan → act → reflect)
  Future<OrchestrationResult> orchestrate(String entityId, {String intent = 'assess credit worthiness'}) async {
    final d = await _post('/orchestrate', {
      'entity_id': entityId,
      'intent': intent,
    });
    return OrchestrationResult.fromJson(d);
  }
}

class ApiException implements Exception {
  ApiException(this.message, {this.uri});
  final String message;
  final Uri? uri;

  @override
  String toString() => 'ApiException($message${uri != null ? ' @ $uri' : ''})';
}
