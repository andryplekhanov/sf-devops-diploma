from django.utils.translation import gettext_lazy as _
from django.views.generic import TemplateView


class IndexView(TemplateView):
    """ Main page view """
    template_name = 'app_main/home.html'
    extra_context = {'title': _('Main page')}
