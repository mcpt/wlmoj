# -*- coding: utf-8 -*-
# Generated by Django 1.11.20 on 2019-09-02 15:58
from __future__ import unicode_literals

import django.core.validators
from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('judge', '0087_problem_resource_limits'),
    ]

    operations = [
        migrations.AlterModelOptions(
            name='contest',
            options={'permissions': (('see_private_contest', 'See private contests'), ('edit_own_contest', 'Edit own contests'), ('edit_all_contest', 'Edit all contests'), ('contest_rating', 'Rate contests'), ('contest_access_code', 'Contest access codes'), ('create_private_contest', 'Create private contests')), 'verbose_name': 'contest', 'verbose_name_plural': 'contests'},
        ),
        migrations.RenameField(
            model_name='contest',
            old_name='is_public',
            new_name='is_visible',
        ),
        migrations.RenameField(
            model_name='contest',
            old_name='is_private',
            new_name='is_organization_private',
        ),
        migrations.AddField(
            model_name='contest',
            name='is_private',
            field=models.BooleanField(default=False, verbose_name='private to specific users'),
        ),
        migrations.AddField(
            model_name='contest',
            name='private_contestants',
            field=models.ManyToManyField(blank=True, help_text='If private, only these users may see the contest', related_name='_contest_private_contestants_+', to='judge.Profile', verbose_name='private contestants'),
        ),
    ]
