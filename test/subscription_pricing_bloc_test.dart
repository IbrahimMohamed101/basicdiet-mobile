import 'package:basic_diet/data/network/failure.dart';
import 'package:basic_diet/domain/model/plans_model.dart';
import 'package:basic_diet/domain/model/subscription_checkout_model.dart';
import 'package:basic_diet/domain/model/subscription_quote_model.dart';
import 'package:basic_diet/domain/repository/repository.dart';
import 'package:basic_diet/domain/usecase/checkout_subscription_usecase.dart';
import 'package:basic_diet/domain/usecase/get_plans_usecase.dart';
import 'package:basic_diet/domain/usecase/get_subscription_quote_usecase.dart';
import 'package:basic_diet/presentation/main/home/subscription/bloc/subscription_bloc.dart';
import 'package:basic_diet/presentation/main/home/subscription/bloc/subscription_event.dart';
import 'package:basic_diet/presentation/main/home/subscription/bloc/subscription_state.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late _FakeGetPlansUseCase getPlansUseCase;
  late _FakeGetSubscriptionQuoteUseCase getQuoteUseCase;
  late _FakeCheckoutSubscriptionUseCase checkoutUseCase;
  late SubscriptionBloc bloc;

  setUp(() {
    getPlansUseCase = _FakeGetPlansUseCase();
    getQuoteUseCase = _FakeGetSubscriptionQuoteUseCase();
    checkoutUseCase = _FakeCheckoutSubscriptionUseCase();
    bloc = SubscriptionBloc(getPlansUseCase, getQuoteUseCase, checkoutUseCase);
  });

  tearDown(() async {
    await bloc.close();
  });

  test('promo apply success updates successful quote state and reenables checkout', () async {
    final baseRequest = _buildQuoteRequest();
    final promoRequest = _buildQuoteRequest(promoCode: 'SAVE10');
    final baseQuote = _buildQuote();
    final promoQuote = _buildQuote(discountHalala: 1000, promoCode: 'SAVE10');

    getQuoteUseCase.enqueue(Right(baseQuote));
    getQuoteUseCase.enqueue(Right(promoQuote));

    await _bootstrapBloc(bloc);
    bloc.add(GetSubscriptionQuoteEvent(baseRequest));
    await _settle();

    bloc.add(const UpdatePromoCodeInputEvent('SAVE10'));
    await _settle();
    bloc.add(const ApplyPromoCodeEvent());
    await _settle();

    final state = bloc.state as SubscriptionSuccess;
    expect(state.subscriptionQuote, promoQuote);
    expect(state.lastSuccessfulQuoteRequest, promoRequest);
    expect(state.promoCodeInput, 'SAVE10');
    expect(state.isPricingStale, isFalse);
    expect(state.canCheckout, isTrue);
    expect(getQuoteUseCase.calls, [baseRequest, promoRequest]);
  });

  test('promo failure preserves last successful quote and keeps checkout disabled', () async {
    final baseRequest = _buildQuoteRequest();
    final baseQuote = _buildQuote();

    getQuoteUseCase.enqueue(Right(baseQuote));
    getQuoteUseCase.enqueue(
      Left(Failure('PROMO_NOT_FOUND', 'Promo code was not found')),
    );

    await _bootstrapBloc(bloc);
    bloc.add(GetSubscriptionQuoteEvent(baseRequest));
    await _settle();

    bloc.add(const UpdatePromoCodeInputEvent('SAVE10'));
    await _settle();
    bloc.add(const ApplyPromoCodeEvent());
    await _settle();

    final state = bloc.state as SubscriptionSuccess;
    expect(state.subscriptionQuote, baseQuote);
    expect(state.lastSuccessfulQuoteRequest, baseRequest);
    expect(state.promoStatus, SubscriptionPromoStatus.invalid);
    expect(state.isPricingStale, isTrue);
    expect(state.canCheckout, isFalse);
  });

  test('editing promo input after successful apply marks pricing stale without replacing quote', () async {
    final baseRequest = _buildQuoteRequest();
    final promoRequest = _buildQuoteRequest(promoCode: 'SAVE10');
    final baseQuote = _buildQuote();
    final promoQuote = _buildQuote(discountHalala: 1000, promoCode: 'SAVE10');

    getQuoteUseCase.enqueue(Right(baseQuote));
    getQuoteUseCase.enqueue(Right(promoQuote));

    await _bootstrapBloc(bloc);
    bloc.add(GetSubscriptionQuoteEvent(baseRequest));
    await _settle();
    bloc.add(const UpdatePromoCodeInputEvent('SAVE10'));
    await _settle();
    bloc.add(const ApplyPromoCodeEvent());
    await _settle();

    bloc.add(const UpdatePromoCodeInputEvent('SAVE11'));
    await _settle();

    final state = bloc.state as SubscriptionSuccess;
    expect(state.subscriptionQuote, promoQuote);
    expect(state.lastSuccessfulQuoteRequest, promoRequest);
    expect(state.isPricingStale, isTrue);
    expect(state.canCheckout, isFalse);
  });

  test('removing promo requotes from the last successful request and restores checkout', () async {
    final baseRequest = _buildQuoteRequest();
    final promoRequest = _buildQuoteRequest(promoCode: 'SAVE10');
    final baseQuote = _buildQuote();
    final promoQuote = _buildQuote(discountHalala: 1000, promoCode: 'SAVE10');

    getQuoteUseCase.enqueue(Right(baseQuote));
    getQuoteUseCase.enqueue(Right(promoQuote));
    getQuoteUseCase.enqueue(Right(baseQuote));

    await _bootstrapBloc(bloc);
    bloc.add(GetSubscriptionQuoteEvent(baseRequest));
    await _settle();
    bloc.add(const UpdatePromoCodeInputEvent('SAVE10'));
    await _settle();
    bloc.add(const ApplyPromoCodeEvent());
    await _settle();

    bloc.add(const RemovePromoCodeEvent());
    await _settle();

    final state = bloc.state as SubscriptionSuccess;
    expect(state.subscriptionQuote, baseQuote);
    expect(state.lastSuccessfulQuoteRequest, baseRequest);
    expect(state.promoCodeInput, isEmpty);
    expect(state.appliedPromo, isNull);
    expect(state.isPricingStale, isFalse);
    expect(state.canCheckout, isTrue);
    expect(getQuoteUseCase.calls, [baseRequest, promoRequest, baseRequest]);
  });

  test('checkout refuses stale promo-edited requests and never calls the backend', () async {
    final baseRequest = _buildQuoteRequest();
    final baseQuote = _buildQuote();
    final staleCheckoutRequest = _buildCheckoutRequest(
      _buildQuoteRequest(promoCode: 'SAVE10'),
    );

    getQuoteUseCase.enqueue(Right(baseQuote));

    await _bootstrapBloc(bloc);
    bloc.add(GetSubscriptionQuoteEvent(baseRequest));
    await _settle();
    bloc.add(const UpdatePromoCodeInputEvent('SAVE10'));
    await _settle();

    bloc.add(CheckoutSubscriptionEvent(staleCheckoutRequest));
    await _settle();

    final state = bloc.state as SubscriptionSuccess;
    expect(state.checkoutStatus, SubscriptionCheckoutStatus.failure);
    expect(state.subscriptionCheckout, isNull);
    expect(state.canCheckout, isFalse);
    expect(checkoutUseCase.calls, isEmpty);
  });

  test('checkout succeeds only when returned totals match the displayed quote', () async {
    final baseRequest = _buildQuoteRequest();
    final baseQuote = _buildQuote();
    final checkoutRequest = _buildCheckoutRequest(baseRequest);
    final checkout = _buildCheckout();

    getQuoteUseCase.enqueue(Right(baseQuote));
    checkoutUseCase.enqueue(Right(checkout));

    await _bootstrapBloc(bloc);
    bloc.add(GetSubscriptionQuoteEvent(baseRequest));
    await _settle();

    bloc.add(CheckoutSubscriptionEvent(checkoutRequest));
    await _settle();

    final state = bloc.state as SubscriptionSuccess;
    expect(state.checkoutStatus, SubscriptionCheckoutStatus.success);
    expect(state.subscriptionCheckout, checkout);
  });

  test('checkout mismatch returns failure instead of proceeding to payment', () async {
    final baseRequest = _buildQuoteRequest();
    final baseQuote = _buildQuote();
    final checkoutRequest = _buildCheckoutRequest(baseRequest);
    final mismatchedCheckout = _buildCheckout(totalHalala: 12000);

    getQuoteUseCase.enqueue(Right(baseQuote));
    checkoutUseCase.enqueue(Right(mismatchedCheckout));

    await _bootstrapBloc(bloc);
    bloc.add(GetSubscriptionQuoteEvent(baseRequest));
    await _settle();

    bloc.add(CheckoutSubscriptionEvent(checkoutRequest));
    await _settle();

    final state = bloc.state as SubscriptionSuccess;
    expect(state.checkoutStatus, SubscriptionCheckoutStatus.failure);
    expect(state.subscriptionCheckout, isNull);
    expect(
      state.checkoutErrorMessage,
      'Pricing changed. Please refresh your quote and try again.',
    );
  });
}

