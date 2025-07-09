import os
import environ
from datetime import timedelta
from AstSmartTime.log_formatters import CustomJsonFormatter


BASE_DIR = environ.Path(__file__) - 2

env = environ.Env()
environ.Env.read_env(env_file=BASE_DIR('.env'))

SECRET_KEY = env.str('SECRET_KEY', 'SECRET_KEY')
DEBUG = env.bool('DEBUG', False)


ALLOWED_HOSTS = env.str('ALLOWED_HOSTS', default='').split(' ')
CORS_ALLOWED_ORIGINS = env.list('CORS_ALLOWED_ORIGINS', default=[])
CORS_ALLOW_HEADERS = ['Access-Control-Allow-Methods', 'Access-Control-Allow-Origin', 'Api-key',
                      'Access-Control-Allow-Headers', 'content-type', 'Authorization']
CORS_ALLOW_CREDENTIALS = True
INTERNAL_IPS = ['127.0.0.1']

SMS_LOGIN = env.str('SMS_LOGIN', 'SMS_LOGIN')
SMS_PASSWORD = env.str('SMS_PASSWORD', 'SMS_PASSWORD')
API_KEY = env.str('API_KEY', 'API_KEY')

INSTALLED_APPS = [
    'django.contrib.admin',
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.messages',
    'django.contrib.staticfiles',
    'rest_framework.authtoken',
    'rest_framework',
    'rest_framework_simplejwt',
    'rest_framework_simplejwt.token_blacklist',
    'corsheaders',
    'drf_yasg',
    'app_orders',
    'app_washes',
    'app_users',
    'app_adminwork',
    'app_bot',
]

AUTH_USER_MODEL = 'app_users.User'

MIDDLEWARE = [
    'AstSmartTime.middleware.ErrorLoggingMiddleware',
    'django.middleware.security.SecurityMiddleware',
    'whitenoise.middleware.WhiteNoiseMiddleware',
    'django.contrib.sessions.middleware.SessionMiddleware',
    'corsheaders.middleware.CorsMiddleware',
    'django.middleware.common.CommonMiddleware',
    'django.contrib.auth.middleware.AuthenticationMiddleware',
    'django.contrib.messages.middleware.MessageMiddleware',
    'django.middleware.clickjacking.XFrameOptionsMiddleware',
]

ROOT_URLCONF = 'AstSmartTime.urls'

TEMPLATES = [
    {
        'BACKEND': 'django.template.backends.django.DjangoTemplates',
        'DIRS': [],
        'APP_DIRS': True,
        'OPTIONS': {
            'context_processors': [
                'django.template.context_processors.debug',
                'django.template.context_processors.request',
                'django.contrib.auth.context_processors.auth',
                'django.contrib.messages.context_processors.messages',
            ],
        },
    },
]

WSGI_APPLICATION = 'AstSmartTime.wsgi.application'


if DEBUG is True:
    DATABASES = {
        'default': {
            'ENGINE': 'django.db.backends.sqlite3',
            'NAME': os.path.join(BASE_DIR, 'db.sqlite3'),
        }
    }
else:
    DATABASES = {
        'default': {
            'ENGINE': 'django.db.backends.postgresql_psycopg2',
            'NAME': env.str('POSTGRES_DB', 'POSTGRES_DB'),
            'USER': env.str('POSTGRES_USER', 'POSTGRES_USER'),
            'PASSWORD': env.str('POSTGRES_PASSWORD', 'POSTGRES_PASSWORD'),
            'HOST': env.str('HOST', 'localhost'),
            'PORT': env.int('PORT', 5432),
        }
    }


AUTH_PASSWORD_VALIDATORS = [
    {
        'NAME': 'django.contrib.auth.password_validation.UserAttributeSimilarityValidator',
    },
    {
        'NAME': 'django.contrib.auth.password_validation.MinimumLengthValidator',
    },
    {
        'NAME': 'django.contrib.auth.password_validation.CommonPasswordValidator',
    },
    {
        'NAME': 'django.contrib.auth.password_validation.NumericPasswordValidator',
    },
]


# Internationalization
# https://docs.djangoproject.com/en/4.1/topics/i18n/

LANGUAGE_CODE = 'en-us'

