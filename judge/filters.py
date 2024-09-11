import logging


class SilenceInvalidHttpHostHeader(logging.Filter):
    def filter(self, record):
        return 'Invalid HTTP_HOST' not in record.msg