Future<void> _bootstrapBloc(SubscriptionBloc bloc) async {
  bloc.add(const GetPlansEvent());
  await _settle();
}

Future<void> _settle() async {
  await Future<void>.delayed(Duration.zero);
  await Future<void>.delayed(Duration.zero);
}

SubscriptionQuoteRequestModel _buildQuoteRequest({String? promoCode}) {
  return SubscriptionQuoteRequestModel(
    planId: 'plan-1',
    grams: 1200,
    mealsPerDay: 3,
    startDate: '2026-05-01',
    promoCode: promoCode,
    premiumItems: const [
      SubscriptionQuotePremiumItemRequestModel(proteinId: 'protein-1', qty: 1),
    ],
    addons: const ['addon-1'],
    delivery: const SubscriptionQuoteDeliveryRequestModel(
      type: 'delivery',
      zoneId: 'zone-1',
      slotId: 'slot-1',
      address: SubscriptionAddressModel(
        street: 'Street',
        building: '1',
        apartment: '2',
        notes: 'Note',
        district: 'District',
        city: 'Riyadh',
      ),
    ),
  );
}

SubscriptionQuoteModel _buildQuote({
  int discountHalala = 0,
  String? promoCode,
}) {
  final subtotalHalala = 9000;
  final vatHalala = 1350;
  final totalHalala = subtotalHalala + vatHalala;
  final totalSar = totalHalala / 100;
  final discountLine = discountHalala > 0
      ? [
          SubscriptionQuoteLineItemModel(
            kind: 'discount',
            label: 'Promo discount',
            amountHalala: -discountHalala,
            amountSar: -(discountHalala / 100),
            amountLabel: '-${discountHalala / 100} SAR',
          ),
        ]
      : <SubscriptionQuoteLineItemModel>[];

  return SubscriptionQuoteModel(
    breakdown: SubscriptionQuoteBreakdownModel(
      basePlanPriceHalala: 5000,
      premiumTotalHalala: 1000,
      addonsTotalHalala: 2000,
      deliveryFeeHalala: 1000,
      vatHalala: vatHalala,
      totalHalala: totalHalala,
      currency: 'SAR',
    ),
    totalSar: totalSar,
    summary: SubscriptionQuoteSummaryModel(
      plan: const SubscriptionQuotePlanSummaryModel(
        id: 'plan-1',
        name: 'Plan',
        daysCount: 20,
        daysLabel: '20 days',
        grams: 1200,
        gramsLabel: '1200g',
        mealsPerDay: 3,
        mealsLabel: '3 meals',
        startDate: '2026-05-01',
      ),
      delivery: const SubscriptionQuoteDeliverySummaryModel(
        type: 'delivery',
        label: 'Home delivery',
        zoneId: 'zone-1',
        zoneName: 'Zone 1',
        feeHalala: 1000,
        feeSar: 10,
        feeLabel: '10 SAR',
        address: SubscriptionAddressModel(
          street: 'Street',
          building: '1',
          apartment: '2',
          notes: 'Note',
          district: 'District',
          city: 'Riyadh',
        ),
        slot: SubscriptionQuoteSlotSummaryModel(
          type: 'delivery',
          slotId: 'slot-1',
          window: '10:00 - 12:00',
          label: '10:00 - 12:00',
        ),
      ),
      premiumItems: const [
        SubscriptionQuotePremiumItemModel(
          id: 'protein-1',
          name: 'Premium Meal',
          qty: 1,
          unitPriceHalala: 1000,
          unitPriceSar: 10,
          totalHalala: 1000,
          totalSar: 10,
          totalLabel: '10 SAR',
        ),
      ],
      addons: const [
        SubscriptionQuoteAddonModel(
          id: 'addon-1',
          name: 'Add-on',
          qty: 1,
          type: 'subscription',
          pricingModel: 'daily_recurring',
          billingUnit: 'day',
          durationDays: 20,
          unitPriceHalala: 100,
          unitPriceSar: 1,
          unitPriceLabel: '1 SAR / day',
          formulaLabel: '1 SAR / day x 20 days',
          totalHalala: 2000,
          totalSar: 20,
          totalLabel: '20 SAR',
        ),
      ],
      lineItems: [
        const SubscriptionQuoteLineItemModel(
          kind: 'plan',
          label: 'Plan',
          amountHalala: 5000,
          amountSar: 50,
          amountLabel: '50 SAR',
        ),
        const SubscriptionQuoteLineItemModel(
          kind: 'premium',
          label: 'Premium meals',
          amountHalala: 1000,
          amountSar: 10,
          amountLabel: '10 SAR',
        ),
        const SubscriptionQuoteLineItemModel(
          kind: 'addons',
          label: 'Add-ons',
          amountHalala: 2000,
          amountSar: 20,
          amountLabel: '20 SAR',
        ),
        const SubscriptionQuoteLineItemModel(
          kind: 'delivery',
          label: 'Delivery',
          amountHalala: 1000,
          amountSar: 10,
          amountLabel: '10 SAR',
        ),
        ...discountLine,
        const SubscriptionQuoteLineItemModel(
          kind: 'vat',
          label: 'VAT',
          amountHalala: 1350,
          amountSar: 13.5,
          amountLabel: '13.5 SAR',
        ),
        SubscriptionQuoteLineItemModel(
          kind: 'total',
          label: 'Total',
          amountHalala: totalHalala,
          amountSar: totalSar,
          amountLabel: '${totalSar.toStringAsFixed(2)} SAR',
        ),
      ],
    ),
    appliedPromo: promoCode == null
        ? null
        : SubscriptionAppliedPromoModel(
            code: promoCode,
            discountType: 'percentage',
            discountValue: 10,
            discountAmountHalala: discountHalala,
            discountAmountSar: discountHalala / 100,
            label: 'Promo discount',
            message: 'Promo applied',
            validityState: 'applied',
          ),
  );
}

