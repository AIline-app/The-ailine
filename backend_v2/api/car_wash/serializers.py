from datetime import datetime

from django.db import transaction
from django.utils.translation import gettext_lazy as _
from rest_framework import serializers

from api.rating.serializers import CarWashRatingSerializer
from car_wash.models import Car
from car_wash.models.box import Box
from car_wash.models.car_wash import CarWash, CarWashSettings, CarWashDocuments, CarType
from car_wash.utils.constants import MAX_CAR_NUMBER_LENGTH, MIN_CAR_NUMBER_LENGTH, IIN_LENGTH



class PublicSerializerMixin:
    public_serializer = None

    def to_representation(self, instance):
        if not self.public_serializer:
            raise ValueError('Public serializer not set')

        if (
            (hasattr(instance, 'owner') and instance.owner != self.context['request'].user)
            or (hasattr(instance, 'car_wash') and instance.car_wash.owner != self.context['request'].user)
        ):

            return self.public_serializer(instance, context=self.context).data

        return super().to_representation(instance)


### BOX ###

class BoxSerializer(serializers.ModelSerializer):

    class Meta:
        model = Box
        exclude = ('car_wash',)


### CAR TYPE ###

class CarWashCarTypesSerializer(serializers.ModelSerializer):

    class Meta:
        model = CarType
        exclude = ('settings',)


### SETTINGS ###

class CarWashSettingsPublicSerializer(serializers.ModelSerializer):

    car_types = CarWashCarTypesSerializer(many=True, read_only=True)

    class Meta:
        model = CarWashSettings
        fields = ('opens_at', 'closes_at', 'car_types')
        read_only_fields = fields


class CarWashSettingsReadSerializer(PublicSerializerMixin, serializers.ModelSerializer):

    public_serializer = CarWashSettingsPublicSerializer
    car_types = CarWashCarTypesSerializer(many=True, read_only=False)

    class Meta:
        model = CarWashSettings
        exclude = ('car_wash',)


class CarWashSettingsWriteSerializer(serializers.ModelSerializer):

    class Meta:
        model = CarWashSettings
        exclude = ('car_wash',)

    def validate(self, attrs):

        if attrs['opens_at'] > attrs['closes_at']:
            raise serializers.ValidationError({'opens_at': _('Must be earlier than closes_at')})

        return attrs

    def to_representation(self, instance):
        return CarWashSettingsReadSerializer(instance, context=self.context).data


### DOCUMENTS ###

class CarWashDocumentsPublicSerializer(serializers.ModelSerializer):

    class Meta:
        model = CarWashDocuments
        fields = ('iin', 'legal_name', 'legal_address')
        read_only_fields = fields


class CarWashDocumentsReadSerializer(PublicSerializerMixin, serializers.ModelSerializer):

    public_serializer = CarWashDocumentsPublicSerializer

    class Meta:
        model = CarWashDocuments
        exclude = ('car_wash',)


class CarWashDocumentsWriteSerializer(serializers.ModelSerializer):

    class Meta:
        model = CarWashDocuments
        exclude = ('car_wash',)

    def _validate_control_digit(self, iin: str) -> None:
        if len(iin) != IIN_LENGTH or not iin.isdigit():
            raise serializers.ValidationError({'iin': _('Invalid IIN/BIN')})

        # Validate IIN last digit (control digit)
        digits = list(map(int, iin))

        weights1 = list(range(1, 12))
        checksum = sum(d * w for d, w in zip(digits[:11], weights1)) % 11

        if checksum == 10:
            weights2 = [3, 4, 5, 6, 7, 8, 9, 10, 11, 1, 2]
            checksum = sum(d * w for d, w in zip(digits[:11], weights2)) % 11
            if checksum == 10:
                raise serializers.ValidationError({'iin': _('Invalid IIN/BIN')})

        if checksum != digits[11]:
            raise serializers.ValidationError({'iin': _('Invalid IIN/BIN')})

    def validate_iin(self, value: str):
        self._validate_control_digit(value)

        # Use the 5th digit to differentiate
        #   IIN - it is the first digit of the day
        #   BIN - a type of business
        if value[4] in ('0', '1', '2', '3',):

            # IIN
            try:
                # Check the first 6 digits are a valid date
                datetime.strptime(value[:6], "%y%m%d")
            except ValueError:
                raise serializers.ValidationError({'iin': _('Invalid IIN/BIN')})

            if value[6] not in range(7):
                # Check the 7th digit is a valid identification of the age and gender
                raise serializers.ValidationError({'iin': _('Invalid IIN/BIN')})

        elif value[4] in ('4', '5', '6',):

            # BIN
            try:
                # Check the first 4 digits are a valid date
                datetime.strptime(value[:4], "%y%m")
            except ValueError:
                raise serializers.ValidationError({'iin': _('Invalid IIN/BIN')})

            if value[5] not in range(4):
                # Type of business
                raise serializers.ValidationError({'iin': _('Invalid IIN/BIN')})


        else:
            raise serializers.ValidationError({'iin': _('Invalid IIN/BIN')})


        return value

    def to_representation(self, instance):

        return CarWashDocumentsReadSerializer(instance, context=self.context).data


