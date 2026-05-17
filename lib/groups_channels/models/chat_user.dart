class ChatUser {
  final String id;
  final String displayName;
  final String? photoUrl;

  const ChatUser({
    required this.id,
    required this.displayName,
    this.photoUrl,
  });

  factory ChatUser.fromMap(String id, Map<String, dynamic> data) {
    return ChatUser(
      id: id,
      displayName: data['displayName']?.toString() ?? 'User',
      photoUrl: data['photoUrl']?.toString(),
    );
  }

  Map<String, dynamic> toMap() => {
        'displayName': displayName,
        if (photoUrl != null) 'photoUrl': photoUrl,
      };
}
