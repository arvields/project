# app/views.py
from django.shortcuts import render, redirect
from .forms import SubmitForm
from .models import SampleMaster, ClassificationResult, FishRatio, FamilyScorecard, GenusScorecard, SummaryRanking

def index(request):
    return render(request, "index.html")

def questionnaire(request):
    if request.method == 'POST':
        form = SubmitForm(request.POST)
        if form.is_valid():
            # If the description field is not present in the form, set it to None
            form.cleaned_data['description'] = form.cleaned_data.get('description', None)
            form.save()
            return redirect('questionnaire')
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

def full_results(request):
    # Assuming you want to retrieve relevant data from each model
    samples = SampleMaster.objects.all()
    classification_results = ClassificationResult.objects.all()
    fish_ratios = FishRatio.objects.all()
    family_scorecards = FamilyScorecard.objects.all()
    genus_scorecards = GenusScorecard.objects.all()
    summary_rankings = SummaryRanking.objects.all()

    # Pass the data to the template
    return render(
        request,
        'full_results.html',
        {
            'samples': samples,
            'classification_results': classification_results,
            'fish_ratios': fish_ratios,
            'family_scorecards': family_scorecards,
            'genus_scorecards': genus_scorecards,
            'summary_rankings': summary_rankings,
        }
    )