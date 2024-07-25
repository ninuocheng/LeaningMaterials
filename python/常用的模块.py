import sys
import time
import urllib.request
import math
print(time.time())
print(time.localtime(time.time()))
print(urllib.request.urlopen('http://www.baidu.com').read())
print(math.pi)