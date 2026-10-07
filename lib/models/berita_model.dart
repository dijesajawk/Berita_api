class BeritaResponse {
  final String message;
  final int total;
  final List<Berita> data;

  BeritaResponse({
    required this.message,
    required this.total,
    required this.data,
  });

  factory BeritaResponse.fromJson(Map<String, dynamic> json) {
    return BeritaResponse(
      message: json['message'] ?? '',
      total: json['total'] ?? 0,
      data: (json['data'] as List)
          .map((item) => Berita.fromJson(item))
          .toList(),
    );
  }
}

class Berita {
  final String title;
  final String link;
  final String contentSnippet;
  final String isoDate;
  final BeritaImage? image;

  Berita({
    required this.title,
    required this.link,
    required this.contentSnippet,
    required this.isoDate,
    this.image,
  });

  factory Berita.fromJson(Map<String, dynamic> json) {
    return Berita(
      title: json['title'] ?? '',
      link: json['link'] ?? '',
      contentSnippet: json['contentSnippet'] ?? '',
      isoDate: json['isoDate'] ?? '',
      image: json['image'] != null
          ? BeritaImage.fromJson(json['image'])
          : null,
    );
  }
}

class BeritaImage {
  final String small;
  final String large;

  BeritaImage({required this.small, required this.large});

  factory BeritaImage.fromJson(Map<String, dynamic> json) {
    return BeritaImage(
      small: json['small'] ?? '',
      large: json['large'] ?? '',
    );
  }
}