// API models — mirror the FastAPI pydantic response schemas from app.py.
// Hand-written to avoid generated-code bloat. Every field maps 1:1.

class HealthStatus {
  final String status;
  final String service;
  final String orchestratorMode;
  final String impalaModel;
  final bool modelLoaded;
  HealthStatus({
    required this.status,
    required this.service,
    required this.orchestratorMode,
    required this.impalaModel,
    required this.modelLoaded,
  });
  factory HealthStatus.fromJson(Map<String, dynamic> j) => HealthStatus(
        status: j['status'] as String? ?? 'ok',
        service: j['service'] as String? ?? '',
        orchestratorMode: j['orchestrator_mode'] as String? ?? 'deterministic',
        impalaModel: j['impala_model'] as String? ?? '',
        modelLoaded: j['model_loaded'] as bool? ?? false,
      );
}

class LedgerEntry {
  final String entityId;
  final String eventType;
  final double amount;
  final String currency;
  final String timestamp;
  final String counterparty;
  LedgerEntry({
    required this.entityId,
    required this.eventType,
    required this.amount,
    required this.currency,
    required this.timestamp,
    required this.counterparty,
  });
  factory LedgerEntry.fromJson(Map<String, dynamic> j) => LedgerEntry(
        entityId: j['entity_id'] as String? ?? '',
        eventType: j['event_type'] as String? ?? '',
        amount: (j['amount'] as num?)?.toDouble() ?? 0,
        currency: j['currency'] as String? ?? 'USD',
        timestamp: j['timestamp'] as String? ?? '',
        counterparty: j['counterparty'] as String? ?? '',
      );
}

class LedgerResponse {
  final String entityId;
  final List<LedgerEntry> entries;
  final int totalEntries;
  LedgerResponse({
    required this.entityId,
    required this.entries,
    required this.totalEntries,
  });
  factory LedgerResponse.fromJson(Map<String, dynamic> j) {
    final raw = j['entries'] as List<dynamic>? ?? [];
    return LedgerResponse(
      entityId: j['entity_id'] as String? ?? '',
      entries: raw.map((e) => LedgerEntry.fromJson(e as Map<String, dynamic>)).toList(),
      totalEntries: j['total_entries'] as int? ?? raw.length,
    );
  }
}

class CreditOffer {
  final String entityId;
  final double creditScore;
  final double riskScore;
  final double recommendedLimit;
  final String explanation;
  final bool escalated;
  final String escalationReason;
  CreditOffer({
    required this.entityId,
    required this.creditScore,
    required this.riskScore,
    required this.recommendedLimit,
    required this.explanation,
    required this.escalated,
    required this.escalationReason,
  });
  factory CreditOffer.fromJson(Map<String, dynamic> j) => CreditOffer(
        entityId: j['entity_id'] as String? ?? '',
        creditScore: (j['credit_score'] as num?)?.toDouble() ?? 0,
        riskScore: (j['risk_score'] as num?)?.toDouble() ?? 0,
        recommendedLimit: (j['recommended_limit'] as num?)?.toDouble() ?? 0,
        explanation: j['explanation'] as String? ?? '',
        escalated: j['escalated'] as bool? ?? false,
        escalationReason: j['escalation_reason'] as String? ?? '',
      );
}

class RiskScore {
  final String entityId;
  final double riskScore;
  final Map<String, dynamic> features;
  final String modelVersion;
  RiskScore({
    required this.entityId,
    required this.riskScore,
    required this.features,
    required this.modelVersion,
  });
  factory RiskScore.fromJson(Map<String, dynamic> j) => RiskScore(
        entityId: j['entity_id'] as String? ?? '',
        riskScore: (j['risk_score'] as num?)?.toDouble() ?? 0,
        features: j['features'] as Map<String, dynamic>? ?? {},
        modelVersion: j['model_version'] as String? ?? '',
      );
}

