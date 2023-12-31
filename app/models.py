# Register your models here.
from django.db import models

class SampleMaster(models.Model):
    sample_no = models.AutoField(primary_key=True)
    assessor_name = models.CharField(max_length=50)
    date_collected = models.DateField()
    date_measured = models.DateField()
    location_code = models.CharField(max_length=10)
    plankton_net_type = models.CharField(max_length=20, blank=True, null=True)
    bl = models.DecimalField(max_digits=10, decimal_places=2, blank=True, null=True)
    pdl = models.DecimalField(max_digits=10, decimal_places=2, blank=True, null=True)
    hl = models.DecimalField(max_digits=10, decimal_places=2, blank=True, null=True)
    snl = models.DecimalField(max_digits=10, decimal_places=2, blank=True, null=True)
    ed = models.DecimalField(max_digits=10, decimal_places=2, blank=True, null=True)
    bd = models.DecimalField(max_digits=10, decimal_places=2, blank=True, null=True)
    pal = models.DecimalField(max_digits=10, decimal_places=2, blank=True, null=True)
    vafl = models.DecimalField(max_digits=10, decimal_places=2, blank=True, null=True)
    dorsal_count = models.IntegerField(blank=True, null=True)
    anal_count = models.IntegerField(blank=True, null=True)
    pectoral_count = models.IntegerField(blank=True, null=True)
    pelvic_count = models.IntegerField(blank=True, null=True)
    caudal_count = models.IntegerField(blank=True, null=True)
    vertebrae_count = models.IntegerField(blank=True, null=True)
    stage_name = models.CharField(max_length=50, blank=True, null=True)
    margin_no = models.DecimalField(max_digits=10, decimal_places=2, blank=True, null=True)
    description = models.CharField(max_length=100, blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'sample_master'