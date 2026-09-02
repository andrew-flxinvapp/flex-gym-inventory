enum DeleteAccountReason {
  notUsingApp('not_using_app'),
  missingFeatures('missing_features'),
  technicalIssues('technical_issues'),
  difficultToUse('difficult_to_use'),
  notEnoughValue('not_enough_value'),
  privacyConcerns('privacy_concerns'),
  switchingApps('switching_apps'),
  other('other');

  const DeleteAccountReason(this.backendValue);

  final String backendValue;
}

class DeleteAccountDto {
  final DeleteAccountReason? reason;
  final String? details;

  const DeleteAccountDto({this.reason, this.details});

  Map<String, dynamic> toJson() {
    final payload = <String, dynamic>{};

    if (reason != null) {
      payload['reason'] = reason!.backendValue;
    }

    final cleanedDetails = details?.trim();
    if (cleanedDetails != null && cleanedDetails.isNotEmpty) {
      payload['details'] = cleanedDetails;
    }

    return payload;
  }
}
