// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(
      _current != null,
      'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.',
    );
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(
      instance != null,
      'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?',
    );
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `Регистрация`
  String get common_registration {
    return Intl.message(
      'Регистрация',
      name: 'common_registration',
      desc: '',
      args: [],
    );
  }

  /// `Зарегистрироваться`
  String get common_register {
    return Intl.message(
      'Зарегистрироваться',
      name: 'common_register',
      desc: '',
      args: [],
    );
  }

  /// `Введите номер телефона`
  String get common_enter_phone {
    return Intl.message(
      'Введите номер телефона',
      name: 'common_enter_phone',
      desc: '',
      args: [],
    );
  }

  /// `Номер телефона`
  String get common_phone_number {
    return Intl.message(
      'Номер телефона',
      name: 'common_phone_number',
      desc: '',
      args: [],
    );
  }

  /// `Придумайте пароль`
  String get common_create_password {
    return Intl.message(
      'Придумайте пароль',
      name: 'common_create_password',
      desc: '',
      args: [],
    );
  }

  /// `На данный номер телефона будет отправлен СМС-код для подтверждения`
  String get common_sms_info {
    return Intl.message(
      'На данный номер телефона будет отправлен СМС-код для подтверждения',
      name: 'common_sms_info',
      desc: '',
      args: [],
    );
  }

  /// `Введите код из СМС`
  String get common_enter_sms_code {
    return Intl.message(
      'Введите код из СМС',
      name: 'common_enter_sms_code',
      desc: '',
      args: [],
    );
  }

  /// `Код будет доставлен в течение 30 секунд. Если код не пришел, проверьте правильность указанного номер телефона и попробуйте еще раз`
  String get common_sms_code_info {
    return Intl.message(
      'Код будет доставлен в течение 30 секунд. Если код не пришел, проверьте правильность указанного номер телефона и попробуйте еще раз',
      name: 'common_sms_code_info',
      desc: '',
      args: [],
    );
  }

  /// `Выслать код повторно`
  String get common_resend_code {
    return Intl.message(
      'Выслать код повторно',
      name: 'common_resend_code',
      desc: '',
      args: [],
    );
  }

  /// `Как вас зовут?`
  String get common_what_is_your_name {
    return Intl.message(
      'Как вас зовут?',
      name: 'common_what_is_your_name',
      desc: '',
      args: [],
    );
  }

  /// `На данный номер телефона будет отправлен СМС-код для подтверждения`
  String get common_sms_verification_info {
    return Intl.message(
      'На данный номер телефона будет отправлен СМС-код для подтверждения',
      name: 'common_sms_verification_info',
      desc: '',
      args: [],
    );
  }

  /// `Информация о машине`
  String get common_vehicle_info {
    return Intl.message(
      'Информация о машине',
      name: 'common_vehicle_info',
      desc: '',
      args: [],
    );
  }

  /// `Номер машины`
  String get common_car_number {
    return Intl.message(
      'Номер машины',
      name: 'common_car_number',
      desc: '',
      args: [],
    );
  }

  /// `Уведомления`
  String get common_notifications {
    return Intl.message(
      'Уведомления',
      name: 'common_notifications',
      desc: '',
      args: [],
    );
  }

  /// `За какой период вам напомнить о записи?`
  String get common_reminder_period {
    return Intl.message(
      'За какой период вам напомнить о записи?',
      name: 'common_reminder_period',
      desc: '',
      args: [],
    );
  }

  /// `Выберите мессенджер для отправки уведомлений`
  String get common_choose_messenger {
    return Intl.message(
      'Выберите мессенджер для отправки уведомлений',
      name: 'common_choose_messenger',
      desc: '',
      args: [],
    );
  }

  /// `Telegram`
  String get common_telegram {
    return Intl.message(
      'Telegram',
      name: 'common_telegram',
      desc: '',
      args: [],
    );
  }

  /// `WhatsApp`
  String get common_whatsapp {
    return Intl.message(
      'WhatsApp',
      name: 'common_whatsapp',
      desc: '',
      args: [],
    );
  }

  /// `Далeе`
  String get common_next {
    return Intl.message('Далeе', name: 'common_next', desc: '', args: []);
  }

  /// `седан`
  String get common_car_type_sedan {
    return Intl.message(
      'седан',
      name: 'common_car_type_sedan',
      desc: '',
      args: [],
    );
  }

  /// `джип`
  String get common_car_type_suv {
    return Intl.message(
      'джип',
      name: 'common_car_type_suv',
      desc: '',
      args: [],
    );
  }

  /// `минивен`
  String get common_car_type_minivan {
    return Intl.message(
      'минивен',
      name: 'common_car_type_minivan',
      desc: '',
      args: [],
    );
  }

  /// `Стандарт`
  String get common_standard {
    return Intl.message(
      'Стандарт',
      name: 'common_standard',
      desc: '',
      args: [],
    );
  }

  /// `Покрытие воском`
  String get common_wax_coating {
    return Intl.message(
      'Покрытие воском',
      name: 'common_wax_coating',
      desc: '',
      args: [],
    );
  }

  /// `Мойка кузова`
  String get common_body_wash {
    return Intl.message(
      'Мойка кузова',
      name: 'common_body_wash',
      desc: '',
      args: [],
    );
  }

  /// `Пылесос`
  String get common_vacuum_cleaning {
    return Intl.message(
      'Пылесос',
      name: 'common_vacuum_cleaning',
      desc: '',
      args: [],
    );
  }

  /// `{distance} метров от вас`
  String common_distance_from_you(Object distance) {
    return Intl.message(
      '$distance метров от вас',
      name: 'common_distance_from_you',
      desc: '',
      args: [distance],
    );
  }

  /// `Перед вами сейчас:`
  String get common_currently_ahead_of_you {
    return Intl.message(
      'Перед вами сейчас:',
      name: 'common_currently_ahead_of_you',
      desc: '',
      args: [],
    );
  }

  /// `машин`
  String get common_cars {
    return Intl.message('машин', name: 'common_cars', desc: '', args: []);
  }

  /// `Вы сможете подъехать к:`
  String get common_you_can_arrive_at {
    return Intl.message(
      'Вы сможете подъехать к:',
      name: 'common_you_can_arrive_at',
      desc: '',
      args: [],
    );
  }

  /// `Дополнительные услуги`
  String get common_additional_services {
    return Intl.message(
      'Дополнительные услуги',
      name: 'common_additional_services',
      desc: '',
      args: [],
    );
  }

  /// `Вы выбрали`
  String get common_you_selected {
    return Intl.message(
      'Вы выбрали',
      name: 'common_you_selected',
      desc: '',
      args: [],
    );
  }

  /// `Я подтверждаю дату и время бронирования и ознакомлен с условиями оплаты`
  String get common_booking_confirmation_text {
    return Intl.message(
      'Я подтверждаю дату и время бронирования и ознакомлен с условиями оплаты',
      name: 'common_booking_confirmation_text',
      desc: '',
      args: [],
    );
  }

  /// `Записаться`
  String get common_book {
    return Intl.message('Записаться', name: 'common_book', desc: '', args: []);
  }

  /// `Сортировать по`
  String get common_sort_by {
    return Intl.message(
      'Сортировать по',
      name: 'common_sort_by',
      desc: '',
      args: [],
    );
  }

  /// `Расстояние`
  String get common_sort_distance {
    return Intl.message(
      'Расстояние',
      name: 'common_sort_distance',
      desc: '',
      args: [],
    );
  }

  /// `Очередь`
  String get common_sort_queue {
    return Intl.message(
      'Очередь',
      name: 'common_sort_queue',
      desc: '',
      args: [],
    );
  }

  /// `Рейтинг`
  String get common_sort_rating {
    return Intl.message(
      'Рейтинг',
      name: 'common_sort_rating',
      desc: '',
      args: [],
    );
  }

  /// `Ошибка загрузки автомоек`
  String get common_loading_error {
    return Intl.message(
      'Ошибка загрузки автомоек',
      name: 'common_loading_error',
      desc: '',
      args: [],
    );
  }

  /// `Нет доступных автомоек`
  String get common_no_carwashes {
    return Intl.message(
      'Нет доступных автомоек',
      name: 'common_no_carwashes',
      desc: '',
      args: [],
    );
  }

  /// `Вход`
  String get common_login {
    return Intl.message('Вход', name: 'common_login', desc: '', args: []);
  }

  /// `Пароль`
  String get common_password {
    return Intl.message('Пароль', name: 'common_password', desc: '', args: []);
  }

  /// `Забыли пароль?`
  String get common_forgot_password {
    return Intl.message(
      'Забыли пароль?',
      name: 'common_forgot_password',
      desc: '',
      args: [],
    );
  }

  /// `Войти`
  String get common_sign_in {
    return Intl.message('Войти', name: 'common_sign_in', desc: '', args: []);
  }

  /// `Стать партнером`
  String get common_become_partner {
    return Intl.message(
      'Стать партнером',
      name: 'common_become_partner',
      desc: '',
      args: [],
    );
  }

  /// `2.02, вторник, 14:00`
  String get common_selected_date_example {
    return Intl.message(
      '2.02, вторник, 14:00',
      name: 'common_selected_date_example',
      desc: '',
      args: [],
    );
  }

  /// `Добавление услуг`
  String get common_add_services {
    return Intl.message(
      'Добавление услуг',
      name: 'common_add_services',
      desc: '',
      args: [],
    );
  }

  /// `Стандарт`
  String get common_tariff_standard {
    return Intl.message(
      'Стандарт',
      name: 'common_tariff_standard',
      desc: '',
      args: [],
    );
  }

  /// `Пена, вода, сушка`
  String get common_tariff_description {
    return Intl.message(
      'Пена, вода, сушка',
      name: 'common_tariff_description',
      desc: '',
      args: [],
    );
  }

  /// `30 мин`
  String get common_tariff_duration {
    return Intl.message(
      '30 мин',
      name: 'common_tariff_duration',
      desc: '',
      args: [],
    );
  }

  /// `500р`
  String get common_tariff_price {
    return Intl.message(
      '500р',
      name: 'common_tariff_price',
      desc: '',
      args: [],
    );
  }

  /// `Добавить услугу`
  String get common_add_service {
    return Intl.message(
      'Добавить услугу',
      name: 'common_add_service',
      desc: '',
      args: [],
    );
  }

  /// `Вы можете изменить информацию позже в личном кабинете`
  String get common_edit_later_info {
    return Intl.message(
      'Вы можете изменить информацию позже в личном кабинете',
      name: 'common_edit_later_info',
      desc: '',
      args: [],
    );
  }

  /// `Сохранить`
  String get common_save {
    return Intl.message('Сохранить', name: 'common_save', desc: '', args: []);
  }

  /// `Подключение автомойки`
  String get common_connect_carwash {
    return Intl.message(
      'Подключение автомойки',
      name: 'common_connect_carwash',
      desc: '',
      args: [],
    );
  }

  /// `ТОО/ИИН`
  String get common_company_or_iin {
    return Intl.message(
      'ТОО/ИИН',
      name: 'common_company_or_iin',
      desc: '',
      args: [],
    );
  }

  /// `Название`
  String get common_company_name {
    return Intl.message(
      'Название',
      name: 'common_company_name',
      desc: '',
      args: [],
    );
  }

  /// `Адрес`
  String get common_address {
    return Intl.message('Адрес', name: 'common_address', desc: '', args: []);
  }

  /// `Укажите время\nработы автомойки`
  String get common_set_working_hours {
    return Intl.message(
      'Укажите время\nработы автомойки',
      name: 'common_set_working_hours',
      desc: '',
      args: [],
    );
  }

  /// `Начало`
  String get common_start_time {
    return Intl.message(
      'Начало',
      name: 'common_start_time',
      desc: '',
      args: [],
    );
  }

  /// `Конец`
  String get common_end_time {
    return Intl.message('Конец', name: 'common_end_time', desc: '', args: []);
  }

  /// `Количество слотов`
  String get common_number_of_slots {
    return Intl.message(
      'Количество слотов',
      name: 'common_number_of_slots',
      desc: '',
      args: [],
    );
  }

  /// `Процент выплаты мойщикам`
  String get common_washer_payout_percent {
    return Intl.message(
      'Процент выплаты мойщикам',
      name: 'common_washer_payout_percent',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'ru'),
      Locale.fromSubtags(languageCode: 'kk'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
