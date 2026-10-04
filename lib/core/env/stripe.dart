/// Stripe client-side (publishable) configuration.
///
/// For production, do NOT hard-code secrets in the app.
/// Only the publishable key belongs here.
const stripePublishableKey =
    'pk_test_51UMdFdIJmqn10DSTpSiEPrwfZJRuhqUdMUCHih8u4SBqmekfZOIetxyIEdzUCP3sCNzhvxYm4llI0J9cjRdTOhwZ00XHrFnWGq';

/// Shown in Stripe PaymentSheet.
const stripeMerchantDisplayName = 'Sentra Parking';

/// Google Pay country code (ISO 3166-1 alpha-2).
const stripeMerchantCountryCode = 'LK';
