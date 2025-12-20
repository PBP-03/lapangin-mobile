class EarningsModel {
  final String mitraId;
  final String mitraName;
  final String mitraEmail;
  final String mitraPhone;
  final double totalEarnings;
  final int completedTransactions;

  EarningsModel({
    required this.mitraId,
    required this.mitraName,
    required this.mitraEmail,
    required this.mitraPhone,
    required this.totalEarnings,
    required this.completedTransactions,
  });

  factory EarningsModel.fromJson(Map<String, dynamic> json) {
    return EarningsModel(
      mitraId: json['mitra_id'] ?? '',
      mitraName: json['mitra_name'] ?? '',
      mitraEmail: json['mitra_email'] ?? '',
      mitraPhone: json['mitra_phone'] ?? '-',
      totalEarnings: (json['total_earnings'] is String)
          ? double.tryParse(json['total_earnings']) ?? 0.0
          : (json['total_earnings'] as num?)?.toDouble() ?? 0.0,
      completedTransactions: json['completed_transactions'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'mitra_id': mitraId,
      'mitra_name': mitraName,
      'mitra_email': mitraEmail,
      'mitra_phone': mitraPhone,
      'total_earnings': totalEarnings,
      'completed_transactions': completedTransactions,
    };
  }
}

class MitraInfo {
  final String id;
  final String name;
  final String email;
  final String phoneNumber;
  final bool isVerified;

  MitraInfo({
    required this.id,
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.isVerified,
  });

  factory MitraInfo.fromJson(Map<String, dynamic> json) {
    return MitraInfo(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phone_number'] ?? '-',
      isVerified: json['is_verified'] ?? false,
    );
  }
}

class EarningsSummary {
  final double totalEarnings;
  final double totalCommission;
  final int totalTransactions;

  EarningsSummary({
    required this.totalEarnings,
    required this.totalCommission,
    required this.totalTransactions,
  });

  factory EarningsSummary.fromJson(Map<String, dynamic> json) {
    return EarningsSummary(
      totalEarnings: (json['total_earnings'] is String)
          ? double.tryParse(json['total_earnings']) ?? 0.0
          : (json['total_earnings'] as num?)?.toDouble() ?? 0.0,
      totalCommission: (json['total_commission'] is String)
          ? double.tryParse(json['total_commission']) ?? 0.0
          : (json['total_commission'] as num?)?.toDouble() ?? 0.0,
      totalTransactions: json['total_transactions'] ?? 0,
    );
  }
}

class TransactionModel {
  final String pendapatanId;
  final String id;
  final String bookingId;
  final String customerName;
  final String venueName;
  final String courtName;
  final String bookingDate;
  final String timeSlot;
  final double amount;
  final double commissionRate;
  final double commissionAmount;
  final double netAmount;
  final String paymentStatus;
  final String? paidAt;
  final String createdAt;

  TransactionModel({
    required this.pendapatanId,
    required this.id,
    required this.bookingId,
    required this.customerName,
    required this.venueName,
    required this.courtName,
    required this.bookingDate,
    required this.timeSlot,
    required this.amount,
    required this.commissionRate,
    required this.commissionAmount,
    required this.netAmount,
    required this.paymentStatus,
    this.paidAt,
    required this.createdAt,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      pendapatanId: json['pendapatan_id'] ?? json['id'] ?? '',
      id: json['id'] ?? '',
      bookingId: json['booking_id'] ?? '',
      customerName: json['customer_name'] ?? '',
      venueName: json['venue_name'] ?? '',
      courtName: json['court_name'] ?? '',
      bookingDate: json['booking_date'] ?? '',
      timeSlot: json['time_slot'] ?? '',
      amount: (json['amount'] is String)
          ? double.tryParse(json['amount']) ?? 0.0
          : (json['amount'] as num?)?.toDouble() ?? 0.0,
      commissionRate: (json['commission_rate'] is String)
          ? double.tryParse(json['commission_rate']) ?? 0.0
          : (json['commission_rate'] as num?)?.toDouble() ?? 0.0,
      commissionAmount: (json['commission_amount'] is String)
          ? double.tryParse(json['commission_amount']) ?? 0.0
          : (json['commission_amount'] as num?)?.toDouble() ?? 0.0,
      netAmount: (json['net_amount'] is String)
          ? double.tryParse(json['net_amount']) ?? 0.0
          : (json['net_amount'] as num?)?.toDouble() ?? 0.0,
      paymentStatus: json['payment_status'] ?? '',
      paidAt: json['paid_at'],
      createdAt: json['created_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pendapatan_id': pendapatanId,
      'id': id,
      'booking_id': bookingId,
      'customer_name': customerName,
      'venue_name': venueName,
      'court_name': courtName,
      'booking_date': bookingDate,
      'time_slot': timeSlot,
      'amount': amount,
      'commission_rate': commissionRate,
      'commission_amount': commissionAmount,
      'net_amount': netAmount,
      'payment_status': paymentStatus,
      'paid_at': paidAt,
      'created_at': createdAt,
    };
  }
}

class MitraEarningsDetail {
  final MitraInfo mitra;
  final EarningsSummary summary;
  final List<TransactionModel> transactions;

  MitraEarningsDetail({
    required this.mitra,
    required this.summary,
    required this.transactions,
  });

  factory MitraEarningsDetail.fromJson(Map<String, dynamic> json) {
    return MitraEarningsDetail(
      mitra: MitraInfo.fromJson(json['mitra'] ?? {}),
      summary: EarningsSummary.fromJson(json['summary'] ?? {}),
      transactions:
          (json['transactions'] as List<dynamic>?)
              ?.map((t) => TransactionModel.fromJson(t as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class RefundModel {
  final String id;
  final String mitraName;
  final String mitraId;
  final String customerName;
  final String venueName;
  final String courtName;
  final double amount;
  final String reason;
  final String refundedAt;
  final String? originalPaidAt;

  RefundModel({
    required this.id,
    required this.mitraName,
    required this.mitraId,
    required this.customerName,
    required this.venueName,
    required this.courtName,
    required this.amount,
    required this.reason,
    required this.refundedAt,
    this.originalPaidAt,
  });

  factory RefundModel.fromJson(Map<String, dynamic> json) {
    return RefundModel(
      id: json['id'] ?? '',
      mitraName: json['mitra_name'] ?? '',
      mitraId: json['mitra_id'] ?? '',
      customerName: json['customer_name'] ?? '',
      venueName: json['venue_name'] ?? '',
      courtName: json['court_name'] ?? '',
      amount: (json['amount'] is String)
          ? double.tryParse(json['amount']) ?? 0.0
          : (json['amount'] as num?)?.toDouble() ?? 0.0,
      reason: json['reason'] ?? '',
      refundedAt: json['refunded_at'] ?? '',
      originalPaidAt: json['original_paid_at'],
    );
  }
}

