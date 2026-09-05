// lib/app/data/models/faq_model.dart

class FAQ {
  final int id;
  final String question;
  final String answer;
  final String type; // general, account, service
  final DateTime createdAt;
  final DateTime updatedAt;

  FAQ({
    required this.id,
    required this.question,
    required this.answer,
    required this.type,
    required this.createdAt,
    required this.updatedAt,
  });

  factory FAQ.fromJson(Map<String, dynamic> json) {
    return FAQ(
      id: json['id'],
      question: json['question'],
      answer: json['answer'],
      type: json['type'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}

// lib/app/modules/help/model/contact_option_model.dart

class ContactOption {
  final int id;
  final String name;
  final String icon; // URL
  final String link;

  ContactOption({
    required this.id,
    required this.name,
    required this.icon,
    required this.link,
  });

  factory ContactOption.fromJson(Map<String, dynamic> json) {
    return ContactOption(
      id: json['id'],
      name: json['name'],
      icon: json['icon'],
      link: json['link'],
    );
  }
}
