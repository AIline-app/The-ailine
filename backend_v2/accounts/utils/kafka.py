import json

from django.conf import settings
from kafka import KafkaProducer


class Singleton(type):
    _instances = {}
    def __call__(cls, *args, **kwargs):
        if cls not in cls._instances:
            cls._instances[cls] = super(Singleton, cls).__call__(*args, **kwargs)
        return cls._instances[cls]


class Kafka(metaclass=Singleton):
    def __init__(self):
        self.__producer = None

    @property
    def producer(self):
        if self.__producer is None:
            self.__producer = KafkaProducer(
                bootstrap_servers=getattr(settings, 'KAFKA_BROKER', 'localhost:9092'),
                value_serializer=lambda v: json.dumps(v).encode('utf-8'),
            )
        return self.__producer

    def send(self, topic: str, payload: dict):
        self.producer.send(topic, payload)
