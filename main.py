import re
from functools import cmp_to_key


# Функция, выполняющая первое задание:
def get_good_nums(str):
    best_nums = []
    special_num_matches = re.findall(r'\b[0-9]{2,4}\\[0-9]{2,5}\b', str)
    for match in special_num_matches:
        bests_num_match = re.findall(r'\b[0-9]{4}\\[0-9]{5}\b', match)
        if len(bests_num_match) != 0:
            best_nums = best_nums + bests_num_match
        else:
            half_A, half_B = match.split('\\')
            half_A = '0' * (4 - len(half_A)) + half_A
            half_B = '0' * (5 - len(half_B)) + half_B
            new_best_num = half_A + '\\' + half_B
            best_nums = best_nums + [new_best_num]
    for num in best_nums:
        print(num)
    return best_nums


# Функция, выполняющая второе задание:
def distribute_ATMs(n, k, L_array):
    if len(L_array) > 0:
        for i in range(k):
            max_L = max(L_array)
            index_max_L = L_array.index(max_L)
            half_dist = max_L/2
            L_array = L_array[:index_max_L] + [half_dist, half_dist] + L_array[index_max_L + 1:]
        return L_array
    else:
        return "The distance matrix must be non-empty!"


# Переопределённая функция сравнения для сортировки строк цифр:
def custom_compare(a, b):
    ab = a + b
    ba = b + a
    if int(ab) > int(ba):
        return 1
    elif int(ab) < int(ba):
        return -1
    else:
        return 0


# Функция, выполняющая третье задание:
def get_max_num(strings_arr):
    sorted_str_arr = sorted(strings_arr, key=cmp_to_key(custom_compare), reverse = True)
    res_str = ''
    for r in sorted_str_arr:
        res_str = res_str + r
    return int(res_str)


def main():
    # Тестовые данные для первого задания:
    test_s1 = r'Адрес 5467\456. Номер 405\549'
    test_s2 = r'Адрес 5467\45611. Номер 405\549'
    test_s3 = r'! 54\56 .12/123 gdsfgsdtyty sdg stfys 4051\53249'
    res_best_nums = get_good_nums(test_s1)

    # Тестовые данные для второго задания:
    test_L_arr1 = [100, 180, 50, 60, 150]
    test_L_arr2 = [10, 20, 70, 30]
    test_L_arr3 = [100]
    test_L_arr4 = [40, 200]
    test_L_arr5 = [400, 80, 900, 100, 200, 350, 500]
    test_L_arr6 = []
    res_L_arr = distribute_ATMs(5, 3, test_L_arr1)

    # Тестовые данные для третьего задания:
    test_arr_nums1 = ['11', '234', '005', '89']
    test_arr_nums2 = ['113', '005', '9', '8', '22', '989', '77']
    test_arr_nums3 = ['11', '2', '11', '11']
    res_max_num = get_max_num(test_arr_nums1)


if __name__ == '__main__':
    main()