# Register your models here.
from django.db import models

class SampleMaster(models.Model):
    sample_no = models.BigAutoField(primary_key=True)
    assessor_name = models.CharField(max_length=50)
    date_collected = models.DateField(null=True)
    date_measured = models.DateField(null=True)
    location_code = models.CharField(max_length=10, null=True)
    plankton_net_type = models.CharField(max_length=20, null=True)
    bl = models.DecimalField(max_digits=10, decimal_places=2, null=True)
    pdl = models.DecimalField(max_digits=10, decimal_places=2, null=True)
    hl = models.DecimalField(max_digits=10, decimal_places=2, null=True)
    snl = models.DecimalField(max_digits=10, decimal_places=2, null=True)
    ed = models.DecimalField(max_digits=10, decimal_places=2, null=True)
    bd = models.DecimalField(max_digits=10, decimal_places=2, null=True)
    pal = models.DecimalField(max_digits=10, decimal_places=2, null=True)
    vafl = models.DecimalField(max_digits=10, decimal_places=2, null=True)
    dorsal_count = models.IntegerField(null=True)
    anal_count = models.IntegerField(null=True)
    pectoral_count = models.IntegerField(null=True)
    pelvic_count = models.IntegerField(null=True)
    caudal_count = models.IntegerField(null=True)
    vertebrae_count = models.IntegerField(null=True)
    stage_name = models.CharField(max_length=50, null=True)
    margin_no = models.DecimalField(max_digits=10, decimal_places=2, null=True)
    description = models.CharField(max_length=100, null=True)

    class Meta:
        db_table = 'sample_master'