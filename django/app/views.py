from django.shortcuts import render

# Create your views here.
def index(request):
    return render(request,"index.html")

def questionnaire(request):
    return render(request,"questionnaire.html")

def about(request):
    return render(request,"about.html")