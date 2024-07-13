import traceback
try:
    print('---------------------')
    print(10 / 0)
except:
    traceback.print_exc()