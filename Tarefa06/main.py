import random
import time

q = []


class SerVivo:
    def __init__(self, id, name=None, idade=None, energia=None):  # Constructor of the class
        self.id = id
        self.name = name
        self.idade = idade
        self.energia = energia

    def tipo(self):  # Abstract method, defined by convention only
        raise NotImplementedError("Subclass must implement abstract method")


class Animal(SerVivo):
    def tipo(self):
        return 'Animal!'


class Carnivoro(Animal):
    def classificacao(self):
        return 'Carnivoro'

    def acao(self, acompanhar, estado):
        if not "morreu" in estado:
            if (int(self.energia) + 30) <= 100:
                alimentou = False
                for ser_vivo in list(q):
                    if is_herbivoro(ser_vivo):
                        herbivoro = ser_vivo
                        q.remove(ser_vivo)
                        self.energia = int(self.energia) + 30
                        alimentou = True
                        if acompanhar:
                            print(estado, "\tacao:", "alimenta-se de", herbivoro.name)
                        break
                if not alimentou:
                    if acompanhar:
                        print(estado, "\tacao:", "sofrendo com falta de alimento")
            else:
                if acompanhar:
                    print(estado, "\tacao:", "descansando")

        else:
            print(estado)


class Herbivoro(Animal):
    def classificacao(self):
        return 'Herbivoro'

    def acao(self, acompanhar, estado):
        if not "morreu" in estado:
            if (int(self.energia) + 30) <= 100:
                alimentou = False
                for ser_vivo in list(q):
                    if is_vegetal(ser_vivo):
                        vegetal = ser_vivo
                        q.remove(ser_vivo)
                        self.energia = int(self.energia) + 30
                        alimentou = True
                        if acompanhar:
                            print(estado, "\tacao:", "alimenta-se de", vegetal.name)
                        break
                if not alimentou:
                    if acompanhar:
                        print(estado, "\tacao:", "\tsofrendo com falta de alimento")
            else:
                if acompanhar:
                    print(estado, "\tacao:", "descansando")
        else:
            print(estado)


class Vegetal(SerVivo):
    def classificacao(self):
        return 'Vegetal'

    def acao(self, acompanhar, estado):
        if not "morreu" in estado:
            if (int(self.energia) + 30) <= 100:
                self.energia = int(self.energia) + 5
                if acompanhar:
                    print(estado, "\tacao:", "faz fotossintese")
            else:
                if acompanhar:
                    print(estado, "\tacao:", "descansando")
        else:
            print(estado)


def is_vegetal(obj):
    if isinstance(obj, Vegetal):
        return True
    else:
        return False


def is_herbivoro(obj):
    if isinstance(obj, Herbivoro):
        return True
    else:
        return False


def eco_sistema():
    turno_tick = 4
    dia = 0

    print("\n--------------------------------------------\nDIA", dia)
    while len(q) >= 10:
        # Exibe Dias/Turnos
        if turno_tick == 0:
            dia += 1
            print("\n--------------------------------------------\nDIA:", dia)
            turno_tick = detalhes_turno(turno_tick)
            atualiza_energia_idade_seres_vivos()
        else:
            turno_tick = detalhes_turno(turno_tick)

        if turno_tick > 24:
            turno_tick = 0

        print("Quantidade total de seres vivos:", len(q))
        print("Sorteados 10 seres vivos para acompanhar:\n")

        if dia == 1:
            print()

        list_seres_vivos_random = list(q)
        random.shuffle(list_seres_vivos_random)
        seres_vivos_acompanhar = []
        for ser_vivo_random in list_seres_vivos_random:
            if len(seres_vivos_acompanhar) < 10:
                seres_vivos_acompanhar.append(ser_vivo_random.id)

        acao_eco_sistema(seres_vivos_acompanhar)

        time.sleep(1)

    print("\nSistema Finalizado\n")


def acao_eco_sistema(seres_vivos_acompanhar):
    for ser_vivo in list(q):
        estado = estado_ser_vivo(ser_vivo)
        if ser_vivo.id in seres_vivos_acompanhar:
            ser_vivo.acao(True, estado)
        else:
            ser_vivo.acao(False, estado)


def atualiza_energia_idade_seres_vivos():
    for i in list(q):
        i.energia = str(int(i.energia) - 30)
        i.idade = str(int(i.idade) + 10)


def detalhes_turno(turno_tick):
    turno_estado = ''
    if turno_tick >= 4 and turno_tick < 12:
        turno_estado = "manhã"
    elif turno_tick >= 12 and turno_tick < 20:
        turno_estado = "tarde"
    elif turno_tick >= 20 or turno_tick < 4:
        turno_estado = "noite"
    # exibe detalhes do turno
    print("\nTurno", turno_estado, "horas:", turno_tick)

    # atualiza o tick
    turno_tick += 4

    return turno_tick


def estado_ser_vivo(ser_vivo):
    # verifica a energia e idade de cada um, para remover da fila

    if int(ser_vivo.energia) <= 0:
        q.remove(ser_vivo)
        return (ser_vivo.name + ' morreu por falta de energia')

    if int(ser_vivo.idade) >= 100:
        q.remove(ser_vivo)
        return ser_vivo.name + ' morreu por velhice'

    return ser_vivo.name + ' idade:' + str(ser_vivo.idade) + ' energia:' + str(ser_vivo.energia)


def criar_eco_sistema():
    # idade max = 100
    # energia min = 0
    print(
        "\n********************************************\nECO-sistema criado\nTodos Seres Vivos com Energia Maxima 100 E Idade Minima 0")
    id = 0
    # vegetais
    qtd_vege = 40
    for j in range(qtd_vege):
        id += 1
        idade = 0
        energia = 100
        vegetal = Vegetal(id, None, str(idade), str(energia))
        vegetal.name = vegetal.classificacao() + str(j)
        q.append(vegetal)

    # carnivoros
    qtd_car = 20
    for j in range(qtd_car):
        id += 1
        idade = 0
        energia = 100
        carnivoro = Carnivoro(id, None, str(idade), str(energia))
        carnivoro.name = carnivoro.classificacao() + str(j)
        q.append(carnivoro)

    # herbivoros
    qtd_her = 40
    for j in range(qtd_her):
        id += 1
        idade = 0
        energia = 100
        herbivoro = Herbivoro(id, None, str(idade), str(energia))
        herbivoro.name = herbivoro.classificacao() + str(j)
        q.append(herbivoro)

    print(str(qtd_vege), "Vegetais \t", str(qtd_car), "Carnivoros \t", str(qtd_car), "Herbivoros")


if __name__ == '__main__':
    criar_eco_sistema()

    eco_sistema()
