class Booking {
  final String id;
  final String userId;
  final int courtId;
  final int? sessionId;
  final DateTime bookingDate;
  final String startTime; // Format: "HH:mm:ss"
  final String endTime; // Format: "HH:mm:ss"
  final double durationHours;
  final double totalPrice;
  final String
  bookingStatus; // 'pending', 'confirmed', 'cancelled', 'completed'
  final String paymentStatus; // 'unpaid', 'paid', 'refunded'
  final String? notes;
  final String? cancellationReason;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Additional info for display
  final String? venueName;
  final String? courtName;
  final Payment? payment;

  Booking({
    required this.id,
    required this.userId,
    required this.courtId,
    this.sessionId,
    required this.bookingDate,
    required this.startTime,
    required this.endTime,
    required this.durationHours,
    required this.totalPrice,
    required this.bookingStatus,
    required this.paymentStatus,
    this.notes,
    this.cancellationReason,
    required this.createdAt,
    required this.updatedAt,
    this.venueName,
    this.courtName,
    this.payment,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'] as String,
      userId: json['user'] as String? ?? json['user_id'] as String,
      courtId: json['court'] as int? ?? json['court_id'] as int,
      sessionId: json['session'] as int?,
      bookingDate: DateTime.parse(json['booking_date'] as String),
      startTime: json['start_time'] as String,
      endTime: json['end_time'] as String,
      durationHours: (json['duration_hours'] as num).toDouble(),
      totalPrice: (json['total_price'] as num).toDouble(),
      bookingStatus: json['booking_status'] as String,
      paymentStatus: json['payment_status'] as String,
      notes: json['notes'] as String?,
      cancellationReason: json['cancellation_reason'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      venueName: json['venue_name'] as String?,
      courtName: json['court_name'] as String?,
      payment: json['payment'] != null
          ? Payment.fromJson(json['payment'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user': userId,
      'court': courtId,
      'session': sessionId,
      'booking_date': bookingDate.toIso8601String().split('T')[0],
      'start_time': startTime,
      'end_time': endTime,
      'duration_hours': durationHours,
      'total_price': totalPrice,
      'booking_status': bookingStatus,
      'payment_status': paymentStatus,
      'notes': notes,
      'cancellation_reason': cancellationReason,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'venue_name': venueName,
      'court_name': courtName,
    };
  }

  bool get isPending => bookingStatus == 'pending';
  bool get isConfirmed => bookingStatus == 'confirmed';
  bool get isCancelled => bookingStatus == 'cancelled';
  bool get isCompleted => bookingStatus == 'completed';

  bool get isUnpaid => paymentStatus == 'unpaid';
  bool get isPaid => paymentStatus == 'paid';
  bool get isRefunded => paymentStatus == 'refunded';

  String get timeRange => '$startTime - $endTime';

  // Convenience getters for backward compatibility
  String get status => bookingStatus;
  String get userName =>
      userId; // In real app, this should be fetched from user data
}

class Payment {
  final String id;
  final String bookingId;
  final double amount;
  final String
  paymentMethod; // 'bank_transfer', 'e_wallet', 'credit_card', 'cash'
  final String? transactionId;
  final String? paymentProof;
  final String? verifiedBy;
  final String? notes;
  final DateTime? paidAt;
  final String? paymentStatus; // 'pending', 'completed', 'failed'

  Payment({
    required this.id,
    required this.bookingId,
    required this.amount,
    required this.paymentMethod,
    this.transactionId,
    this.paymentProof,
    this.verifiedBy,
    this.notes,
    this.paidAt,
    this.paymentStatus,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'] as String,
      bookingId: json['booking'] as String? ?? json['booking_id'] as String,
      amount: (json['amount'] as num).toDouble(),
      paymentMethod: json['payment_method'] as String,
      transactionId: json['transaction_id'] as String?,
      paymentProof: json['payment_proof'] as String?,
      verifiedBy: json['verified_by'] as String?,
      notes: json['notes'] as String?,
      paidAt: json['paid_at'] != null
          ? DateTime.parse(json['paid_at'] as String)
          : null,
      paymentStatus: json['payment_status'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'booking': bookingId,
      'amount': amount,
      'payment_method': paymentMethod,
      'transaction_id': transactionId,
      'payment_proof': paymentProof,
      'verified_by': verifiedBy,
      'notes': notes,
      'paid_at': paidAt?.toIso8601String(),
      'payment_status': paymentStatus,
    };
  }

  // Convenience getter
  String get status => paymentStatus ?? 'pending';

  String get displayPaymentMethod {
    switch (paymentMethod) {
      case 'bank_transfer':
        return 'Bank Transfer';
      case 'e_wallet':
        return 'E-Wallet';
      case 'credit_card':
        return 'Credit Card';
      case 'cash':
        return 'Cash';
      default:
        return paymentMethod;
    }
  }
}