class RouteResult {
  final String id;
  final String fromEntity;
  final String toEntity;
  final double amount;
  final String currency;
  final String selectedRoute;
  final double fee;
  final double feePct;
  final String eta;
  final List<Map<String, dynamic>> alternatives;
  RouteResult({
    required this.id,
    required this.fromEntity,
    required this.toEntity,
    required this.amount,
    required this.currency,
    required this.selectedRoute,
    required this.fee,
    required this.feePct,
    required this.eta,
    required this.alternatives,
  });
  factory RouteResult.fromJson(Map<String, dynamic> j) => RouteResult(
        id: j['id'] as String? ?? '',
        fromEntity: j['from_entity'] as String? ?? '',
        toEntity: j['to_entity'] as String? ?? '',
        amount: (j['amount'] as num?)?.toDouble() ?? 0,
        currency: j['currency'] as String? ?? 'USD',
        selectedRoute: j['selected_route'] as String? ?? '',
        fee: (j['fee'] as num?)?.toDouble() ?? 0,
        feePct: (j['fee_pct'] as num?)?.toDouble() ?? 0,
        eta: j['eta'] as String? ?? '',
        alternatives: (j['alternatives'] as List<dynamic>?)
                ?.map((a) => a as Map<String, dynamic>)
                .toList() ??
            [],
      );
}

class AuditResponse {
  final String entityId;
  final List<Map<String, dynamic>> logs;
  AuditResponse({required this.entityId, required this.logs});
  factory AuditResponse.fromJson(Map<String, dynamic> j) => AuditResponse(
        entityId: j['entity_id'] as String? ?? '',
        logs: (j['logs'] as List<dynamic>?)
                ?.map((l) => l as Map<String, dynamic>)
                .toList() ??
            [],
      );
}

class OrchestrationResult {
  final String entityId;
  final String intent;
  final Map<String, dynamic> state;
  final String? llmReasoning;
  final List<String> plan;
  final Map<String, dynamic>? results;
  final Map<String, dynamic>? reflection;
  OrchestrationResult({
    required this.entityId,
    required this.intent,
    required this.state,
    this.llmReasoning,
    required this.plan,
    this.results,
    this.reflection,
  });
  factory OrchestrationResult.fromJson(Map<String, dynamic> j) => OrchestrationResult(
        entityId: j['entity_id'] as String? ?? '',
        intent: j['intent'] as String? ?? '',
        state: j['state'] as Map<String, dynamic>? ?? {},
        llmReasoning: j['llm_reasoning'] as String?,
        plan: (j['plan'] as List<dynamic>?)?.map((p) => p.toString()).toList() ?? [],
        results: j['results'] as Map<String, dynamic>?,
        reflection: j['reflection'] as Map<String, dynamic>?,
      );
}

class KycSubmitResult {
  final String entityId;
  final String kycStatus; // verified | pending | flagged
  final bool sanctionsMatch;
  final List<String> checks;
  final List<String> flags;
  final String status; // PASSED | PENDING_REVIEW | FLAGGED

  KycSubmitResult({
    required this.entityId,
    required this.kycStatus,
    required this.sanctionsMatch,
    required this.checks,
    required this.flags,
    required this.status,
  });

  bool get isPassed => status == 'PASSED' || kycStatus == 'verified';
  bool get isPending => status == 'PENDING_REVIEW' || kycStatus == 'pending';
  bool get isFlagged => status == 'FLAGGED' || kycStatus == 'flagged' || sanctionsMatch;

  factory KycSubmitResult.fromJson(Map<String, dynamic> j) => KycSubmitResult(
        entityId: j['entity_id'] as String? ?? '',
        kycStatus: j['kyc_status'] as String? ?? 'verified',
        sanctionsMatch: j['sanctions_match'] as bool? ?? false,
        checks: (j['checks'] as List<dynamic>?)?.map((c) => c.toString()).toList() ?? [],
        flags: (j['flags'] as List<dynamic>?)?.map((f) => f.toString()).toList() ?? [],
        status: j['status'] as String? ?? 'PASSED',
      );
}

typedef KycSubmitResponse = KycSubmitResult;
