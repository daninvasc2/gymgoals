class CurrentUser {
  final String? id;
  final String name;
  final String email;
  final String? profilePictureUrl;

  CurrentUser({
    this.id,
    required this.name,
    required this.email,
    this.profilePictureUrl,
  });
}