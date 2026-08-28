/// DTO for Feedback submissions.
/// Contains only the fields required by the Edge Function payload.
class FeedbackDto {
  final String name;
  final String email;
  final String subject;
  final String message;

  const FeedbackDto({
    required this.name,
    required this.email,
    required this.subject,
    required this.message,
  });

  /// Serialize to the JSON shape expected by the Edge Function.
  Map<String, dynamic> toJson() {
    return {
      'name': name.trim(),
      'email': email.trim(),
      'subject': subject.trim(),
      'message': message.trim(),
    };
  }
}
