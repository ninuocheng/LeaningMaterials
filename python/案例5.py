import random
num = random.randint(1,100)
for i in range(1,11):
    guess = int(input('请输入'))
    if guess > num:
        print('大了')
    elif guess < num:
        print('小了')
    else:
        print('猜对了')
        break
print(f'猜了{i}次')
if i < 3:
    print('聪明')
elif i <= 7:
    print('才可以')
else:
    print('笨')