from datetime import datetime

from pythonjsonlogger import jsonlogger


class CustomJsonFormatter(jsonlogger.JsonFormatter):
    def add_fields(self, log_record, record, message_dict):
        super(CustomJsonFormatter, self).add_fields(log_record, record, message_dict)
        if not log_record.get('timestamp'):
            log_record['timestamp'] = datetime.utcnow().strftime('%Y-%m-%dT%H:%M:%S.%fZ')
        if log_record.get('level'):
            log_record['level'] = log_record['level'].upper()
        else:
            log_record['level'] = record.levelname

        log_record['filename'] = record.filename
        log_record['module'] = record.module
        log_record['func'] = record.funcName
        log_record['args'] = record.args
        log_record['message'] = record.message
        log_record['exc_info'] = record.exc_info
        if record.exc_info:
            log_record['traceback'] = self.formatException(record.exc_info)

        log_record['stack_info'] = record.stack_info
        if record.exc_info:
            log_record['stack_info'] = self.formatException(record.exc_info)
