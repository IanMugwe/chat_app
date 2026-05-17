enum MessageType { text, image, video, audio, file, system }
enum MessageStatus { sent, edited, deleted, failed }

String enumName(Object e) => e.toString().split('.').last;

T enumFromString<T>(List<T> values, String? value, T fallback) {
  if (value == null) return fallback;
  return values.firstWhere(
    (e) => enumName(e as Object) == value,
    orElse: () => fallback,
  );
}
