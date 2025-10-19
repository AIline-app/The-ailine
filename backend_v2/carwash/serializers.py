from rest_framework import serializers

from carwash.models.carwash import CarWash, CarWashSettings, CarWashDocuments


class CarWashSettingsSerializer(serializers.ModelSerializer):
    class Meta:
        model = CarWashSettings
        exclude = ('car_wash',)


class CarWashDocumentsSerializer(serializers.ModelSerializer):
    class Meta:
        model = CarWashDocuments
        exclude = ('car_wash',)


class CarWashSerializer(serializers.ModelSerializer):
    settings = CarWashSettingsSerializer(many=False)
    documents = CarWashDocumentsSerializer(many=False)

    class Meta:
        model = CarWash
        fields = ['id','owner', 'name', 'address', 'created_at', 'settings', 'documents']

    def validate(self, attrs):
        return attrs

    def create(self, validated_data):
        settings_data = validated_data.pop('settings')
        documents_data = validated_data.pop('documents')
        car_wash = CarWash.objects.create(**validated_data)
        CarWashSettings.objects.create(car_wash=car_wash, **settings_data)
        CarWashDocuments.objects.create(car_wash=car_wash, **documents_data)
        return car_wash

    def update(self, instance, validated_data):
        for field in ('settings', 'documents'):
            if field in validated_data:
                data = validated_data.pop(field)
                obj = getattr(instance, field)
                for k, v in data.items():
                    setattr(obj, k, v)
                obj.save()
        return super().update(instance, validated_data)
