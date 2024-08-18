import logging

from django.contrib.auth.decorators import login_required
from django.http import HttpResponse
from django.utils.decorators import method_decorator
from revproxy.views import ProxyView

from proxy.process import FavaProcess

# too noisy...
logging.getLogger('revproxy.view').setLevel(logging.ERROR)
logging.getLogger('revproxy.response').setLevel(logging.ERROR)

@method_decorator(login_required(login_url = '/'), 'dispatch')
class ReverseFava(ProxyView):
    def __init__(self):
        super().__init__()
        self.process = FavaProcess.instance()
        self.upstream = 'http://127.0.0.1:' + str(self.process.port) + '/fava/'
        logging.debug(f"Proxying requests to: {self.upstream}")

    def get_request_headers(self):
        headers = super(ReverseFava, self).get_request_headers()
        headers['Key'] = self.process.key
        return headers

@login_required(login_url = '/')
def restart(request):
    process = FavaProcess.instance()
    process.restart()
    return HttpResponse("done")
