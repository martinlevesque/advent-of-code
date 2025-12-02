
struct Resolver:
    var current: Int

    fn __init__(out self, initial: Int):
        self.current = initial

    fn next(mut self, line: StringSlice) raises:
        side = line[0]
        rotation_count_s = line[1:]
        var rotation_count = atol(rotation_count_s)

        if side == "L":
            print(rotation_count)
            print("left")
        elif side == "R":
            print(rotation_count)
            print("right")

def main():
    try:
        var result = Resolver(50)

        with open("1.txt", "r") as f:
            var file_content = f.read()

            for line in file_content.splitlines():
                result.next(line)
    except e:
        print("failed!", e)

