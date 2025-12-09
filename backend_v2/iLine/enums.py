import enum


class EventEnum(enum.StrEnum):
    REGISTER = "register"
    SEND_REGISTER_SMS = "send_register_sms"
    VERIFIED_PHONE = "verified_phone"

    ORDER_PLACED = "order_placed"