SubscriptionCheckoutRequestModel _buildCheckoutRequest(
  SubscriptionQuoteRequestModel request,
) {
  return SubscriptionCheckoutRequestModel(
    idempotencyKey: 'checkout-key',
    planId: request.planId,
    grams: request.grams,
    mealsPerDay: request.mealsPerDay,
    startDate: request.startDate,
    promoCode: request.promoCode,
    premiumItems: request.premiumItems
        .map(
          (item) => SubscriptionCheckoutPremiumItemRequestModel(
            proteinId: item.proteinId,
            qty: item.qty,
          ),
        )
        .toList(),
    addons: request.addons,
    delivery: SubscriptionCheckoutDeliveryRequestModel(
      type: request.delivery.type,
      zoneId: request.delivery.zoneId,
      slotId: request.delivery.slotId,
      address: request.delivery.address,
    ),
    successUrl: 'https://app.example.com/payments/success',
    backUrl: 'https://app.example.com/payments/cancel',
  );
}

SubscriptionCheckoutModel _buildCheckout({int totalHalala = 10350}) {
  return SubscriptionCheckoutModel(
    subscriptionId: null,
    draftId: 'draft-1',
    paymentId: 'payment-1',
    paymentUrl: 'https://pay.example.com',
    reused: false,
    totals: SubscriptionCheckoutTotalsModel(
      basePlanPriceHalala: 5000,
      premiumTotalHalala: 1000,
      addonsTotalHalala: 2000,
      deliveryFeeHalala: 1000,
      vatHalala: 1350,
      totalHalala: totalHalala,
      currency: 'SAR',
    ),
  );
}

