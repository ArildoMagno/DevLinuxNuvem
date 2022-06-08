import random
import threading
import time
import queue



class Estoque():
    capacidade = 10
    fila = queue.Queue(capacidade)
    cont_produto = 0

    def inserir(self, item):
        self.fila.put(item)
        print("\nProdutor:", item[0], "adicionou produto:", item[1])

    def consumir(self):
        item = estoque.fila.get()
        print("\nConsumidor:", item[0], "consumiu produto:", item[1])


class Produtor(threading.Thread):
    def __init__(self, group=None, target=None, id=None, estoque=None,
                 args=(), kwargs=None, verbose=None):
        super(Produtor, self).__init__()
        self.target = target
        self.id = id
        self.estoque = estoque

    def run(self):
        while True:
            time.sleep(random.randint(1, 3))
            if not estoque.fila.full():
                item = (self.id, str(estoque.cont_produto))
                estoque.inserir(item)
                estoque.cont_produto += 1


class Consumidor(threading.Thread):
    def __init__(self, group=None, target=None, id=None, estoque=None,
                 args=(), kwargs=None, verbose=None):
        super(Consumidor, self).__init__()
        self.target = target
        self.id = id
        self.estoque = estoque

    def run(self):
        while True:
            time.sleep(random.randint(1, 3))
            if not estoque.fila.empty():
                estoque.consumir()


if __name__ == '__main__':
    estoque = Estoque()
    producer1 = Produtor(id='1', estoque=estoque)
    consumer1 = Consumidor(id='1', estoque=estoque)
    producer2 = Produtor(id='2', estoque=estoque)
    consumer2 = Consumidor(id='2', estoque=estoque)
    producer3 = Produtor(id='3', estoque=estoque)
    consumer3 = Consumidor(id='3', estoque=estoque)

    producer1.start()
    producer2.start()
    producer3.start()
    time.sleep(2)
    consumer1.start()
    consumer2.start()
    consumer3.start()
    time.sleep(2)

    producer1.join()
    producer2.join()
    producer3.join()
    consumer1.join()
    consumer2.join()
    consumer3.join()