TIME_ZONE = 'UTC'

USE_I18N = True

USE_TZ = True


# Static files (CSS, JavaScript, Images)
# https://docs.djangoproject.com/en/4.1/howto/static-files/

STATIC_URL = 'static/'
STATIC_ROOT = os.path.join(BASE_DIR, 'staticfiles')

MEDIA_URL = '/resources/'
MEDIA_ROOT = os.path.join(BASE_DIR, 'resources')

# Default primary key field type
# https://docs.djangoproject.com/en/4.1/ref/settings/#default-auto-field

DEFAULT_AUTO_FIELD = 'django.db.models.BigAutoField'

REST_FRAMEWORK = {
    'EXCEPTION_HANDLER': 'AstSmartTime.custom_exception_handler.custom_exception_handler',
    'DEFAULT_PERMISSION_CLASSES': [
        'rest_framework.permissions.DjangoModelPermissionsOrAnonReadOnly'
    ],
    'DEFAULT_AUTHENTICATION_CLASSES': [
        'rest_framework_simplejwt.authentication.JWTAuthentication',
    ],
}

SIMPLE_JWT = {
    'ACCESS_TOKEN_LIFETIME': timedelta(minutes=30),
    'REFRESH_TOKEN_LIFETIME': timedelta(days=30),
    'ROTATE_REFRESH_TOKENS': False,
    'BLACKLIST_AFTER_ROTATION': False,
    'UPDATE_LAST_LOGIN': False,

    'ALGORITHM': 'HS256',
    'SIGNING_KEY': SECRET_KEY,
    'VERIFYING_KEY': None,
    'AUDIENCE': None,
    'ISSUER': None,
    'JWK_URL': None,
    'LEEWAY': 0,

    'AUTH_HEADER_TYPES': ('JWT',),
    'AUTH_HEADER_NAME': 'HTTP_AUTHORIZATION',
    'USER_ID_FIELD': 'id',
    'USER_ID_CLAIM': 'user_id',
    'USER_AUTHENTICATION_RULE': 'rest_framework_simplejwt.authentication.default_user_authentication_rule',

    'AUTH_TOKEN_CLASSES': ('rest_framework_simplejwt.tokens.AccessToken',),
    'TOKEN_TYPE_CLAIM': 'token_type',
    'TOKEN_USER_CLASS': 'rest_framework_simplejwt.models.TokenUser',

    'JTI_CLAIM': 'jti',

    'SLIDING_TOKEN_REFRESH_EXP_CLAIM': 'refresh_exp',
    'SLIDING_TOKEN_LIFETIME': timedelta(minutes=5),
    'SLIDING_TOKEN_REFRESH_LIFETIME': timedelta(days=1),
}

SWAGGER_SETTINGS = {
    'SECURITY_DEFINITIONS': {
        'JWT': {
            'type': 'apiKey',
            'in': 'header',
            'name': 'Authorization'
        }
    },
    "exclude_namespaces": [],
    "api_version": '0.1',
    "api_path": "/",
    "enabled_methods": [
        'get',
        'post',
        'put',
        'patch',
        'delete'
    ],
    "api_key": 'JWT',
    "is_authenticated": False,
    "is_superuser": False,
}

LOGGING = {
    'version': 1,
    'disable_existing_loggers': False,

    'formatters': {
        'main_format': {
            'format': '[{filename} - {module} - {asctime} - {levelname}] {message}',
            'style': '{',
        },
        'json_formatter': {
            '()': CustomJsonFormatter,
        },
    },

    'handlers': {
        'file': {
            'class': 'logging.handlers.RotatingFileHandler',
            'filename': f'{BASE_DIR}/logging.log',
            'maxBytes': 1024 * 1024,
            'backupCount': 1,
            'formatter': 'json_formatter'
        },
        'console': {
            'class': 'logging.StreamHandler',
            'formatter': 'main_format'
        },
    },

    'loggers': {
        'main': {
            'handlers': ['file', 'console'],
            'level': 'ERROR' if not DEBUG else 'DEBUG',
            'propagate': True,
        }
    },
    'root': {
        'handlers': ['console', 'file'],
        'level': 'ERROR',
    }
}
