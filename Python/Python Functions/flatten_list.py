def flatten(nestedlist):
    """flatten a nested list. returns one full list"""
    return [item for sublist in nestedlist for item in sublist]