# app/views.py
from django.shortcuts import render, redirect, get_object_or_404
from .forms import SubmitForm
from .models import SampleMaster, ClassificationResult, FishRatio, FamilyScorecard, GenusScorecard, SummaryRanking, ShapeCharacteristicResult

def index(request):
    return render(request, "index.html")

def questionnaire(request):
    if request.method == 'POST':
        form = SubmitForm(request.POST)
        if form.is_valid():
            # If the description field is not present in the form, set it to None
            form.cleaned_data['description'] = form.cleaned_data.get('description', None)
            # Save the form and get the generated or existing sample_no
            sample = form.save()
            sample_no = sample.sample_no  # Assuming sample_no is the field name
            return redirect('full_results', sample_no=sample_no)
    else:
        form = SubmitForm()

    return render(request, 'questionnaire.html', {'form': form})


def about(request):
    return render(request, "about.html")

def description(request):
    if request.method == 'POST':
        form = SubmitForm(request.POST)
        if form.is_valid():
            # If the description field is not present in the form, set it to None
            form.cleaned_data['description'] = form.cleaned_data.get('description', None)
            form.save()
            return redirect('description')
    else:
        form = SubmitForm()

    return render(request, 'description.html', {'form': form})

def results(request):
    classification_results = ClassificationResult.objects.filter(rank__isnull=False).values(
        'sample_no',
        'fgroup_no',
        'ffamily_name',
        'fgenus_name',
        'rank',
        'sample_timestamp'
    ).order_by('sample_no', 'rank')
    return render(request, 'results.html', {'classification_results': classification_results})

def full_results(request, sample_no):
    sample = get_object_or_404(SampleMaster, sample_no=sample_no)
    
    classification_results = ClassificationResult.objects.filter(sample_no=sample).first()

    fish_ratios = get_object_or_404(FishRatio, sample_no=sample_no)

    shape_characteristic_result = get_object_or_404(ShapeCharacteristicResult, sample_no=sample_no)

    genus_scorecards = GenusScorecard.objects.filter(sample_no=sample_no).order_by('ffamily_name','fgenus_name')

    family_scorecards = FamilyScorecard.objects.filter(sample_no=sample_no).order_by('ffamily_name')

    summary_rankings = SummaryRanking.objects.filter(sample_no=sample_no, rank__isnull=False).order_by('rank')

    return render(
        request,
        'full_results.html',
        {
            'sample': sample,
            'classification_results': classification_results,
            'fish_ratios': fish_ratios,
            'family_scorecards': family_scorecards,
            'genus_scorecards': genus_scorecards,
            'summary_rankings': summary_rankings,
            'shape_characteristic_result': shape_characteristic_result,
        }
    )
