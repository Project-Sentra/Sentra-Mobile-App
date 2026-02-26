/// Stripe client-side (publishable) configuration.
///
/// For production, do NOT hard-code secrets in the app.
/// Only the publishable key belongs here.
const stripePublishableKey =
	'pk_test_51T4kYe3yuOh4QYXU1BIwIwnsaXtFuK73zZqeGszvAdq60UaLLjYX75UU5jx3EU4gnRtzfVbAcEk9p2aQc4314jP600AEkOt1SH';

/// Shown in Stripe PaymentSheet.
const stripeMerchantDisplayName = 'Sentra Parking';

/// Google Pay country code (ISO 3166-1 alpha-2).
const stripeMerchantCountryCode = 'LK';
