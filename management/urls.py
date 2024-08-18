from django.contrib import admin
from django.urls import path, re_path

import proxy.views
urlpatterns = [
    re_path(r'fava/(?P<path>.*)$', proxy.views.ReverseFava.as_view()),
    path('control/restart/', proxy.views.restart),
    path('', admin.site.urls),
]
