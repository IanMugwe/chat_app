enum ChatScope { direct, group, channel }
enum ConversationType { direct, group, channel }
enum MemberRole { owner, admin, moderator, member, viewer, subscriber }
enum MessageType { text, image, video, audio, file, system }
enum MessageStatus { sent, edited, deleted, failed }
enum ChannelPostingPolicy { adminsOnly, subscribers }

String enumName(Object e) => e.toString().split('.').last;

T enumFromString<T>(List<T> values, String? value, T fallback) {
  if (value == null) return fallback;
  return values.firstWhere(
    (e) => enumName(e as Object) == value,
    orElse: () => fallback,
  );
}
