import enum


class EventEnum(enum.StrEnum):
    REGISTER = "register"
    SEND_REGISTER_SMS = "send_register_sms"
    VERIFIED_PHONE = "verified_phone"

    ORDER_PLACED = "order_placed"
    ORDER_STARTED = "order_started"
    ORDER_COMPLETED = "order_completed"
    ORDER_CANCELED = "order_canceled"
    ORDER_SERVICES_UPDATED = "order_services_updated"

    # Accounts and authentication
    LOGIN_SUCCESS = "login_success"
    PROFILE_VIEWED = "profile_viewed"

    # Services
    SERVICE_LIST_VIEWED = "service_list_viewed"
    SERVICE_RETRIEVED = "service_retrieved"
    SERVICE_CREATED = "service_created"
    SERVICE_UPDATED = "service_updated"

    # Car and boxes
    CAR_CREATED = "car_created"
    CAR_UPDATED = "car_updated"
    BOX_CREATED = "box_created"
    BOX_UPDATED = "box_updated"

    # Car wash and queues
    CAR_WASH_CREATED = "car_wash_created"
    CAR_WASH_UPDATED = "car_wash_updated"
    QUEUE_VIEWED = "queue_viewed"
    EARNINGS_VIEWED = "earnings_viewed"

