import logging

from django.apps import AppConfig
from django.db import DatabaseError
from django.utils.translation import gettext_lazy

logger = logging.getLogger('judge.apps')


class JudgeAppConfig(AppConfig):
    name = 'judge'
    verbose_name = gettext_lazy('Online Judge')

    def ready(self):
        # WARNING: AS THIS IS NOT A FUNCTIONAL PROGRAMMING LANGUAGE,
        #          OPERATIONS MAY HAVE SIDE EFFECTS.
        #          DO NOT REMOVE THINKING THE IMPORT IS UNUSED.
        # noinspection PyUnresolvedReferences
        from . import signals, jinja2  # noqa: F401, imported for side effects

        from judge.models import Language, Profile
        from django.contrib.auth.models import User

        try:
            lang = Language.get_default_language()
            for user in User.objects.filter(profile=None):
                # These poor profileless users
                profile = Profile(user=user, language=lang)
                profile.save()
                logger.info('Created profile for user %s', user)
        except DatabaseError as e:
            logger.error('Failed to create profiles for users: %s', e.__traceback__)
