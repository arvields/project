# app/views.py
from django.shortcuts import render, redirect
from .forms import SubmitForm

def index(request):
    return render(request, "index.html")

def questionnaire(request):
    if request.method == 'POST':
        form = SubmitForm(request.POST)
        if form.is_valid():
            form.save()
        return redirect('questionnaire')
    else:
        form = SubmitForm()

    return render(request, 'questionnaire.html', {'form': SubmitForm})

def about(request):
    return render(request, "about.html")