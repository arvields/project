# forms.py
from django import forms
from .models import SampleMaster

class SubmitForm(forms.ModelForm):
    class Meta:
        model = SampleMaster
        fields = '__all__'
        exclude = ['sample_no']
