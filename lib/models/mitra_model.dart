class MitraModel {
  final String id;
  final String nama;
  final String email;
  final String status; // 'pending', 'approved', 'rejected'
  final String? deskripsi;
  final String? gambar;
  final String tanggalDaftar;
  final List<CourtModel> courts;

  MitraModel({
    required this.id,
    required this.nama,
    required this.email,
    required this.status,
    this.deskripsi,
    this.gambar,
    required this.tanggalDaftar,
    required this.courts,
  });

  factory MitraModel.fromJson(Map<String, dynamic> json) {
    List<CourtModel> courtsList = [];
    if (json['courts'] != null) {
      courtsList = (json['courts'] as List)
          .map((court) => CourtModel.fromJson(court))
          .toList();
    }

    return MitraModel(
      id: json['id'] ?? '',
      nama: json['nama'] ?? '',
      email: json['email'] ?? '',
      status: json['status'] ?? 'pending',
      deskripsi: json['deskripsi'],
      gambar: json['gambar'],
      tanggalDaftar: json['tanggal_daftar'] ?? '',
      courts: courtsList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama': nama,
      'email': email,
      'status': status,
      'deskripsi': deskripsi,
      'gambar': gambar,
      'tanggal_daftar': tanggalDaftar,
      'courts': courts.map((c) => c.toJson()).toList(),
    };
  }
}

class CourtModel {
  final String categoryCode;
  final String categoryName;
  final int count;

  CourtModel({
    required this.categoryCode,
    required this.categoryName,
    required this.count,
  });

  factory CourtModel.fromJson(Map<String, dynamic> json) {
    return CourtModel(
      categoryCode: json['category_code'] ?? '',
      categoryName: json['category_name'] ?? '',
      count: json['count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'category_code': categoryCode,
      'category_name': categoryName,
      'count': count,
    };
  }
}
