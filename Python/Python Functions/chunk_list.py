def chunk(totallist, size):
    for i in range(0, len(totallist), size):
        yield totallist[i:i + size]