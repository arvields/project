# Generated by Django 5.0 on 2024-01-01 18:20

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('app', '0004_alter_samplemaster_options'),
    ]

    operations = [
        migrations.CreateModel(
            name='ClassificationResult',
            fields=[
                ('classification_result_id', models.AutoField(primary_key=True, serialize=False)),
                ('fgroup_no', models.IntegerField(blank=True, null=True)),
                ('ffamily_name', models.CharField(blank=True, max_length=45, null=True)),
                ('fgenus_name', models.CharField(blank=True, max_length=45, null=True)),
                ('rank', models.IntegerField(blank=True, null=True)),
                ('sample_timestamp', models.DateTimeField(blank=True, null=True)),
            ],
            options={
                'db_table': 'classification_result',
                'managed': False,
            },
        ),
    ]