PlansModel _buildPlansModel() {
  return const PlansModel(
    plans: [
      PlanModel(
        id: 'plan-1',
        name: 'Plan',
        daysCount: 20,
        currency: 'SAR',
        isActive: true,
        gramsOptions: [
          GramOptionModel(
            grams: 1200,
            mealsOptions: [
              MealOptionModel(
                mealsPerDay: 3,
                priceSar: 50,
                compareAtSar: 0,
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

class _NoopRepository implements Repository {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _FakeGetPlansUseCase extends GetPlansUseCase {
  _FakeGetPlansUseCase() : super(_NoopRepository());

  @override
  Future<Either<Failure, PlansModel>> execute(void input) async {
    return Right(_buildPlansModel());
  }
}

class _FakeGetSubscriptionQuoteUseCase extends GetSubscriptionQuoteUseCase {
  _FakeGetSubscriptionQuoteUseCase() : super(_NoopRepository());

  final List<Either<Failure, SubscriptionQuoteModel>> _results = [];
  final List<SubscriptionQuoteRequestModel> calls = [];

  void enqueue(Either<Failure, SubscriptionQuoteModel> result) {
    _results.add(result);
  }

  @override
  Future<Either<Failure, SubscriptionQuoteModel>> execute(
    SubscriptionQuoteRequestModel input,
  ) async {
    calls.add(input);
    return _results.removeAt(0);
  }
}

class _FakeCheckoutSubscriptionUseCase extends CheckoutSubscriptionUseCase {
  _FakeCheckoutSubscriptionUseCase() : super(_NoopRepository());

  final List<Either<Failure, SubscriptionCheckoutModel>> _results = [];
  final List<SubscriptionCheckoutRequestModel> calls = [];

  void enqueue(Either<Failure, SubscriptionCheckoutModel> result) {
    _results.add(result);
  }

  @override
  Future<Either<Failure, SubscriptionCheckoutModel>> execute(
    SubscriptionCheckoutRequestModel input,
  ) async {
    calls.add(input);
    return _results.removeAt(0);
  }
}
