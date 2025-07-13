import copy

def merge_dictionaries(diction1, diction2):
    """
    This function works RECURSIVELY.
    Therefore, it can handle more depth than flatten_list can.
    """
    for key, value in diction2.items():
        if key in diction1 and isinstance(diction1[key], dict) and isinstance(value, dict):
            merge_dictionaries(diction1[key], value)
        else:
            diction1[key] = value
    return diction1


def merge_dictionaries_no_mutation(diction1, diction2):
    diction1_copy = copy.deepcopy(diction1)
    return merge_dictionaries(diction1_copy, diction2)

