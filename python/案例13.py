class Instrumnet():
    def make_sound(self):
        pass

class Erhu(Instrumnet):
    def make_sound(self):
        print('二胡在演奏')

class Pinao(Instrumnet):
    def make_sound(self):
        print('钢琴在演奏')

class Violin(Instrumnet):
    def make_sound(self):
        print('小提琴在演奏')
#演奏的函数
def play(instrumnet):
    instrumnet.make_sound()

class Bird():
    def make_sound(self):
        print('小鸟在唱歌')

if __name__ == '__main__':
    play(Erhu())
    play(Pinao())
    play(Violin())
    play(Bird())