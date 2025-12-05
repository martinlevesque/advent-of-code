struct Resolver:
    var current: Int

    fn __init__(out self, initial: Int):
        self.current = initial
        print("initial =", initial)

    fn next(mut self, line: StringSlice) raises -> Int:
        var side = line[0]
        var rotation_count = atol(line[1:])
        var n = rotation_count % 100   # wrap only needed amount

        if side == "L":
            # rotate left: decreasing
            self.current = (self.current - n) % 100
        elif side == "R":
            # rotate right: increasing
            self.current = (self.current + n) % 100
        else:
            print("Unknown direction:", side)

        print("next - current =", self.current)
        return self.current


def main():
    var resolver = Resolver(50)
    var result = 0

    try:
        with open("1.txt", "r") as f:
            for line in f.read().splitlines():
                var current = resolver.next(line)

                if current == 0:
                    result += 1

        print("result =", result)

    except e:
        print("failed!", e)

