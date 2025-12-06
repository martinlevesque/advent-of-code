struct Resolver:
    var current: Int

    fn __init__(out self, initial: Int):
        self.current = initial

    fn next(mut self, line: StringSlice) raises -> Int:
        side = line[0]
        rotation_count_s = line[1:]
        var rotation_count = atol(rotation_count_s)
        var rotation_remaining = rotation_count
        var nb_zeros = 0

        if side == "L":
            while rotation_remaining > 0:
                if self.current - rotation_remaining < 0:
                    rotation_remaining -= self.current + 1

                    if self.current != 0:
                        nb_zeros += 1

                    self.current = 99
                else:
                    self.current -= rotation_remaining
                    rotation_remaining = 0

                    if self.current == 0:
                        nb_zeros += 1

        elif side == "R":
            while rotation_remaining > 0:

                if self.current + rotation_remaining > 99:
                    var moving_right_up_to_limit = 99 - self.current

                    self.current = 0
                    rotation_remaining -= moving_right_up_to_limit + 1

                    nb_zeros += 1
                else:
                    self.current += rotation_remaining
                    rotation_remaining = 0

                    if self.current == 0:
                        nb_zeros += 1

        return nb_zeros

def main():
    try:
        var resolver = Resolver(50)
        var result = 0

        with open("1.txt", "r") as f:
            var file_content = f.read()

            for line in file_content.splitlines():
                var nb_zeros = resolver.next(line)

                result += nb_zeros

        print("result =", result)

    except e:
        print("failed!", e)


