class CurrentUser {
  final String name;
  final String email;
  final String? profilePictureUrl; // This can be nullable in case the user doesn't have a profile picture.

  CurrentUser({
    required this.name,
    required this.email,
    this.profilePictureUrl,
  });
}