### CAR WASH ###

class CarWashPublicReadSerializer(serializers.ModelSerializer):

    settings = CarWashSettingsReadSerializer(many=False)
    documents = CarWashDocumentsReadSerializer(many=False)
    rating = CarWashRatingSerializer(many=False)

    class Meta:

        model = CarWash
        fields = ('id', 'name', 'address', 'location', 'created_at', 'is_active', 'settings', 'documents', 'rating')
        read_only_fields = fields


class CarWashReadSerializer(PublicSerializerMixin, CarWashPublicReadSerializer):

    public_serializer = CarWashPublicReadSerializer
    boxes = BoxSerializer(many=True)

    class Meta(CarWashPublicReadSerializer.Meta):

        fields = CarWashPublicReadSerializer.Meta.fields + (
            'documents',
            'boxes',
            'managers',
            'washers',
        )


class CarWashChangeSerializer(serializers.ModelSerializer):

    class Meta:
        model = CarWash
        fields = ('name', 'address', 'location')

    def validate_location(self, value):
        try:
            lat, long = value.split(',')
            lat, long = float(lat), float(long)
        except ValueError:
            raise serializers.ValidationError({'location': _('Must be in format "11.1111,22.2222"')})

        if not -90 <= lat <= 90:
            raise serializers.ValidationError({'location': _('Latitude must be between -90 and 90')})
        if not -90 <= long <= 90:
            raise serializers.ValidationError({'location': _('Longitude must be between -90 and 90')})

        return value

    def to_representation(self, instance):
        return CarWashReadSerializer(instance, context=self.context).data


class CarWashWriteSerializer(CarWashChangeSerializer):

    settings = CarWashSettingsWriteSerializer(many=False)
    documents = CarWashDocumentsWriteSerializer(many=False)
    boxes_amount = serializers.IntegerField()

    class Meta(CarWashChangeSerializer.Meta):

        fields = CarWashChangeSerializer.Meta.fields + ('settings', 'documents', 'boxes_amount')

    @transaction.atomic
    def create(self, validated_data):
        settings_data = validated_data.pop('settings')
        documents_data = validated_data.pop('documents')
        boxes_amount = validated_data.pop('boxes_amount')

        car_wash = super().create(validated_data)
        car_wash.initialize(settings_data=settings_data, documents_data=documents_data, boxes_amount=boxes_amount)

        return car_wash


### EARNINGS ###

class CarWashEarningsByCarTypesReadSerializer(serializers.Serializer):

    car_type = serializers.CharField(read_only=True)
    orders_count = serializers.IntegerField(read_only=True)


class CarWashEarningsReadSerializer(serializers.Serializer):

    revenue = serializers.IntegerField(read_only=True)
    orders_count = serializers.IntegerField(read_only=True)
    by_car_types = CarWashEarningsByCarTypesReadSerializer(many=True, read_only=True)


### CAR ###

class CarSerializer(serializers.ModelSerializer):
    number = serializers.CharField(min_length=MIN_CAR_NUMBER_LENGTH, max_length=MAX_CAR_NUMBER_LENGTH)

    class Meta:
        model = Car
        fields = ('id', 'number')

    def validate(self, attrs):
        if Car.objects.filter(number=attrs['number']).exists():
            raise serializers.ValidationError({'number': _('This car already exists')})

        if not attrs['number'].isalnum():
            raise serializers.ValidationError({'number': _('Must contain only alphanumeric')})

        attrs['number'] = attrs['number'].upper()
        return attrs


### MARKETING ###

class CampaignBriefSerializer(serializers.Serializer):
    id = serializers.CharField(read_only=True)
    name = serializers.CharField(read_only=True)


class MarketingLinkItemSerializer(serializers.Serializer):
    campaign = CampaignBriefSerializer(read_only=True)
    link = serializers.URLField(read_only=True)
    qr_code = serializers.URLField(read_only=True)


class MarketingLinksResponseSerializer(serializers.Serializer):
    results = MarketingLinkItemSerializer(many=True, read_only=True)


### QUEUE ###

class CarWashQueueSerializer(serializers.Serializer):
    wait_time = serializers.CharField(read_only=True)
    car_amount = serializers.IntegerField(read_only=True)
    # late_for = serializers.CharField(read_only=True, allow_null=True)
