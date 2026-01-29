enum UiMessageType { info, success, warning, error }

class UiMessage {
  final String title;
  final String? subtitle;
  final UiMessageType type;

  UiMessage(this.title, {this.subtitle, this.type = UiMessageType.info});
}
