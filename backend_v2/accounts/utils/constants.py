MAX_USERNAME_LENGTH = 100
MAX_PASSWORD_LENGTH = 128

MIN_PHONE_NUMBER_LENGTH = 9
MAX_PHONE_NUMBER_LENGTH = 15
PHONE_VALIDATE_REGEX =  fr'^\+?1?\d{{{MIN_PHONE_NUMBER_LENGTH},{MAX_PHONE_NUMBER_LENGTH}}}$'
PHONE_VALIDATE_MESSAGE = ("Phone number must be entered in the format: '+999999999'."
                          " Up to {MAX_PHONE_NUMBER_LENGTH} digits allowed.")

SMS_CODE_LENGTH = 4
MIN_SMS_CODE_VALUE = 10 ** (SMS_CODE_LENGTH - 1)
MAX_SMS_CODE_VALUE = 10 ** SMS_CODE_LENGTH - 1
SMS_REGISTRATION_MESSAGE = "Registration code - {code}"
MANAGER_REGISTRATION_MESSAGE = "You were added as a manager to the car wash. Register at {app_link}"
