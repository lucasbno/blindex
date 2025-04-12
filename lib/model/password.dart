class Password {
  final String id;
  String title;
  String login;
  String password;
  String site;
  String notes;
  String icon;
  bool isFavorite;

  Password({
    required this.id,
    required this.title,
    required this.login,
    required this.password,
    this.site = '',
    this.notes = '',
    this.icon = '',
    this.isFavorite = false,
  });

  factory Password.create({
    required String title,
    required String login,
    required String password,
    String site = '',
    String notes = '',
    String icon = '',
    bool isFavorite = false,
  }) {
    return Password(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      login: login,
      password: password,
      site: site,
      notes: notes,
      icon: icon,
      isFavorite: isFavorite,
    );
  }

  factory Password.fromMap(Map<String, dynamic> map) {
    return Password(
      id: map['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: map['title'] ?? '',
      login: map['login'] ?? '',
      password: map['password'] ?? '',
      site: map['site'] ?? '',
      notes: map['notes'] ?? '',
      icon: map['icon'] ?? '',
      isFavorite: map['isFavorite'] == true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'login': login,
      'password': password,
      'site': site,
      'notes': notes,
      'icon': icon,
      'isFavorite': isFavorite,
    };
  }

  Password copyWith({
    String? title,
    String? login,
    String? password,
    String? site,
    String? notes,
    String? icon,
    bool? isFavorite,
  }) {
    return Password(
      id: id,
      title: title ?? this.title,
      login: login ?? this.login,
      password: password ?? this.password,
      site: site ?? this.site,
      notes: notes ?? this.notes,
      icon: icon ?? this.icon,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  @override
  String toString() {
    return 'Password(id: $id, title: $title, login: $login)';
  }
}