enum InvoiceStatus {
  paid,
  pending,
  refunded;

  String get label {
    switch (this) {
      case InvoiceStatus.paid:
        return 'Payée';
      case InvoiceStatus.pending:
        return 'En attente';
      case InvoiceStatus.refunded:
        return 'Remboursée';
    }
  }
}

enum CardBrand {
  visa,
  mastercard,
  amex;

  String get label {
    switch (this) {
      case CardBrand.visa:
        return 'Visa';
      case CardBrand.mastercard:
        return 'Mastercard';
      case CardBrand.amex:
        return 'Amex';
    }
  }
}

class MockInvoice {
  const MockInvoice({
    required this.id,
    required this.date,
    required this.description,
    required this.amount,
    required this.status,
    required this.stripeInvoiceUrl,
  });

  final String id;
  final DateTime date;
  final String description;
  final double amount;
  final InvoiceStatus status;
  final String stripeInvoiceUrl;

  String get formattedAmount => '${amount.toStringAsFixed(2)} \$';
}

class MockPaymentCard {
  const MockPaymentCard({
    required this.brand,
    required this.last4,
    required this.expMonth,
    required this.expYear,
    this.isDefault = true,
  });

  final CardBrand brand;
  final String last4;
  final int expMonth;
  final int expYear;
  final bool isDefault;

  String get expDisplay =>
      '${expMonth.toString().padLeft(2, '0')}/${expYear.toString().substring(2)}';

  String get maskedNumber => '**** **** **** $last4';
}

final List<MockInvoice> mockInvoices = [
  MockInvoice(
    id: 'inv_001',
    date: DateTime(2026, 3, 22),
    description: 'Course — Griffintown',
    amount: 15.00,
    status: InvoiceStatus.paid,
    stripeInvoiceUrl: 'https://invoice.stripe.com/i/acct_mock/inv_001',
  ),
  MockInvoice(
    id: 'inv_002',
    date: DateTime(2026, 3, 15),
    description: 'Course — Plateau Mont-Royal',
    amount: 12.00,
    status: InvoiceStatus.paid,
    stripeInvoiceUrl: 'https://invoice.stripe.com/i/acct_mock/inv_002',
  ),
  MockInvoice(
    id: 'inv_003',
    date: DateTime(2026, 3, 8),
    description: 'Course — Vieux-Montréal',
    amount: 18.00,
    status: InvoiceStatus.refunded,
    stripeInvoiceUrl: 'https://invoice.stripe.com/i/acct_mock/inv_003',
  ),
  MockInvoice(
    id: 'inv_004',
    date: DateTime(2026, 4, 5),
    description: 'Course — Lachine',
    amount: 15.00,
    status: InvoiceStatus.pending,
    stripeInvoiceUrl: 'https://invoice.stripe.com/i/acct_mock/inv_004',
  ),
  MockInvoice(
    id: 'inv_005',
    date: DateTime(2026, 2, 20),
    description: 'Course — Ahuntsic',
    amount: 10.00,
    status: InvoiceStatus.paid,
    stripeInvoiceUrl: 'https://invoice.stripe.com/i/acct_mock/inv_005',
  ),
];

MockPaymentCard? mockPaymentCard = const MockPaymentCard(
  brand: CardBrand.visa,
  last4: '4242',
  expMonth: 8,
  expYear: 2027,
);
