import uuid
from datetime import timedelta

from django.db import models
from django.utils.translation import gettext_lazy as _
from django.utils.timezone import now
from django.db.models import Sum, F, DurationField, Value, ExpressionWrapper


class QueueEntry(models.Model):
    """Model to track queue entries for car wash orders.
    
    This model maintains a persistent queue state, allowing for:
    - Accurate wait time calculations
    - Delay detection and tracking
    - Notification scheduling based on queue position
    
    Attributes:
        id: Primary key
        car_wash: Reference to the car wash
        order: Reference to the order in queue
        position: Position in queue (lower = earlier)
        expected_start_time: Calculated expected start time
        expected_duration: Total duration of services for this order
        created_at: When this queue entry was created
        updated_at: When this queue entry was last updated
    """
    
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    car_wash = models.ForeignKey(
        'car_wash.CarWash',
        verbose_name=_('Car Wash'),
        on_delete=models.CASCADE,
        related_name='queue_entries',
    )
    order = models.OneToOneField(
        'orders.Orders',
        verbose_name=_('Order'),
        on_delete=models.CASCADE,
        related_name='queue_entry',
    )
    position = models.PositiveSmallIntegerField(
        verbose_name=_('Position in Queue'),
        help_text=_('Lower number means earlier in queue'),
    )
    expected_start_time = models.DateTimeField(
        verbose_name=_('Expected Start Time'),
        null=False,
        blank=False,
    )
    expected_duration = models.DurationField(
        verbose_name=_('Expected Duration'),
        null=True,
        blank=True,
    )
    created_at = models.DateTimeField(verbose_name=_('Created at'), auto_now_add=True)
    updated_at = models.DateTimeField(verbose_name=_('Updated at'), auto_now=True)
    
    class Meta:
        verbose_name = _('Queue Entry')
        verbose_name_plural = _('Queue Entries')
        ordering = ['position']
        indexes = [
            models.Index(fields=['car_wash', 'position']),
            models.Index(fields=['order']),
        ]
        unique_together = [['car_wash', 'position']]
    
    def __str__(self):
        return f'<QueueEntry (CarWash: {self.car_wash_id}, Order: {self.order_id}, Position: {self.position})>'
    
    def get_approximate_wait_time(self):
        """Calculate approximate wait time for this order based on queue position.
        
        Returns:
            timedelta: Approximate wait time
        """
        return max(self.expected_start_time - now(), timedelta(seconds=0))
    
    def is_delayed(self):
        """Check if the order is delayed.
        
        An order is considered delayed if:
        - It has an expected_start_time in the past
        - There are no active orders (in progress) taking up all boxes
        
        Returns:
            bool: True if delayed, False otherwise
        """

        return self.expected_start_time < now()
        if self.expected_start_time >= now():
            return False

        return True
        # Check if there are available boxes (not all occupied by IN_PROGRESS orders)
        from orders.utils.enums import OrderStatus
        boxes_count = self.car_wash.boxes.count()
        active_orders_count = self.car_wash.orders.filter(status=OrderStatus.IN_PROGRESS).count()
        
        # Delayed if expected time passed and there are available boxes
        return active_orders_count < boxes_count
    
    def get_delay_duration(self):
        """Get how long the order has been delayed.
        
        Returns:
            timedelta: Duration of delay, or None if not delayed
        """
        if not self.is_delayed():
            return None
        
        return now() - self.expected_start_time
