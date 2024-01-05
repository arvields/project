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

class ClassificationResult(models.Model):
    classification_result_id = models.AutoField(primary_key=True)
    sample_no = models.ForeignKey('SampleMaster', models.CASCADE, db_column='sample_no', blank=True, null=True)
    fgroup_no = models.IntegerField(blank=True, null=True)
    ffamily_name = models.CharField(max_length=45, blank=True, null=True)
    fgenus_name = models.CharField(max_length=45, blank=True, null=True)
    rank = models.IntegerField(blank=True, null=True)
    sample_timestamp = models.DateTimeField(blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'classification_result'

class FishRatio(models.Model):
    sample_no = models.OneToOneField('SampleMaster', models.DO_NOTHING, db_column='sample_no', primary_key=True)
    bd_bl_ratio = models.DecimalField(db_column='BD/BL_ratio', max_digits=10, decimal_places=2, blank=True, null=True)  # Field name made lowercase. Field renamed to remove unsuitable characters.
    pdl_bl_ratio = models.DecimalField(db_column='PDL/BL_ratio', max_digits=10, decimal_places=2, blank=True, null=True)  # Field name made lowercase. Field renamed to remove unsuitable characters.
    hl_bl_ratio = models.DecimalField(db_column='HL/BL_ratio', max_digits=10, decimal_places=2, blank=True, null=True)  # Field name made lowercase. Field renamed to remove unsuitable characters.
    snl_bl_ratio = models.DecimalField(db_column='SnL/BL_ratio', max_digits=10, decimal_places=2, blank=True, null=True)  # Field name made lowercase. Field renamed to remove unsuitable characters.
    ed_bl_ratio = models.DecimalField(db_column='ED/BL_ratio', max_digits=10, decimal_places=2, blank=True, null=True)  # Field name made lowercase. Field renamed to remove unsuitable characters.
    pal_bl_ratio = models.DecimalField(db_column='PAL/BL_ratio', max_digits=10, decimal_places=2, blank=True, null=True)  # Field name made lowercase. Field renamed to remove unsuitable characters.
    vafl_bl_ratio = models.DecimalField(db_column='VAFL/BL_ratio', max_digits=10, decimal_places=2, blank=True, null=True)  # Field name made lowercase. Field renamed to remove unsuitable characters.

    class Meta:
        managed = False
        db_table = 'fish_ratio'

class FamilyScorecard(models.Model):
    fscorecard_no = models.AutoField(primary_key=True)
    sample_no = models.ForeignKey('SampleMaster', models.CASCADE, db_column='sample_no', blank=True, null=True)
    ffamily_name = models.CharField(max_length=45, blank=True, null=True)
    bd_score = models.SmallIntegerField(blank=True, null=True)
    ed_score = models.SmallIntegerField(blank=True, null=True)
    hl_score = models.SmallIntegerField(blank=True, null=True)
    pdl_score = models.SmallIntegerField(blank=True, null=True)
    snl_score = models.SmallIntegerField(blank=True, null=True)
    pal_score = models.SmallIntegerField(blank=True, null=True)
    vafl_score = models.SmallIntegerField(blank=True, null=True)
    sample_remarks = models.CharField(max_length=150, blank=True, null=True)
    kbs_remarks = models.CharField(max_length=150, blank=True, null=True)
    morphometric_sum = models.CharField(max_length=10, blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'family_scorecard'

class GenusScorecard(models.Model):
    genus_scorecard_no = models.AutoField(primary_key=True)
    sample_no = models.ForeignKey('SampleMaster', models.DO_NOTHING, db_column='sample_no')
    ffamily_name = models.CharField(max_length=45, blank=True, null=True)
    fgenus_name = models.CharField(max_length=45, blank=True, null=True)
    dorsal_count_score = models.SmallIntegerField(blank=True, null=True)
    anal_count_score = models.SmallIntegerField(blank=True, null=True)
    pectoral_count_score = models.SmallIntegerField(blank=True, null=True)
    caudal_count_score = models.SmallIntegerField(blank=True, null=True)
    vertebrae_count_score = models.SmallIntegerField(blank=True, null=True)
    pelvic_count_score = models.SmallIntegerField(blank=True, null=True)
    sample_remarks = models.CharField(max_length=150, blank=True, null=True)
    kbs_remarks = models.CharField(max_length=150, blank=True, null=True)
    meristic_sum = models.CharField(max_length=10, blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'genus_scorecard'

class SummaryRanking(models.Model):
    summary_ranking_no = models.AutoField(primary_key=True)
    sample_no = models.ForeignKey(SampleMaster, models.CASCADE, db_column='sample_no')
    ffamily_name = models.CharField(max_length=45, blank=True, null=True)
    fgenus_name = models.CharField(max_length=45, blank=True, null=True)
    meristic_sum = models.CharField(max_length=10, blank=True, null=True)
    morphometric_sum = models.CharField(max_length=10, blank=True, null=True)
    combined_scores = models.DecimalField(max_digits=10, decimal_places=5, blank=True, null=True)
    meristic_sample_remarks = models.CharField(max_length=150, blank=True, null=True)
    meristic_kbs_remarks = models.CharField(max_length=150, blank=True, null=True)
    morphometric_sample_remarks = models.CharField(max_length=150, blank=True, null=True)
    morphometric_kbs_remarks = models.CharField(max_length=150, blank=True, null=True)
    rank = models.IntegerField(blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'summary_ranking'

class ShapeCharacteristicResult(models.Model):
    result_id = models.AutoField(primary_key=True)
    sample_no = models.ForeignKey(SampleMaster, models.CASCADE, db_column='sample_no')
    fgroup_no = models.IntegerField(blank=True, null=True)
    bd_characteristic = models.CharField(max_length=20, blank=True, null=True)
    hl_characteristic = models.CharField(max_length=20, blank=True, null=True)
    ed_characteristic = models.CharField(max_length=20, blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'shape_characteristic_result'